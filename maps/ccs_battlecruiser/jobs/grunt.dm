
/datum/job/opredflag_cov/grunt
	title = "Unggoy Minor"
	supervisors = "the Grunt Majors, Grunt Ultras and the Elites"
	outfit_type = /decl/hierarchy/outfit/unggoy
	selection_color = "#ff00ff"
	whitelisted_species = list(/datum/species/unggoy)
	spawn_positions = -1
	total_positions = -1
	track_players = 1

/datum/job/opredflag_cov/grunt/major
	title = "Unggoy Major"
	supervisors = "the Grunt Ultras and the Elites"
	outfit_type = /decl/hierarchy/outfit/unggoy/major
	open_slot_on_death = 1
	spawn_positions = 6
	total_positions = 6

/datum/job/opredflag_cov/grunt/ultra
	title = "Unggoy Ultra"
	supervisors = "the Elites"
	outfit_type = /decl/hierarchy/outfit/unggoy/ultra
	generate_email = 0
	open_slot_on_death = 1
	total_positions = 3
	spawn_positions = 3

/datum/job/opredflag_cov/grunt/specops
	title = "Special Operations Unggoy"
	supervisors = "the Elites"
	outfit_type = /decl/hierarchy/outfit/unggoy/specops
	open_slot_on_death = 1
	spawn_positions = 1
