
#include "../faction_base_unsc.dm"

#include "new_areas.dm"
#include "ai_items.dm"
#include "presets.dm"
#include "new_ODP_Cassius.dmm"

/obj/effect/overmap/ship/unsc_odp_cassius
	name = "ODP Cassius"
	desc = "Located in geosynchronous orbit above the planet, this relatively compact Moncton-class Orbital Defense Platform has enough firepower to pierce any spacecraft known to man in a single hit."
	icon = 'code/modules/halo/icons/overmap/faction_misc.dmi'
	icon_state = "SMAC"
	faction = "UNSC"
	overmap_spawn_near_me = list()
	base = 1
	block_slipspace = 1
	fore_dir = WEST
	anchored = 1

	parent_area_type = /area/faction_base/unsc/odp

	map_bounds = list(32,150,170,57) //Format: (TOP_LEFT_X,TOP_LEFT_Y,BOTTOM_RIGHT_X,BOTTOM_RIGHT_Y)

	occupy_range = 7

/obj/effect/overmap/ship/unsc_odp_cassius/Initialize()
	. = ..()
	loot_distributor.loot_list["bombRandom"] = list(/obj/effect/bombpoint_mark,/obj/effect/bombpoint_mark)

/obj/effect/overmap/ship/unsc_odp_cassius/Destroy()
	var/datum/game_mode/outer_colonies/gm = ticker.mode
	if(istype(gm))
		gm.allow_scan = 1

		//unlock some new job slots after a short delay
		spawn(30)
			GLOB.UNSC.unlock_special_job()
			GLOB.COVENANT.unlock_special_job()

		//this is janky, i really should fix spawns instead
		//its necessary because the AI initial spawn is on the ODP
		//without the ODP the AI will spawn somewhere random like the Cov ship
		var/datum/job/ai_job = job_master.occupations_by_type[/datum/job/unsc_ai]
		ai_job.total_positions = 0

	. = ..()
