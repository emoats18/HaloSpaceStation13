/datum/job/soe_commando
	title = "URF Commando"
	spawn_faction = "Insurrection"
	latejoin_at_spawnpoints = 1
	outfit_type = /decl/hierarchy/outfit/job/soe_commando
	alt_titles = list("URFC Initiate",\
	"URFC Trooper",\
	"URFC Corporal",\
	"URFC Surgeon")

	total_positions = 8
	spawn_positions = 8
	selection_color = "#ff0000"
	access = list(access_innie,access_innie_prowler,access_innie_asteroid, access_soe)
	//is_whitelisted = 1
	spawnpoint_override = "Innie Base Spawns"
	whitelisted_species = list(/datum/species/human)

/datum/job/soe_commando_officer
	title = "URF Commando Officer"
	spawn_faction = "Insurrection"
	latejoin_at_spawnpoints = 1
	outfit_type = /decl/hierarchy/outfit/job/soe_commando_officer
	alt_titles = list("URFC Sergeant",\
	"URFC Adjutant",\
	"URFC Lieutenant")

	total_positions = 2
	spawn_positions = 2
	selection_color = "#ff0000"
	access = list(access_innie,access_innie_prowler,access_innie_asteroid,access_innie_asteroid_boss, access_soe, access_soe_officer)
	//is_whitelisted = 1
	spawnpoint_override = "Innie Base Spawns"
	whitelisted_species = list(/datum/species/human)

/datum/job/soe_commando_captain
	title = "URF Commando Captain"
	spawn_faction = "Insurrection"
	latejoin_at_spawnpoints = 1
	outfit_type = /decl/hierarchy/outfit/job/soe_commando_captain
	alt_titles = list("URFC Commander",\
	"URFC Captain")

	total_positions = 1
	spawn_positions = 1
	selection_color = "#ff0000"
	access = list(access_innie,access_innie_prowler,access_innie_asteroid,access_innie_asteroid_boss,access_soe, access_soe_officer, access_soe_captain)
	//is_whitelisted = 1
	spawnpoint_override = "Innie Base Spawns"
	whitelisted_species = list(/datum/species/human)
