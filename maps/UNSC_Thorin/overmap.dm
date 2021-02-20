
/obj/effect/overmap/ship/unsc_corvette
	name = "URFS Thorn"
	desc = "A standard contruction-model corvette. Seems to have taken some battle damage."

	icon = 'corvette.dmi'
	icon_state = "ship"
	fore_dir = WEST
	vessel_mass = 2.75
	faction = "Insurrection"
	flagship = 1

	map_bounds = list(2,76,76,26)
	parent_area_type = /area/corvette/unscthorin

/obj/machinery/button/toggle/alarm_button/urf_flagship_alarm
	alarm_sound = 'sound/misc/TestLoop1.ogg'
	alarm_loop_time = 7 SECONDS
	area_base = /area/corvette/unscthorin
