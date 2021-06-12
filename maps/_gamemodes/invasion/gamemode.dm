
#define SCANNER_TICK_DELAY 10 SECONDS
#define BASE_SCANNER_DESTROYABLE_AMOUNT 4
#define SCAN_JAM_LOC_NAME "Orbital Facility"

#include "objectives.dm"

/datum/game_mode/outer_colonies
	name = "Outer Colonies"
	config_tag = "outer_colonies"
	round_description = "In an outer colony on the edge of human space, an insurrection is brewing. Meanwhile an alien threat lurks in the void."
	extended_round_description = "In an outer colony on the edge of human space, an insurrection is brewing. Meanwhile an alien threat lurks in the void."
	probability = 1
	ship_lockdown_duration = 12 MINUTES
	required_players = 6

	var/safe_expire_warning = 0

	var/list/factions = list(/datum/faction/unsc, /datum/faction/covenant, /datum/faction/insurrection)
	var/list/endgame_fleets = list(/datum/faction/unsc)

	var/list/overmap_hide = list()

	var/list/objectives_slipspace_affected = list()

	var/list/round_end_reasons = list()

	var/scan_percent = 0
	var/allow_scan = 0
	var/scanner_destructions_left = BASE_SCANNER_DESTROYABLE_AMOUNT
	var/scanners_active = 0
	var/cov_scan_next_tick = 0

	var/end_conditions_required = 4 //3 destructions, with the fourth causing failure.
	votable = 0

/datum/game_mode/outer_colonies/pre_setup()
	. = ..()

	//hide some faction sectors from factions not playing
	for(var/obj/effect/overmap/S in world)
		if(S.type in overmap_hide)
			if(S && S.map_z_data.len)
				var/obj/effect/landmark/map_data/check_data = S.map_z_data[1]
				S.loc = check_data.loc
			else
				message_admins("GAMEMODE WARNING: Attempted to hide overmap object [S] ([S.type]) but it was not loaded properly. \
				Deleting instead...")
				qdel(S)

	setup_objectives()

	//some NPC civilian ships to fly around the overmap
	shipmap_handler.spawn_ship(GLOB.HUMAN_CIV, 3)

	//setup the endgame fleet spawning
	GLOB.UNSC.set_endless_fleets()

	//setup faction handling
	for(var/faction_type in factions)
		factions.Remove(faction_type)
		var/datum/faction/F = GLOB.factions_by_type[faction_type]

		//this is normally bad practice, but it seems to work fine in byond
		factions.Add(F)

/datum/game_mode/outer_colonies/proc/setup_objectives()

	//setup covenant objectives
	var/list/objective_types = list(\
		/datum/objective/overmap/covenant_ship,\
		/datum/objective/protect/leader,\
		//datum/objective/glass_colony,
		//datum/objective/retrieve/steal_ai,
		//datum/objective/retrieve/nav_data,
		//datum/objective/overmap/covenant_unsc_ship,
		/datum/objective/overmap/covenant_odp,\
		//datum/objective/colony_capture/cov,
		/datum/objective/phase2_scan,\
		/datum/objective/retrieve/artifact)
	GLOB.COVENANT.setup_faction_objectives(objective_types)
	GLOB.COVENANT.has_flagship = 1

	//setup unsc objectives
	objective_types = list(\
		//datum/objective/overmap/unsc_ship,
		//datum/objective/retrieve/artifact/unsc,
		/datum/objective/protect/leader,\
		/datum/objective/capture_innies,\
		//datum/objective/retrieve/steal_ai/cole_protocol,
		//datum/objective/retrieve/nav_data/cole_protocol,
		/datum/objective/overmap/unsc_cov_ship,\
		//datum/objective/colony_capture/unsc,
		/datum/objective/phase2_scan_unsc,\
		/datum/objective/protect_colony,\
		//datum/objective/overmap/unsc_innie_base,
		/datum/objective/overmap/unsc_innie_ship)
	GLOB.UNSC.setup_faction_objectives(objective_types)
	//GLOB.UNSC.has_flagship = 1
	GLOB.UNSC.has_base = 1

	//setup innie objectives
	objective_types = list(\
		/datum/objective/protect/leader,\
		//datum/objective/overmap/innie_unsc_ship,\
		/datum/objective/assassinate/leader/innies_unsc,\
		///datum/objective/recruit_pirates,
		///datum/objective/recruit_scientists,
		/datum/objective/overmap/innie_odp,\
		/datum/objective/colony_capture/innie,\
		/datum/objective/overmap/innie_ship)
		//datum/objective/overmap/innie_base)
	GLOB.INSURRECTION.setup_faction_objectives(objective_types)
	GLOB.INSURRECTION.has_flagship = 1
	//GLOB.INSURRECTION.base_desc = "secret underground HQ"

	//todo: remove the hardcoded Geminus colony name here

	GLOB.HUMAN_CIV.name = "Geminus City"
	GLOB.HUMAN_CIV.has_base = 1
	GLOB.HUMAN_CIV.base_desc = "human colony"

/datum/game_mode/outer_colonies/proc/increase_scan_percent(var/amt)
	var/old_scan = scan_percent
	scan_percent = min(100,max(0,scan_percent+amt))
	if(prob(25 * scanners_active) || (old_scan < 25 && scan_percent >= 25) || (old_scan < 50 && scan_percent >= 50) || (old_scan < 75 && scan_percent >= 75))
		GLOB.global_announcer.autosay("Intel suggests Covenant scanning has reached [scan_percent] percent complete.", "HIGHCOMM SIGINT", RADIO_SQUAD, LANGUAGE_ENGLISH)
		GLOB.global_announcer.autosay("Our scan moves forward, bringing us closer to the holy relic! [scan_percent]%", "Covenant Overwatch", RADIO_COV, LANGUAGE_SANGHEILI)
	if(scan_percent >= 100)
		GLOB.global_announcer.autosay("The Covenant has completed their scan! We have failed to defend the colony. Stop the covenant escaping with what they found.", "HIGHCOMM SIGINT", RADIO_FLEET, LANGUAGE_ENGLISH)
		GLOB.global_announcer.autosay("We have found the holy relic! Rejoice, for the Forerunners smile upon us on this day!", "Covenant Overwatch", RADIO_COV, LANGUAGE_SANGHEILI)
		var/list/relic_sites = list()
		for(var/obj/effect/landmark/artifact_spawn/spawnpoint in world)
			relic_sites += spawnpoint.loc
		new /obj/machinery/artifact/forerunner_artifact (pick(relic_sites))

/datum/game_mode/outer_colonies/proc/register_scanner()
	scanners_active++

/datum/game_mode/outer_colonies/proc/unregister_scanner()
	scanners_active = max(scanners_active-1,0)

/datum/game_mode/outer_colonies/proc/register_scanner_destroy()
	unregister_scanner()
	if(scan_percent >= 100) //They already won the phase, destruction does nothing
		return
	scanner_destructions_left = max(0,scanner_destructions_left-1)
	increase_scan_percent(-25)
	GLOB.global_announcer.autosay("The Covenant's scanning signal has weakened! Eliminate all of their scanners!", "HIGHCOMM SIGINT", RADIO_FLEET, LANGUAGE_ENGLISH)
	GLOB.global_announcer.autosay("A holy scanner has gone dark. Protect them, for their loss inhibits our progress!", "Covenant Overwatch", RADIO_COV, LANGUAGE_SANGHEILI)

/datum/game_mode/outer_colonies/handle_latejoin(var/mob/living/carbon/human/character)
	for(var/datum/faction/F in factions)
		for(var/datum/objective/objective in F.objectives_without_targets)
			if(objective.find_target())
				F.objectives_without_targets -= objective

	return 1

/datum/game_mode/outer_colonies/post_setup(var/announce = 0)
	. = ..()
	for(var/datum/faction/F in factions)
		for(var/datum/objective/objective in F.objectives_without_targets)
			if(objective.find_target())
				F.objectives_without_targets -= objective

/datum/game_mode/outer_colonies/process()
	. = ..()
	if(scan_percent < 100 && scanner_destructions_left && scanners_active && world.time >= cov_scan_next_tick)
		if(allow_scan)
			increase_scan_percent(scanners_active)
		else
			GLOB.global_announcer.autosay("Their [SCAN_JAM_LOC_NAME] blocks our holy scanning! Eliminate it!", "Covenant Overwatch", RADIO_COV, LANGUAGE_SANGHEILI)
		cov_scan_next_tick = world.time + SCANNER_TICK_DELAY

/datum/game_mode/outer_colonies/check_finished()

	round_end_reasons = list()
	. = evacuation_controller.round_over()
	if(.)
		round_end_reasons += "an early round end was voted for"
		return .
	var/extra_pts = 0 //Extra "round end reason" points assigned by some factors

	if(scan_percent < 100 && scanner_destructions_left == 0 && !scanners_active)
		round_end_reasons += "the Covenant scanning devices were destroyed"
		extra_pts += 1

	if(GLOB.UNSC.fleet_spawn_at > 0 && world.time > GLOB.UNSC.fleet_spawn_at && GLOB.COVENANT.flagship_slipspaced != 0)
		round_end_reasons += "the UNSC fleet has taken control of the sector in the absence of the Covenant"
		extra_pts += 1

	for(var/datum/faction/F in factions)

		if(F.has_flagship)
			//currently only the covenant have has_flagship = 1, but this can be tweaked as needed
			var/obj/effect/overmap/flagship = F.get_flagship()
			if(flagship)
				if(!flagship.loc)
					if(F.flagship_slipspaced || flagship.slipspace_status == 2)
						round_end_reasons += "the [F.name] ship has gone to slipspace and left the system"
						extra_pts += 1
						/*var/datum/faction/covenant/C = locate() in factions
						C.ignore_players_dead = 1*/
					else if(!flagship.slipspace_status)
						round_end_reasons += "the [F.name] ship has been destroyed"
			else
				round_end_reasons += "the [F.name] ship has been destroyed"

		if(F.has_base)
			//currently no factions have has_base = 1, but this can be tweaked as needed (see: UNSC cassius station, innie rabbit hole base)
			var/obj/effect/overmap/base = F.get_base()
			var/base_name = F.get_base_name()
			if(!base || !base.loc)
				round_end_reasons += "the [base_name] has been destroyed"
			else if(base)
				if(base.demolished)
					round_end_reasons += "the [base_name] has been demolished"
				if(base.nuked)
					round_end_reasons += "the [base_name] has been nuked"
				if(base.glassed)
					round_end_reasons += "the [base_name] has been glassed"

		/*
		//if all faction players have been killed/captured... only check 1 faction
		if(faction_safe_time - world.time < 2 MINUTES)
			var/safe_expire_warning_check = 0
			if(!F.players_alive() && !F.ignore_players_dead)
				if(world.time >= faction_safe_time)
					round_end_reasons += "the [F.name] presence in the system has been destroyed"
					factions_destroyed++

				else if(!safe_expire_warning)
					safe_expire_warning_check = 1
					message_admins("GAMEMODE WARNING: Faction safe time expiring in 2 minutes and the [F.name] have no living players.")
			if(safe_expire_warning_check)
				safe_expire_warning = 1
				*/

	/*
	var/end_round_triggers = round_end_reasons.len
	//only count 1 destroyed faction towards the end round triggers
	if(factions_destroyed > 0)
		end_round_triggers -= factions_destroyed
		end_round_triggers += 1
		*/

	//if 2 or more end conditions are met, end the game
	return (round_end_reasons.len + extra_pts >= end_conditions_required)

/datum/game_mode/outer_colonies/declare_completion()
	if(round_end_reasons.len == 0)
		round_end_reasons += "the round ended early"

	var/announce_text = ""

	announce_text += "<h4>The round ended because "
	announce_text += english_list(round_end_reasons)
	announce_text += "</h4>"

	to_world(announce_text)

	//work out survivors
	var/clients = 0
	var/surviving_total = 0
	var/ghosts = 0
	var/list/survivor_factions = list()

	for(var/mob/M in GLOB.player_list)
		if(M.client)
			clients++
			if(M.stat != DEAD)
				surviving_total++
				if(!M.faction)
					M.faction = "unaligned"
				if(survivor_factions[M.faction])
					survivor_factions[M.faction] += 1
				else
					survivor_factions[M.faction] = 1

			else if(isghost(M))
				ghosts++

	var/text = ""
	if(surviving_total > 0)
		var/list/formatted_survivors = list()
		for(var/faction_name in survivor_factions)
			formatted_survivors.Add("[survivor_factions[faction_name]] [faction_name]")
		text += "<br>There was [english_list(formatted_survivors)] survivor[surviving_total != 1 ? "s" : ""] (<b>[ghosts] ghost[ghosts != 1 ? "s" : ""]</b>)."
	else
		text += "There were <b>no survivors</b> (<b>[ghosts] ghost[ghosts > 1 ? "s" : ""]</b>)."

	text += "<br><br>"

	//calculate victory for colony capture objectives... needs to be done here
	var/datum/objective/colony_capture/capture_objective
	for(var/datum/faction/F in GLOB.all_factions)
		for(var/datum/objective/colony_capture/O in F.all_objectives)
			if(!capture_objective)
				if(O.capture_score > 0)
					capture_objective = O
			else if(O.capture_score > capture_objective.capture_score)
				capture_objective = O
	if(capture_objective)
		capture_objective.is_winner = 1

	//work out faction points
	var/datum/faction/winning_faction
	var/datum/faction/second_faction
	var/all_points = 0
	for(var/datum/faction/faction in factions)
		text += "<h3>[faction.name] Objectives</h3>"
		if(!winning_faction)
			winning_faction = faction
		else if(!second_faction && winning_faction != faction)
			second_faction = faction
		if(faction.max_points)
			to_debug_listeners("faction [faction.name] has max_points: [faction.max_points] prior to being reset at round end")
		faction.max_points = 0

		for(var/datum/objective/objective in faction.all_objectives)
			if(objective.fake)
				continue
			var/result = objective.check_completion()
			faction.max_points += objective.get_win_points()
			if(result == 1)
				text += "<span class='good'>Completed (+[objective.get_win_points()]): [objective.short_text]</span><br>"
				faction.points += objective.get_win_points()
			else if(result == 2)
				text += "<span class='mixed'>Partially Completed (+[objective.get_win_points()]): [objective.short_text]</span><br>"
				faction.points += objective.get_win_points()
			else if(objective.lose_points)
				text += "<span class='bad'>Failed (-[objective.get_lose_points()]): [objective.short_text]</span><br>"
				faction.points -= objective.get_lose_points()
			else
				text += "<span class='prefix'>Not Completed: [objective.short_text]</span><br>"

		if(faction.points > 0)
			all_points += faction.points
		if(winning_faction != faction && faction.points >= winning_faction.points)		//<= is necessary to correctly track second place
			second_faction = winning_faction
			winning_faction = faction
		text += "<h4>Total [faction.name] Score: [faction.points] points</h4><br>"

	//these victory tiers will need balancing depending on objectives and points
	var/win_ratio = 0
	if(second_faction.points == winning_faction.points)
		text += "<h2>Tie! [winning_faction.name] and [second_faction.name] ([winning_faction.points] points)</h2>"
	else if(all_points <= 0)
		text += "<h2>Stalemate! All factions failed in their objectives.</h2>"
	else
		/*
		//calculate the win type based on whether other faction scored points and how many of the winning faction objectives are completed
		win_ratio = (winning_faction.points) / (all_points + winning_faction.max_points - winning_faction.points)
		*/

		//calculate points based on how many of their own objectives were completed
		win_ratio = winning_faction.points / winning_faction.max_points

		var/win_type = "Pyrrhic"
		if(win_ratio <= 0.34)
			//this should never or rarely happen
			win_type = "Pyrrhic"
		else if(win_ratio < 0.66)
			win_type = "Minor"
		else if(win_ratio < 0.9)
			win_type = "Moderate"
		else if(win_ratio != 1)
			win_type = "Major"
		else
			win_type = "Supreme"

		text += "<h2>[win_type] [winning_faction.name] Victory! ([round(100*win_ratio)]% of objectives)</h2>"
	to_world(text)

	if(clients > 0)
		feedback_set("round_end_clients",clients)
	if(ghosts > 0)
		feedback_set("round_end_ghosts",ghosts)
	if(surviving_total > 0)
		feedback_set("survived_total",surviving_total)

	send2mainirc("A round of [src.name] has ended - [surviving_total] survivor\s, [ghosts] ghost\s.")

	return 0

/datum/game_mode/outer_colonies/handle_mob_death(var/mob/M, var/unsc_capture = 0)
	. = ..()

/*	if(M.mind.assigned_role in list("Insurrectionist","Insurrectionist Commander","Insurrectionist Officer") || M.mind.faction == "Insurrectionist")
		var/datum/faction/unsc/unsc = locate() in factions
		if(unsc)			var/datum/objective/capture_innies/capture_innies = locate() in unsc.all_objectives
			if(capture_innies)
				if(unsc_capture)
					capture_innies.minds_captured.Add(M.mind)
				else
					capture_innies.minds_killed.Add(M.mind)*/

	if(M.mind)
		for(var/datum/faction/F in factions)
			if(M.mind in F.assigned_minds)
				F.living_minds -= M.mind
				break

/datum/game_mode/outer_colonies/handle_slipspace_jump(var/obj/effect/overmap/ship/ship)

	var/obj/effect/overmap/flagship
	var/datum/faction/F = GLOB.factions_by_name[ship.faction]
	if(F)
		flagship = F.get_flagship()

	if(flagship == ship)
		//record a round end condition
		F.flagship_slipspaced = 1

		//lock in any covenant objectives now so they arent failed by the ship despawning
		for(var/datum/objective/objective in objectives_slipspace_affected)

			//a 1 here means the objective was successful
			objective.override = objective.check_completion()

			//a 0 means it fails so we set -1 to lock in a 0 result
			if(!objective.override)
				objective.override = -1

		check_finished()
