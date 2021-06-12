#define FLIGHT_DODGE_DIVISOR 6
#define FLIGHT_DODGE_MESSAGE_CHANCE 33

/mob/living/CanPass(atom/movable/mover, turf/start, height=0, air_group=0)
	. = ..()
	if(.)
		if(flight_ticks_remain > 0)
			var/obj/item/mover_obj = mover
			if(istype(mover_obj))
				var/dam_to_remove = mover_obj.force
				var/obj/item/projectile/p = mover
				if(istype(p))
					dam_to_remove = p.damage
				dam_to_remove = round(dam_to_remove / FLIGHT_DODGE_DIVISOR)
				decrement_flight_ticks(dam_to_remove)
				if(prob(FLIGHT_DODGE_MESSAGE_CHANCE))
					to_chat(src,"<span class = 'danger'>You use energy dodging [mover]</span>")

#undef FLIGHT_DODGE_DIVISOR
#undef FLIGHT_DODGE_MESSAGE_CHANCE