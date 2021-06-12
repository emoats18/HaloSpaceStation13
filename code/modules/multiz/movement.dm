/mob/verb/up()
	set name = "Move Upwards"
	set category = "IC"

	if(zMove(UP))
		to_chat(src, "<span class='notice'>You move upwards.</span>")

/mob/verb/down()
	set name = "Move Down"
	set category = "IC"

	if(zMove(DOWN))
		to_chat(src, "<span class='notice'>You move down.</span>")

/mob/proc/zMove(direction)
	if(eyeobj)
		return eyeobj.zMove(direction)
	var/turf/start = loc
	var/atom/movable/to_move = src
	if(!istype(loc,/obj/vehicles))
		if(!can_ztravel())
			to_chat(src, "<span class='warning'>You lack means of travel in that direction.</span>")
			return

		if(!istype(start))
			to_chat(src, "<span class='notice'>You are unable to move from here.</span>")
			return 0
	else
		var/obj/vehicles/v = loc
		if(!v.can_traverse_zs)
			to_chat(src,"<span class = 'notice'>Your vehicle can't traverse z-levels</span>")
			return
		if(!v.active)
			to_chat(src,"<span class = 'notice'>Your vehicle needs to be active to move z-levels.</span>")
			return
		if(v.movement_destroyed)
			to_chat(src,"<span class = 'notice'>You need functioning movement to change z-levels.</span>")
			return
		to_move = v
		start = v.loc

	var/turf/destination = (direction == UP) ? GetAbove(to_move) : GetBelow(to_move)
	if(!destination)
		to_chat(src, "<span class='notice'>There is nothing of interest in this direction.</span>")
		return 0

	if(!start.CanZPass(to_move, direction))
		to_chat(src, "<span class='warning'>\The [start] is in the way.</span>")
		return 0
	if(!destination.CanZPass(to_move, direction))
		to_chat(src, "<span class='warning'>You bump against \the [destination].</span>")
		return 0

	if(to_move == src)
		var/area/area = get_area(to_move)
		if(direction == UP && area.has_gravity() && !can_overcome_gravity())
			to_chat(src, "<span class='warning'>Gravity stops you from moving upward.</span>")
			return 0

	for(var/atom/A in destination)
		if(!A.CanPass(to_move, start, 1.5, 0))
			to_chat(src, "<span class='warning'>\The [A] blocks you.</span>")
			return 0
	visible_message("<span class = 'notice'>[src] starts moving [direction == UP ? "upwards" : "downwards"].</span>")
	if(!do_after(src,2.5 SECONDS))
		return
	to_move.Move(destination)
	return 1

/mob/proc/can_overcome_gravity()
	return FALSE

/mob/living/can_overcome_gravity()
	return (flight_ticks_remain != 0)

/mob/living/carbon/human/can_overcome_gravity()
	. = ..()
	if(!.)
		return species && species.can_overcome_gravity(src)

/mob/observer/zMove(direction)
	var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
	if(destination)
		forceMove(destination)
	else
		to_chat(src, "<span class='notice'>There is nothing of interest in this direction.</span>")

/mob/observer/eye/zMove(direction)
	var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
	if(destination)
		setLoc(destination)
	else
		to_chat(src, "<span class='notice'>There is nothing of interest in this direction.</span>")

/mob/proc/can_ztravel()
	return 0

/mob/observer/can_ztravel()
	return 1

/mob/living/carbon/human/can_ztravel()
	if(incapacitated())
		return 0

	if(Allow_Spacemove())
		return 1

	var/obj/effect/antigrav/A = locate() in src.loc
	if(A)
		return 1

	if(Check_Shoegrip())	//scaling hull with magboots
		for(var/turf/simulated/T in trange(1,src))
			if(T.density)
				return 1

/mob/living/silicon/robot/can_ztravel()
	if(incapacitated() || is_dead())
		return 0

	if(Allow_Spacemove()) //Checks for active jetpack
		return 1

	for(var/turf/simulated/T in trange(1,src)) //Robots get "magboots"
		if(T.density)
			return 1

//FALLING STUFF

//Holds fall checks that should not be overriden by children
/atom/movable/proc/fall()
	if(!isturf(loc))
		return

	var/turf/below = GetBelow(src)
	if(!below)
		return

	var/turf/T = loc
	if(!T.CanZPass(src, DOWN) || !below.CanZPass(src, DOWN))
		return

	// No gravity in space, apparently.
	var/area/area = get_area(src)
	if(!area.has_gravity())
		return

	if(throwing)
		return

	if(can_fall())
		handle_fall(below)

//For children to override
/atom/movable/proc/can_fall()
	if(anchored)
		return FALSE

	if(locate(/obj/structure/lattice, loc))
		return FALSE

	// See if something prevents us from falling.
	var/turf/below = GetBelow(src)
	for(var/atom/A in below)
		if(!A.CanPass(src, src.loc))
			return FALSE

	return TRUE

/obj/effect/can_fall()
	return FALSE

/obj/effect/decal/cleanable/can_fall()
	return TRUE

/obj/item/pipe/can_fall()
	var/turf/simulated/open/below = loc
	below = below.below

	. = ..()

	if(anchored)
		return FALSE

	if((locate(/obj/structure/disposalpipe/up) in below) || locate(/obj/machinery/atmospherics/pipe/zpipe/up in below))
		return FALSE

/mob/living/can_fall()
	. = ..()
	if(.)
		if(flight_ticks_remain != 0)
			return 0

/mob/living/carbon/human/can_fall()
	. = ..()
	if(.)
		return species.can_fall(src)

/atom/movable/proc/handle_fall(var/turf/landing)
	Move(landing)
	if(locate(/obj/structure/stairs) in landing)
		return 1
	else
		handle_fall_effect(landing)

/atom/movable/proc/handle_fall_effect(var/turf/landing)
	if(istype(landing, /turf/simulated/open))
		visible_message("\The [src] falls from the deck above through \the [landing]!", "You hear a whoosh of displaced air.")
	else
		visible_message("\The [src] falls from the deck above and slams into \the [landing]!", "You hear something slam into the deck.")

/mob/living/carbon/human/handle_fall_effect(var/turf/landing)
	if(species && species.handle_fall_special(src, landing))
		return

	..()
	var/damage = 10
	apply_damage(rand(0, damage), BRUTE, BP_HEAD)
	apply_damage(rand(0, damage), BRUTE, BP_CHEST)
	apply_damage(rand(0, damage), BRUTE, BP_L_LEG)
	apply_damage(rand(0, damage), BRUTE, BP_R_LEG)
	apply_damage(rand(0, damage), BRUTE, BP_L_ARM)
	apply_damage(rand(0, damage), BRUTE, BP_R_ARM)
	weakened = max(weakened,2)
	updatehealth()