/datum/unit_test/jobs_shall_have_a_valid_outfit_type
	name = "JOB: Shall have a valid outfit type"

/datum/unit_test/jobs_shall_have_a_valid_outfit_type/start_test()
	var/failed_jobs = 0

	for (var/occ in job_master.occupations)
		var/datum/job/occupation = occ
		//this was formerly checking for /decl/hierarchy/outfit/job/outfit
		//we have more nonstandard "job" types so we dont use the standard outfits
		var/decl/hierarchy/outfit/outfit = outfit_by_type(occupation.outfit_type)
		if(!istype(outfit))
			log_bad("[occupation.title] - [occupation.type]: Invalid outfit type [outfit ? outfit.type : "NULL"].")
			failed_jobs++

	if(failed_jobs)
		fail("[failed_jobs] job\s with invalid outfit type.")
	else
		pass("All jobs had outfit types.")
	return 1

/datum/unit_test/jobs_shall_have_a_HUD_icon
	name = "JOB: Shall have a HUD icon"

/datum/unit_test/jobs_shall_have_a_HUD_icon/start_test()
	var/failed_jobs = 0
	var/failed_sanity_checks = 0

	var/job_huds = icon_states(GLOB.using_map.id_hud_icons)

	if(!("" in job_huds))
		log_bad("Sanity Check - Missing default/unnamed HUD icon")
		failed_sanity_checks++

	if(!("hudunknown" in job_huds))
		log_bad("Sanity Check - Missing HUD icon: hudunknown")
		failed_sanity_checks++

	/*
	if(!("hudcentcom" in job_huds))
		log_bad("Sanity Check - Missing HUD icon: hudcentcom")
		failed_sanity_checks++
		*/

	for (var/job in joblist)
		var/datum/job/J = joblist[job]
		if(!(J.type in GLOB.using_map.allowed_jobs))
			continue

		var/hud_icon_state = "hud[ckey(job)]"
		if(!(hud_icon_state in job_huds))
			log_bad("[job] - Missing HUD icon: [hud_icon_state]")
			failed_jobs++

	if(failed_sanity_checks || failed_jobs)
		fail("[GLOB.using_map.id_hud_icons] - [failed_sanity_checks] failed sanity check\s, [failed_jobs] job\s with missing HUD icon.")
	else
		pass("All jobs have a HUD icon.")
	return 1

/datum/unit_test/jobs_shall_have_a_valid_spawn
	name = "JOB: Shall have a valid spawn"

/datum/unit_test/jobs_shall_have_a_valid_spawn/start_test()
	var/failed_jobs = 0

	for(var/datum/job/occupation in job_master.occupations)
		var/spawnpoint_id = DEFAULT_SPAWNPOINT_ID
		if(occupation.spawnpoint_override)
			spawnpoint_id = occupation.spawnpoint_override

		//grab the spawn
		var/datum/spawnpoint/candidate = spawntypes()[spawnpoint_id]

		if(candidate)
			var/retval = candidate.check_job_spawning(occupation)
			if(retval)
				log_bad("[occupation.title] - [occupation.type]: Found spawn \"[spawnpoint_id]\" but spawning was blocked: [retval]")
				failed_jobs++
			else
				retval = candidate.check_job_spawning(occupation, 1)
				if(retval)
					log_bad("[occupation.title] - [occupation.type]: Found spawn \"[spawnpoint_id]\" but latejoin spawning was blocked: [retval]")
					failed_jobs++
		else
			log_bad("[occupation.title] - [occupation.type]: Searched for \"[spawnpoint_id]\" but couldn't find it.")
			failed_jobs++


	if(failed_jobs)
		fail("[failed_jobs] job\s with invalid spawn.")
	else
		pass("All jobs had valid spawns.")
	return 1
