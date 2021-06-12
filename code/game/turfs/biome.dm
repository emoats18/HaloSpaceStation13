
//place this landmark on your map to generate randomised atoms from a preset list (place one in each area you want to be done over)
//can do turfs or objs or anything, just make a child of this
/obj/effect/landmark/biome
	name = "DO NOT USE ME"
	var/tiles_per_tick = 2000
	var/area/my_area
	var/list/my_turfs = list()
	var/turf_index = 1
	var/list/atom_types = list()
	var/list/turf_types = list()
	var/chosen_turf_type
	var/time_start = 0
	var/skip_chance = 0

/obj/effect/landmark/biome/New()
	..()
	if(atom_types.len || turf_types.len)
		GLOB.processing_objects.Add(src)
		var/turf/my_turf = get_turf(src)
		my_area = my_turf.loc
		my_turfs = get_area_turfs(my_area)
		time_start = world.time

		if(turf_types.len)
			chosen_turf_type = pick(turf_types)

/obj/effect/landmark/biome/process()
	set background = 1
	var/tiles_processed = 0

	while(tiles_processed < tiles_per_tick)
		//check if we are finished
		if(turf_index > my_turfs.len)
			GLOB.processing_objects.Remove(src)
			log_admin("[src] [src.type] ([src.x],[src.y],[src.z]) has finished processing in [my_area] [my_area.type]. Time taken: [(world.time-time_start)/10] seconds.")
			qdel(src)
			break

		//we may want some periodic empty turfs
		var/do_spawn = (!prob(skip_chance) && atom_types.len)
		if(chosen_turf_type || do_spawn)
			//grab the current turf
			var/turf/cur_turf = my_turfs[turf_index]

			//change it to the chosen biome turf type
			if(chosen_turf_type)
				cur_turf.ChangeTurf(chosen_turf_type)

			//spawn something there
			if(do_spawn)

				//dont spawn if there is already something there
				if(cur_turf.density)
					do_spawn = 0
				else
					for(var/atom/A in cur_turf)
						if(A.density)
							do_spawn = 0
							break

				if(do_spawn)
					var/atom_type = pickweight(atom_types)
					new atom_type(cur_turf)

		//increment the counters
		turf_index++
		tiles_processed++
