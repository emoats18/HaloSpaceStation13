
/obj/item/projectile/bullet/shotgun
	name = "slug"
	fire_sound = 'sound/weapons/gunshot/shotgun.ogg'
	damage = 50
	armor_penetration = 10
	shield_damage = 25

/obj/item/projectile/bullet/shotgun/beanbag		//because beanbags are not bullets
	name = "beanbag"
	check_armour = "melee"
	damage = 10
	agony = 50
	armor_penetration = 0
	embed = 0
	sharp = 0

//Overall less damage than slugs in exchange for more damage at very close range and more embedding
/obj/item/projectile/bullet/pellet/shotgun
	name = "shrapnel"
	fire_sound = 'sound/weapons/gunshot/shotgun.ogg'
	damage = 25
	armor_penetration = 10
	pellets = 8
	range_step = 1
	spread_step = 5