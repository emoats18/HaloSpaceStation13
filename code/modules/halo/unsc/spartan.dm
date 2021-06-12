/datum/species/spartan
	name = "Spartan"
	name_plural = "Spartans"
	blood_color = "#A10808"
	flesh_color = "#FFC896"
	blurb = "The SPARTAN-II Program, originally known as the ORION Project Generation II,\
		 was part of the SPARTAN Program, an effort to produce elite soldiers through \
		 mechanical and biological augmentation. The Spartans would be combined with advanced\
		 MJOLNIR armour containing energy shielding and augmenting their physical abilities."
	icobase = 'code/modules/halo/unsc/r_Augmented_Human.dmi' //The DMI needed modification to fit the usual format (see other species' dmis)
	deform = 'code/modules/halo/unsc/r_Augmented_Human.dmi'
	icon_template = 'code/modules/halo/unsc/r_Augmented_Human_template.dmi'
	flags = NO_MINOR_CUT
	appearance_flags = HAS_HAIR_COLOR | HAS_SKIN_TONE | HAS_LIPS | HAS_EYE_COLOR
	total_health = 250 //Same base health as sangheili
	spawn_flags = SPECIES_CAN_JOIN
	brute_mod = 0.8 //Lower amount of brute damage taken than sangheili
	burn_mod = 0.8 //ditto for burn
	pain_mod = 0.8 //Lower pain damage taken than sangheili
	item_icon_offsets = list(list(1,0),list(1,0),null,list(1,0),null,null,null,list(1,0),null)
	inhand_icon_offsets = list(list(-2,0),list(2,0),null,list(0,0),null,null,null,list(0,0),null)
	slowdown = -0.1
	can_force_door = 1
	additional_langs = list(LANGUAGE_SIGN)
	inherent_verbs = list()
	unarmed_types = list(/datum/unarmed_attack/spartan_punch)

	metabolism_mod = 1.25 //Faster metabolism
	breath_pressure = 14.5 //Better lungs!
	darksight = 4 //Better night vision!
	explosion_effect_mod = 0.5

	//Spartans have a bit better temperature tolerance
	siemens_coefficient = 0.9 //Better insulated against temp changes
	heat_discomfort_level = 330 //57C
	cold_discomfort_level = T0C
	//Buff to temperature damage levels (5% per level)
	heat_level_1 = 380 //~107C
	heat_level_2 = 420 //147C
	heat_level_3 = 1050 //777C
	cold_level_1 = 247 //-26C
	cold_level_2 = 190 //-83C
	cold_level_3 = 114 //-159C

	//As of 2018-03-24 we're in 2525 - 2526, thus Spartans IIs were just augmented - updated as of server timeline moving to 2531
	min_age = 19
	max_age = 20

	//Spartan's have some better organs than normal humans. Also, we'll say the UNSC cut out their appendix already
	has_organ = list(
		BP_HEART =    /obj/item/organ/internal/heart/spartan,
		BP_LUNGS =    /obj/item/organ/internal/lungs,
		BP_LIVER =    /obj/item/organ/internal/liver/spartan,
		BP_KIDNEYS =  /obj/item/organ/internal/kidneys,
		BP_BRAIN =    /obj/item/organ/internal/brain,
		BP_EYES =     /obj/item/organ/internal/eyes/occipital_reversal
		)

	has_limbs =  list(
		BP_CHEST =  list("path" = /obj/item/organ/external/chest/augmented),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin/augmented),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/augmented),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/augmented),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/augmented),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/augmented),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/augmented),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/augmented),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/augmented),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/augmented),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/augmented)
		)

	equipment_slowdown_multiplier = 0.8

	roll_distance = 3
	per_roll_delay = 1.5 //Slightly faster than a human's dodge roll
	dodge_roll_delay = DODGE_ROLL_BASE_COOLDOWN - 2 SECOND

/datum/species/spartan/get_random_name(var/gender)
	var/name = ""
	if(gender == FEMALE)
		name = capitalize(pick(GLOB.first_names_female))
	else
		name = capitalize(pick(GLOB.first_names_male))
	name += "-"
	var/spartan_number = rand(1,150)
	if(spartan_number < 10)
		name += "00"
	else if(spartan_number < 100)
		name += "0"
	name += "[spartan_number]"
	return name

/datum/species/spartan/sanitize_name(name)
	return sanitizeName(name, allow_numbers=TRUE)

/datum/unarmed_attack/spartan_punch
    attack_verb = list("jabs", "slams", "punches", "knees", "kicks", "strikes")
    attack_noun = list("fist")
    eye_attack_text = "fingers"
    eye_attack_text_victim = "digits"
    damage = 20
