
GLOBAL_DATUM(flood_overmind, /datum/npc_overmind/flood)

#define REPORT_CONTACT 1
#define REPORT_CONSTRUCT 2
#define REPORT_RECLAIM_EQUIP 3
#define REPORT_CASUALTY 4
#define REPORT_SUPPORT_TEAM_REQ 5

#define SQUADFORM_SEARCHRANGE 7
#define TASKPOINT_TIMEOUT_DELAY 1 MINUTE
#define TASKPOINT_TIMEOUT_UPDATE_DELAY 2 MINUTES //The default delay to assign to a taskpoint when the timeout is updated.
#define SINGLESQUAD_MAXTARGET_HANDLE 3 //How many people should we assume our squad can handle before starting to apply squadsize increases.

#define COMBAT_TROOPS_REQUIRED list(0,2,2,1) //Constructor, Combat, Support, Other.
#define CONSTRUCTOR_TROOPS_REQUIRED list(3,1,1,0)
#define REINFORCEMENT_TROOPS_REQUIRED list(0,2,1,1) //Send at least one of everything as reinforcements, if we can.

#define RADIO_COMMS_DELAY 5 SECONDS

/datum/npc_report
	var/report_type = REPORT_CONTACT
	var/mob/living/simple_animal/hostile/reporter_mob = null
	var/targets_reported //Used for REPORT_CONTACT to determine severity
	var/report_target //Used for REPORT_RECLAIM_EQUIP types
	var/obj/reporter_assault_point // Used for REPORT_CASUALTY
	var/reporter_loc //Used for REPORT_CASUALTY

/datum/npc_report/New(var/type,var/reporter,var/report_obj_target,var/num_targets,var/reporter_assault,var/reporter_location)
	. = ..()
	report_type = type
	reporter_mob = reporter
	if(report_obj_target)
		report_target = report_obj_target
	if(num_targets)
		targets_reported = num_targets
	if(reporter_assault)
		reporter_assault_point = reporter_assault
	if(reporter_location)
		reporter_loc = reporter_location

/datum/npc_overmind

	var/overmind_active = 0
	var/overmind_name = "Overmind"

	//Typepaths to mob-types of different categories.
	var/constructor_types = list()
	var/combat_types = list()
	var/support_types = list()
	//End Mob-Type categories//

	var/list/reports = list()

	var/list/constructor_troops = list()
	var/list/combat_troops = list()
	var/list/support_troops = list()
	var/list/other_troops = list()

	var/list/assigned_taskpoints = list() //Overmind should sort this as linkedTaskpoint = ListOfMobs.
	var/list/taskpoints = list() //List of taskpoints available (currently aka Assault markers) format: taskpoint = timecreated

	var/form_squad_searchrange = SQUADFORM_SEARCHRANGE

	var/comms_channel = RADIO_HUMAN
	var/comms_language = LANGUAGE_ENGLISH
	var/next_comms_at = 0

/datum/npc_overmind/proc/create_comms_message(var/message,var/override = 0, var/mob/living/source_mob)
	if(isnull(comms_channel))
		return
	if(!override && world.time < next_comms_at)
		return
	GLOB.global_announcer.autosay(message, source_mob ? source_mob.name : overmind_name, comms_channel, comms_language)
	next_comms_at = world.time + RADIO_COMMS_DELAY

/datum/npc_overmind/proc/create_report(var/report_type,var/mob/reporter,var/target_num = null,var/report_targ = null,var/reporter_assault_point = null,var/reporter_loc)
	reports += new /datum/npc_report (report_type,reporter,report_targ,target_num,reporter_assault_point)

/datum/npc_overmind/proc/get_taskpoint_assigned(var/mob/m)
	for(var/taskpoint in assigned_taskpoints)
		if(m in assigned_taskpoints[taskpoint])
			return taskpoint
	return null

/datum/npc_overmind/proc/create_taskpoint(var/turf/loc_create)
	var/obj/assault_target = new /obj/effect/landmark/assault_target (loc_create)
	taskpoints[assault_target] = world.time
	return assault_target

/datum/npc_overmind/proc/update_taskpoint_timeout(var/obj/taskpoint,var/timeout =  TASKPOINT_TIMEOUT_UPDATE_DELAY)
	if(taskpoint in taskpoints)
		taskpoints[taskpoint] = world.time + timeout

/datum/npc_overmind/proc/is_type_list(var/checked_atom,var/list/our_list)
	for(var/type in our_list)
		if(istype(checked_atom,type))
			return 1
	return 0

/datum/npc_overmind/proc/get_tasked_troops()
	. = list()
	for(var/taskpoint in assigned_taskpoints)
		var/list/task_troops = assigned_taskpoints[taskpoint]
		. += task_troops

/datum/npc_overmind/proc/create_taskpoint_assign(var/mob/leader,var/obj/taskpoint,var/task_type,var/severity = 1,var/search_range = form_squad_searchrange)
	var/required_troops = list(0,0,0,0) //constructor,combat,support,other
	switch (task_type)
		if("combat")
			required_troops = COMBAT_TROOPS_REQUIRED
		if("construct")
			required_troops = CONSTRUCTOR_TROOPS_REQUIRED
		if("reinforcement")
			required_troops = REINFORCEMENT_TROOPS_REQUIRED
	if(severity > 1)
		for(var/num in required_troops)
			num *= severity

	var/turf/leader_turf
	if(isnull(leader))
		leader_turf = taskpoint.loc
	else
		leader_turf = leader.loc
	var/list/inrange_squadmembers = list()
	var/list/chosen_squadmembers = list(leader)
	for(var/mob/m in range(search_range,leader_turf))
		if(m == leader)
			continue
		inrange_squadmembers += m
	inrange_squadmembers &= (constructor_troops + combat_troops + support_troops + other_troops)
	inrange_squadmembers -= get_tasked_troops()
	if(inrange_squadmembers.len == 0)
		return
	for(var/mob/living/simple_animal/hostile/m in inrange_squadmembers)
		var/is_chosen = 0
		if(required_troops[1] > 0 && m in constructor_troops)
			is_chosen = 1
			required_troops[1]--
		if(required_troops[2] > 0 && m in combat_troops)
			is_chosen = 1
			required_troops[2]--
		if(required_troops[3] > 0 && m in support_troops)
			is_chosen = 1
			required_troops[3]--
		if(required_troops[4] > 0)
			is_chosen = 1
			required_troops[4]--
		if(is_chosen)
			chosen_squadmembers += m
			m.assault_target_type = null //Assume control over tasked members, just in case they were spawned before the overmind activated.

	assign_taskpoint(taskpoint,chosen_squadmembers)

/datum/npc_overmind/proc/taskpoint_exists_for_loc(var/turf/loc_checked)
	for(var/obj/t in taskpoints)
		if(t.loc == loc_checked)
			return 1
	return 0

/datum/npc_overmind/proc/process_contact_report(var/datum/npc_report/report)
	if(isnull(report.reporter_mob) || isnull(report.reporter_mob.target_mob))
		return
	var/mob_squad = get_taskpoint_assigned(report.reporter_mob)
	if(mob_squad && report.reporter_mob.target_mob) //Only bother trying to retask if our mob has a target.
		for(var/mob/living/simple_animal/hostile/m in mob_squad)
			if(!m.target_mob)
				m.target_mob = report.reporter_mob.target_mob
				update_taskpoint_timeout(mob_squad)
	else if(!mob_squad && report.reporter_mob.target_mob)
		if(taskpoint_exists_for_loc(report.reporter_mob.target_mob.loc))
			return
		else
			var/obj/taskpoint = create_taskpoint(report.reporter_mob.target_mob.loc)
			create_comms_message("Hostile Contact at [taskpoint.loc.loc]. Engaging.", 0, report.reporter_mob)
			create_taskpoint_assign(report.reporter_mob,taskpoint,"combat",max(1,report.targets_reported/SINGLESQUAD_MAXTARGET_HANDLE))

/datum/npc_overmind/proc/process_casualty_report(var/datum/npc_report/report)

	constructor_troops -= report.reporter_mob
	combat_troops -= report.reporter_mob
	support_troops -= report.reporter_mob
	other_troops -= report.reporter_mob

	var/list/squad_assigned = assigned_taskpoints[report.reporter_assault_point]
	if(isnull(squad_assigned))
		return
	var/list/valid_squadmembers = squad_assigned.Copy()
	valid_squadmembers &= (constructor_troops + combat_troops + support_troops + other_troops)
	if(isnull(valid_squadmembers) || valid_squadmembers.len == 0)
		squad_assigned.Cut()
		return
	var/obj/reporter_taskpoint = create_taskpoint(report.reporter_loc)
	create_comms_message("Taking casualties at [reporter_taskpoint.loc.loc].", 0, report.reporter_mob)
	create_taskpoint_assign(pick(valid_squadmembers),reporter_taskpoint,"reinforcement",max(1,report.targets_reported/SINGLESQUAD_MAXTARGET_HANDLE),form_squad_searchrange*3)
	update_taskpoint_timeout(report.reporter_assault_point)
	update_taskpoint_timeout(reporter_taskpoint)

/datum/npc_overmind/proc/process_reports()
	for(var/datum/npc_report/report in reports)
		switch(report.report_type)
			if(REPORT_CONTACT)
				process_contact_report(report)
			if(REPORT_CASUALTY)
				process_casualty_report(report)
			//if(REPORT_CONSTRUCT)
				//TODO: CONSTRUCTOR DISPATCH CODE. INCLUDES BUILDER MOBS.
			//if(REPORT_RECLAIM_EQUIP)
				//TODO: EQUIPMENT RECLAMATION.
			//if(REPORT_SUPPORT_TEAM_REQ)
				//TODO: REQUESTING SUPPORT TEAMS.
		reports -= report
		qdel(report)

/datum/npc_overmind
	var/prune_index = 1

/datum/npc_overmind/proc/prune_trooplists()
	var/list/list_prune = combat_troops
	var/checks = 0
	var/checks_max = min(list_prune.len, 6)
	while(checks < checks_max && list_prune.len)
		checks++
		if(prune_index > list_prune.len)
			prune_index = 1
		var/mob/living/simple_animal/hostile/entry_mob = list_prune[prune_index]
		if(entry_mob && entry_mob.health > 0)
			prune_index++
			continue
		list_prune.Cut(prune_index, prune_index + 1)

/datum/npc_overmind/proc/unassign_taskpoint(var/obj/taskpoint)
	var/squad_assigned = assigned_taskpoints[taskpoint]
	assigned_taskpoints -= taskpoint
	for(var/mob/living/simple_animal/hostile/m in squad_assigned)
		m.last_assault_target = m.assault_target
		m.assault_target = null
	return squad_assigned

/datum/npc_overmind/proc/assign_taskpoint(var/taskpoint,var/list/squad)
	var/list/current_squad = assigned_taskpoints[taskpoint]
	if(current_squad)
		current_squad += squad
	else
		assigned_taskpoints[taskpoint] = squad
	for(var/mob/living/simple_animal/hostile/m in squad)
		m.assault_target = taskpoint

/datum/npc_overmind/proc/prune_taskpoints()
	for(var/taskpoint in taskpoints)
		if(!(taskpoint in assigned_taskpoints) || (world.time > taskpoints[taskpoint] + TASKPOINT_TIMEOUT_DELAY))
			if(taskpoint in assigned_taskpoints)
				unassign_taskpoint(taskpoint)
			taskpoints -= taskpoint
			qdel(taskpoint)

/datum/npc_overmind/proc/process()
	prune_taskpoints()
	prune_trooplists()
	process_reports()
	if(overmind_active == 0)
		GLOB.processing_objects -= src

/datum/npc_overmind/flood
	overmind_name = "Gravemind"
	constructor_types = list(/mob/living/simple_animal/hostile/builder_mob/flood)
	combat_types = list(/mob/living/simple_animal/hostile/flood/combat_form,\
		/mob/living/simple_animal/hostile/flood/infestor,\
		/mob/living/simple_animal/hostile/flood/carrier)
	comms_channel = null

/obj/structure/overmind_controller
	name = "overmind controller"
	var/controlling_overmind = null

/obj/structure/overmind_controller/proc/create_overmind()

/obj/structure/overmind_controller/proc/delete_overmind()

/obj/structure/overmind_controller/Initialize()
	create_overmind()
	. = ..()

/obj/structure/overmind_controller/Destroy()
	delete_overmind()
	. = ..()

/obj/structure/overmind_controller/flood/create_overmind()
	if(!GLOB.flood_overmind)
		GLOB.flood_overmind = new()
		controlling_overmind =  GLOB.flood_overmind
		GLOB.processing_objects |= GLOB.flood_overmind
		GLOB.flood_overmind.overmind_active = 1
		GLOB.flood_overmind.reports.Cut() //We're likely activating the overmind here. Cut all previous reports out, they're likely outdated.

/obj/structure/overmind_controller/flood/delete_overmind()
	GLOB.flood_overmind.overmind_active = 0

#undef REPORT_CONTACT
#undef REPORT_CONSTRUCT
#undef REPORT_RECLAIM_EQUIP
#undef REPORT_CASUALTY
#undef REPORT_SUPPORT_TEAM_REQ

#undef SQUADFORM_SEARCHRANGE
#undef TASKPOINT_TIMEOUT_DELAY
#undef TASKPOINT_TIMEOUT_UPDATE_DELAY
#undef SINGLESQUAD_MAXTARGET_HANDLE

#undef COMBAT_TROOPS_REQUIRED
#undef CONSTRUCTOR_TROOPS_REQUIRED
#undef REINFORCEMENT_TROOPS_REQUIRED

#undef RADIO_COMMS_DELAY
