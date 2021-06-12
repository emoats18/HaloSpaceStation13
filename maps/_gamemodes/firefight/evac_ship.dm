
/obj/effect/evac_ship
	name = "Evac Pelican Spawn"
	desc = "You shouldn't see this."
	invisibility = 101
	anchored = 1
	density = 0
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x3"
	var/ship_type = /obj/structure/evac_ship
	var/spawned = 0

/obj/effect/evac_ship/proc/spawn_dropship()
	. = new ship_type(src.loc)
	qdel(src)

/obj/structure/evac_ship
	name = "D77-TC Pelican"
	desc = "A versatile aircraft used by the UNSC for medium-lift operations of personnel, vehicles and equipment. It can also be used as a support gunship."
	anchored = 1
	density = 1
	icon = 'evac_pelican.dmi'
	icon_state = "base"
	bound_width = 96
	bound_height = 192
	var/health = 600
	var/healthmax = 600
	var/is_thrusting = 0
	var/pilot_name = "D77-TC Pelican Pilot"

/obj/structure/evac_ship/proc/arrival_message(var/time_left)
	world_say_pilot_message("Get ready to fall back! I'm out of here in [time_left / 10] seconds.")

/obj/structure/evac_ship/proc/halfway_message(var/time_left)
	world_say_pilot_message("Halfway there, only [time_left / 10] seconds to go.")

/obj/structure/evac_ship/proc/leaving_message(var/time_left)
	world_say_pilot_message("[time_left / 10] seconds! Go go go go go!")

/obj/structure/evac_ship/New()
	..()
	layer = MOB_LAYER + 1
	var/matrix/M = src.transform
	M.Translate(-48,0)
	src.transform = M
	set_thrust(1)
	spawn(50)
		set_thrust(0)

/obj/structure/evac_ship/proc/set_thrust(var/thrusting = 1)
	var/old_thrust = is_thrusting
	is_thrusting = thrusting
	if(old_thrust != is_thrusting)
		if(is_thrusting)
			overlays += "thrust"
		else
			overlays -= "thrust"

/obj/structure/evac_ship/attack_generic(var/atom/movable/attacker, var/amount, var/attacktext)
	//disable destroyable evac ship for now
	/*
	//..()
	var/old_icon_state = icon_state
	var/pilot_message = pick("They're tearing into the armour plating!","Don't let them near me!","They're destroying the engine housing!","I'm taking damage!")
	health -= amount
	if(health < 0)
		//destroy
		explosion(src.loc,20,30,40,50)
		qdel(src)

	else if(health / healthmax < 0.2)
		icon_state = "dam5"
		pilot_message = "Any more hits and we won't be getting out of here!"
	else if(health / healthmax < 0.4)
		icon_state = "dam4"
	else if(health / healthmax < 0.6)
		icon_state = "dam3"
	else if(health / healthmax < 0.8)
		icon_state = "dam2"
	else if(health / healthmax < 1)
		icon_state = "dam1"
		pilot_message = "I'm taking damage, you've got to protect me while we evacuate the survivors!"
	else
		icon_state = "base"

	if((icon_state != old_icon_state))
		world_say_pilot_message(pilot_message)
	/*
	attack_sfx = list(\
		'sound/effects/attackblob.ogg',\
		'sound/effects/blobattack.ogg'\
		)
		*/
		*/

/obj/structure/evac_ship/proc/world_say_pilot_message(var/pilot_message)
	//var/image/I = image(icon = 'pilot_head.dmi', icon_state = "head")
	to_world("\
		<span class='radio'>\
			<span class='name'>[pilot_name]</span> \
			\icon[src] \
			<b>\[Emergency Freq\]</b> \
			<span class='message'>\"[pilot_message]\"</span>\
		</span>")
	//qdel(I)

/obj/structure/evac_ship/attack_hand(var/mob/M)
	attempt_enter(M)

/obj/structure/evac_ship/proc/attempt_enter(var/mob/L)
	if(isliving(usr))
		var/mob/living/M = usr
		if(!M.incapacitated())
			var/success = 0
			for(var/turf/T in range(1,M))
				if(T in src.locs)
					success = 1
					M.loc = src
					to_chat(M, "<span class='info'>You enter [src].</span>")
					break
			if(!success)
				to_chat(M, "<span class='warning'>You are too far to do that.</span>")
		else
			to_chat(M, "<span class='warning'>You are unable to do that.</span>")

/obj/structure/evac_ship/proc/attempt_exit(var/mob/L)
	if(isliving(usr))
		var/mob/living/M = usr
		M.loc = pick(src.locs)
		to_chat(M, "<span class='info'>You exit [src].</span>")

/obj/structure/evac_ship/verb/enter_ship()
	set name = "Enter the evac ship"
	set src in view()
	set category = "IC"

	attempt_enter(usr)

/obj/structure/evac_ship/verb/exit_ship()
	set name = "Exit the evac ship"
	set src = usr.loc
	set category = "IC"

	attempt_exit(usr)
