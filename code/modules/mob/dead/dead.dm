/mob/dead/Login()
	. = ..()
	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

/mob/dead/Logout()
	update_z(null)
	return ..()

/mob/dead/forceMove(atom/destination)
	var/turf/old_turf = get_turf(src)
	var/turf/new_turf = get_turf(destination)
	if (old_turf?.z != new_turf?.z)
		onTransitZ(old_turf?.z, new_turf?.z)
	var/oldloc = loc
	loc = destination
	Moved(oldloc, NONE, TRUE)

/mob/dead/onTransitZ(old_z,new_z)
	..()
	update_z(new_z)

/mob/dead/proc/update_z(new_z) // 1+ to register, null to unregister
	if (registered_z != new_z)
		if (registered_z)
			SSmobs.dead_players_by_zlevel[registered_z] -= src
		if (client)
			if (new_z)
				SSmobs.dead_players_by_zlevel[new_z] += src
			registered_z = new_z
		else
			registered_z = null

/mob/dead/verb/respawn()
	set name = "Respawn"
	set category = "OOC"

	if (!(config.abandon_allowed))
		to_chat(usr, SPAN_WARNING("Respawn is disabled."))
		return
	if (!SSticker.mode)
		to_chat(usr, SPAN_WARNING("<b>You may not attempt to respawn yet.</b>"))
		return
	if (SSticker.mode.deny_respawn)
		to_chat(usr, SPAN_WARNING("Respawn is disabled for this roundtype."))
		return
	if(!MayRespawn(1, started_as_observer ? OBSERV_SPAWN_DELAY : config.respawn_delay))
		return

	to_chat(usr, SPAN_NOTICE("You can respawn now, enjoy your new life!"))
	to_chat(usr, SPAN_NOTICE("<b>Make sure to play a different character, and please roleplay correctly!</b>"))
	announce_ghost_joinleave(client, 0)

	var/mob/new_player/M = new /mob/new_player()
	M.key = key
	log_and_message_admins("has respawned.", M)
