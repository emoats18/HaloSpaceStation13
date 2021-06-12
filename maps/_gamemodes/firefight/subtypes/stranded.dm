
/datum/game_mode/firefight/stranded
	name = "Stranded"
	config_tag = "stranded"
	enemy_faction_name = "Flood"
	votable = 1
	round_description = "Build a base in order to survive. The Flood is coming..."
	extended_round_description = "Your ship has crash landed on a distant alien world. Now waves of Flood are attacking and there is only limited time to setup defences. Can you survive until the rescue team arrives?"
	assault_landmark_type = /obj/effect/landmark/assault_target/flood

	wave_message = "Flood spawns have started! Get back to your base and dig in..."
	rest_message = "Flood have been destroyed! Get back to your base and repair your defences..."
	evac_message = "The pelican has arrived! Protect it until it is ready to liftoff!"

	list/resupply_procs = list(\
		/datum/game_mode/firefight/proc/spawn_resupply,\
		/datum/game_mode/firefight/proc/spawn_ship_debris)

	max_spawns_tick_perf = 30
	max_spawns_tick_base = 15
	max_spawns_tick = 15
	enemy_numbers_base = 25
	enemy_numbers_left = 25

	wave_spawns = list()

/datum/game_mode/firefight/stranded/pre_setup()
	. = ..()
	allowed_ghost_roles += list(/datum/ghost_role/flood_combat_form)

	//flood dont use radio to communicate with each other
	overmind.comms_channel = null

//An important override for the ghost role flood
/datum/ghost_role/flood_combat_form
	objects_spawn_on = list(/obj/effect/landmark/flood_spawn,/obj/effect/landmark/spawn_medium,/obj/structure/biomass)

/datum/ghost_role/flood_combat_form/unique_role_checks(var/mob/observer/ghost/ghost,var/list/possible_spawns)//Used to check some special circumstances, like welded vents for mice.
	var/datum/game_mode/firefight/gm = ticker.mode
	if(!istype(gm))
		return 1
	if(gm.is_spawning)
		return 1
	return 0
