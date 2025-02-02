// The time a datum was destroyed by the GC, or null if it hasn't been
/datum/var/gcDestroyed

#define GC_COLLECTIONS_PER_RUN 150
#define GC_COLLECTION_TIMEOUT (30 SECONDS)
#define GC_FORCE_DEL_PER_RUN 30

/var/global/datum/controller/process/garbage/garbage_collector
/var/global/list/delayed_garbage = list()

/datum/controller/process/garbage
	var/garbage_collect = TRUE	// Whether or not to actually do work
	var/total_dels	= 0			// number of total del()'s
	var/tick_dels	= 0			// number of del()'s we've done this tick
	var/soft_dels	= 0
	var/hard_dels	= 0			// number of hard dels in total
	var/list/destroyed = list() // list of refID's of things that should be garbage collected
								// refID's are associated with the time at which they time out and need to be manually del()
								// we do this so we aren't constantly locating them and preventing them from being gc'd

	var/list/logging = list()	// list of all types that have failed to GC associated with the number of times that's happened.
								// the types are stored as strings

/datum/controller/process/garbage/setup()
	name = "garbage"
	schedule_interval = 2 SECONDS
	start_delay = 3

	if(!global.garbage_collector)
		global.garbage_collector = src

	for(var/garbage in global.delayed_garbage)
		qdel(garbage)
	global.delayed_garbage.Cut()
	global.delayed_garbage = null

/datum/controller/process/garbage/doWork()
	if(!garbage_collect)
		return

	tick_dels = 0
	var/time_to_kill = world.time - GC_COLLECTION_TIMEOUT
	var/checkRemain = GC_COLLECTIONS_PER_RUN
	var/remaining_force_dels = GC_FORCE_DEL_PER_RUN

	while(destroyed.len && --checkRemain >= 0)
		if(remaining_force_dels <= 0)
			#ifdef GC_DEBUG
			testing("GC: Reached max force dels per tick [dels] vs [maxDels]")
			#endif
			break // Server's already pretty pounded, everything else can wait 2 seconds
		var/refID = destroyed[1]
		var/GCd_at_time = destroyed[refID]
		if(GCd_at_time > time_to_kill)
			#ifdef GC_DEBUG
			testing("GC: [refID] not old enough, breaking at [world.time] for [GCd_at_time - time_to_kill] deciseconds until [GCd_at_time + collection_timeout]")
			#endif
			break // Everything else is newer, skip them
		var/atom/A = locate(refID)
		#ifdef GC_DEBUG
		testing("GC: [refID] old enough to test: GCd_at_time: [GCd_at_time] time_to_kill: [time_to_kill] current: [world.time]")
		#endif
		if(A && A.gcDestroyed == GCd_at_time) // So if something else coincidently gets the same ref, it's not deleted by mistake
			// Something's still referring to the qdel'd object.  Kill it.
			testing("GC: -- \ref[A] | [A.type] was unable to be GC'd and was deleted --")
			logging["[A.type]"]++
			del(A)

			hard_dels++
			remaining_force_dels--
		else
			#ifdef GC_DEBUG
			testing("GC: [refID] properly GC'd at [world.time] with timeout [GCd_at_time]")
			#endif
			soft_dels++
		tick_dels++
		total_dels++
		destroyed.Cut(1, 2)
		SCHECK

//#undef GC_FORCE_DEL_PER_TICK
#undef GC_COLLECTION_TIMEOUT
//#undef GC_COLLECTIONS_PER_TICK

/datum/controller/process/garbage/proc/AddTrash(datum/A)
	if(!istype(A) || !isnull(A.gcDestroyed))
		return
	#ifdef GC_DEBUG
	testing("GC: AddTrash(\ref[A] - [A.type])")
	#endif
	A.gcDestroyed = world.time
	destroyed -= "\ref[A]" // Removing any previous references that were GC'd so that the current object will be at the end of the list.
	destroyed["\ref[A]"] = world.time

/datum/controller/process/garbage/statProcess()
	..()
	stat(null, "[garbage_collect ? "On" : "Off"], [destroyed.len] queued")
	stat(null, "Dels: [total_dels], [soft_dels] soft, [hard_dels] hard, [tick_dels] last run")

// Should be treated as a replacement for the 'del' keyword.
// Datums passed to this will be given a chance to clean up references to allow the GC to collect them.
/proc/qdel(datum/A)
	if(!A)
		return
	if(islist(A))
		var/list/L = A
		for(var/E in L)
			qdel(E)
		return

	if(!istype(A))
		warning("qdel() passed object of type [A.type]. qdel() can only handle /datum types.")
		del(A)
		global.garbage_collector.total_dels++
		global.garbage_collector.hard_dels++
	else if(isnull(A.gcDestroyed))
		// Let our friend know they're about to get collected
		. = !A.Destroy()
		if(. && A)
			A.finalize_qdel()

/datum/proc/finalize_qdel()
	if(IsPooled(src))
		PlaceInPool(src)
	else
		del(src)

/atom/finalize_qdel()
	if(IsPooled(src))
		PlaceInPool(src)
	else
		if(global.garbage_collector)
			global.garbage_collector.AddTrash(src)
		else
			global.delayed_garbage |= src

/icon/finalize_qdel()
	del(src)

/image/finalize_qdel()
	del(src)

/mob/finalize_qdel()
	del(src)

/turf/finalize_qdel()
	del(src)

// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return true if the the GC controller should allow the object to continue existing. (Useful if pooling objects.)
/datum/proc/Destroy()
	tag = null
	return

#ifdef TESTING
/client/var/running_find_references

/mob/verb/create_thing()
	set category = "Debug"
	set name = "Create Thing"

	var/path = input("Enter path")
	var/atom/thing = new path(loc)
	thing.find_references()

/atom/verb/find_references()
	set category = "Debug"
	set name = "Find References"
	set background = 1
	set src in world

	if(!usr || !usr.client)
		return

	if(usr.client.running_find_references)
		testing("CANCELLED search for references to a [usr.client.running_find_references].")
		usr.client.running_find_references = null
		return

	if(alert("Running this will create a lot of lag until it finishes.  You can cancel it by running it again.  Would you like to begin the search?", "Find References", "Yes", "No") == "No")
		return

	// Remove this object from the list of things to be auto-deleted.
	if(global.garbage_collector)
		global.garbage_collector.destroyed -= "\ref[src]"

	usr.client.running_find_references = type
	testing("Beginning search for references to a [type].")
	var/list/things = list()
	for(var/client/thing)
		things += thing
	for(var/datum/thing)
		things += thing
	for(var/atom/thing)
		things += thing
	testing("Collected list of things in search for references to a [type]. ([things.len] Thing\s)")
	for(var/datum/thing in things)
		if(!usr.client.running_find_references)
			return
		for(var/varname in thing.vars)
			var/variable = thing.vars[varname]
			if(variable == src)
				testing("Found [src.type] \ref[src] in [thing.type]'s [varname] var.")
			else if(islist(variable))
				if(src in variable)
					testing("Found [src.type] \ref[src] in [thing.type]'s [varname] list var.")
	testing("Completed search for references to a [type].")
	usr.client.running_find_references = null

/client/verb/purge_all_destroyed_objects()
	set category = "Debug"
	if(global.garbage_collector)
		while(global.garbage_collector.destroyed.len)
			var/datum/o = locate(global.garbage_collector.destroyed[1])
			if(istype(o) && o.gcDestroyed)
				del(o)
				global.garbage_collector.dels++
			global.garbage_collector.destroyed.Cut(1, 2)
#endif

#ifdef GC_DEBUG
#undef GC_DEBUG
#endif