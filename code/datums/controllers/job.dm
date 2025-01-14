/var/global/datum/controller/occupations/job_master // Set in /datum/controller/master/New()

#define GET_RANDOM_JOB 0
#define BE_ASSISTANT 1
#define RETURN_TO_LOBBY 2

/datum/controller/occupations
	//List of all jobs
	var/list/occupations = list()
	//Players who need jobs
	var/list/unassigned = list()
	//Debug info
	var/list/job_debug = list()

/datum/controller/occupations/proc/setup_occupations(faction = "Station")
	occupations = list()
	var/list/all_jobs = typesof(/datum/job)
	if(!all_jobs.len)
		to_world(SPAN_DANGER("Error setting up jobs, no job datums found"))
		return 0
	for(var/J in all_jobs)
		var/datum/job/job = new J()
		if(!job)
			continue
		if(job.faction != faction)
			continue
		occupations += job

	return 1

/datum/controller/occupations/proc/debug(text)
	if(!global.debug2)
		return 0
	job_debug.Add(text)
	return 1

/datum/controller/occupations/proc/get_job(rank)
	if(!rank)
		return null
	for(var/datum/job/J in occupations)
		if(!J)
			continue
		if(J.title == rank)
			return J
	return null

/datum/controller/occupations/proc/get_player_alt_title(mob/new_player/player, rank)
	return player.client.prefs.GetPlayerAltTitle(get_job(rank))

/datum/controller/occupations/proc/assign_role(mob/new_player/player, rank, latejoin = 0)
	debug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
	if(player && player.mind && rank)
		var/datum/job/job = get_job(rank)
		if(!job)
			return 0
		if(jobban_isbanned(player, rank))
			return 0
		if(!job.player_old_enough(player.client))
			return 0
		var/position_limit = job.total_positions
		if(!latejoin)
			position_limit = job.spawn_positions
		if((job.current_positions < position_limit) || position_limit == -1)
			debug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]")
			player.mind.assigned_role = rank
			player.mind.role_alt_title = get_player_alt_title(player, rank)
			unassigned -= player
			job.current_positions++
			return 1
	debug("AR has failed, Player: [player], Rank: [rank]")
	return 0

/datum/controller/occupations/proc/free_role(rank)	//making additional slot on the fly
	var/datum/job/job = get_job(rank)
	if(job && job.current_positions >= job.total_positions && job.total_positions != -1)
		job.total_positions++
		return 1
	return 0

/datum/controller/occupations/proc/find_occupation_candidates(datum/job/job, level, flag)
	debug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
	var/list/candidates = list()
	for(var/mob/new_player/player in unassigned)
		if(jobban_isbanned(player, job.title))
			debug("FOC isbanned failed, Player: [player]")
			continue
		if(!job.player_old_enough(player.client))
			debug("FOC player not old enough, Player: [player]")
			continue
		if(flag && !(player.client.prefs.be_special & flag))
			debug("FOC flag failed, Player: [player], Flag: [flag], ")
			continue
		if(player.client.prefs.GetJobDepartment(job, level) & job.flag)
			debug("FOC pass, Player: [player], Level:[level]")
			candidates += player
	return candidates

/datum/controller/occupations/proc/give_random_job(mob/new_player/player)
	debug("GRJ Giving random job, Player: [player]")
	for(var/datum/job/job in shuffle(occupations))
		if(!job)
			continue

		if(istype(job, get_job("Assistant"))) // We don't want to give him assistant, that's boring!
			continue

		if(job in command_positions) //If you want a command position, select it!
			continue

		if(jobban_isbanned(player, job.title))
			debug("GRJ isbanned failed, Player: [player], Job: [job.title]")
			continue

		if(!job.player_old_enough(player.client))
			debug("GRJ player not old enough, Player: [player]")
			continue

		if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
			debug("GRJ Random job given, Player: [player], Job: [job]")
			assign_role(player, job.title)
			unassigned -= player
			break

/datum/controller/occupations/proc/reset_occupations()
	for(var/mob/new_player/player in player_list)
		if((player) && (player.mind))
			player.mind.assigned_role = null
			player.mind.special_role = null
	setup_occupations()
	unassigned = list()
	return

//This proc is called before the level loop of DivideOccupations() and will try to select a head, ignoring ALL non-head preferences for every level until it locates a head or runs out of levels to check
/datum/controller/occupations/proc/fill_head_position()
	for(var/level = 1 to 3)
		for(var/command_position in command_positions)
			var/datum/job/job = get_job(command_position)
			if(!job)
				continue
			var/list/candidates = find_occupation_candidates(job, level)
			if(!candidates.len)
				continue

			// Build a weighted list, weight by age.
			var/list/weightedCandidates = list()

			// Different head positions have different good ages.
			var/good_age_minimal = 25
			var/good_age_maximal = 60
			if(command_position == "Captain")
				good_age_minimal = 30
				good_age_maximal = 70 // Old geezer captains ftw

			for(var/mob/V in candidates)
				// Log-out during round-start? What a bad boy, no head position for you!
				if(!V.client)
					continue
				var/age = V.client.prefs.age
				switch(age)
					if(good_age_minimal - 10 to good_age_minimal)
						weightedCandidates[V] = 3 // Still a bit young.
					if(good_age_minimal to good_age_minimal + 10)
						weightedCandidates[V] = 6 // Better.
					if(good_age_minimal + 10 to good_age_maximal - 10)
						weightedCandidates[V] = 10 // Great.
					if(good_age_maximal - 10 to good_age_maximal)
						weightedCandidates[V] = 6 // Still good.
					if(good_age_maximal to good_age_maximal + 10)
						weightedCandidates[V] = 6 // Bit old, don't you think?
					if(good_age_maximal to good_age_maximal + 50)
						weightedCandidates[V] = 3 // Geezer.
					else
						// If there's ABSOLUTELY NOBODY ELSE
						if(candidates.len == 1)
							weightedCandidates[V] = 1

				var/mob/new_player/candidate = pickweight(weightedCandidates)
				if(assign_role(candidate, command_position))
					return 1
		return 0

//This proc is called at the start of the level loop of DivideOccupations() and will cause head jobs to be checked before any other jobs of the same level
/datum/controller/occupations/proc/check_head_positions(level)
	for(var/command_position in command_positions)
		var/datum/job/job = get_job(command_position)
		if(!job)
			continue
		var/list/candidates = find_occupation_candidates(job, level)
		if(!candidates.len)
			continue
		var/mob/new_player/candidate = pick(candidates)
		assign_role(candidate, command_position)
	return

/datum/controller/occupations/proc/fill_ai_position()
	var/ai_selected = 0
	var/datum/job/job = get_job("AI")
	if(!job)
		return 0
	if((job.title == "AI") && (config) && (!config.allow_ai))
		return 0

	for(var/i = job.total_positions, i > 0, i--)
		for(var/level = 1 to 3)
			var/list/candidates = list()
			if(ticker.mode.name == "AI malfunction")//Make sure they want to malf if its malf
				candidates = find_occupation_candidates(job, level, BE_MALF)
			else
				candidates = find_occupation_candidates(job, level)
			if(candidates.len)
				var/mob/new_player/candidate = pick(candidates)
				if(assign_role(candidate, "AI"))
					ai_selected++
					break
		//Malf NEEDS an AI so force one if we didn't get a player who wanted it
		if((ticker.mode.name == "AI malfunction") && (!ai_selected))
			unassigned = shuffle(unassigned)
			for(var/mob/new_player/player in unassigned)
				if(jobban_isbanned(player, "AI"))
					continue
				if(assign_role(player, "AI"))
					ai_selected++
					break
		if(ai_selected)
			return 1
		return 0


/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
/datum/controller/occupations/proc/divide_occupations()
	//Setup new player list and get the jobs list
	debug("Running DO")
	setup_occupations()

	//Holder for Triumvirate is stored in the ticker, this just processes it
	if(ticker)
		for(var/datum/job/ai/A in occupations)
			if(ticker.triai)
				A.spawn_positions = 3

	//Get the players who are ready
	for(var/mob/new_player/player in player_list)
		if(player.ready && player.mind && !player.mind.assigned_role)
			unassigned += player

	debug("DO, Len: [unassigned.len]")
	if(unassigned.len == 0)
		return 0

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	handle_feedback_gathering()

	//People who wants to be assistants, sure, go on.
	debug("DO, Running Assistant Check 1")
	var/datum/job/assist = new /datum/job/assistant()
	var/list/assistant_candidates = find_occupation_candidates(assist, 3)
	debug("AC1, Candidates: [assistant_candidates.len]")
	for(var/mob/new_player/player in assistant_candidates)
		debug("AC1 pass, Player: [player]")
		assign_role(player, "Assistant")
		assistant_candidates -= player
	debug("DO, AC1 end")

	//Select one head
	debug("DO, Running Head Check")
	fill_head_position()
	debug("DO, Head Check end")

	//Check for an AI
	debug("DO, Running AI Check")
	fill_ai_position()
	debug("DO, AI Check end")

	//Other jobs are now checked
	debug("DO, Running Standard Check")

	// New job giving system by Donkie
	// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
	// Hopefully this will add more randomness and fairness to job giving.

	// Loop through all levels from high to low
	var/list/shuffledoccupations = shuffle(occupations)
	for(var/level = 1 to 3)
		//Check the head jobs first each level
		check_head_positions(level)

		// Loop through all unassigned players
		for(var/mob/new_player/player in unassigned)
			// Loop through all jobs
			for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
				if(!job)
					continue

				if(jobban_isbanned(player, job.title))
					debug("DO isbanned failed, Player: [player], Job:[job.title]")
					continue

				if(!job.player_old_enough(player.client))
					debug("DO player not old enough, Player: [player], Job:[job.title]")
					continue

				// If the player wants that job on this level, then try give it to him.
				if(player.client.prefs.GetJobDepartment(job, level) & job.flag)
					// If the job isn't filled
					if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
						debug("DO pass, Player: [player], Level:[level], Job:[job.title]")
						assign_role(player, job.title)
						unassigned -= player
						break

	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/mob/new_player/player in unassigned)
		if(player.client.prefs.alternate_option == GET_RANDOM_JOB)
			give_random_job(player)

	debug("DO, Standard Check end")

	debug("DO, Running AC2")

	// For those who wanted to be assistant if their preferences were filled, here you go.
	for(var/mob/new_player/player in unassigned)
		if(player.client.prefs.alternate_option == BE_ASSISTANT)
			debug("AC2 Assistant located, Player: [player]")
			assign_role(player, "Assistant")

	//For ones returning to lobby
	for(var/mob/new_player/player in unassigned)
		if(player.client.prefs.alternate_option == RETURN_TO_LOBBY)
			player.ready = FALSE
			unassigned -= player
	return 1

/datum/controller/occupations/proc/equip_rank(mob/living/carbon/human/H, rank, joined_late = 0)
	if(!H)
		return 0

	var/datum/job/job = get_job(rank)
	if(job)
		job.equip(H)
	else
		H << "Your job is [rank] and the game just can't handle it! Please report this bug to an administrator."

	H.job = rank

	if(!joined_late)
		var/obj/S = null
		for(var/obj/effect/landmark/start/sloc in landmarks_list)
			if(sloc.name != rank)
				continue
			if(locate(/mob/living) in sloc.loc)
				continue
			S = sloc
			break
		if(!S)
			S = locate("start*[rank]") // use old stype
		if(istype(S, /obj/effect/landmark/start) && istype(S.loc, /turf))
			H.loc = S.loc

	//give them an account in the station database
	var/datum/money_account/M = create_account(H.real_name, rand(50,500)*10, null)
	if(H.mind)
		var/remembered_info = ""
		remembered_info += "<b>Your account number is:</b> #[M.account_number]<br>"
		remembered_info += "<b>Your account pin is:</b> [M.remote_access_pin]<br>"
		remembered_info += "<b>Your account funds are:</b> $[M.money]<br>"

		if(M.transaction_log.len)
			var/datum/transaction/T = M.transaction_log[1]
			remembered_info += "<b>Your account was created:</b> [T.time], [T.date] at [T.source_terminal]<br>"
		H.mind.store_memory(remembered_info)

		H.mind.initial_account = M

	// If they're head, give them the account info for their department
	if(H.mind && job.head_position)
		var/remembered_info = ""
		var/datum/money_account/department_account = department_accounts[job.department]

		if(department_account)
			remembered_info += "<b>Your department's account number is:</b> #[department_account.account_number]<br>"
			remembered_info += "<b>Your department's account pin is:</b> [department_account.remote_access_pin]<br>"
			remembered_info += "<b>Your department's account funds are:</b> $[department_account.money]<br>"

		H.mind.store_memory(remembered_info)

	spawn(0)
		to_chat(H, SPAN_INFO_B("Your account number is: [M.account_number], your account pin is: [M.remote_access_pin]."))

	var/alt_title = null
	if(H.mind)
		H.mind.assigned_role = rank
		alt_title = H.mind.role_alt_title

		switch(rank)
			if("Cyborg")
				H.Robotize()
				return 1
			if("AI", "Clown", "Mime")	//don't need bag preference stuff!
			else
				switch(H.backbag) //BS12 EDIT
					if(1)
						if(H.species.survival_kit)
							H.equip_to_slot_or_del(new H.species.survival_kit(H), slot_r_hand)
					if(2)
						var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack(H)
						if(H.species.survival_kit)
							new H.species.survival_kit(BPK)
						H.equip_to_slot_or_del(BPK, slot_back, 1)
					if(3)
						var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack/satchel_norm(H)
						if(H.species.survival_kit)
							new H.species.survival_kit(BPK)
						H.equip_to_slot_or_del(BPK, slot_back, 1)
					if(4)
						var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack/satchel(H)
						if(H.species.survival_kit)
							new H.species.survival_kit(BPK)
						H.equip_to_slot_or_del(BPK, slot_back, 1)

	if(H.species)
		if(H.species.name == "Tajaran" || H.species.name == "Soghun")
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes, 1)
		else if(H.species.name == "Vox")
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/breath/vox(src), slot_wear_mask)
			if(!H.r_hand)
				H.equip_to_slot_or_del(new /obj/item/weapon/tank/nitrogen(src), slot_r_hand)
				H.internal = H.r_hand
			else if(!H.l_hand)
				H.equip_to_slot_or_del(new /obj/item/weapon/tank/nitrogen(src), slot_l_hand)
				H.internal = H.l_hand
			H.internals.icon_state = "internal1"
		else if(H.species.name == "Plasmalin")
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(H), slot_wear_mask)
			if(!H.r_hand)
				H.equip_to_slot_or_del(new /obj/item/weapon/tank/plasma2(H), slot_r_hand)
				H.internal = H.r_hand
			else if(!H.l_hand)
				H.equip_to_slot_or_del(new /obj/item/weapon/tank/plasma2(H), slot_l_hand)
				H.internal = H.l_hand
			H.internals.icon_state = "internal1"

	to_chat(H, "<B>You are the [alt_title ? alt_title : rank].</B>")
	to_chat(H, "<b>As the [alt_title ? alt_title : rank] you answer directly to [job.supervisors]. Special circumstances may change this.</b>")
	if(job.req_admin_notify)
		to_chat(H, "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")

	spawn_id(H, rank, alt_title)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset(H), slot_l_ear)

	//Gives glasses to the vision impaired
	if(H.disabilities & NEARSIGHTED)
		var/equipped = H.equip_to_slot_or_del(new /obj/item/clothing/glasses/regular(H), slot_glasses)
		if(equipped != 1)
			var/obj/item/clothing/glasses/G = H.glasses
			G.prescription = 1
//	H.update_icons()

	BITSET(H.hud_updateflag, ID_HUD)
	BITSET(H.hud_updateflag, IMPLOYAL_HUD)
	BITSET(H.hud_updateflag, SPECIALROLE_HUD)
	return 1


/datum/controller/occupations/proc/spawn_id(mob/living/carbon/human/H, rank, title)
	if(!H)
		return 0
	var/obj/item/weapon/card/id/C = null

	var/datum/job/job = null
	for(var/datum/job/J in occupations)
		if(J.title == rank)
			job = J
			break

	if(job)
		if(job.title == "Cyborg")
			return
		else
			C = new job.idtype(H)
			C.access = job.get_access()
	else
		C = new /obj/item/weapon/card/id(H)
	if(C)
		C.registered_name = H.real_name
		C.rank = rank
		C.assignment = title ? title : rank
		C.name = "[C.registered_name]'s ID Card ([C.assignment])"

		//put the player's account number onto the ID
		if(H.mind && H.mind.initial_account)
			C.associated_account_number = H.mind.initial_account.account_number

		H.equip_to_slot_or_del(C, slot_wear_id)

	H.equip_to_slot_or_del(new /obj/item/device/pda(H), slot_belt)
	if(locate(/obj/item/device/pda, H))
		var/obj/item/device/pda/pda = locate(/obj/item/device/pda, H)
		pda.owner = H.real_name
		pda.ownjob = C.assignment
		pda.name = "PDA - [H.real_name] ([pda.ownjob])" // Edited this to space out the dash. -Frenjo

	return 1

/datum/controller/occupations/proc/load_jobs(jobsfile) //ran during round setup, reads info from jobs.txt -- Urist
	if(!config.load_jobs_from_txt)
		return 0

	var/list/jobEntries = file2list(jobsfile)

	for(var/job in jobEntries)
		if(!job)
			continue

		job = trim(job)
		if(!length(job))
			continue

		var/pos = findtext(job, "=")
		var/name = null
		var/value = null

		if(pos)
			name = copytext(job, 1, pos)
			value = copytext(job, pos + 1)
		else
			continue

		if(name && value)
			var/datum/job/J = get_job(name)
			if(!J)
				continue
			J.total_positions = text2num(value)
			J.spawn_positions = text2num(value)
			if(name == "AI" || name == "Cyborg")	//I dont like this here but it will do for now
				J.total_positions = 0

	return 1

/datum/controller/occupations/proc/handle_feedback_gathering()
	for(var/datum/job/job in occupations)
		var/tmp_str = "|[job.title]|"

		var/level1 = 0 //high
		var/level2 = 0 //medium
		var/level3 = 0 //low
		var/level4 = 0 //never
		var/level5 = 0 //banned
		var/level6 = 0 //account too young
		for(var/mob/new_player/player in player_list)
			if(!(player.ready && player.mind && !player.mind.assigned_role))
				continue //This player is not ready
			if(jobban_isbanned(player, job.title))
				level5++
				continue
			if(!job.player_old_enough(player.client))
				level6++
				continue
			if(player.client.prefs.GetJobDepartment(job, 1) & job.flag)
				level1++
			else if(player.client.prefs.GetJobDepartment(job, 2) & job.flag)
				level2++
			else if(player.client.prefs.GetJobDepartment(job, 3) & job.flag)
				level3++
			else level4++ //not selected

		tmp_str += "HIGH=[level1]|MEDIUM=[level2]|LOW=[level3]|NEVER=[level4]|BANNED=[level5]|YOUNG=[level6]|-"
		feedback_add_details("job_preferences", tmp_str)