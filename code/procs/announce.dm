/var/datum/announcement/priority/priority_announcement = new(do_log = 0)
/var/datum/announcement/priority/command/command_announcement = new(do_log = 0, do_newscast = 1)
/var/datum/announcement/minor/minor_announcement = new(new_sound = 'sound/AI/commandreport.ogg',)

/datum/announcement
	var/title = "Attention"
	var/announcer = ""
	var/log = 0
	var/sound
	var/newscast = 0
	var/channel_name = "Announcements"
	var/announcement_type = "Announcement"
	var/list/faction_restrict
	var/fax_department
	var/species_restrict

/datum/announcement/priority
	title = "Priority Announcement"
	announcement_type = "Priority Announcement"

/datum/announcement/priority/security
	title = "Security Announcement"
	announcement_type = "Security Announcement"

/datum/announcement/New(var/do_log = 0, var/new_sound = null, var/do_newscast = 0)
	sound = new_sound
	log = do_log
	newscast = do_newscast

/datum/announcement/priority/command/New(var/do_log = 1, var/new_sound = 'sound/misc/notice2.ogg', var/do_newscast = 0)
	..(do_log, new_sound, do_newscast)
	title = "[command_name()] Update"
	announcement_type = "[command_name()] Update"

/datum/announcement/proc/Announce(var/message as text, var/new_title = "", var/new_sound = null, var/do_newscast = newscast, var/msg_sanitized = 0)
	if(!message)
		return
	var/message_title = new_title ? new_title : title
	var/message_sound = new_sound ? new_sound : sound

	if(!msg_sanitized)
		message = sanitize(message, extra = 0)
	message_title = sanitizeSafe(message_title)

	var/msg = FormMessage(message, message_title)
	var/list/announce_mobs = get_announcement_mobs()
	for(var/mob/M in announce_mobs)
		to_chat(M, msg)
		if(message_sound)
			sound_to(M, message_sound)

	if(do_newscast)
		NewsCast(message, message_title)

	if(log)
		log_say("[key_name(usr)] has made \a [announcement_type]: [message_title] - [message] - [announcer]")
		message_admins("[key_name_admin(usr)] has made \a [announcement_type].", 1)

/datum/announcement/proc/get_announcement_mobs()
	var/list/announce_mobs = list()
	. = announce_mobs
	for(var/mob/M in GLOB.player_list)
		//ghosts can always hear
		if(isghost(M))
			announce_mobs.Add(M)
		else if(!istype(M,/mob/new_player))
			if(faction_restrict && M.faction != faction_restrict)
				continue
			if(species_restrict)
				var/mob/living/carbon/human/H = M
				if(!istype(H) || !H.species || (H.species.name != species_restrict))
					continue
			announce_mobs.Add(M)

datum/announcement/proc/FormMessage(message as text, message_title as text)
	. = "<h2 class='alert'>[message_title]</h2>"
	. += "<br><span class='alert'>[message]</span>"
	if (announcer)
		. += "<br><span class='alert'> -[html_encode(announcer)]</span>"

datum/announcement/minor/FormMessage(message as text, message_title as text)
	. = "<b>[message]</b>"

datum/announcement/priority/FormMessage(message as text, message_title as text)
	. = "<h1 class='alert'>[message_title]</h1>"
	. += "<br><span class='alert'>[message]</span>"
	if(announcer)
		. += "<br><span class='alert'> -[html_encode(announcer)]</span>"
	. += "<br>"

datum/announcement/priority/command/FormMessage(message as text, message_title as text)
	. = "<h1 class='alert'>[command_name()] Update</h1>"
	if (message_title)
		. += "<br><h2 class='alert'>[message_title]</h2>"

	. += "<br><span class='alert'>[message]</span><br>"
	. += "<br>"

datum/announcement/priority/security/FormMessage(message as text, message_title as text)
	. = "<font size=4 color='red'>[message_title]</font>"
	. += "<br><font color='red'>[message]</font>"

datum/announcement/proc/NewsCast(message as text, message_title as text)
	if(!newscast)
		return

	var/datum/news_announcement/news = new
	news.channel_name = channel_name
	news.author = announcer
	news.message = message
	news.message_type = announcement_type
	news.can_be_redacted = 0
	announce_newscaster_news(news)

/proc/GetNameAndAssignmentFromId(var/obj/item/weapon/card/id/I)
	// Format currently matches that of newscaster feeds: Registered Name (Assigned Rank)
	return I.assignment ? "[I.registered_name] ([I.assignment])" : I.registered_name

/proc/level_seven_announcement()
	GLOB.using_map.level_x_biohazard_announcement(7)

/proc/ion_storm_announcement()
	command_announcement.Announce("It has come to our attention that the [station_name()] passed through an ion storm.  Please monitor all electronic equipment for malfunctions.", "Anomaly Alert")

/proc/AnnounceArrival(var/mob/living/carbon/human/character, var/datum/job/job, var/join_message)
	if(!istype(job) || !job.announced)
		return
	if (ticker.current_state != GAME_STATE_PLAYING)
		return

	//call the gamemode version here in case they want to override it
	//by default, the gamemode calls AnnounceArrivalSimple()
	return ticker.mode.AnnounceLateArrival(character, job, join_message)

/proc/AnnounceArrivalSimple(var/name, var/rank = "visitor", var/join_message = "has arrived on the [station_name()]", var/channel_name, var/language_name)
	GLOB.global_announcer.autosay("[name], [rank], [join_message].", "Arrivals Computer", channel_name, language_name)

/proc/get_announcement_frequency(var/datum/job/job)
	return job.get_arrivals_channel()
	/*
	if(job.department_flag & (COM | CIV | MSC))
		return "Common"
	if(job.department_flag & (SUP | CRG))
		return "Supply"
	if(job.department_flag & SPT)
		return "Command"
	if(job.department_flag & SEC)
		return "Security"
	if(job.department_flag & ENG)
		return "Engineering"
	if(job.department_flag & MED)
		return "Medical"
	if(job.department_flag & SCI)
		return "Science"
	if(job.department_flag & SRV)
		return "Service"
	return "System"
	*/