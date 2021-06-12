
/obj/payload
	name = "Nuclear Warhead Payload"
	desc = "The word 'UNSC' is scratched out, replaced with a spraypainted image of a skull"
	icon = 'code/modules/halo/misc/payload.dmi'
	icon_state = "MFDD"
	anchored = 0
	density = 1
	var/explodetype = /datum/explosion/nuclearexplosion
	var/exploding
	var/explode_at
	var/seconds_to_explode = 240
	var/arm_time = 3 //Time in seconds to arm the bomb.
	var/seconds_to_disarm = 30
	var/disarming
	var/explodedesc = "A spraypainted image of a skull adorns this slowly ticking bomb."
	var/activeoverlay = "MFDD_active"
	var/strength=1 //The size of the explosion
	var/free_explode = 0
	var/do_arm_disarm_alert = 1
	var/list/blocked_species = list()//COVENANT_SPECIES_AND_MOBS

/obj/payload/attack_hand(var/mob/living/carbon/human/user)
	if(!exploding)
		if(blocked_species.len && user.species in blocked_species)
			to_chat(user,"<span class='warning'>Your species does not know how to use that!</span>")
		if(!checkturf())
			visible_message("<span class='danger'>[src] beeps a warning:'OPTIMAL LOCATION NOT REACHED'</span>")
		else if(istype(get_area(src),/area/space))
			visible_message("<span class='danger'>[src] beeps a warning:'CURRENT LOCATION WOULD CAUSE EFFECT-ELIMINATING DISPERSION OF EXPLOSION ENERGY. ABORTING ARMING. RELOCATE DEVICE.'</span>")
		else if(alert("Once activated, [src] cannot be moved. Are you sure you want to proceed?",\
				"Are you sure you want to proceed?","Continue","Get me out of here!") == "Continue")
			if(do_after(user,arm_time SECONDS,src,1,1,,1))
				visible_message("<span class = 'userdanger'>[user.name] primes the [src] for detonation</span>","<span class ='notice'>You prime the [src] for detonation</span>")
				log_and_message_admins(" primed a nuke/anti-matter charge.",user)
				explode_at = world.time + seconds_to_explode SECONDS
				exploding = 1
				GLOB.processing_objects += src
				message2discord(config.oni_discord, "Alert! Payload device armed by [user.real_name] ([user.ckey]) @ ([loc.x],[loc.y],[loc.z])")
				set_anchor(1)
				checkoverlay(1)
				if(do_arm_disarm_alert)
					var/om_obj = map_sectors["[z]"]
					if(om_obj)
						for(var/m in GLOB.mobs_in_sectors[om_obj])
							to_chat(m,"<span class = 'danger'>HIGH-YIELD EXPLOSIVE ARMING DETECTED AT [loc.loc], ([x],[y])</span>")
	else
		if(!disarming)
			visible_message("<span class = 'danger'>[user.name] starts disarming the [src]</span>","<span class ='notice'>You start disarming the [src]. You estimate it'll take [seconds_to_disarm] seconds</span>")
			disarming = 1
			if(do_after(user,seconds_to_disarm SECONDS,src))
				visible_message("<span class = 'danger'>[user] disarms the [src]</span>","<span class = 'notice'>You disarm the [src]</span>")
				exploding = 0
				set_anchor(0)
				desc = initial(desc)
				checkoverlay(0)
				GLOB.processing_objects -= src
				if(do_arm_disarm_alert)
					var/om_obj = map_sectors["[z]"]
					if(om_obj)
						for(var/m in GLOB.mobs_in_sectors[om_obj])
							to_chat(m,"<span class = 'danger'>HIGH-YIELD EXPLOSIVE DISARM DETECTED AT [loc.loc], ([x],[y])</span>")
			disarming = 0
		else
			to_chat(user,"<span class ='notice'>Someone else is already disarming the [src]</span>")

/obj/payload/proc/checkoverlay(var/on)
	if(!activeoverlay)
		return
	if(on)
		overlays += activeoverlay
	else
		overlays -= activeoverlay

/obj/payload/proc/checkturf()
  if(free_explode)
    return 1
  for(var/obj/effect/bomblocation/b in range(0,src))
    return 1
  return 0

/obj/payload/proc/checkexplode()
	if(exploding)
		desc = explodedesc + " [(explode_at - world.time)/10] seconds remain."
	if(exploding && world.time >= explode_at)
		GLOB.processing_objects -= src
		var/explode_datum = new explodetype(src)
		loc = null
		qdel(explode_datum)
		qdel(src)
		return

/obj/payload/proc/set_anchor(var/onoff)
	anchored = onoff

/obj/payload/process()
	checkexplode()

//SELF DESTRUCT PAYLOAD DOES NOT MOVE//
/obj/payload/self_destruct
	anchored = 1
	free_explode = 1

/obj/payload/self_destruct/set_anchor(var/onoff)
	return

/obj/effect/bomblocation
	name = "Bomb Delivery Point"
	desc = "Marks the location for the delivery of a bomb."
	icon = 'icons/misc/mark.dmi'
	icon_state = "rup"
	anchored = 1
	invisibility = 100 //Don't want this to be seen at all.

/obj/effect/bombpoint_mark
	name = "Structural Weakpoint Marker"
	icon = 'code/modules/halo/misc/payload.dmi'
	icon_state = "floormark"
	desc = "These panels are placed nearby to structural weakpoints to identify them to repair crews and structural refit crews."
	anchored = 1

/obj/effect/bombpoint_mark/Initialize()
	. = ..()
	for(var/turf/simulated/floor/f in range(1,src))
		new /obj/effect/bomblocation (f)
		f.ChangeTurf(/turf/simulated/floor/plating)

/obj/payload/covenant
	name = "Antimatter Bomb"
	desc = "Menacing spikes jut out from this device's frame."
	icon_state ="Antimatter"
	activeoverlay = "am_active"
	explodedesc = "Spikes conceal a countdown timer."
	seconds_to_explode = 300
	strength=1.5
	explodetype = /datum/explosion
	blocked_species = list()

/obj/payload/self_destruct/covenant
	name = "Antimatter Bomb"
	desc = "Menacing spikes jut out from this device's frame."
	icon_state ="Antimatter"
	activeoverlay = "am_active"
	explodedesc = "Spikes conceal a countdown timer."
	seconds_to_explode = 300
	strength=1.5
	explodetype = /datum/explosion
	blocked_species = list()

/obj/item/weapon/pinpointer/advpinpointer/bombplantlocator
	name = "Optimal Ordinance Yield Locator"
	desc = "A locator device that points towards an optimal location that maximises the yield of a bomb."
	mode = 2
	var/list/bomblocations = list()

/obj/item/weapon/pinpointer/advpinpointer/bombplantlocator/New()
	. = ..()
	for(var/obj/effect/bomblocation/b in world)
		bomblocations += b.loc
	if(bomblocations.len == 0)
		return log_admin("ERROR: Bombplantlocator cannot find any bomblocations")
	target = pick(bomblocations)

/obj/item/weapon/pinpointer/advpinpointer/bombplantlocator/toggle_mode()
	visible_message("<span class = 'notice'>The locator announces 'TARGET LOCKED: MODE CHANGE UNAVAILABLE'</span>")
	return

/datum/explosion/New(var/obj/payload/b)
	if(config.oni_discord)
		message2discord(config.oni_discord, "Nuclear detonation detected. [b.name] @ ([b.loc.x],[b.loc.y],[b.loc.z])")
	var/obj/effect/overmap/OM = map_sectors["[b.z]"]
	if(OM)
		OM.nuked_effects(b.loc)
	explosion(get_turf(b),b.strength*20,b.strength*30,b.strength*35,b.strength*40)
	for(var/mob/living/m in range(b.strength*20,b.loc))
		to_chat(m,"<span class = 'userdanger'>A shockwave slams into you! You feel yourself falling apart...</span>")
		m.gib() // Game over.
	if(OM)
		GLOB.processing_objects |= OM //If they're not already processing, they better start now!
		OM.superstructure_process()

/datum/explosion/nuclearexplosion/New(var/obj/payload/b)
	radiation_repository.radiate(b.loc,1000,10000)
	. = ..()