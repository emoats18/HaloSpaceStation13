#define STALEMATE_TIMER 60 MINUTES
#define BASE_ASSAULT_ONEFLANK_THRESHOLD 15
#define BASE_ASSAULT_TWOFLANK_THRESHOLD 30
#define RESPAWN_TIME 5

/datum/game_mode/base_assault_innie
	name = "Base Assault URF"
	config_tag = "base_assault_innie"
	round_description = "Assault a well-defended UNSC base."
	extended_round_description = "Assault a well defended UNSC base and plant a bomb."
	probability = 1
	ship_lockdown_duration = 12 MINUTES
	faction_balance = list(/datum/faction/insurrection,/datum/faction/unsc)
	var/stalemate_at = 0
	var/defenders = "The UNSC"
	var/attackers = " The URF"
	var/winning_side = "error"
	var/list/flank_tags = list("rightflank","leftflank","midlane")

/datum/game_mode/base_assault_innie/pre_setup()
	. = ..()
	stalemate_at = world.time + STALEMATE_TIMER
	do_flank_poplock()

/datum/game_mode/base_assault_innie/proc/do_flank_poplock()
	if(flank_tags.len == 0)
		return
	var/flanks_close = 2
	if(GLOB.clients.len > BASE_ASSAULT_ONEFLANK_THRESHOLD)
		flanks_close = 1
	else if(GLOB.clients.len > BASE_ASSAULT_TWOFLANK_THRESHOLD)
		flanks_close = 0
	if(flanks_close > 0)
		for(var/i = 1 to flanks_close)
			var/tag_close = "landmark*[pick(flank_tags)]"
			var/obj/rockspawn_mark = locate(tag_close)
			while(rockspawn_mark)
				var/turf/rockspawn_loc = rockspawn_mark.loc
				if(rockspawn_loc)
					rockspawn_loc.ChangeTurf(/turf/unsimulated/mineral)
				qdel(rockspawn_mark)
				rockspawn_mark = locate(tag_close)

/datum/game_mode/base_assault_innie/proc/get_defender_loss_status()
	var/obj/effect/overmap/base = GLOB.UNSC.get_base()
	if(!base || isnull(base.loc) || base.superstructure_failing > 0)
		return 1
	return 0

/datum/game_mode/base_assault_innie/proc/get_attacker_loss_status()
	var/obj/effect/overmap/base = GLOB.INSURRECTION.get_flagship()
	if(!base || isnull(base.loc) || base.superstructure_failing > 0)
		return 1
	return 0

/datum/game_mode/base_assault_innie/check_finished()
	if(world.time >= stalemate_at)
		winning_side = "Stalemate! [defenders] have attained a minor victory!"
		return 1
	if(get_defender_loss_status())
		winning_side = attackers
		return 1
	if(get_attacker_loss_status())
		winning_side = defenders
		return 1
	return 0

/datum/game_mode/base_assault_innie/declare_completion()
	. = ..()
	to_world("<span class = 'danger'>The winning faction was: [winning_side]</span>")

#undef STALEMATE_TIMER
#undef BASE_ASSAULT_ONEFLANK_THRESHOLD
#undef BASE_ASSAULT_TWOFLANK_THRESHOLD



