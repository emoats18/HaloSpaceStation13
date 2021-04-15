
/datum/job/covenant/yanmee_minor
	title = "Yanme e Minor"
	total_positions = -1
	spawn_positions = -1
	outfit_type = /decl/hierarchy/outfit/yanmee/minor
	whitelisted_species = list(/datum/species/yanmee)

/datum/job/covenant/yanmee_major
	title = "Yanme e Major"
	total_positions = 2
	spawn_positions = 2
	open_slot_on_death = 1
	outfit_type = /decl/hierarchy/outfit/yanmee/major
	whitelisted_species = list(/datum/species/yanmee)

/datum/job/covenant/yanmee_ultra
	title = "Yanme e Ultra"
	total_positions = 1
	spawn_positions = 1
	outfit_type = /decl/hierarchy/outfit/yanmee/ultra
	access = list(access_covenant, access_covenant_command, access_covenant_slipspace, access_covenant_cargo)
	faction_whitelist = "Covenant"
	whitelisted_species = list(/datum/species/yanmee)
	pop_balance_mult = 1.5 //They have a shield.

/datum/job/covenant/yanmee_leader
	title = "Yanme e Leader"
	total_positions = 1
	spawn_positions = 1
	outfit_type = /decl/hierarchy/outfit/yanmee/leader
	access = list(access_covenant, access_covenant_command, access_covenant_slipspace, access_covenant_cargo)
	faction_whitelist = "Covenant"
	whitelisted_species = list(/datum/species/yanmee)
	pop_balance_mult = 1.5
