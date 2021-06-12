#if !defined(using_map_DATUM)

	#define using_map_DATUM /datum/map/first_contact
	#include "mapdef.dm"
	#include "spawns.dm"
	#include "presets.dm"
	#include "jobs.dm"
	#include "outfits.dm"
	#include "../faction_bases/civ_shuttle.dm"
	#include "../UNSC_With_Noble_Cause/includes_singledeck.dm"
	#include "../kig_yar_pirates/includes.dm"
	#include "../Exoplanet Mining/includes.dm"
	#include "../ks7_elmsville/includes.dm"

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, First Contact include ignored.

#endif