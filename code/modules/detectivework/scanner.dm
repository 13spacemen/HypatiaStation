//CONTAINS: Detective's Scanner

/obj/item/device/detective_scanner
	name = "Scanner"
	desc = "Used to scan objects for DNA and fingerprints."
	icon_state = "forensic1"
	var/amount = 20.0
	var/list/stored = list()
	w_class = 3.0
	item_state = "electronic"
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_BELT

/obj/item/device/detective_scanner/attackby(obj/item/weapon/f_card/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/f_card))
		if(W.fingerprints)
			return
		if(src.amount == 20)
			return
		if(W.amount + src.amount > 20)
			src.amount = 20
			W.amount = W.amount + src.amount - 20
		else
			src.amount += W.amount
			//W = null
			qdel(W)
		add_fingerprint(user)
		if(W)
			W.add_fingerprint(user)
	return

/obj/item/device/detective_scanner/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	if(!ishuman(M))
		to_chat(user, SPAN_WARNING("[M] is not human and cannot have fingerprints."))
		flick("forensic0", src)
		return 0
	if(!istype(M.dna, /datum/dna) || M.gloves)
		to_chat(user, SPAN_INFO("No fingerprints found on [M]."))
		flick("forensic0", src)
		return 0
	else
		if(src.amount < 1)
			to_chat(user, SPAN_INFO("Fingerprints scanned on [M]. Need more cards to print."))
		else
			src.amount--
			var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card(user.loc)
			F.amount = 1
			F.add_fingerprint(M)
			F.icon_state = "fingerprint1"
			F.name = "FPrintC - '[M.name]'"

			to_chat(user, SPAN_INFO("Done printing."))
		to_chat(user, SPAN_INFO("[M]'s Fingerprints: [md5(M.dna.uni_identity)]"))
	if(!M.blood_DNA || !M.blood_DNA.len)
		to_chat(user, SPAN_INFO("No blood found on [M]."))
		if(M.blood_DNA)
			qdel(M.blood_DNA)
	else
		to_chat(user, SPAN_INFO("Blood found on [M]. Analysing..."))
		spawn(15)
			for(var/blood in M.blood_DNA)
				to_chat(user, SPAN_INFO("Blood type: [M.blood_DNA[blood]]\nDNA: [blood]"))
	return

/obj/item/device/detective_scanner/afterattack(atom/A as obj|turf|area, mob/user as mob, proximity)
	if(!proximity)
		return
	if(loc != user)
		return
	if(istype(A,/obj/machinery/computer/forensic_scanning)) //breaks shit.
		return

	if(istype(A,/obj/item/weapon/f_card))
		to_chat(user, "The scanner displays on the screen: \"ERROR 43: Object on Excluded Object List.\"")
		flick("forensic0", src)
		return

	add_fingerprint(user)

	//Special case for blood splatters, runes and gibs.
	if(istype(A, /obj/effect/decal/cleanable/blood) || isrune(A) || istype(A, /obj/effect/decal/cleanable/blood/gibs))
		if(!isnull(A.blood_DNA))
			for(var/blood in A.blood_DNA)
				to_chat(user, SPAN_INFO("Blood type: [A.blood_DNA[blood]]\nDNA: [blood]"))
				flick("forensic2", src)
		return

	//General
	if((!A.fingerprints || !A.fingerprints.len) && !A.suit_fibers && !A.blood_DNA)
		user.visible_message(
			"\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,
			SPAN_INFO("Unable to locate any fingerprints, materials, fibers, or blood on [A]!"),
			"You hear a faint hum of electrical equipment."
		)
		flick("forensic0", src)
		return 0

	if(add_data(A))
		to_chat(user, SPAN_INFO("Object already in internal memory. Consolidating data..."))
		flick("forensic2", src)
		return

	//PRINTS
	if(!A.fingerprints || !A.fingerprints.len)
		if(A.fingerprints)
			qdel(A.fingerprints)
	else
		to_chat(user, SPAN_INFO("Isolated [A.fingerprints.len] fingerprints: Data Stored: Scan with Hi-Res Forensic Scanner to retrieve."))
		var/list/complete_prints = list()
		for(var/i in A.fingerprints)
			var/print = A.fingerprints[i]
			if(stringpercent(print) <= FINGERPRINT_COMPLETE)
				complete_prints += print
		if(complete_prints.len < 1)
			to_chat(user, SPAN_INFO("&nbsp;&nbsp;No intact prints found."))
		else
			to_chat(user, SPAN_INFO("&nbsp;&nbsp;Found [complete_prints.len] intact prints."))
			for(var/i in complete_prints)
				to_chat(user, SPAN_INFO("&nbsp;&nbsp;&nbsp;&nbsp;[i]."))

	//FIBERS
	if(A.suit_fibers)
		to_chat(user, SPAN_INFO("Fibers/Materials Data Stored: Scan with Hi-Res Forensic Scanner to retrieve."))
		flick("forensic2", src)

	//Blood
	if(A.blood_DNA)
		to_chat(user, SPAN_INFO("Blood found on [A]. Analysing..."))
		spawn(15)
			for(var/blood in A.blood_DNA)
				to_chat(user, "Blood type: \red [A.blood_DNA[blood]] \t \black DNA: \red [blood]")
	if(prob(80) || !A.fingerprints)
		user.visible_message(
			"\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]" ,
			"You finish scanning \the [A].",
			"You hear a faint hum of electrical equipment."
		)
		flick("forensic2", src)
		return 0
	else
		user.visible_message(
			"\The [user] scans \the [A] with \a [src], the air around [user.gender == MALE ? "him" : "her"] humming[prob(70) ? " gently." : "."]\n[user.gender == MALE ? "He" : "She"] seems to perk up slightly at the readout.",
			"The results of the scan pique your interest.",
			"You hear a faint hum of electrical equipment, and someone making a thoughtful noise."
		)
		flick("forensic2", src)
		return 0

/obj/item/device/detective_scanner/proc/add_data(atom/A as mob|obj|turf|area)
	//I love associative lists.
	var/list/data_entry = stored["\ref [A]"]
	if(islist(data_entry)) //Yay, it was already stored!
		//Merge the fingerprints.
		var/list/data_prints = data_entry[1]
		for(var/print in A.fingerprints)
			var/merged_print = data_prints[print]
			if(!merged_print)
				data_prints[print] = A.fingerprints[print]
			else
				data_prints[print] = stringmerge(data_prints[print],A.fingerprints[print])

		//Now the fibers
		var/list/fibers = data_entry[2]
		if(!fibers)
			fibers = list()
		if(A.suit_fibers && A.suit_fibers.len)
			for(var/j = 1, j <= A.suit_fibers.len, j++)	//Fibers~~~
				if(!fibers.Find(A.suit_fibers[j]))	//It isn't!  Add!
					fibers += A.suit_fibers[j]
		var/list/blood = data_entry[3]
		if(!blood)
			blood = list()
		if(A.blood_DNA && A.blood_DNA.len)
			for(var/main_blood in A.blood_DNA)
				if(!blood[main_blood])
					blood[main_blood] = A.blood_DNA[blood]
		return 1
	var/list/sum_list[4]	//Pack it back up!
	sum_list[1] = A.fingerprints ? A.fingerprints.Copy() : null
	sum_list[2] = A.suit_fibers ? A.suit_fibers.Copy() : null
	sum_list[3] = A.blood_DNA ? A.blood_DNA.Copy() : null
	sum_list[4] = "\The [A] in \the [get_area(A)]"
	stored["\ref [A]"] = sum_list
	return 0