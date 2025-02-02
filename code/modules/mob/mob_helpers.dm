/proc/hsl2rgb(h, s, l)
	return

/proc/check_zone(zone)
	if(!zone)
		return "chest"
	switch(zone)
		if("eyes")
			zone = "head"
		if("mouth")
			zone = "head"
/*		if("l_hand")
			zone = "l_arm"
		if("r_hand")
			zone = "r_arm"
		if("l_foot")
			zone = "l_leg"
		if("r_foot")
			zone = "r_leg"
		if("groin")
			zone = "chest"
*/
	return zone


/proc/ran_zone(zone, probability)
	zone = check_zone(zone)
	if(!probability)
		probability = 90
	if(probability == 100)
		return zone

	if(zone == "chest")
		if(prob(probability))
			return "chest"
		var/t = rand(1, 9)
		switch(t)
			if(1 to 3)
				return "head"
			if(4 to 6)
				return "l_arm"
			if(7 to 9)
				return "r_arm"

	if(prob(probability * 0.75))
		return zone
	return "chest"

// Emulates targetting a specific body part, and miss chances
// May return null if missed
// miss_chance_mod may be negative.
/proc/get_zone_with_miss_chance(zone, mob/target, miss_chance_mod = 0)
	zone = check_zone(zone)

	// you can only miss if your target is standing and not restrained
	if(!target.buckled && !target.lying)
		var/miss_chance = 10
		switch(zone)
			if("head")
				miss_chance = 40
			if("l_leg")
				miss_chance = 20
			if("r_leg")
				miss_chance = 20
			if("l_arm")
				miss_chance = 20
			if("r_arm")
				miss_chance = 20
			if("l_hand")
				miss_chance = 50
			if("r_hand")
				miss_chance = 50
			if("l_foot")
				miss_chance = 50
			if("r_foot")
				miss_chance = 50
		miss_chance = max(miss_chance + miss_chance_mod, 0)
		if(prob(miss_chance))
			if(prob(70))
				return null
			else
				var/t = rand(1, 10)
				switch(t)
					if(1)
						return "head"
					if(2)
						return "l_arm"
					if(3)
						return "r_arm"
					if(4) 
						return "chest"
					if(5) 
						return "l_foot"
					if(6)
						return "r_foot"
					if(7)
						return "l_hand"
					if(8)
						return "r_hand"
					if(9)
						return "l_leg"
					if(10)
						return "r_leg"

	return zone

// Holy shit, this code. Why? -- Marajin
/proc/stars(n, pr)
	if(pr == null)
		pr = 25
	if(pr <= 0)
		return null
	else
		if(pr >= 100)
			return n
	var/te = n
	var/t = ""
	n = length(n)
	var/p = null
	p = 1
	while(p <= n)
		if((copytext(te, p, p + 1) == " " || prob(pr)))
			t = "[t][copytext(te, p, p + 1)]"
		else
			t = "[t]*"
		p++
	return t

/proc/slur(phrase)
	phrase = html_decode(phrase)
	var/leng = length(phrase)
	var/counter = length(phrase)
	var/newphrase = ""
	var/newletter = ""
	while(counter >= 1)
		newletter = copytext(phrase, (leng - counter) + 1, (leng - counter) + 2)
		if(rand(1, 3) == 3)
			if(lowertext(newletter) == "o")
				newletter = "u"
			if(lowertext(newletter) == "s")
				newletter = "ch"
			if(lowertext(newletter) == "a")
				newletter = "ah"
			if(lowertext(newletter) == "c")
				newletter = "k"
		switch(rand(1, 15))
			if(1, 3, 5, 8)
				newletter = "[lowertext(newletter)]"
			if(2, 4, 6, 15)
				newletter = "[uppertext(newletter)]"
			if(7)
				newletter += "'"
			//if(9,10)	newletter="<b>[newletter]</b>"
			//if(11,12)	newletter="<big>[newletter]</big>"
			//if(13)	newletter="<small>[newletter]</small>"
		newphrase += "[newletter]"
		counter -= 1
	return newphrase

/proc/stutter(n)
	var/te = html_decode(n)
	var/t = ""//placed before the message. Not really sure what it's for.
	n = length(n)//length of the entire word
	var/p = null
	p = 1//1 is the start of any word
	while(p <= n)//while P, which starts at 1 is less or equal to N which is the length.
		var/n_letter = copytext(te, p, p + 1)//copies text from a certain distance. In this case, only one letter at a time.
		if(prob(80) && (ckey(n_letter) in list("b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z")))
			if(prob(10))
				n_letter = "[n_letter]-[n_letter]-[n_letter]-[n_letter]" //replaces the current letter with this instead.
			else
				if(prob(20))
					n_letter = "[n_letter]-[n_letter]-[n_letter]"
				else
					if(prob(5))
						n_letter = null
					else
						n_letter = "[n_letter]-[n_letter]"
		t = "[t][n_letter]" //since the above is ran through for each letter, the text just adds up back to the original word.
		p++//for each letter p is increased to find where the next letter will be.
	return copytext(sanitize(t), 1, MAX_MESSAGE_LEN)

/proc/Gibberish(t, p)//t is the inputted message, and any value higher than 70 for p will cause letters to be replaced instead of added
	/* Turn text into complete gibberish! */
	var/returntext = ""
	for(var/i = 1, i <= length(t), i++)

		var/letter = copytext(t, i, i+1)
		if(prob(50))
			if(p >= 70)
				letter = ""

			for(var/j = 1, j <= rand(0, 2), j++)
				letter += pick("#", "@", "*", "&", "%", "$", "/", "<", ">", ";", "*", "*", "*", "*", "*", "*", "*")

		returntext += letter

	return returntext

/proc/ninjaspeak(n)
/*
The difference with stutter is that this proc can stutter more than 1 letter
The issue here is that anything that does not have a space is treated as one word (in many instances). For instance, "LOOKING," is a word, including the comma.
It's fairly easy to fix if dealing with single letters but not so much with compounds of letters./N
*/
	var/te = html_decode(n)
	var/t = ""
	n = length(n)
	var/p = 1
	while(p <= n)
		var/n_letter
		var/n_mod = rand(1, 4)
		if(p + n_mod > n + 1)
			n_letter = copytext(te, p, n + 1)
		else
			n_letter = copytext(te, p, p + n_mod)
		if(prob(50))
			if(prob(30))
				n_letter = "[n_letter]-[n_letter]-[n_letter]"
			else
				n_letter = "[n_letter]-[n_letter]"
		else
			n_letter = "[n_letter]"
		t = "[t][n_letter]"
		p = p + n_mod
	return copytext(sanitize(t), 1, MAX_MESSAGE_LEN)

/proc/shake_camera(mob/M, duration, strength = 1)
	if(!M || !M.client || M.shakecamera)
		return
	spawn(1)
		var/oldeye = M.client.eye
		var/x
		M.shakecamera = 1
		for(x = 0; x < duration, x++)
			M.client.eye = locate(dd_range(1, M.loc.x + rand(-strength, strength), world.maxx), dd_range(1, M.loc.y + rand(-strength, strength), world.maxy), M.loc.z)
			sleep(1)
		M.shakecamera = 0
		M.client.eye = oldeye


/proc/findname(msg)
	for(var/mob/M in mob_list)
		if(M.real_name == msg)
			return 1
	return 0


/mob/proc/abiotic(full_body = 0)
	if(full_body && ((src.l_hand && !src.l_hand.abstract) || (src.r_hand && !src.r_hand.abstract) || (src.back || src.wear_mask)))
		return 1

	if((src.l_hand && !src.l_hand.abstract) || (src.r_hand && !src.r_hand.abstract))
		return 1

	return 0

//converts intent-strings into numbers and back
var/list/intents = list("help", "disarm", "grab", "hurt")
/proc/intent_numeric(argument)
	if(istext(argument))
		switch(argument)
			if("help")
				return 0
			if("disarm")
				return 1
			if("grab")
				return 2
			else
				return 3
	else
		switch(argument)
			if(0)
				return "help"
			if(1)
				return "disarm"
			if(2)
				return "grab"
			else
				return "hurt"

//change a mob's act-intent. Input the intent as a string such as "help" or use "right"/"left
/mob/verb/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if(ishuman(src) || isbrain(src))
		switch(input)
			if("help", "disarm", "grab", "hurt")
				a_intent = input
			if("right")
				a_intent = intent_numeric((intent_numeric(a_intent)+1) % 4)
			if("left")
				a_intent = intent_numeric((intent_numeric(a_intent)+3) % 4)
		if(hud_used && hud_used.action_intent)
			hud_used.action_intent.icon_state = "intent_[a_intent]"

	else if(isrobot(src) || ismonkey(src) || islarva(src))
		switch(input)
			if("help")
				a_intent = "help"
			if("hurt")
				a_intent = "hurt"
			if("right","left")
				a_intent = intent_numeric(intent_numeric(a_intent) - 3)
		if(hud_used && hud_used.action_intent)
			if(a_intent == "hurt")
				hud_used.action_intent.icon_state = "harm"
			else
				hud_used.action_intent.icon_state = "help"

/proc/is_blind(A)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(C.sdisabilities & BLIND || C.blinded)
			return 1
	return 0