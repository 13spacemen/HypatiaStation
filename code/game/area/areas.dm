/var/global/list/active_areas = list()
/var/global/list/all_areas = list()

// This bit is originally from Space Station 13 areas.dm. -Frenjo
/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = 0 				(defaults to 1)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/

/area
	var/fire = null
	var/atmos = 1
	var/atmosalm = 0
	var/poweralm = 1
	var/party = null
	level = null
	name = "Unknown"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = 10
	mouse_opacity = 0
	luminosity = 0
	var/lightswitch = 1

	var/eject = null

	var/destruct = null // Added this to make use of unused sprites. -Frenjo

	var/debug = 0
	var/requires_power = 1
	var/always_unpowered = 0	//this gets overriden to 1 for space in area/New()

	var/power_equip = 1
	var/power_light = 1
	var/power_environ = 1
	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0

	var/has_gravity = 1
	var/obj/machinery/power/apc/apc = null
	var/no_air = null

	var/list/all_doors = list()		//Added by Strumpetplaya - Alarm Change - Contains a list of doors adjacent to this area
	var/air_doors_activated = 0
	var/list/ambience = list(
		'sound/ambience/ambigen1.ogg',
		'sound/ambience/ambigen3.ogg',
		'sound/ambience/ambigen4.ogg',
		'sound/ambience/ambigen5.ogg',
		'sound/ambience/ambigen6.ogg',
		'sound/ambience/ambigen7.ogg',
		'sound/ambience/ambigen8.ogg',
		'sound/ambience/ambigen9.ogg',
		'sound/ambience/ambigen10.ogg',
		'sound/ambience/ambigen11.ogg',
		'sound/ambience/ambigen12.ogg',
		'sound/ambience/ambigen14.ogg'
	)
	var/turf/base_turf //The base turf type of the area, which can be used to override the z-level's base turf

/*Adding a wizard area teleport list because motherfucking lag -- Urist*/
/*I am far too lazy to make it a proper list of areas so I'll just make it run the usual telepot routine at the start of the game*/
var/list/teleportlocs = list()

/hook/startup/proc/setupTeleportLocs()
	for(var/area/AR in world)
		if(istype(AR, /area/shuttle) || istype(AR, /area/syndicate_station) || istype(AR, /area/wizard_station))
			continue
		if(teleportlocs.Find(AR.name))
			continue
		var/turf/picked = pick(get_area_turfs(AR.type))
		if(isStationLevel(picked.z))
			teleportlocs += AR.name
			teleportlocs[AR.name] = AR

	teleportlocs = sortAssoc(teleportlocs)

	return 1

var/list/ghostteleportlocs = list()

/hook/startup/proc/setupGhostTeleportLocs()
	for(var/area/AR in world)
		if(ghostteleportlocs.Find(AR.name))
			continue
		if(istype(AR, /area/turret_protected/aisat) || istype(AR, /area/derelict) || istype(AR, /area/tdome))
			ghostteleportlocs += AR.name
			ghostteleportlocs[AR.name] = AR
		var/turf/picked = pick(get_area_turfs(AR.type))
		if(isPlayerLevel(picked.z))
			ghostteleportlocs += AR.name
			ghostteleportlocs[AR.name] = AR

	ghostteleportlocs = sortAssoc(ghostteleportlocs)

	return 1

// Areas.dm
// ===
/area
	var/global/global_uid = 0
	var/uid

/area/New()
	icon_state = ""
	layer = 10
	uid = ++global_uid
	active_areas += src
	all_areas += src

	if(dynamic_lighting)
		luminosity = 0
	else
		luminosity = 1

	..()

/area/proc/initialize()
	if(!requires_power || !(locate(/obj/machinery/power/apc) in apc))
		power_light = 0			//rastaf0
		power_equip = 0			//rastaf0
		power_environ = 0		//rastaf0
	power_change()		// all machines set to current power level, also updates lighting icon

/area/proc/poweralert(state, obj/source as obj)
	if(state != poweralm)
		poweralm = state
		if(istype(source))	//Only report power alarms on the z-level where the source is located.
			var/list/cameras = list()
			for(var/obj/machinery/camera/C in src)
				cameras += C
				if(state == 1)
					C.network.Remove("Power Alarms")
				else
					C.network.Add("Power Alarms")
			for(var/mob/living/silicon/aiPlayer in player_list)
				if(aiPlayer.z == source.z)
					if(state == 1)
						aiPlayer.cancelAlarm("Power", src, source)
					else
						aiPlayer.triggerAlarm("Power", src, cameras, source)
			for(var/obj/machinery/computer/station_alert/a in machines)
				if(a.z == source.z)
					if(state == 1)
						a.cancelAlarm("Power", src, source)
					else
						a.triggerAlarm("Power", src, cameras, source)
	return

/area/proc/atmosalert(danger_level)
	if(danger_level != atmosalm)
		if(danger_level == 2)
			var/list/cameras = list()
			for(var/obj/machinery/camera/C in src)
				cameras += C
				C.network.Add("Atmosphere Alarms")
			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.triggerAlarm("Atmosphere", src, cameras, src)
			for(var/obj/machinery/computer/station_alert/a in machines)
				a.triggerAlarm("Atmosphere", src, cameras, src)
		else if(atmosalm == 2)
			for(var/obj/machinery/camera/C in src)
				C.network.Remove("Atmosphere Alarms")
			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.cancelAlarm("Atmosphere", src, src)
			for(var/obj/machinery/computer/station_alert/a in machines)
				a.cancelAlarm("Atmosphere", src, src)
		atmosalm = danger_level
		return 1
	return 0

/area/proc/firealert()
	if(!fire)
		fire = 1
		updateicon()
		mouse_opacity = 0
		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = DOOR_CLOSED
				else if(!D.density)
					spawn()
						D.close()
		var/list/cameras = list()
		for(var/obj/machinery/camera/C in src)
			cameras.Add(C)
			C.network.Add("Fire Alarms")
		for(var/mob/living/silicon/ai/aiPlayer in player_list)
			aiPlayer.triggerAlarm("Fire", src, cameras, src)
		for(var/obj/machinery/computer/station_alert/a in machines)
			a.triggerAlarm("Fire", src, cameras, src)

/area/proc/firereset()
	if(fire)
		fire = 0
		mouse_opacity = 0
		updateicon()
		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					spawn(0)
						D.open()
		for(var/obj/machinery/camera/C in src)
			C.network.Remove("Fire Alarms")
		for(var/mob/living/silicon/ai/aiPlayer in player_list)
			aiPlayer.cancelAlarm("Fire", src, src)
		for(var/obj/machinery/computer/station_alert/a in machines)
			a.cancelAlarm("Fire", src, src)

/area/proc/readyalert()
	if(!eject)
		eject = 1
		updateicon()
	return

/area/proc/readyreset()
	if(eject)
		eject = 0
		updateicon()
	return

/area/proc/partyalert()
	if(!(party))
		party = 1
		updateicon()
		mouse_opacity = 0
	return

/area/proc/partyreset()
	if(party)
		party = 0
		mouse_opacity = 0
		updateicon()
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					spawn(0)
					D.open()
	return

// Added these to make use of unused sprites. -Frenjo
/area/proc/destructalert()
	if(!destruct)
		destruct = 1
		updateicon()
	return

/area/proc/destructreset()
	if(destruct)
		destruct = 0
		updateicon()
	return

/area/proc/updateicon()
	if((fire || eject || party || destruct) && ((!requires_power) ? (!requires_power) : power_environ))
		if(fire && !eject && !party && !destruct)
			icon_state = "blue"
		else if(atmosalm && !fire && !eject && !party && !destruct)
			icon_state = "bluenew"
		else if(eject && !fire && !party && !destruct)
			icon_state = "red"
		else if(party && !fire && !eject && !destruct)
			icon_state = "party"
		else if(destruct && !fire && !party)
			icon_state = "_rednew"
		else
			icon_state = "blue-red"
	else
	//	new lighting behaviour with obj lights
		icon_state = null

/area/proc/powered(chan)		// return true if the area has power to given channel
	if(!requires_power)
		return 1
	if(always_unpowered)
		return 0

	switch(chan)
		if(EQUIP)
			return power_equip
		if(LIGHT)
			return power_light
		if(ENVIRON)
			return power_environ

	return 0

// called when power status changes
/area/proc/power_change()
	for(var/obj/machinery/M in src)	// for each machine in the area
		M.power_change()			// reverify power status (to update icons etc.)
	if(fire || eject || party || destruct)
		updateicon()

/area/proc/usage(chan)
	var/used = 0
	switch(chan)
		if(LIGHT)
			used += used_light
		if(EQUIP)
			used += used_equip
		if(ENVIRON)
			used += used_environ
		if(TOTAL)
			used += used_light + used_equip + used_environ
	return used

/area/proc/clear_usage()
	used_equip = 0
	used_light = 0
	used_environ = 0

/area/proc/use_power(amount, chan)
	switch(chan)
		if(EQUIP)
			used_equip += amount
		if(LIGHT)
			used_light += amount
		if(ENVIRON)
			used_environ += amount

/area/proc/set_lightswitch(new_switch)
	if(lightswitch != new_switch)
		lightswitch = new_switch
		updateicon()
		power_change()

/area/proc/set_emergency_lighting(enable)
	for(var/obj/machinery/light/M in src)
		M.set_emergency_lighting(enable)

/area/Entered(A)
	var/musVolume = 25
	var/sound = 'sound/ambience/ambigen1.ogg'

	if(!isliving(A))
		return

	var/mob/living/L = A
	if(!L.ckey)
		return

	if(!L.lastarea)
		L.lastarea = get_area(L.loc)
	var/area/newarea = get_area(L.loc)
	var/area/oldarea = L.lastarea
	if(oldarea.has_gravity == 0 && newarea.has_gravity == 1 && L.m_intent == "run") // Being ready when you change areas gives you a chance to avoid falling all together.
		thunk(L)

	L.lastarea = newarea

	// Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	if(!(L && L.client && (L.client.prefs.toggles & SOUND_AMBIENCE)))
		return

	if(!L.client.ambience_playing)
		L.client.ambience_playing = 1
		L << sound('sound/ambience/shipambience.ogg', repeat = 1, wait = 0, volume = 35, channel = 2)

	if(src.ambience.len && prob(35))
		sound = pick(ambience)

		if(world.time > L.client.played + 600)
			L << sound(sound, repeat = 0, wait = 0, volume = musVolume, channel = 1)
			L.client.played = world.time

/area/proc/gravitychange(gravitystate = 0, area/A)
	A.has_gravity = gravitystate
	if(gravitystate)
		for(var/mob/living/carbon/human/M in A)
			thunk(M)

/area/proc/thunk(mob)
	if(istype(get_turf(mob), /turf/space)) // Can't fall onto nothing.
		return

	if(ishuman(mob)) // Only humans can wear magboots, so we give them a chance to.
		var/mob/living/carbon/human/human = mob
		if(istype(human.shoes, /obj/item/clothing/shoes/magboots) && (human.shoes.flags & NOSLIP))
			return
		if(human.m_intent == "run") // Only clumsy humans can fall on their asses.
			human.AdjustStunned(5)
			human.AdjustWeakened(5)
		else
			human.AdjustStunned(2)
			human.AdjustWeakened(2)
	
	to_chat(mob, "Gravity!")