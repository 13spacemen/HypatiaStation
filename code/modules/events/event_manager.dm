var/list/allEvents = SUBTYPESOF(/datum/event)
var/list/potentialRandomEvents = SUBTYPESOF(/datum/event)
//var/list/potentialRandomEvents = typesof(/datum/event) - /datum/event - /datum/event/spider_infestation - /datum/event/alien_infestation

var/eventTimeLower = 12000	//20 minutes
var/eventTimeUpper = 24000	//40 minutes
var/scheduledEvent = null


//Currently unused. Needs an admin panel for messing with events.
/*/proc/addPotentialEvent(var/type)
	potentialRandomEvents |= type

/proc/removePotentialEvent(var/type)
	potentialRandomEvents -= type*/


/proc/checkEvent()
	if(!scheduledEvent)
		//more players = more time between events, less players = less time between events
		var/playercount_modifier = 1
		switch(player_list.len)
			if(0 to 10)
				playercount_modifier = 1.2
			if(11 to 15)
				playercount_modifier = 1.1
			if(16 to 25)
				playercount_modifier = 1
			if(26 to 35)
				playercount_modifier = 0.9
			if(36 to 100000)
				playercount_modifier = 0.8
		var/next_event_delay = rand(eventTimeLower, eventTimeUpper) * playercount_modifier
		scheduledEvent = world.timeofday + next_event_delay
		log_debug("Next event in [next_event_delay/600] minutes.")

	else if(world.timeofday > scheduledEvent)
		spawn_dynamic_event()

		scheduledEvent = null
		checkEvent()

//unused, see proc/dynamic_event()
/*
/proc/spawnEvent()
	if(!config.allow_random_events)
		return

	var/Type = pick(potentialRandomEvents)
	if(!Type)
		return

	//The event will add itself to the MC's event list
	//and start working via the constructor.
	new Type
*/

/client/proc/forceEvent(var/type in allEvents)
	set name = "Trigger Event (Debug Only)"
	set category = "Debug"

	if(!holder)
		return

	if(ispath(type))
		new type
		message_admins("[key_name_admin(usr)] has triggered an event. ([type])", 1)
