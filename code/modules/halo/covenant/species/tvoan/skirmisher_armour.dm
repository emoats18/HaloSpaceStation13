
/obj/item/clothing/suit/armor/special/skirmisher
	name = "T\'Vaoan Skirmisher harness"
	desc = "A protective harness for use during combat by  T\'vaoan Kig'Yar."
	icon = 'code/modules/halo/covenant/species/tvoan/skirm_clothing.dmi'
	icon_state = "minor_obj"
	item_state = "minor"
	sprite_sheets = list("Tvaoan Kig-Yar" = 'code/modules/halo/covenant/species/tvoan/skirm_clothing.dmi')
	species_restricted = list("Tvaoan Kig-Yar")
	armor = list(melee = 55, bullet = 50, laser = 55, energy = 45, bomb = 40, bio = 25, rad = 25)
	armor_thickness_modifiers = list()
	body_parts_covered = ARMS|UPPER_TORSO|LOWER_TORSO
	matter = list("nanolaminate" = 1)

/obj/item/clothing/suit/armor/special/skirmisher/major
	name = "T\'Vaoan Major harness"
	icon_state = "major_obj"
	item_state = "major"

/obj/item/clothing/suit/armor/special/skirmisher/murmillo
	name = "T\'Vaoan Murmillo harness"
	icon_state = "murmillo_obj"
	item_state = "murmillo"

/obj/item/clothing/suit/armor/special/skirmisher/commando
	name = "T\'Vaoan Commando harness"
	icon_state = "commando_obj"
	item_state = "commando"
	specials = list(/datum/armourspecials/holo_decoy)

/obj/item/clothing/suit/armor/special/skirmisher/champion
	name = "T\'Vaoan Champion harness"
	icon_state = "champion_obj"
	item_state = "champion"
	specials = list(/datum/armourspecials/holo_decoy)
