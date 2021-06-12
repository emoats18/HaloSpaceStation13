/datum/species/orion
	name = "Orion"
	name_plural = "Orion Subjects"
	spawn_flags = SPECIES_CAN_JOIN
	pain_mod = 0.9 //Slight reduction in pain recieved
	total_health = 220 //Slightly more health then a normal human
	metabolism_mod = 1.15 //Slightly faster metabolism
	darksight = 3 //Slightly better night vision!
	slowdown = -0.05 //Increased move speed.
	inherent_verbs = list()
	unarmed_types = list(/datum/unarmed_attack/spartan_punch)
	appearance_flags = HAS_HAIR_COLOR | HAS_SKIN_TONE | HAS_EYE_COLOR

	dodge_roll_delay = DODGE_ROLL_BASE_COOLDOWN - 1 SECOND

	//Spartan 1's have a bit better temperature tolerance
	siemens_coefficient = 0.9 //Better insulated against temp changes
	heat_discomfort_level = 355 //Normal human is 315
	cold_discomfort_level = 255 // Normal human is 285
	//Buff to temperature damage levels (5% per level)
	heat_level_1 = 380 //~107C
	heat_level_2 = 420 //147C
	heat_level_3 = 1050 //777C
	cold_level_1 = 247 //-26C
	cold_level_2 = 190 //-83C
	cold_level_3 = 114 //-159C
	blood_volume = 600 // Normal Human has 560
