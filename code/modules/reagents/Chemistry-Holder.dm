//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

///////////////////////////////////////////////////////////////////////////////////

/datum/reagents
	var/list/datum/reagent/reagent_list = new/list()
	var/total_volume = 0
	var/maximum_volume = 100
	var/atom/my_atom = null

/datum/reagents/New(maximum = 100)
	maximum_volume = maximum
	//I dislike having these here but map-objects are initialised before world/New() is called. >_>
	if(!global.chemical_reagents_list)
		//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id
		var/paths = SUBTYPESOF(/datum/reagent)
		global.chemical_reagents_list = list()
		for(var/path in paths)
			var/datum/reagent/D = new path()
			global.chemical_reagents_list[D.id] = D

	if(!global.chemical_reactions_list)
		//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
		// It is filtered into multiple lists within a list.
		// For example:
		// chemical_reaction_list["plasma"] is a list of all reactions relating to plasma
		var/paths = SUBTYPESOF(/datum/chemical_reaction)
		global.chemical_reactions_list = list()

		for(var/path in paths)
			var/datum/chemical_reaction/D = new path()
			var/list/reaction_ids = list()

			if(D.required_reagents && D.required_reagents.len)
				for(var/reaction in D.required_reagents)
					reaction_ids += reaction

			// Create filters based on each reagent id in the required reagents list
			for(var/id in reaction_ids)
				if(!global.chemical_reactions_list[id])
					global.chemical_reactions_list[id] = list()
				global.chemical_reactions_list[id] += D
				break // Don't bother adding ourselves to other reagent ids, it is redundant.


/datum/reagents/Destroy()
	..()
	for(var/datum/reagent/R in reagent_list)
		qdel(R)
	reagent_list.Cut()
	reagent_list = null
	if(my_atom && my_atom.reagents == src)
		my_atom.reagents = null


/datum/reagents/proc/remove_any(amount = 1)
	var/total_transfered = 0
	var/current_list_element = 1

	current_list_element = rand(1, reagent_list.len)

	while(total_transfered != amount)
		if(total_transfered >= amount)
			break
		if(total_volume <= 0 || !reagent_list.len)
			break

		if(current_list_element > reagent_list.len)
			current_list_element = 1
		var/datum/reagent/current_reagent = reagent_list[current_list_element]

		src.remove_reagent(current_reagent.id, 1)

		current_list_element++
		total_transfered++
		src.update_total()

	handle_reactions()
	return total_transfered


/datum/reagents/proc/get_master_reagent_name()
	var/the_name = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_name = A.name

	return the_name


/datum/reagents/proc/get_master_reagent_id()
	var/the_id = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_id = A.id

	return the_id


/datum/reagents/proc/trans_to(obj/target, amount = 1, multiplier = 1, preserve_data = 1)//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
	if(!target)
		return
	if(!target.reagents || src.total_volume <= 0)
		return
	var/datum/reagents/R = target.reagents
	amount = min(min(amount, src.total_volume), R.maximum_volume - R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for(var/datum/reagent/current_reagent in src.reagent_list)
		if(!current_reagent)
			continue
		if(current_reagent.id == "blood" && ishuman(target))
			var/mob/living/carbon/human/H = target
			H.inject_blood(my_atom, amount)
			continue
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = current_reagent.data

		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, safety = 1)	//safety checks on these so all chemicals are transferred
		src.remove_reagent(current_reagent.id, current_reagent_transfer, safety = 1)							// to the target container before handling reactions

	src.update_total()
	R.update_total()
	R.handle_reactions()
	src.handle_reactions()
	return amount


/datum/reagents/proc/trans_to_ingest(obj/target, amount = 1, multiplier = 1, preserve_data = 1)//For items ingested. A delay is added between ingestion and addition of the reagents
	if(!target)
		return
	if(!target.reagents || src.total_volume <= 0)
		return

	/*var/datum/reagents/R = target.reagents

	var/obj/item/weapon/reagent_containers/glass/beaker/noreact/B = new /obj/item/weapon/reagent_containers/glass/beaker/noreact //temporary holder

	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if (!current_reagent)
			continue
		//if (current_reagent.id == "blood" && ishuman(target))
		//	var/mob/living/carbon/human/H = target
		//	H.inject_blood(my_atom, amount)
		//	continue
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = current_reagent.data

		B.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, safety = 1)	//safety checks on these so all chemicals are transferred
		src.remove_reagent(current_reagent.id, current_reagent_transfer, safety = 1)							// to the target container before handling reactions

	src.update_total()
	B.update_total()
	B.handle_reactions()
	src.handle_reactions()*/

	var/obj/item/weapon/reagent_containers/glass/beaker/noreact/B = new /obj/item/weapon/reagent_containers/glass/beaker/noreact //temporary holder
	B.volume = 1000

	var/datum/reagents/BR = B.reagents
	var/datum/reagents/R = target.reagents

	amount = min(min(amount, src.total_volume), R.maximum_volume - R.total_volume)

	src.trans_to(B, amount)

	spawn(95)
		BR.reaction(target, INGEST)
		spawn(5)
			BR.trans_to(target, BR.total_volume)
			qdel(B)

	return amount


/datum/reagents/proc/copy_to(obj/target, amount = 1, multiplier = 1, preserve_data = 1, safety = 0)
	if(!target)
		return
	if(!target.reagents || src.total_volume <= 0)
		return
	var/datum/reagents/R = target.reagents
	amount = min(min(amount, src.total_volume), R.maximum_volume - R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for(var/datum/reagent/current_reagent in src.reagent_list)
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = current_reagent.data
		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, safety = 1)	//safety check so all chemicals are transferred before reacting

	src.update_total()
	R.update_total()
	if(!safety)
		R.handle_reactions()
		src.handle_reactions()
	return amount


/datum/reagents/proc/trans_id_to(obj/target, reagent, amount = 1, preserve_data = 1)//Not sure why this proc didn't exist before. It does now! /N
	if(!target)
		return
	if(!target.reagents || src.total_volume <= 0 || !src.get_reagent_amount(reagent))
		return

	var/datum/reagents/R = target.reagents
	if(src.get_reagent_amount(reagent)<amount)
		amount = src.get_reagent_amount(reagent)
	amount = min(amount, R.maximum_volume - R.total_volume)
	var/trans_data = null
	for(var/datum/reagent/current_reagent in src.reagent_list)
		if(current_reagent.id == reagent)
			if(preserve_data)
				trans_data = current_reagent.data
			R.add_reagent(current_reagent.id, amount, trans_data)
			src.remove_reagent(current_reagent.id, amount, 1)
			break

	src.update_total()
	R.update_total()
	R.handle_reactions()
	//src.handle_reactions() Don't need to handle reactions on the source since you're (presumably isolating and) transferring a specific reagent.
	return amount

/*
	if(!target)
		return
	var/total_transfered = 0
	var/current_list_element = 1
	var/datum/reagents/R = target.reagents
	var/trans_data = null
	//if(R.total_volume + amount > R.maximum_volume) return 0

	current_list_element = rand(1, reagent_list.len) //Eh, bandaid fix.

	while(total_transfered != amount)
		if(total_transfered >= amount)
			break //Better safe than sorry.
		if(total_volume <= 0 || !reagent_list.len)
			break
		if(R.total_volume >= R.maximum_volume)
			break

		if(current_list_element > reagent_list.len) current_list_element = 1
		var/datum/reagent/current_reagent = reagent_list[current_list_element]
		if(preserve_data)
			trans_data = current_reagent.data
		R.add_reagent(current_reagent.id, (1 * multiplier), trans_data)
		src.remove_reagent(current_reagent.id, 1)

		current_list_element++
		total_transfered++
		src.update_total()
		R.update_total()
	R.handle_reactions()
	handle_reactions()

	return total_transfered
*/


/datum/reagents/proc/metabolize(mob/M, alien)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(M && R)
			R.on_mob_life(M, alien)
	update_total()


/datum/reagents/proc/conditional_update_move(atom/A, Running = 0)
	for(var/datum/reagent/R in reagent_list)
		R.on_move(A, Running)
	update_total()


/datum/reagents/proc/conditional_update(atom/A)
	for(var/datum/reagent/R in reagent_list)
		R.on_update(A)
	update_total()


/datum/reagents/proc/handle_reactions()
	if(my_atom.flags & NOREACT)
		return //Yup, no reactions here. No siree.

	var/reaction_occured = 0
	do
		reaction_occured = 0
		for(var/datum/reagent/R in reagent_list) // Usually a small list
			for(var/reaction in global.chemical_reactions_list[R.id]) // Was a big list but now it should be smaller since we filtered it with our reagent id
				if(!reaction)
					continue

				var/datum/chemical_reaction/C = reaction

				//check if this recipe needs to be heated to mix
				if(C.requires_heating)
					if(istype(my_atom.loc, /obj/machinery/bunsen_burner))
						if(!my_atom.loc:heated)
							continue
					else
						continue

				var/total_required_reagents = C.required_reagents.len
				var/total_matching_reagents = 0
				var/total_required_catalysts = C.required_catalysts.len
				var/total_matching_catalysts = 0
				var/matching_container = 0
				var/matching_other = 0
				var/list/multipliers = new/list()

				for(var/B in C.required_reagents)
					if(!has_reagent(B, C.required_reagents[B]))
						break
					total_matching_reagents++
					multipliers += round(get_reagent_amount(B) / C.required_reagents[B])
				for(var/B in C.required_catalysts)
					if(!has_reagent(B, C.required_catalysts[B]))
						break
					total_matching_catalysts++

				if(!C.required_container)
					matching_container = 1

				else
					if(my_atom.type == C.required_container)
						matching_container = 1

				if(!C.required_other)
					matching_other = 1

				else
					/*
					if(istype(my_atom, /obj/item/slime_core))
						var/obj/item/slime_core/M = my_atom

						if(M.POWERFLAG == C.required_other && M.Uses > 0) // added a limit to slime cores -- Muskets requested this
							matching_other = 1
					*/
					if(istype(my_atom, /obj/item/slime_extract))
						var/obj/item/slime_extract/M = my_atom
						if(M.Uses > 0) // added a limit to slime cores -- Muskets requested this
							matching_other = 1


				if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other)
					var/multiplier = min(multipliers)
					var/preserved_data = null
					for(var/B in C.required_reagents)
						if(!preserved_data)
							preserved_data = get_data(B)
						remove_reagent(B, (multiplier * C.required_reagents[B]), safety = 1)

					var/created_volume = C.result_amount*multiplier
					if(C.result)
						feedback_add_details("chemical_reaction", "[C.result]|[C.result_amount * multiplier]")
						multiplier = max(multiplier, 1) //this shouldnt happen ...
						add_reagent(C.result, C.result_amount * multiplier)
						set_data(C.result, preserved_data)

						//add secondary products
						for(var/S in C.secondary_results)
							add_reagent(S, C.result_amount * C.secondary_results[S] * multiplier)

					var/list/seen = viewers(4, get_turf(my_atom))
					for(var/mob/M in seen)
						to_chat(M, SPAN_INFO("\icon[my_atom] The solution begins to bubble."))

				/*
					if(istype(my_atom, /obj/item/slime_core))
						var/obj/item/slime_core/ME = my_atom
						ME.Uses--
						if(ME.Uses <= 0) // give the notification that the slime core is dead
							for(var/mob/M in viewers(4, get_turf(my_atom)) )
								M << "\blue \icon[my_atom] The innards begin to boil!"
				*/

					if(istype(my_atom, /obj/item/slime_extract))
						var/obj/item/slime_extract/ME2 = my_atom
						ME2.Uses--
						if(ME2.Uses <= 0) // give the notification that the slime core is dead
							for(var/mob/M in seen)
								to_chat(M, SPAN_INFO("\icon[my_atom] The [my_atom]'s power is consumed in the reaction."))
								ME2.name = "used slime extract"
								ME2.desc = "This extract has been used up."

					playsound(get_turf(my_atom), 'sound/effects/bubbles.ogg', 80, 1)

					C.on_reaction(src, created_volume)
					reaction_occured = 1
					break

	while(reaction_occured)
	update_total()
	return 0


/datum/reagents/proc/isolate_reagent(reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(R.id != reagent)
			del_reagent(R.id)
			update_total()


/datum/reagents/proc/del_reagent(reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(R.id == reagent)
			reagent_list -= A
			qdel(A)
			update_total()
			my_atom.on_reagent_change()
			return 0
	return 1


/datum/reagents/proc/update_total()
	total_volume = 0
	for(var/datum/reagent/R in reagent_list)
		if(R.volume < 0.1)
			del_reagent(R.id)
		else
			total_volume += R.volume
	return 0


/datum/reagents/proc/clear_reagents()
	for(var/datum/reagent/R in reagent_list)
		del_reagent(R.id)
		return 0


/datum/reagents/proc/reaction(atom/A, method = TOUCH, volume_modifier = 0)
	switch(method)
		if(TOUCH)
			for(var/datum/reagent/R in reagent_list)
				if(ismob(A))
					spawn(0)
						if(!R)
							return
						else
							R.reaction_mob(A, TOUCH, R.volume + volume_modifier)
				if(isturf(A))
					spawn(0)
						if(!R)
							return
						else
							R.reaction_turf(A, R.volume + volume_modifier)
				if(isobj(A))
					spawn(0)
						if(!R)
							return
						else
							R.reaction_obj(A, R.volume + volume_modifier)
		if(INGEST)
			for(var/datum/reagent/R in reagent_list)
				if(ismob(A) && R)
					spawn(0)
						if(!R)
							return
						else
							R.reaction_mob(A, INGEST, R.volume + volume_modifier)
				if(isturf(A) && R)
					spawn(0)
						if(!R)
							return
						else
							R.reaction_turf(A, R.volume + volume_modifier)
				if(isobj(A) && R)
					spawn(0)
						if(!R)
							return
						else
							R.reaction_obj(A, R.volume + volume_modifier)
	return


/datum/reagents/proc/add_reagent(reagent, amount, list/data = null, safety = 0)
	if(!isnum(amount))
		return 1
	update_total()
	if(total_volume + amount > maximum_volume)
		amount = (maximum_volume - total_volume) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.

	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(R.id == reagent)
			R.volume += amount
			update_total()
			my_atom.on_reagent_change()

			// mix dem viruses
			if(R.id == "blood" && reagent == "blood")
				if(R.data && data)
					if(R.data["viruses"] || data["viruses"])
						var/list/mix1 = R.data["viruses"]
						var/list/mix2 = data["viruses"]

						// Stop issues with the list changing during mixing.
						var/list/to_mix = list()

						for(var/datum/disease/advance/AD in mix1)
							to_mix += AD
						for(var/datum/disease/advance/AD in mix2)
							to_mix += AD

						var/datum/disease/advance/AD = Advance_Mix(to_mix)
						if(AD)
							var/list/preserve = list(AD)
							for(var/D in R.data["viruses"])
								if(!istype(D, /datum/disease/advance))
									preserve += D
							R.data["viruses"] = preserve

			if(!safety)
				handle_reactions()
			return 0

	var/datum/reagent/D = global.chemical_reagents_list[reagent]
	if(D)
		var/datum/reagent/R = new D.type()
		reagent_list += R
		R.holder = src
		R.volume = amount
		SetViruses(R, data) // Includes setting data

		//debug
		//world << "Adding data"
		//for(var/D in R.data)
		//	world << "Container data: [D] = [R.data[D]]"
		//debug
		update_total()
		my_atom.on_reagent_change()
		if(!safety)
			handle_reactions()
		return 0
	else
		warning("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")

	if(!safety)
		handle_reactions()

	return 1


/datum/reagents/proc/remove_reagent(reagent, amount, safety = 0)//Added a safety check for the trans_id_to
	if(!isnum(amount))
		return 1

	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(R.id == reagent)
			R.volume -= amount
			update_total()
			if(!safety)//So it does not handle reactions when it need not to
				handle_reactions()
			my_atom.on_reagent_change()
			return 0

	return 1


/datum/reagents/proc/has_reagent(reagent, amount = -1)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(R.id == reagent)
			if(!amount)
				return R
			else
				if(R.volume >= amount)
					return R
				else return 0

	return 0


/datum/reagents/proc/get_reagent_amount(reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(R.id == reagent)
			return R.volume

	return 0


/datum/reagents/proc/get_reagents()
	var/res = ""
	for(var/datum/reagent/A in reagent_list)
		if(res != "")
			res += ","
		res += A.name

	return res


/datum/reagents/proc/remove_all_type(reagent_type, amount, strict = 0, safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
	if(!isnum(amount))
		return 1

	var/has_removed_reagent = 0

	for(var/datum/reagent/R in reagent_list)
		var/matches = 0
		// Switch between how we check the reagent type
		if(strict)
			if(R.type == reagent_type)
				matches = 1
		else
			if(istype(R, reagent_type))
				matches = 1
		// We found a match, proceed to remove the reagent.	Keep looping, we might find other reagents of the same type.
		if(matches)
			// Have our other proc handle removement
			has_removed_reagent = remove_reagent(R.id, amount, safety)

	return has_removed_reagent


//two helper functions to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/get_data(reagent_id)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)
			//world << "proffering a data-carrying reagent ([reagent_id])"
			return D.data


/datum/reagents/proc/set_data(reagent_id, new_data)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)
			//world << "reagent data set ([reagent_id])"
			D.data = new_data


///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
/atom/proc/create_reagents(max_vol)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src