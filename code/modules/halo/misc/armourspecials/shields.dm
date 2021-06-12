
#define SHIELD_MELEE_BYPASS_DAM_MOD 0.5
#define SHIELD_IDLE 0
#define SHIELD_PROCESS 1
#define SHIELD_RECHARGE 2
#define SHIELD_DAMAGE 3
#define SHIELD_RECHARGE_DELAY_EMP_MULT 1.5

/obj/screen/shieldbar
	icon = 'code/modules/halo/icons/hud_display/hud_shieldbar.dmi'
	icon_state = "bar_outer"
	screen_loc = "NORTH,CENTER-1"
	mouse_opacity = 0
	var/transform_image_x = 1
	var/transform_image_y = 0
	var/matrix/base_transform
	var/image/barimage

/obj/screen/shieldbar/New(var/mob/living/l)
	if(!istype(l) || !l.client)
		return INITIALIZE_HINT_QDEL
	l.client.screen += src
	barimage = image(icon,src,"bar")
	base_transform = new(barimage.transform)
	to_chat(l,barimage)

/obj/screen/shieldbar/proc/update(var/currshield,var/maxshield)
	var/new_pct = min(1,max(0,currshield/maxshield))
	var/matrix/m = new(base_transform)
	m.Scale(transform_image_x ? new_pct : 1,transform_image_y ? new_pct : 1)
	barimage.transform = m

/obj/screen/shieldbar/Destroy()
	qdel(barimage)
	. = ..()

/mob/living/carbon/human/Stat()
	. = ..()
	if(client)
		var/obj/screen/shieldbar/bar = locate(/obj/screen/shieldbar) in client.screen
		if(wear_suit && istype(wear_suit,/obj/item/clothing/suit/armor/special))
			var/obj/item/clothing/suit/armor/special/suit = wear_suit
			var/datum/armourspecials/shields/shield_datum = locate(/datum/armourspecials/shields) in suit.specials
			var/datum/armourspecials/shieldmonitor/mon = locate(/datum/armourspecials/shieldmonitor) in suit.specials
			if(shield_datum && mon)
				for(var/helm in mon.valid_helmets)
					if(istype(head,helm)) //No correct helm? No shield indicator.
						if(!bar)
							bar = new mon.bar_type (src)
						bar.update(shield_datum.shieldstrength,shield_datum.totalshields)
					return
		if(bar)
			client.screen -= bar
			qdel(bar)

/datum/armourspecials
	var/mob/living/carbon/human/user

/obj/effect/overlay/shields
	icon = 'code/modules/halo/covenant/species/sangheili/Sangheili_Combat_Harness.dmi'
	icon_state = "shield_overlay"
	plane = ABOVE_HUMAN_PLANE
	layer = ABOVE_HUMAN_LAYER

/obj/effect/overlay/shields/spartan
	icon = 'code/modules/halo/clothing/spartan_armour.dmi'

/obj/effect/overlay/shields/unggoy
	icon = 'code/modules/halo/covenant/species/unggoy/grunt_gear.dmi'

/datum/armourspecials/shields
	var/shieldstrength
	var/totalshields
	var/nextcharge
	var/shield_recharge_delay = 10 SECONDS//The delay for the shields to start recharging from damage (Multiplied by 1.5 if shields downed entirely)
	var/shield_recharge_ticktime = 1 SECOND //The delay between recharge ticks
	var/obj/effect/overlay/shields/shieldoverlay = new /obj/effect/overlay/shields
	var/image/mob_overlay
	var/obj/item/clothing/suit/armor/special/connectedarmour
	var/armour_state = SHIELD_IDLE
	var/tick_recharge = 40
	var/intercept_chance = 100
	var/eva_mode_active = FALSE
	var/shields_recharge_sound = 'code/modules/halo/sounds/shields/SpartanRecharge.ogg'
	var/shields_low_sound = 'code/modules/halo/sounds/shields/SpartanLow.ogg'
	var/shields_down_sound = 'code/modules/halo/sounds/shields/SpartanDown.ogg'

/datum/armourspecials/shields/New(var/obj/item/clothing/suit/armor/special/c) //Needed the type path for typecasting to use the totalshields var.
	. = ..()
	connectedarmour = c
	totalshields = connectedarmour.totalshields
	shieldstrength = totalshields
	add_evamode_verb()

/datum/armourspecials/shields/proc/add_evamode_verb() //Proc-ified to allow subtypes to disable EVA mode.
	connectedarmour.verbs += /obj/item/clothing/suit/armor/special/proc/toggle_eva_mode

/datum/armourspecials/shields/proc/toggle_eva_mode(var/mob/toggler)

	src.eva_mode_active = !src.eva_mode_active
	if(eva_mode_active)
		connectedarmour.visible_message("[toggler] reroutes their shields, prioritising atmospheric and pressure containment.")
		totalshields = connectedarmour.totalshields /4
		take_damage(shieldstrength) //drop our shields to 0
		connectedarmour.item_flags |= STOPPRESSUREDAMAGE
		connectedarmour.item_flags |= AIRTIGHT
		connectedarmour.min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
		connectedarmour.cold_protection = FULL_BODY //There's probably a better way to do this, but I'm not sure of the correct use of the operators.

	else
		connectedarmour.visible_message("[toggler] reroutes their shields, prioritising defense.")
		take_damage(shieldstrength) //drop our shields to 0
		totalshields = connectedarmour.totalshields
		connectedarmour.item_flags = initial(connectedarmour.item_flags)
		connectedarmour.min_cold_protection_temperature = initial(connectedarmour.min_cold_protection_temperature)
		connectedarmour.cold_protection = initial(connectedarmour.cold_protection)

/datum/armourspecials/shields/update_mob_overlay(var/image/generated_overlay)
	mob_overlay = generated_overlay
	if(generated_overlay)
		mob_overlay.overlays += shieldoverlay

/datum/armourspecials/shields/handle_shield(mob/m,damage,atom/damage_source)
	var/mob/living/attacker = damage_source
	if(istype(attacker) && damage < 5 && (attacker.a_intent == "help" || attacker.a_intent == "grab")) //We don't need to block helpful actions. (Or grabs)
		return 0
	var/obj/item/projectile/dam_proj = damage_source
	if(istype(dam_proj))
		if(dam_proj.shield_damage < 0) //Handling for -'ve shield damage numbers
			damage = max(0,damage - dam_proj.shield_damage)
		else if(dam_proj.shield_damage >0 && !take_damage(dam_proj.shield_damage,0))
			return 0
	if(take_damage(damage))
		//Melee damage through shields is reduced
		var/obj/item/dam_source = damage_source
		if(istype(dam_source) &&!istype(dam_proj) && dam_source.loc.Adjacent(connectedarmour.loc))
			var/original_dam = dam_source.force
			dam_source.force *= SHIELD_MELEE_BYPASS_DAM_MOD
			user.visible_message("<span class = 'warning'>[user]'s shields fail to fully absorb the melee attack!</span>")
			spawn(2)
				dam_source.force = original_dam
			return FALSE
		return TRUE
	else
		return FALSE

/datum/armourspecials/shields/handle_shield(var/mob/living/m,damage,atom/damage_source)
	. = ..()
	if(istype(m) && m.client)
		var/obj/screen/shieldbar/bar = locate(/obj/screen/shieldbar) in m.client.screen
		if(bar)
			bar.update(shieldstrength,totalshields,m)

/datum/armourspecials/shields/proc/update_overlay(var/new_icon_state)
	if(mob_overlay)
		mob_overlay.overlays -= shieldoverlay
		shieldoverlay.icon_state = new_icon_state
		mob_overlay.overlays += shieldoverlay

/datum/armourspecials/shields/proc/take_damage(var/damage,var/shield_gate = 1)
	. = 0

	//some shields dont have full coverage
	if(prob(intercept_chance))
		//reset or begin the recharge timer
		reset_recharge()

		if(shieldstrength > 0)

			//tell the damage procs that we blocked the attack
			. = 1

			//shield visual effect
			update_overlay("shield_overlay_damage")
			armour_state = SHIELD_DAMAGE

			var/oldstrength = shieldstrength 

			//apply the damage
			shieldstrength -= damage

			//chat log output
			if(shieldstrength <= 0)
				shieldstrength = 0
				playsound(user, shields_down_sound, 100, 0)
				user.visible_message("<span class ='warning'>[user]'s [connectedarmour] shield collapses!</span>","<span class ='userdanger'>Your [connectedarmour] shields fizzle and spark, losing their protective ability!</span>")
				if(!shield_gate)
					. = 0
				return
			else
				user.visible_message("<span class='warning'>[user]'s [connectedarmour] shields absorbs the force of the impact.</span>","<span class = 'notice'>Your [connectedarmour] shields absorbs the force of the impact.</span>")
			
			//If we jumped from at least 20% shields to below 20% shields and they haven't collapsed yet
			if((oldstrength / totalshields) >= 0.2 && (shieldstrength / totalshields) < 0.2 && shieldstrength > 0)
				playsound(user, shields_low_sound, 100, 0)

/datum/armourspecials/shields/proc/reset_recharge(var/extra_delay = 0)
	//begin counting down the recharge
	if(armour_state == SHIELD_IDLE)
		GLOB.processing_objects |= src

	//update the shield effect overlay
	if(shieldstrength > 0)
		update_overlay("shield_overlay")
	else
		update_overlay("shield_overlay_dead")

	armour_state = SHIELD_PROCESS
	nextcharge = world.time + shield_recharge_delay + extra_delay

/datum/armourspecials/shields/process()

	//reset the shield visual
	if(armour_state == SHIELD_DAMAGE)
		if(shieldstrength > 0)
			update_overlay("shield_overlay")
		else
			update_overlay("shield_overlay_dead")
		armour_state = SHIELD_PROCESS

	//check if its a recharge tick
	if(world.time > nextcharge)
		//recharge
		shieldstrength += tick_recharge
		if(shieldstrength >= totalshields)
			shieldstrength = totalshields

		//tell the user
		to_chat(user, "<span class ='notice'>Your [connectedarmour] shield level: [(shieldstrength/totalshields)*100]%</span>")

		//begin this recharge cycle
		if(armour_state == SHIELD_PROCESS)
			playsound(user, shields_recharge_sound,100,0)
			if(user)
				user.visible_message("<span class = 'notice'>A faint hum emanates from [user]'s [connectedarmour].</span>")
			else
				connectedarmour.visible_message("<span class = 'notice'>A faint hum emanates from [connectedarmour].</span>")
			update_overlay("shield_overlay_recharge")
			armour_state = SHIELD_RECHARGE
		nextcharge = world.time + shield_recharge_ticktime

	//finished recharging
	if(shieldstrength >= totalshields)
		shieldstrength = totalshields
		armour_state = SHIELD_IDLE
		GLOB.processing_objects -= src
		update_overlay("shield_overlay")
		user.update_icons()

/datum/armourspecials/shields/tryemp(severity)
	switch(severity)
		if(1)
			take_damage(totalshields/2)
			user.visible_message("<span class = 'warning'>[user.name]'s shields momentarily fail, the internal capacitors barely recovering.</span>")
		if(2)
			take_damage(totalshields)
			user.visible_message("<span class = 'warning'>[user.name]'s shields violently spark, the internal capacitors shorting out.</span>")
	reset_recharge(shield_recharge_delay * SHIELD_RECHARGE_DELAY_EMP_MULT)

/datum/armourspecials/shields/spartan
	shieldoverlay = new /obj/effect/overlay/shields/spartan
	shield_recharge_delay = 8 SECONDS

/datum/armourspecials/shields/elite
	shields_recharge_sound = 'code/modules/halo/sounds/shields/EliteRecharge.ogg'
	shields_low_sound = 'code/modules/halo/sounds/shields/EliteLow.ogg'
	shields_down_sound = 'code/modules/halo/sounds/shields/EliteDown.ogg'

/datum/armourspecials/shields/unggoy
	shields_recharge_sound = 'code/modules/halo/sounds/shields/EliteRecharge.ogg'
	shields_low_sound = 'code/modules/halo/sounds/shields/EliteLow.ogg'
	shields_down_sound = 'code/modules/halo/sounds/shields/EliteDown.ogg'

	shield_recharge_delay = 7.5 SECONDS //Their shields are usually very low capacity.
	shieldoverlay = new /obj/effect/overlay/shields/unggoy

#undef SHIELD_IDLE
#undef SHIELD_PROCESS
#undef SHIELD_RECHARGE
#undef SHIELD_DAMAGE