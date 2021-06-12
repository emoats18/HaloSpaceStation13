
/obj/item/weapon_attachment/sight
	name = "sight attachment"
	desc = "An attachment designed to replace or augment your gun's sight."
	icon = 'code/modules/halo/icons/attachments/sights.dmi'
	icon_state = "sight"
	weapon_slot = "sight"
	var/zoom_amount = 1
	var/is_variable = 0

/obj/item/weapon_attachment/sight/apply_attachment_effects(var/obj/item/weapon/gun/gun)
	. = ..()
	gun.verbs += /obj/item/weapon/gun/proc/use_scope
	if(zoom_amount > 1)
		gun.scope_zoom_amount = zoom_amount
		gun.max_zoom_amount = zoom_amount
		gun.create_scope_actions(0)
		if(is_variable)
			gun.is_scope_variable = 1
			gun.verbs += /obj/item/weapon/gun/proc/verb_set_scope_zoom
			gun.create_scope_actions(1)

/obj/item/weapon_attachment/sight/remove_attachment_effects(var/obj/item/weapon/gun/gun)
	. = ..()
	gun.verbs -= /obj/item/weapon/gun/proc/use_scope
	gun.scope_zoom_amount = 0
	gun.max_zoom_amount = 0
	if(is_variable)
		gun.is_scope_variable = 0
		gun.verbs -= /obj/item/weapon/gun/proc/verb_set_scope_zoom


/obj/item/weapon_attachment/sight/rds
	name = "red dot sight"
	desc = "A red dot sight which provides an increase in accuracy, resulting in a tighter grouping of consecutive shots."
	icon_state = "red-dot-obj"

/obj/item/weapon_attachment/sight/acog
	name = "acog sight"
	desc = "An ACOG which provides an increase in accuracy, resulting in a tighter grouping of consecutive shots."
	icon_state = "acog-scope-obj"

/obj/item/weapon_attachment/sight/br55_scope
	name = "BR55 scope"
	desc = "A scope specific to the BR55 that allows 2x magnification."
	icon_state = "BR55-CarryHandle-Scope-obj"
	zoom_amount = 2

/obj/item/weapon_attachment/sight/M395_scope
	name = "M395 scope"
	desc = "A scope specific to the M395 that allows 3x magnification. Adjustable."
	icon_state = "M395-Scope"
	zoom_amount = 3
	is_variable = 1