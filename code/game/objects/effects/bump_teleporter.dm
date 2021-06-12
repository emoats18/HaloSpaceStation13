var/list/obj/effect/bump_teleporter/BUMP_TELEPORTERS = list()

/obj/effect/bump_teleporter
	name = "bump-teleporter"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	var/id = null			//id of this bump_teleporter.
	var/id_target = null	//id of bump_teleporter which this moves you to.
	invisibility = 101 		//nope, can't see this
	anchored = 1
	density = 1
	opacity = 0
	var/faction_restrict
	var/list/blocked_types = list()

/obj/effect/bump_teleporter/New()
	..()
	BUMP_TELEPORTERS += src

/obj/effect/bump_teleporter/Destroy()
	BUMP_TELEPORTERS -= src
	return ..()

/obj/effect/bump_teleporter/Bumped(atom/movable/user)
	if(!istype(user))
		return

	if(!id_target)
		//user.loc = src.loc	//Stop at teleporter location, there is nowhere to teleport to.
		return

	if(faction_restrict)
		if(isliving(user))
			var/mob/living/L = user
			if(L.faction != faction_restrict)
				return
		else
			var/success = 0
			for(var/mob/living/L in user)
				if(L.faction == faction_restrict)
					success = 1
					break
			if(!success)
				return

	if(blocked_types.len)
		for(var/atom/movable/M in user.contents + user)
			for(var/check_type in blocked_types)
				if(istype(M, check_type))
					to_chat(usr, "<span class='notice'>You cannot take [M] through there!</span>")
					return

	for(var/obj/effect/bump_teleporter/BT in BUMP_TELEPORTERS)
		if(BT.id == src.id_target)
			user.forceMove(BT.loc)	//Teleport to location with correct id.
			var/obj/vehicles/v = user
			if(istype(v))
				v.update_occupant_z_level(BT.loc.z)
			return