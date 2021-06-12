
//M739 Light Machine Gun

/obj/item/weapon/gun/projectile/m739_lmg
	name = "\improper M739 Light Machine Gun"
	desc = "Standard-issue squad automatic weapon, designed for use in heavy engagements. Takes 7.62mm box type magazines."
	icon = 'code/modules/halo/weapons/icons/Weapon Sprites.dmi'
	icon_state = "M739"
	item_state = "SAW"
	caliber = "7.62mm"
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/m739/m118
	allowed_magazines = list(/obj/item/ammo_magazine/m739)
	fire_sound = 'code/modules/halo/sounds/Assault_Rifle_Fire_New.wav'
	reload_sound = 'code/modules/halo/sounds/UNSC_Saw_Reload_Sound_Effect.ogg'
	one_hand_penalty = -1
	burst_accuracy = list(0, 0, -1, -1, -1, -2, -2, -2, -3, -3, 0, 0, -1, -1, -1, -2, -2, -2, -3, -3, 0, 0, -1, -1, -1, -2, -2, -2, -3, -3,0,0,-1)
	dispersion = list(0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 1.0, 1.0, 1.0, 1.2, 1.2, 1.2, 1.4, 1.4, 1.4, 1.6, 1.6, 1.6, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8)
	w_class = ITEM_SIZE_HUGE
	hud_bullet_row_num = 50
	hud_bullet_reffile = 'code/modules/halo/icons/hud_display/hud_bullet_2x5.dmi'
	wielded_item_state = "SAW-wielded"
	item_icons = list(
		slot_l_hand_str = 'code/modules/halo/weapons/icons/Weapon_Inhands_left.dmi',
		slot_r_hand_str = 'code/modules/halo/weapons/icons/Weapon_Inhands_right.dmi',
		)
	move_delay_malus = 1.5
	slowdown_general = 1

	sustain_time = 4.5 SECONDS
	sustain_delay = 1.5

/obj/item/weapon/gun/projectile/m739_lmg/update_icon()
	if(ammo_magazine)
		icon_state = "M739"
	else
		icon_state = "M739_unloaded"
	. = ..()

//Basic Magazine

/obj/item/ammo_magazine/m739
	name = "M739 box magazine"
	icon = 'code/modules/halo/weapons/icons/Weapon Sprites.dmi'
	icon_state = "M739mag"
	mag_type = MAGAZINE
	caliber = "7.62mm"
	max_ammo = 150
	multiple_sprites = 1
	w_class = ITEM_SIZE_NORMAL

//M118 Ammunition

/obj/item/ammo_magazine/m739/m118
	name = "M739 box magazine (7.62mm) M118"
	desc = "7.62x51mm M118 Full Metal Jacket Armour Piercing (FMJ-AP) box magazine for the M739 squad support weapon containing 150 shots."
	ammo_type = /obj/item/ammo_casing/m118

/obj/item/weapon/storage/box/large/m739_m118
	name = "box of M739 7.62mm M118 box magazines"
	startswith = list(/obj/item/ammo_magazine/m739/m118 = 3)
