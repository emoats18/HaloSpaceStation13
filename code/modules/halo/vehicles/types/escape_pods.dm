
/obj/vehicles/drop_pod/escape_pod
	name = "Escape Pod"
	desc = "An emergency escape pod of unknown make, model or origin."
	density = 1
	anchored = 1
	launch_arm_time = 10 SECONDS
	drop_accuracy = 10
	occupants = list(8,0)

/obj/vehicles/drop_pod/escape_pod/update_object_sprites()
	//Enclosed, we don't need to care about the person-sprites.

/obj/vehicles/drop_pod/escape_pod/is_on_launchbay()
	return 1

/obj/vehicles/drop_pod/escape_pod/get_drop_point()
	var/list/valid_points = list()
	var/obj/effect/overmap/om_obj = map_sectors["[z]"]
	var/list/z_donot_land = list()
	if(om_obj)
		z_donot_land += om_obj.map_z
	for(var/obj/effect/landmark/drop_pod_landing/l in world)
		if(l.z in z_donot_land)
			continue
		valid_points += l
	if(isnull(valid_points) || valid_points.len == 0)
		log_error("ERROR: Drop pods placed on map but no /obj/effect/drop_pod_landing markers present!")
		return
	return pick(valid_points)

/obj/vehicles/drop_pod/escape_pod/get_drop_turf(var/turf/drop_point)
	if(isnull(drop_point))
		visible_message("<span class = 'warning'>[src] blurts a warning: ERROR: NO AVAILABLE DROP-TARGETS.</span>")
		return
	var/list/valid_points = list()
	for(var/turf/t in range(drop_point,drop_accuracy))
		if(istype(t,/turf/simulated/floor))
			valid_points += t
		if(istype(t,/turf/unsimulated/floor))
			valid_points += t
	if(isnull(valid_points))
		return
	return pick(valid_points)

/obj/vehicles/drop_pod/escape_pod/bumblebee
	name = "Class-3 Enclosed Heavy Lifeboat"
	desc = "An enclosed environment for use in emergency evacuation procedures."
	icon = 'code/modules/halo/vehicles/types/bumblebee_full.dmi'
	icon_state = "escape"

	bound_width = 64
	bound_height = 96

/obj/vehicles/drop_pod/escape_pod/bumblebee/north
	bound_width = 64
	bound_height = 96
	dir = 1

/obj/vehicles/drop_pod/escape_pod/bumblebee/south
	bound_width = 64
	bound_height = 96
	dir = 2

/obj/vehicles/drop_pod/escape_pod/bumblebee/east
	bound_width = 96
	bound_height = 64
	dir = 4

/obj/vehicles/drop_pod/escape_pod/bumblebee/west
	bound_width = 96
	bound_height = 64
	dir = 8

/obj/vehicles/drop_pod/escape_pod/covenant
	name = "Escape Pod"
	desc = "An enclosed environment for use in emergency evacuation procedures."
	icon = 'code/modules/halo/vehicles/types/covenant_pods.dmi'
	icon_state = "cov_escape"

	bound_width = 64
	bound_height = 96

/obj/vehicles/drop_pod/escape_pod/covenant/north
	bound_width = 64
	bound_height = 96
	dir = 1

/obj/vehicles/drop_pod/escape_pod/covenant/south
	bound_width = 64
	bound_height = 96
	dir = 2

/obj/vehicles/drop_pod/escape_pod/covenant/east
	bound_width = 96
	bound_height = 64
	dir = 4

/obj/vehicles/drop_pod/escape_pod/covenant/west
	bound_width = 96
	bound_height = 64
	dir = 8
