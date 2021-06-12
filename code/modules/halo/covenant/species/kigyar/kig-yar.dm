/datum/species/kig_yar
	name = "Kig-Yar"
	name_plural = "Kig-Yar"
	blurb = "Ruutian Kig'Yar are the most commonly encountered species of Kig'Yar, known as Jackals. \
		They have an avian appearance and serve as light infantry in combat, being equipped with either \
		light weaponry and large energy defence point defence shields or (less frequently) marksman weaponry \
		due to their enhanced hearing and eyesight. Kig'Yar feud with Unggoy for status as the lowest ranked\
		members of the Covenant."
	flesh_color = "#FF9463"
	blood_color = "#532476"
	icobase = 'code/modules/halo/covenant/species/kigyar/r_kig-yar.dmi' //The DMI needed modification to fit the usual format (see other species' dmis)
	deform = 'code/modules/halo/covenant/species/kigyar/r_kig-yar.dmi'
	default_language = LANGUAGE_SANGHEILI
	language = LANGUAGE_SANGHEILI
	additional_langs = list(LANGUAGE_KIGYAR)
	radiation_mod = 0.6 //Covie weapons emit beta radiation. Resistant to 1/3 types of radiation.
	inherent_verbs = list(/mob/living/carbon/human/proc/focus_view)
	spawn_flags = SPECIES_CAN_JOIN
	flags = NO_MINOR_CUT
	appearance_flags = HAS_HAIR_COLOR | HAS_EYE_COLOR
	darksight = 6
	brute_mod = 1.1
	burn_mod = 1.1
	gluttonous = GLUT_ANYTHING
	item_icon_offsets = list(list(0,0),list(0,0),null,list(0,0),null,null,null,list(0,0),null)
	default_faction = "Covenant"
	unarmed_types = list(/datum/unarmed_attack/bird_punch)
	gibbed_anim = null
	dusted_anim = null

	has_limbs = list(
		BP_CHEST =  list("path" = /obj/item/organ/external/chest),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/kigyar),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/hollow_bones),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/hollow_bones),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/hollow_bones),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/hollow_bones),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/hollow_bones),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/hollow_bones),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/hollow_bones),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/hollow_bones)
		)

	pain_scream_sounds = list(\
		'code/modules/halo/sounds/species_pain_screams/kiggyscream_1.ogg',
		'code/modules/halo/sounds/species_pain_screams/kiggyscream_2.ogg',
		'code/modules/halo/sounds/species_pain_screams/kiggyscream_3.ogg',
		'code/modules/halo/sounds/species_pain_screams/kiggyscream_4.ogg',
		'code/modules/halo/sounds/species_pain_screams/kiggyscream_5.ogg')

GLOBAL_LIST_INIT(first_names_kig_yar, world.file2list('code/modules/halo/covenant/species/kigyar/first_kig-yar.txt'))

/mob/living/carbon/human/covenant/kigyar/New(var/new_loc)
	. = ..(new_loc,"Kig-Yar")

/obj/item/clothing/shoes/ruutian_boots/dropped(mob/user as mob)
	. = ..()
	if(isnull(src.gc_destroyed))
		qdel(src)

/datum/species/kig_yar/get_random_name(var/gender)
	return pick(GLOB.first_names_kig_yar)

/datum/species/kig_yar/equip_survival_gear(var/mob/living/carbon/human/H,var/extendedtank = 1)
	return

/datum/unarmed_attack/bird_punch
    attack_verb = list("claws", "kicks", "strikes", "slashes", "rips", "bites")
    attack_noun = list("talon")
    eye_attack_text = "talons"
    eye_attack_text_victim = "digits"
    damage = 0
    sharp = 1
    edge = 1

/datum/sprite_accessory/hair/kiggyhair/
		icon = 'code/modules/halo/covenant/species/kigyar/r_kig-yar.dmi'
		icon_state = "h_kiggyhair"
		name = "No Quills"
		species_allowed = list("Kig-Yar")
		gender = FEMALE

/datum/sprite_accessory/hair/kiggyhair/one
		icon = 'code/modules/halo/covenant/species/kigyar/r_kig-yar.dmi'
		icon_state = "h_kiggyhairone"
		name = "Long Quills"
		species_allowed = list("Kig-Yar")
		gender = MALE

/datum/sprite_accessory/hair/kiggyhair/two
		icon = 'code/modules/halo/covenant/species/kigyar/r_kig-yar.dmi'
		icon_state = "h_kiggyhairtwo"
		name = "Short Quills"
		species_allowed = list("Kig-Yar")
		gender = MALE

/obj/item/organ/external/head/kigyar
	eye_icon = "eyes_s"
	eye_icon_location = 'code/modules/halo/covenant/species/kigyar/r_kig-yar.dmi'

