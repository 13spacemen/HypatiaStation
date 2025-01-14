/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20

	var/icon_living = ""
	var/icon_dead = ""
	var/icon_gib = null	//We only try to show a gibbing animation if this exists.

	var/list/speak = list()
	var/speak_chance = 0
	var/list/emote_hear = list()	//Hearable emotes
	var/list/emote_see = list()		//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

	var/turns_per_move = 1
	var/turns_since_move = 0
	universal_speak = 0		//No, just no.
	var/meat_amount = 0
	var/meat_type
	var/stop_automated_movement = 0 //Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/wander = 1	// Does the mob wander around when idle?
	var/stop_automated_movement_when_pulled = 1 //When set to 1 this stops the animal from moving when someone is pulling it.

	//Interaction
	var/response_help	= "tries to help"
	var/response_disarm = "tries to disarm"
	var/response_harm	= "tries to hurt"
	var/harm_intent_damage = 3

	//Temperature effect
	var/minbodytemp = 250
	var/maxbodytemp = 350
	var/heat_damage_per_tick = 3	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	var/cold_damage_per_tick = 2	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp

	//Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/min_oxy = 5
	var/max_oxy = 0					//Leaving something at 0 means it's off - has no maximum
	var/min_tox = 0
	var/max_tox = 1
	var/min_co2 = 0
	var/max_co2 = 5
	var/min_n2 = 0
	var/max_n2 = 0
	var/unsuitable_atoms_damage = 2	//This damage is taken when atmos doesn't fit all the requirements above

	var/speed = 0 //LETS SEE IF I CAN SET SPEEDS FOR SIMPLE MOBS WITHOUT DESTROYING EVERYTHING. Higher speed is slower, negative speed is faster


	//LETTING SIMPLE ANIMALS ATTACK? WHAT COULD GO WRONG. Defaults to zero so Ian can still be cuddly
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "attacks"
	attack_sound = null
	friendly = "nuzzles" //If the mob does no damage with it's attack

/mob/living/simple_animal/New()
	..()
	verbs -= /mob/verb/observe

/mob/living/simple_animal/Login()
	if(src && src.client)
		src.client.screen = null
	..()

/mob/living/simple_animal/updatehealth()
	return

/mob/living/simple_animal/Life()
	//Health
	if(stat == DEAD)
		if(health > 0)
			icon_state = icon_living
			dead_mob_list -= src
			living_mob_list += src
			stat = CONSCIOUS
			density = 1
		return 0


	if(health < 1)
		Die()

	if(health > maxHealth)
		health = maxHealth

	if(stunned)
		AdjustStunned(-1)
	if(weakened)
		AdjustWeakened(-1)
	if(paralysis)
		AdjustParalysis(-1)

	//Movement
	if(!client && !stop_automated_movement && wander && !anchored)
		if(isturf(src.loc) && !resting && !buckled && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) //Soma animals don't move when pulled
					Move(get_step(src, pick(cardinal)))
					turns_since_move = 0

	//Speaking
	if(!client && speak_chance)
		if(rand(0, 200) < speak_chance)
			if(speak && speak.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1, length)
					if(randomValue <= speak.len)
						say(pick(speak))
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							emote(pick(emote_see), 1)
						else
							emote(pick(emote_hear), 2)
				else
					say(pick(speak))
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					emote(pick(emote_see), 1)
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					emote(pick(emote_hear), 2)
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1, length)
					if(pick <= emote_see.len)
						emote(pick(emote_see), 1)
					else
						emote(pick(emote_hear), 2)


	//Atmos
	var/atmos_suitable = 1

	var/atom/A = src.loc
	if(isturf(A))
		var/turf/T = A

		var/datum/gas_mixture/Environment = T.return_air()

		if(Environment)
			if(abs(Environment.temperature - bodytemperature) > 40)
				var/diff = Environment.temperature - bodytemperature
				diff = diff / 5
				bodytemperature += diff

			if(min_oxy)
				if(Environment.gas[GAS_OXYGEN] < min_oxy)
					atmos_suitable = 0
			if(max_oxy)
				if(Environment.gas[GAS_OXYGEN] > max_oxy)
					atmos_suitable = 0
			if(min_tox)
				if(Environment.gas[GAS_PLASMA] < min_tox)
					atmos_suitable = 0
			if(max_tox)
				if(Environment.gas[GAS_PLASMA] > max_tox)
					atmos_suitable = 0
			if(min_n2)
				if(Environment.gas[GAS_NITROGEN] < min_n2)
					atmos_suitable = 0
			if(max_n2)
				if(Environment.gas[GAS_NITROGEN] > max_n2)
					atmos_suitable = 0
			if(min_co2)
				if(Environment.gas[GAS_CARBON_DIOXIDE] < min_co2)
					atmos_suitable = 0
			if(max_co2)
				if(Environment.gas[GAS_CARBON_DIOXIDE] > max_co2)
					atmos_suitable = 0

	//Atmos effect
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(cold_damage_per_tick)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(heat_damage_per_tick)

	if(!atmos_suitable)
		adjustBruteLoss(unsuitable_atoms_damage)
	return 1

/mob/living/simple_animal/gib()
	if(meat_amount && meat_type)
		for(var/i = 0; i < meat_amount; i++)
			new meat_type(src.loc)
	..(icon_gib, 1)

/mob/living/simple_animal/emote(act, type, desc)
	if(act)
		if(act == "scream")
			act = "whimper" //ugly hack to stop animals screaming when crushed :P
		..(act, type, desc)

/mob/living/simple_animal/attack_animal(mob/living/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message(SPAN_WARNING("<B>[M]</B> [M.attacktext] [src]!"), 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)

/mob/living/simple_animal/bullet_act(obj/item/projectile/Proj)
	if(!Proj)
		return
	adjustBruteLoss(Proj.damage)
	return 0

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M as mob)
	..()
	switch(M.a_intent)
		if("help")
			if(health > 0)
				for(var/mob/O in viewers(src, null))
					if((O.client && !O.blinded))
						O.show_message(SPAN_INFO("[M] [response_help] [src]."))

		if("grab")
			if (M == src)
				return
			if(!(status_flags & CANPUSH))
				return

			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, M, src)

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()
			G.affecting = src
			LAssailant = M

			for(var/mob/O in viewers(src, null))
				if((O.client && !O.blinded))
					O.show_message(SPAN_WARNING("[M] has grabbed [src] passively!"), 1)

		if("hurt", "disarm")
			adjustBruteLoss(harm_intent_damage)
			for(var/mob/O in viewers(src, null))
				if((O.client && !O.blinded))
					O.show_message(SPAN_WARNING("[M] [response_harm] [src]."))

	return

/mob/living/simple_animal/attack_slime(mob/living/carbon/slime/M as mob)
	if(!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.Victim)
		return // can't attack while eating!

	visible_message(SPAN_DANGER("The [M.name] glomps [src]!"))

	var/damage = rand(1, 3)

	if(isslimeadult(src))
		damage = rand(20, 40)
	else
		damage = rand(5, 35)

	adjustBruteLoss(damage)

	return


/mob/living/simple_animal/attackby(obj/item/O as obj, mob/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/stack/medical))

		if(stat != DEAD)
			var/obj/item/stack/medical/MED = O
			if(health < maxHealth)
				if(MED.amount >= 1)
					adjustBruteLoss(-MED.heal_brute)
					MED.amount -= 1
					if(MED.amount <= 0)
						qdel(MED)
					for(var/mob/M in viewers(src, null))
						if((M.client && !M.blinded))
							M.show_message(SPAN_INFO("[user] applies the [MED] on [src]."))
		else
			to_chat(user, SPAN_INFO("This [src] is dead, medical items won't bring it back to life."))
	if(meat_type && (stat == DEAD))	//if the animal has a meat, and if it is dead.
		if(istype(O, /obj/item/weapon/kitchenknife) || istype(O, /obj/item/weapon/butch))
			new meat_type (get_turf(src))
			if(prob(95))
				qdel(src)
				return
			gib()
	else
		if(O.force)
			var/damage = O.force
			if(O.damtype == HALLOSS)
				damage = 0
			adjustBruteLoss(damage)
			for(var/mob/M in viewers(src, null))
				if((M.client && !M.blinded))
					M.show_message(SPAN_DANGER("[src] has been attacked with the [O] by [user]."))
		else
			to_chat(usr, SPAN_WARNING("This weapon is ineffective, it does no damage."))
			for(var/mob/M in viewers(src, null))
				if((M.client && !M.blinded))
					M.show_message(SPAN_WARNING("[user] gently taps [src] with the [O]."))



/mob/living/simple_animal/movement_delay()
	var/tally = 0 //Incase I need to add stuff other than "speed" later

	tally = speed

	return tally + config.animal_delay

/mob/living/simple_animal/Stat()
	..()
	statpanel("Status")
	stat("Health:", "[round((health / maxHealth) * 100)]%")

/mob/living/simple_animal/proc/Die()
	living_mob_list -= src
	dead_mob_list += src
	icon_state = icon_dead
	stat = DEAD
	density = 0
	return

/mob/living/simple_animal/ex_act(severity)
	if(!blinded)
		flick("flash", flash)
	switch (severity)
		if(1.0)
			adjustBruteLoss(500)
			gib()
			return

		if(2.0)
			adjustBruteLoss(60)


		if(3.0)
			adjustBruteLoss(30)

/mob/living/simple_animal/adjustBruteLoss(damage)
	health = Clamp(health - damage, 0, maxHealth)

/mob/living/simple_animal/proc/SA_attackable(target_mob)
	if(isliving(target_mob))
		var/mob/living/L = target_mob
		if(!L.stat && L.health >= 0)
			return 0
	if(istype(target_mob, /obj/mecha))
		var/obj/mecha/M = target_mob
		if(M.occupant)
			return 0
	if(istype(target_mob, /obj/machinery/bot))
		var/obj/machinery/bot/B = target_mob
		if(B.health > 0)
			return 0
	return 1

//Call when target overlay should be added/removed
/mob/living/simple_animal/update_targeted()
	if(!targeted_by && target_locked)
		qdel(target_locked)
	overlays = null
	if(targeted_by && target_locked)
		overlays += target_locked


/mob/living/simple_animal/say(message)
	if(stat)
		return

	if(copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2))

	if(stat)
		return

	var/verbage = "says"

	if(speak_emote.len)
		verbage = pick(speak_emote)

	message = capitalize(trim_left(message))

	..(message, null, verbage)