
/datum/faction
	var/name = "Unknown faction"
	var/parent_faction
	var/points = 0
	var/blurb
	var/list/all_objectives = list()
	var/list/objectives_without_targets = list()
	var/list/assigned_minds = list()
	var/list/living_minds = list()
	var/list/defender_mob_types = list()
	var/max_points = 0
	var/ignore_players_dead = 0
	var/obj/effect/overmap/flagship
	var/obj/effect/overmap/base
	var/archived_base_name = "NA_BASE_NAME"
	var/archived_flagship_name = "NA_FLAGSHIP_NAME"
	var/list/enemy_faction_names = list()
	var/list/enemy_factions = list()
	var/list/angry_factions = list()

	var/list/all_quests = list()
	var/list/available_quests = list()
	var/list/processing_quests = list()

	var/datum/job/commander_job			//this needs to be set in the gamemode code
	var/commander_job_types = list()	//checks in order of priority for objective purposes
	var/has_flagship = 0
	var/flagship_slipspaced = 0
	var/has_base = 0
	var/base_desc
	var/destroyed_reason = null
	var/list/ship_types = list()
	var/list/overpowered_ship_types = list()
	var/list/npc_ships = list()
	var/list/player_ships = list()
	var/list/all_ships = list()
	var/list/faction_reputation = list()
	var/leader_name
	var/datum/computer_file/data/com/faction_contact_data
	var/is_processing = 0
	var/datum/money_account/money_account
	var/max_npc_quests = 0
	var/time_next_quest = 0
	var/quest_interval_min = 1 SECONDS
	var/quest_interval_max = 5 MINUTES
	var/gear_supply_type
	var/default_radio_channel = RADIO_HUMAN
	var/default_language = LANGUAGE_ENGLISH

	var/income = 0	//credits
	var/income_delay = 15 MINUTES
	var/next_income = 0
	var/list/special_jobs = list()
	var/next_special_job = 0

	var/list/listening_programs = list()
	var/datum/repository/crew/crew_repo

/datum/faction/New()
	. = ..()
	GLOB.all_factions.Add(src)
	GLOB.factions_by_name[src.name] = src
	GLOB.factions_by_type[src.type] = src

	/*
	//in case this bit of code becomes useful in future, because i know im going to forget it
	while(length(codename) < 6)
		codename += pick(ascii2text(rand(text2ascii("a"), text2ascii("z"))), "[rand(0,9)]")
		*/

	//generate some stuff for radio contacts
	faction_contact_data = new()
	faction_contact_data.generate_data(src)

	setup_announcement()

	//leader name
	if(prob(50))
		leader_name = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
	else
		leader_name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

/datum/faction/proc/Initialize()
	for(var/faction_name in enemy_faction_names)
		var/datum/faction/F = GLOB.factions_by_name[faction_name]
		if(F)
			enemy_factions.Add(F)

	generate_supply_categories()

	if(income)
		start_processing()

	crew_repo = new()
	crew_repo.my_faction = src

/datum/faction/proc/add_faction_reputation(var/faction_name, var/new_rep)
	if(!faction_reputation.Find(faction_name))
		faction_reputation[faction_name] = 0
	var/old_rep = faction_reputation[faction_name]
	faction_reputation[faction_name] += new_rep
	if(faction_reputation[faction_name] < 0.1 && faction_reputation[faction_name] > -0.1)
		faction_reputation[faction_name] = 0

	if(old_rep >= 0 && old_rep + new_rep < 0)
		var/datum/faction/F = GLOB.factions_by_name[faction_name]
		angry_factions |= F
		start_processing()

/datum/faction/proc/get_faction_reputation(var/faction_name)
	if(faction_reputation.Find(faction_name))
		return faction_reputation[faction_name]
	else
		return 0

/datum/faction/proc/is_angry_at_faction(var/faction_name)
	for(var/datum/faction/F in angry_factions)
		if(F.name == faction_name)
			return 1

	return 0

/datum/faction/proc/players_alive()
	//loop over and check if our playerlist is up to date
	for(var/index=1, index <= living_minds.len, index++)
		var/datum/mind/M = living_minds[index]

		if(!M || !M.current || !isliving(M.current) || M.current.stat == DEAD)
			//remove this entry
			living_minds.Cut(index, index + 1)

			//the order has shifted so make sure we test every entry
			index -= 1

	return living_minds.len

/datum/faction/proc/get_flagship()
	if(!flagship)
		for(var/obj/effect/overmap/check_ship in world)
			if(check_ship.flagship && check_ship.get_faction() == src.name)
				flagship = check_ship
				break

	return flagship

/datum/faction/proc/get_flagship_name()
	if(!flagship && has_flagship)
		return archived_flagship_name
	archived_flagship_name = flagship.name
	return archived_flagship_name

/*/datum/faction/proc/find_flagship()
	for(var/obj/effect/overmap/ship in world)
		if(ship.faction != src.name)
			continue
		if(ship.flagship)
			flagship = ship
			break*/

/datum/faction/proc/get_base()
	if(!base && has_base)
		for(var/obj/effect/overmap/check_base in world)
			if(check_base.base && check_base.faction == src.name)
				base = check_base
				break
	return base

/*/datum/faction/proc/find_base()
	for(var/obj/effect/overmap/sector in world)
		if(sector.faction != src.name)
			continue
		if(sector.base)
			base = sector
			break*/

/datum/faction/proc/get_base_name()
	if(!base)
		return archived_base_name
	archived_base_name = base.name
	return archived_base_name

/datum/faction/proc/get_commander(var/datum/mind/check_mind)

	commander_job = null
	for(var/job_type in commander_job_types)
		commander_job = job_master.occupations_by_type[job_type]
		if(commander_job)
			break

	if(commander_job)
		//if(!. && check_mind && check_mind.assigned_role == "UNSC Bertels Commanding Officer")
		if(check_mind && check_mind in commander_job.assigned_players)
			return check_mind

		for(var/mind in commander_job.assigned_players)
			return mind

/datum/faction
	var/obj/effect/overmap/delivery_target

/datum/faction/proc/find_objective_delivery_target()
	var/obj/effect/overmap/delivery_target = get_base()
	if(!delivery_target)
		delivery_target = get_flagship()

/datum/faction/proc/get_objective_delivery_areas()
	if(!delivery_target)
		find_objective_delivery_target()

	var/list/found_areas = list()
	if(delivery_target)
		for(var/cur_area in typesof(delivery_target.parent_area_type) - delivery_target.parent_area_type)
			var/area/A = locate(cur_area)
			found_areas.Add(A)

	return found_areas

/datum/faction/proc/unlock_special_job()
	//override this in children for faction announcements
	if(special_jobs.len)
		var/datum/job/special_job = job_master.occupations_by_type[pick(special_jobs)]
		if(special_job)
			special_job.total_positions += 1
			. = special_job
	else
		log_and_message_admins("Warning, attempted to unlock a special job slot for [src.name] but none were listed!")

/datum/faction/proc/get_hq_name()
	//attempt to find the HQ name
	var/hq_name

	//is there a base?
	if(has_base)
		hq_name = get_base_name()
	if(hq_name)
		return hq_name

	//is there a flagship?
	if(has_flagship)
		hq_name = get_flagship_name()
	if(hq_name)
		return hq_name

	//cant figure it out
	return "Unknown"
