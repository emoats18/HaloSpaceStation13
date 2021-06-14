
/datum/map/neutral_city_innie
	name = "KS7-535, Unknown Colony"
	full_name = "111 Tauri System, UNSC Outpost"
	system_name = "111 Tauri"
	path = "base_Assault_neutral_base_urf"
	station_levels = list()
	admin_levels = list()
	accessible_z_levels = list()
	lobby_icon = 'code/modules/halo/splashworks/title8.jpg'
	id_hud_icons = 'maps/ks7_elmsville/hud_icons.dmi'
	station_networks = list()
	station_name  = "URF Insurrection"
	station_short = "URF Insurrection"
	dock_name     = "Space Elevator"
	boss_name     = "United Rebel Front"
	boss_short    = "UNSC HIGHCOM"
	company_name  = "United Rebel Front"
	company_short = "URF"

	use_overmap = 1
	overmap_size= 30
	overmap_event_tokens = 1

	allowed_gamemodes = list("base_assault_capture_and_hold_urf")
	map_admin_faxes = list("URF Highcomm")


#if !defined(using_map_DATUM)

	#define using_map_DATUM /datum/map/neutral_city_innie

	#include "unit_tests.dm"

	#include "../npc_ships/om_ship_areas.dm"
	#include "../area_holders/overmap_ship_area_holder.dmm"

	#include "../Admin Planet/includes.dm"

	#include "../faction_bases/complex046/complex046.dm"

	#include "../UNSC_Difference_Of_Opinion/includes.dm"

	#include "gm.dm"

	#include "areas.dm"
	#include "overmap.dm"
	#include "neutral_city_innie.dmm"

	#include "../UNSC_Thorin/includes.dm"

	#include "../../code/modules/halo/lobby_music/odst_music.dm"
	#include "../../code/modules/halo/lobby_music/halo_music.dm"

	#include "../../code/modules/halo/supply/unsc.dm"
	#include "../../code/modules/halo/supply/oni.dm"
	#include "../../code/modules/halo/supply/innie.dm"

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring Base Assault URF, neutral base

#endif


/datum/map/neutral_city_innie
	allowed_jobs = list(\
	/datum/job/unsc/marine,
	/datum/job/unsc/marine/specialist,
	/datum/job/unsc/marine/squad_leader,
	/datum/job/unsc/odst,
	/datum/job/unsc/odst/squad_leader,
	/datum/job/unsc/commanding_officer,
	/datum/job/unsc/executive_officer,
	/datum/job/geminus_innie,
	/datum/job/geminus_innie/officer,
	/datum/job/geminus_innie/commander,
	/datum/job/soe_commando,
	/datum/job/soe_commando_officer,
	/datum/job/geminus_innie/orion_defector,
	)

	allowed_spawns = list(\
		DEFAULT_SPAWNPOINT_ID,\
		"UNSC Base Spawns",\
		"UNSC Base Fallback Spawns",\
		"Innie Base Spawns"\
		)

	default_spawn = DEFAULT_SPAWNPOINT_ID

//Move the unsc backup base to nullspace.
/obj/effect/overmap/complex046/Initialize()
	. = ..()
	loc = null

/obj/effect/overmap/ship/unsc_corvette
	occupy_range = 2
	has_external_dropship_points = 0
	alpha = 0
	is_boardable = 0
	mouse_opacity = 0

/obj/effect/overmap/ship/unscDoO
	occupy_range = 2
	has_external_dropship_points = 0
	alpha = 0
	is_boardable = 0
	mouse_opacity = 0
