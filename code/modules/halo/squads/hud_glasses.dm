
/* SQUAD WAYPOINTS */

/obj/item/clothing/glasses/hud/tactical
	name = "Tactical Hud"
	desc = "Provides vital tactical information."
	icon = 'code/modules/halo/squads/hud_glasses.dmi'
	icon_state = "hud_visor"
	var/list/known_waypoints = list()
	var/list/waypoint_pointers = list()
	var/mob/last_user
	armor = list(melee = 5, bullet = 5, laser = 0, energy = 0, bomb = 5, bio = 0, rad = 0)
	var/enable_camera = TRUE
	var/camera_status = 0

/obj/item/clothing/glasses/hud/tactical/New()
	. = ..()
	//setup_nightvision()
	GLOB.emp_candidates.Add(src)

/obj/item/clothing/glasses/hud/tactical/Destroy()
	GLOB.emp_candidates.Remove(src)
	. = ..()

/obj/item/clothing/glasses/hud/tactical/examine(var/mob/user)
	. = ..()
	if(camera_status & BROKEN)
		to_chat(user,"<span class='warning'>[src]'s remote camera has been destroyed!</span>")
	else if(camera_status & EMPED)
		to_chat(user,"<span class='notice'>Something has temporarily disrupted [src]'s remote camera!</span>")

/obj/item/clothing/glasses/hud/tactical/verb/toggle_camera()
	set name = "Toggle Remote Camera"
	set category = "Object"
	set src in usr
	..()
	if(camera_status & BROKEN)
		to_chat(usr,"<span class='notice'>[src]'s remote camera has been destroyed!</span>")
	else if(camera_status & EMPED)
		to_chat(usr,"<span class='notice'>Something has temporarily disrupted [src]'s remote camera!</span>")
	else
		enable_camera = !enable_camera
		to_chat(usr,"<span class='info'>You [enable_camera ? "en" : "dis"]able [src]'s remote camera.</span>")
/*
/obj/item/clothing/glasses/hud/tactical/ex_act(var/severity)
	switch(severity)
		if(1)
			camera_status |= BROKEN
			enable_camera = FALSE
		if(2)
			if(prob(50))
				camera_status |= BROKEN
				enable_camera = FALSE
		if(3)
			if(prob(25))
				camera_status |= BROKEN
				enable_camera = FALSE
*/
/obj/item/clothing/glasses/hud/tactical/emp_act(var/severity)
	//visual effect
	var/image/I = image('icons/effects/effects.dmi', src, "empdisable")
	overlays += I
	show_image(src.loc, I)
	spawn(30)
		overlays -= I
		qdel(I)

	//disable camera
	enable_camera = FALSE
	camera_status |= EMPED


	//disable nightvision
	if(nv_enabled)
		nv_enabled = FALSE

	//update the visual effect
	var/mob/living/carbon/human/user = src.loc
	if(istype(user) && user.glasses == src)
		reset_effect(user)

	//reset it
	spawn(60 + (severity * 20))
		enable_camera = TRUE
		camera_status &= ~EMPED

	. = ..()

/obj/item/clothing/glasses/hud/tactical/proc/get_loc_used()
	if(!isturf(loc))
		return get_turf(loc)
	else
		return loc

/obj/item/clothing/glasses/hud/tactical/proc/update_known_waypoints(var/list/new_waypoint_list)
	known_waypoints = new_waypoint_list.Copy()
	process_hud()

/obj/item/clothing/glasses/hud/tactical/proc/remove_pointer(var/mob/user,var/waypoint)
	var/pointer = waypoint_pointers[waypoint]
	waypoint_pointers -= waypoint
	if(user && user.client && user.client.screen)
		user.client.screen -= pointer
	qdel(pointer)

/obj/item/clothing/glasses/hud/tactical/proc/remove_all_pointers(var/mob/user)
	if(!user.client)
		return
	for(var/point in waypoint_pointers)
		remove_pointer(user,point)

/obj/item/clothing/glasses/hud/tactical/proc/process_hud_pointers() //This is for directional pointers around the character, for waypoints off-screen.
	if(!isnull(last_user))
		remove_all_pointers(last_user)
		last_user = null
	var/mob/user = loc
	if(!istype(user))
		return
	if(isnull(user.client))
		return
	last_user = user
	for(var/obj/effect/waypoint_holder/waypoint in known_waypoints)
		var/dist_to = get_dist(waypoint,get_loc_used())
		if(dist_to == 0) //Don't render it if we're right on top of it. It'd just get in the way.
			continue
		if(dist_to <= user.client.view)
			process_visible_marker(waypoint,user)
			continue
		var/dir_to_point = get_dir(get_loc_used(),waypoint)
		var/turf/waypoint_render_loc = get_step(get_loc_used(),dir_to_point)
		var/image/pointer = waypoint_pointers[waypoint]
		if(pointer)
			pointer.loc = waypoint_render_loc
			pointer.dir = dir_to_point
		else
			pointer = image(waypoint.icon,waypoint_render_loc,waypoint.waypoint_icon,,dir_to_point)
			pointer.name = waypoint.waypoint_name
			pointer.mouse_opacity = 0
			pointer.alpha = 150
			pointer.plane = HUD_PLANE
			pointer.layer = HUD_ABOVE_ITEM_LAYER
			waypoint_pointers[waypoint] = pointer
			to_chat(user,pointer)

/obj/item/clothing/glasses/hud/tactical/proc/process_visible_marker(var/obj/effect/waypoint_holder/waypoint,var/mob/user) //This is for waypoints the player can currently see on-screen
	if(waypoint_pointers[waypoint])
		remove_pointer(user,waypoint)
	var/image/pointer = image(waypoint.icon,waypoint.loc,"[waypoint.waypoint_icon]_onscreen")
	pointer.name = waypoint.waypoint_name
	pointer.mouse_opacity = 0
	pointer.alpha = 150
	pointer.plane = HUD_PLANE
	pointer.layer = HUD_ABOVE_ITEM_LAYER
	waypoint_pointers[waypoint] = pointer
	to_chat(user,pointer)

/obj/item/clothing/glasses/hud/tactical/process_hud()
	process_hud_pointers()

/* NIGHT VISION */

#define NV_LAYER 6
#define VISION_CONE_LAYER 7

/obj/item/clothing/glasses/hud/tactical
	var/nv_enabled = 0
	var/nv_screen_colour = /obj/screen/fullscreen/night_vision/green
	var/nv_screen_impair = /obj/screen/fullscreen/night_vision/cone
	action_button_name = "Toggle HUD Night Vision"
	var/image/vision_cone
	var/limit_ui_entire_screen = 0
	var/output_visioncone = 0

/obj/item/clothing/glasses/hud/tactical/ui_action_click()
	toggle_nv()

/obj/item/clothing/glasses/hud/tactical/verb/toggle_nv()
	set name = "Toggle HUD Night Vision"
	set src in usr.contents
	set category = "Object"

	var/mob/living/carbon/human/user = usr

	if(camera_status & EMPED)
		to_chat(user,"<span class='notice'>Something has temporarily disrupted [src]'s night vision!</span>")
		return

	//swap the setting
	nv_enabled = !nv_enabled

	//tell the user
	to_chat(user,"\icon[src] <span class='[nv_enabled ? "notice" : "info"]'>You [nv_enabled ? "en" : "dis"]able night vision setting on [src].</span>")

	//update the visual effect
	if(user.glasses == src)
		reset_effect(user)

/obj/item/clothing/glasses/hud/tactical/proc/reset_effect(var/mob/living/user)
	if(nv_enabled)
		darkness_view = 3	//6 = fullscreen, because this adds to the default mob darkvision of 2 (1 = self tile only)
		see_invisible = SEE_INVISIBLE_NOLIGHTING
		enable_effect(user)

	else
		darkness_view = 0
		see_invisible = 0
		disable_effect(user)

/obj/item/clothing/glasses/hud/tactical/proc/enable_effect(var/mob/living/user)
	user.overlay_fullscreen("nv_colour", nv_screen_colour)
	user.overlay_fullscreen("nv_noise", /obj/screen/fullscreen/night_vision/noise)
	user.overlay_fullscreen("nv_visioncone", nv_screen_impair)
	/*
	for(var/screen_name in nv_screens)
		user.overlay_fullscreen(screen_name, nv_screens[screen_name])
		if(user.screens[screen_name].screen_loc == ui_entire_screen && limit_ui_entire_screen)
			user.screens[screen_name].screen_loc = "CENTER-[darkness_view-limit_ui_entire_screen],CENTER-[darkness_view-limit_ui_entire_screen] to \
				CENTER+[darkness_view+limit_ui_entire_screen],CENTER+[darkness_view+limit_ui_entire_screen]"
				*/
	//user.screens["nv_visioncone"].icon_state = "visioncone90-[darkness_view+1]"

	update_vision()

/obj/item/clothing/glasses/hud/tactical/proc/disable_effect(var/mob/user)
	user.clear_fullscreen("nv_colour", 0)
	user.clear_fullscreen("nv_noise", 0)
	user.clear_fullscreen("nv_visioncone", 0)

	update_vision()

/obj/item/clothing/glasses/hud/tactical/equipped(var/mob/living/carbon/human/user)
	. = ..()
	if(nv_enabled && user.glasses == src)
		//when we put the hud on
		enable_effect(user)

/obj/item/clothing/glasses/hud/tactical/dropped(mob/user as mob)
	. = ..()
	//when we take the hud off
	disable_effect(user)



/* SUBTYPES */

/obj/item/clothing/glasses/hud/tactical/odst_hud
	name = "ODST HUD"

/obj/item/clothing/glasses/hud/tactical/odst_hud/medic
	name = "ODST Medic HUD"

/obj/item/clothing/glasses/hud/tactical/odst_hud/medic/process_hud(var/mob/M)
	process_med_hud(M, 1)
	. = ..()

/obj/item/clothing/glasses/hud/tactical/spartan_hud
	name = "Spartan HUD"

/obj/item/clothing/glasses/hud/tactical/kigyar_nv
	name = "Kig-Yar Scout Helmet Night Vision"
	desc = "Scout Helmet night vision active."
	icon = KIGYAR_CLOTHING_PATH
	icon_state = "inbuilt_nv"
	species_restricted = list("Kig-Yar","Tvaoan Kig-Yar")
	nv_screen_colour = /obj/screen/fullscreen/night_vision/cyan
	nv_screen_impair = /obj/screen/fullscreen/night_vision/cone/better

/obj/item/clothing/glasses/hud/tactical/covenant
	icon_state = "hud_covie"
	nv_screen_colour = /obj/screen/fullscreen/night_vision/purple

/obj/item/clothing/glasses/hud/tactical/innie
	nv_screen_colour = /obj/screen/fullscreen/night_vision/red


/* SCREEN VISUAL EFFECTS */

// These don't strictly need to be /obj/screen/fullscreen but the mob code is already setup to nicely update them

/obj/screen/fullscreen/night_vision/cyan
	icon = 'icons/effects/ULIcons.dmi'
	icon_state = "0-5-7"
	screen_loc = ui_entire_screen
	plane = LIGHTING_PLANE
	layer = LIGHTING_LAYER

/obj/screen/fullscreen/night_vision/purple
	icon = 'icons/effects/ULIcons.dmi'
	icon_state = "0-0-7"
	screen_loc = ui_entire_screen
	alpha = 127
	plane = LIGHTING_PLANE
	layer = LIGHTING_LAYER

/obj/screen/fullscreen/night_vision/green
	icon = 'icons/effects/ULIcons.dmi'
	icon_state = "0-7-0"
	screen_loc = ui_entire_screen
	alpha = 127
	plane = LIGHTING_PLANE
	layer = LIGHTING_LAYER

/obj/screen/fullscreen/night_vision/red
	icon = 'icons/effects/ULIcons.dmi'
	icon_state = "7-0-0"
	screen_loc = ui_entire_screen
	alpha = 127
	plane = LIGHTING_PLANE
	layer = LIGHTING_LAYER

/obj/screen/fullscreen/night_vision/dark
	icon = 'icons/effects/ULIcons.dmi'
	icon_state = "0-0-0"
	screen_loc = ui_entire_screen
	plane = LIGHTING_PLANE
	layer = 11

/obj/screen/fullscreen/night_vision/noise
	icon = 'icons/effects/static.dmi'
	icon_state = "1 moderate"
	screen_loc = ui_entire_screen
	plane = LIGHTING_PLANE
	layer = LIGHTING_LAYER
	alpha = 150

/obj/screen/fullscreen/night_vision/noise/New()
	. = ..()
	icon_state = "[pick(1,9)] moderate"

/obj/screen/fullscreen/night_vision/cone
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "nvobscure"//"visioncone90-7"
	screen_loc = "CENTER-7,CENTER-7"
	plane = LIGHTING_PLANE
	layer = 11

/obj/screen/fullscreen/night_vision/cone/better
	icon_state = "nvobscurebetter"
