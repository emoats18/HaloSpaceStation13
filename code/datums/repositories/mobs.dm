var/repository/mob/mob_repository = new()

/repository/mob
	var/list/mobs_

/repository/mob/New()
	..()
	mobs_ = list()

// A lite mob is unique per ckey and mob real name/ref (ref conflicts possible.. but oh well)
/repository/mob/proc/get_lite_mob(var/mob/M)
	. = mobs_[mob2unique(M)]
	if(!.)
		. = new/datum/mob_lite(M)
		mobs_[mob2unique(M)] = .

/datum/mob_lite
	var/name
	var/ref
	var/datum/client_lite/client
	var/assigned_role

/datum/mob_lite/New(var/mob/M)
	if(isnull(M))
		name = "Error"
		assigned_role = "Error"
		ref = null
		client = null
	else
		name = M ? (M.real_name ? M.real_name : M.name) : name
		assigned_role = M.mind ? M.mind.assigned_role : null
		ref = any2ref(M)
		client = client_repository.get_lite_client(M)

/datum/mob_lite/proc/key_name(var/pm_link = TRUE, var/check_if_offline = TRUE)
	return client.key_name(pm_link, check_if_offline)
