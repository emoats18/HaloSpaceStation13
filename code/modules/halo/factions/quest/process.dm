
/datum/npc_quest
	var/defender_check_index = 1
	var/num_respawns = 0
	var/respawn_interval = 4 SECONDS
	var/time_next_respawn = 0

/datum/npc_quest/proc/process()
	if(quest_status != STATUS_PROGRESS)
		//future todo: sometimes quests might have ticking effects as long as they are available
		//for now, just tell the faction we dont need to process any more
		to_debug_listeners("QUEST WARNING: \ref[src] is attempting to process with quest status [get_status_text(quest_status)]")

		return PROCESS_KILL

	//quests have a limited time
	if(world.time > time_failed)
		faction.finalise_quest(src, STATUS_TIMEOUT)
		return PROCESS_KILL

	process_defenders()

/datum/npc_quest/proc/process_defenders()

	if(quest_status == STATUS_PROGRESS)

		//increment the index
		defender_check_index++
		if(defender_check_index > living_defenders.len)
			defender_check_index = 1

		//scan over our living defenders to see if any have died
		if(defender_check_index <= living_defenders.len)
			//grab the next mob to check
			var/mob/living/simple_animal/S = living_defenders[defender_check_index]

			//this one has been gibbed, so remove it's entry
			if(!S)
				living_defenders.Cut(defender_check_index, defender_check_index + 1)

			//see if it's dead/unconscious and we should respawn them
			else if(S.stat)

				//move it to the dead list
				living_defenders -= S
				dead_defenders += S

		//see if we need to manually respawn any defenders - because they have been gibbed or whatever
		if(living_defenders.len < defender_amount && num_respawns > 0)
			if(world.time >= time_next_respawn)
				//spawn a random new defender
				spawn_defender()
				time_next_respawn = world.time + respawn_interval
				num_respawns--
