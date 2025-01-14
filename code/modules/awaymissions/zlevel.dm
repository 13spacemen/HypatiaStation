/proc/createRandomZlevel()
	if(global.awaydestinations.len)	//crude, but it saves another var!
		return

	var/list/potentialRandomZlevels = list()
	to_world(SPAN_DANGER("Searching for away missions..."))
	var/list/Lines = file2list("maps/RandomZLevels/fileList.txt")
	if(!Lines.len)
		return
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
	//	var/value = null

		if(pos)
			// No, don't do lowertext here, that breaks paths on linux
			name = copytext(t, 1, pos)
		//	value = copytext(t, pos + 1)
		else
			// No, don't do lowertext here, that breaks paths on linux
			name = t

		if(!name)
			continue

		potentialRandomZlevels.Add(name)

	if(potentialRandomZlevels.len)
		to_world(SPAN_DANGER("Loading away mission..."))

		var/map = pick(potentialRandomZlevels)
		var/file = file(map)
		if(isfile(file))
			global.maploader.load_map(file)
			world.log << "away mission loaded: [map]"

		for(var/obj/effect/landmark/L in landmarks_list)
			if(L.name != "awaystart")
				continue
			global.awaydestinations.Add(L)

		to_world(SPAN_DANGER("Away mission loaded."))

	else
		to_world(SPAN_DANGER("No away missions found."))
		return