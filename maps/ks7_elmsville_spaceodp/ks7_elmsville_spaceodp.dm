#if !defined(using_map_DATUM)

	#define using_map_DATUM /datum/map/ks7_elmsville

	#include "../ks7_elmsville/unit_tests.dm"

	#include "../../code/modules/halo/covenant/invasion_scanner.dm"

	#include "../npc_ships/om_ship_areas.dm"
	#include "../area_holders/overmap_ship_area_holder.dmm"

	#include "../Admin Planet/includes.dm"

	#include "../faction_bases/ODP_Cassius/ODP_Cassius.dm"

	#include "../CRS_Unyielding_Transgression/includes.dm"

	#include "../urf_flagship/includes.dm"

	#include "../../code/modules/halo/lobby_music/odst_music.dm"
	#include "../../code/modules/halo/lobby_music/halo_music.dm"

	#include "../_gamemodes/invasion/gamemode.dm"
	#include "../_gamemodes/invasion/gamemode_revolution.dm"
	#include "../_gamemodes/invasion/gamemode_reclamation.dm"

	#include "../../code/modules/halo/supply/unsc.dm"
	#include "../../code/modules/halo/supply/oni.dm"
	#include "../../code/modules/halo/supply/covenant.dm"

	#include "../ks7_elmsville/includes_pvp.dm"

	#include "../faction_bases/complex046/complex046.dm"

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring KS7 Elmsville, space ODP
#endif