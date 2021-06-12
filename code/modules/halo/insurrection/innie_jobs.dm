
/datum/job/geminus_innie
	title = "Insurrectionist"
	spawn_faction = "Insurrection"
	latejoin_at_spawnpoints = 1
	total_positions = -1
	spawn_positions = -1
	generate_email = 1
	account_allowed = 1
	access = list(access_innie)
	outfit_type = /decl/hierarchy/outfit/job/geminus_innie
	//outfit_type = /decl/hierarchy/outfit/job/colonist/geminus_innie
	selection_color = "#ff0000"
	alt_titles = list(\
	"Insurrectionist Ship Crew",
	"Insurrectionist Technician",
	"Insurrectionist Machine Gunner",
	"Insurrectionist Field Medic",
	"Insurrectionist Bartender",
	"Insurrectionist Janitor",
	"Insurrectionist Breacher",
	"Insurrectionist Engineer",
	"Insurrectionist Guard",
	"Insurrectionist Negotiator",
	"Insurrectionist Interrogator",
	"Insurrectionist Tracker",
	"Insurrectionist Trainer",
	"Insurrectionist Bombmaker",
	"Insurrectionist Mechanic",
	"Insurrectionist Pilot",
	"Insurrectionist Marksman",
	"Insurrectionist Trooper",
	"Insurrectionist Smuggler",\
	"Insurrectionist Broker",\
	"Insurrectionist Recruiter",\
	"Insurrectionist Saboteur",\
	"Insurrectionist Infiltrator")
	spawnpoint_override = "Innie Base Spawns"
	whitelisted_species = list(/datum/species/human)
	loadout_allowed = TRUE
	var/datum/antagonist/geminus_insurrectionist/antag

/datum/job/geminus_innie/get_email_domain()
	return "geminus.net"

/datum/job/geminus_innie/New()
	. = ..()
	antag = all_antag_types()["Geminus Insurrectionist"]

/datum/job/geminus_innie/equip(var/mob/living/carbon/human/H, var/alt_title, var/datum/mil_branch/branch)
	. = ..()

	antag.add_antagonist_mind(H.mind, 1, "Geminus Insurrectionist")

/obj/effect/landmark/start/geminus_innie
	name = "Insurrectionist"

/datum/job/geminus_innie/officer
	title = "Insurrectionist Officer"
	spawn_faction = "Insurrection"
	open_slot_on_death = 1
	track_players = 1
	latejoin_at_spawnpoints = 1
	total_positions = 2
	spawn_positions = 2
	access = list(access_innie, access_innie_boss)
	selection_color = "#ff0000"
	alt_titles = null

/datum/job/geminus_innie/officer/equip(var/mob/living/carbon/human/H, var/alt_title, var/datum/mil_branch/branch)
	. = ..()

	for(var/datum/mind/player in antag.faction_members)
		to_chat(player.current,"<span class='info'>[title] [H] has arrived at the base.</span>")

/datum/job/geminus_innie/commander
	title = "Insurrectionist Commander"
	department_flag = COM
	spawn_faction = "Insurrection"
	latejoin_at_spawnpoints = 1
	track_players = 1
	total_positions = 1
	spawn_positions = 1
	access = list(access_innie, access_innie_boss)
	selection_color = "#ff0000"
	//faction_whitelist = "Insurrection"
	spawnpoint_override = "Innie Base Spawns"
	alt_titles = null
	outfit_type = /decl/hierarchy/outfit/job/geminus_innie_leader

/datum/job/geminus_innie/commander/equip(var/mob/living/carbon/human/H, var/alt_title, var/datum/mil_branch/branch)
	. = ..()

	for(var/datum/mind/player in antag.faction_members)
		to_chat(player.current,"<span class='info'>[title] [H] has arrived at the base.</span>")

/datum/job/geminus_innie/orion_defector
	title = "Insurrectionist Orion Defector"
	outfit_type = /decl/hierarchy/outfit/job/colonist/geminus_innie_orion_defector
	whitelisted_species = list(/datum/species/orion)
	total_positions = 2
	spawn_positions = 2
	spawnpoint_override = "Innie Base Spawns"
	//faction_whitelist = "Insurrection"

/datum/job/insurrectionist_ai
	title = "Insurrectionist AI"
	spawn_faction = "Insurrection"
	selection_color = "#800000"
	total_positions = 1
	spawn_positions = 1
	outfit_type = /decl/hierarchy/outfit/halo_ai_smart
	//faction_whitelist = "Insurrection"
	whitelisted_species = list()
