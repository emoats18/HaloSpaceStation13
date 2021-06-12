

/obj/machinery/overmap_weapon_console/deck_gun_control/plastorp_control
	name = "Plasma Torpedo Control Console"
	icon = 'code/modules/halo/overmap/weapons/covenant_consoles.dmi'
	icon_state = "covie_console"

/obj/machinery/overmap_weapon_console/deck_gun_control/plastorp_control/New()
	if(isnull(control_tag))
		control_tag = "plastorp_control - [z]"
	. = ..()

/obj/machinery/overmap_weapon_console/deck_gun_control/local/plastorp_control
	name = "Local Plasma Torpedo Control Console"
	icon = 'code/modules/halo/overmap/weapons/covenant_consoles.dmi'
	icon_state = "covie_console"
	fire_sound = 'code/modules/halo/sounds/plasma_torpedoes_fire.ogg'
	fired_projectile = /obj/item/projectile/overmap/missile/plas_torp
	deck_gun_area = null

/obj/machinery/overmap_weapon_console/deck_gun_control/local/plastorp_control/New()
	if(isnull(control_tag))
		control_tag = "plastorp_control - [z]"
	. = ..()

//Missile "deck gun"//
/obj/machinery/deck_gun/missile_pod/plasma_torpedo
	name = "Plasma Torpedo Launcher"
	desc = "Generates magnetic fields to channel and store the plasma needed for plasma torpedoes."
	icon = 'code/modules/halo/overmap/weapons/plasma_torpedo.dmi'
	icon_state = "plasma_pod"
	fire_sound = 'code/modules/halo/sounds/plasma_torpedoes_fire.ogg'
	fired_projectile = /obj/item/projectile/overmap/missile/plas_torp
	round_reload_time = 10 SECONDS
	rounds_loaded = 2
	max_rounds_loadable = 2
	tag_prefix = "plastorp_control"

/obj/machinery/deck_gun/missile_pod/plasma_torpedo/return_list_addto()
	return list(src,src)

//Projectiles//
/obj/item/projectile/overmap/missile/plas_torp
	name = "plasma torpedo"
	desc = "A ball of plasma contained within a magnetic field"
	icon = 'code/modules/halo/overmap/weapons/plasma_torpedo.dmi'
	icon_state = "plasma_torp_om_proj"
	ship_damage_projectile = /obj/item/projectile/plas_torp_damage_proj
	ship_hit_sound = 'code/modules/halo/sounds/plasma_torpedoes_impact.ogg'
	penetrating = 1
	damage = 100

/obj/item/projectile/plas_torp_damage_proj
	name = "plasma torpedo"
	desc = "A ball of plasma within a magnetic field"
	icon = 'code/modules/halo/overmap/weapons/plasma_torpedo.dmi'
	icon_state = "plasma_torp"
	penetrating = 1
	damage = 7 //It's a missile, it has no innate damage.

/obj/item/projectile/plas_torp_damage_proj/on_impact(var/atom/impacted)
	if(!istype(impacted,/obj/effect/shield))
		explosion(get_turf(loc),-1,4,3,5, adminlog = 0)
	var/obj/effect/overmap/sector/S = map_sectors["[src.z]"]
	S.adminwarn_attack()
	. = ..()
