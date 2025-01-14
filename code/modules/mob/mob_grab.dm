#define UPGRADE_COOLDOWN	40
#define UPGRADE_KILL_TIMER	100

/obj/item/weapon/grab
	name = "grab"
	flags = NOBLUDGEON
	var/obj/screen/grab/hud = null
	var/mob/affecting = null
	var/mob/assailant = null
	var/state = GRAB_PASSIVE

	var/allow_upgrade = 1
	var/last_upgrade = 0

	var/destroying = 0

	layer = 21
	abstract = 1
	item_state = "nothing"
	w_class = 5.0

/obj/item/weapon/grab/New(mob/user, mob/victim)
	..()
	loc = user
	assailant = user
	affecting = victim

	if(affecting.anchored || !assailant.Adjacent(victim))
		qdel(src)
		return

	hud = new /obj/screen/grab(src)
	hud.icon_state = "reinforce"
	hud.name = "reinforce grab"
	hud.master = src

/obj/item/weapon/grab/Destroy()
	if(affecting)
		affecting.grabbed_by -= src
		affecting = null
	if(assailant)
		if(assailant.client)
			assailant.client.screen -= hud
		assailant = null
	qdel(hud)
	hud = null
	destroying = 1 // stops us calling qdel(src) on dropped()
	return ..()

//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/weapon/grab/proc/thrown()
	if(affecting)
		if(affecting.buckled)
			return null
		if(state >= GRAB_AGGRESSIVE)
			return affecting
	return null

//This makes sure that the grab screen object is displayed in the correct hand.
/obj/item/weapon/grab/proc/synch()
	if(affecting)
		if(assailant.r_hand == src)
			hud.screen_loc = ui_rhand
		else
			hud.screen_loc = ui_lhand

/obj/item/weapon/grab/process()
	if(gcDestroyed) // GC is trying to delete us, we'll kill our processing so we can cleanly GC
		return PROCESS_KILL

	confirm()
	if(!assailant)
		qdel(src) // Same here, except we're trying to delete ourselves.
		return PROCESS_KILL

	if(assailant.client)
		assailant.client.screen -= hud
		assailant.client.screen += hud

	if(assailant.pulling == affecting)
		assailant.stop_pulling()

	if(state <= GRAB_AGGRESSIVE)
		allow_upgrade = 1
		//disallow upgrading if we're grabbing more than one person
		if((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.l_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.r_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if(state == GRAB_AGGRESSIVE)
			affecting.drop_l_hand()
			affecting.drop_r_hand()
			//disallow upgrading past aggressive if we're being grabbed aggressively
			for(var/obj/item/weapon/grab/G in affecting.grabbed_by)
				if(G == src)
					continue
				if(G.state == GRAB_AGGRESSIVE)
					allow_upgrade = 0
		if(allow_upgrade)
			hud.icon_state = "reinforce"
		else
			hud.icon_state = "!reinforce"

	else if(!affecting.buckled)
		affecting.loc = assailant.loc

	if(state >= GRAB_NECK)
		affecting.Stun(1)
		if(isliving(affecting))
			var/mob/living/L = affecting
			L.adjustOxyLoss(1)

	if(state >= GRAB_KILL)
		//affecting.apply_effect(STUTTER, 5) //would do this, but affecting isn't declared as mob/living for some stupid reason.
		affecting.stuttering = max(affecting.stuttering, 5) //It will hamper your voice, being choked and all.
		affecting.Weaken(5)	//Should keep you down unless you get help.
		affecting.losebreath = min(affecting.losebreath + 2, 3)

/obj/item/weapon/grab/proc/s_click(obj/screen/S)
	if(!affecting)
		return
	if(state == GRAB_UPGRADING)
		return
	if(assailant.next_move > world.time)
		return
	if(world.time < (last_upgrade + UPGRADE_COOLDOWN))
		return
	if(!assailant.canmove || assailant.lying)
		qdel(src)
		return

	last_upgrade = world.time

	if(state < GRAB_AGGRESSIVE)
		if(!allow_upgrade)
			return
		assailant.visible_message(SPAN_WARNING("[assailant] has grabbed [affecting] aggressively (now hands)!"))
		state = GRAB_AGGRESSIVE
		icon_state = "grabbed1"

	else if(state < GRAB_NECK)
		if(isslime(affecting))
			to_chat(assailant, SPAN_NOTICE("You squeeze [affecting], but nothing interesting happens."))
			return

		assailant.visible_message(SPAN_WARNING("[assailant] has reinforced \his grip on [affecting] (now neck)!"))
		state = GRAB_NECK
		icon_state = "grabbed+1"
		if(!affecting.buckled)
			affecting.loc = assailant.loc
		affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has had their neck grabbed by [assailant.name] ([assailant.ckey])</font>"
		assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Grabbed the neck of [affecting.name] ([affecting.ckey])</font>"
		msg_admin_attack("[key_name(assailant)] grabbed the neck of [key_name(affecting)]")
		hud.icon_state = "disarm/kill"
		hud.name = "disarm/kill"

	else if(state < GRAB_UPGRADING)
		assailant.visible_message(SPAN_DANGER("[assailant] starts to tighten \his grip on [affecting]'s neck!"))
		hud.icon_state = "disarm/kill1"
		state = GRAB_UPGRADING
		if(do_after(assailant, UPGRADE_KILL_TIMER))
			if(state == GRAB_KILL)
				return
			if(!affecting)
				qdel(src)
				return
			if(!assailant.canmove || assailant.lying)
				qdel(src)
				return
			state = GRAB_KILL
			assailant.visible_message(SPAN_DANGER("[assailant] has tightened \his grip on [affecting]'s neck!"))
			affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been strangled (kill intent) by [assailant.name] ([assailant.ckey])</font>"
			assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Strangled (kill intent) [affecting.name] ([affecting.ckey])</font>"
			msg_admin_attack("[key_name(assailant)] strangled (kill intent) [key_name(affecting)]")

			assailant.next_move = world.time + 10
			affecting.losebreath += 1
		else
			assailant.visible_message(SPAN_WARNING("[assailant] was unable to tighten \his grip on [affecting]'s neck!"))
			hud.icon_state = "disarm/kill"
			state = GRAB_NECK

//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/grab/proc/confirm()
	if(!assailant || !affecting)
		qdel(src)
		return 0

	if(affecting)
		if(!isturf(assailant.loc) || (!isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1))
			qdel(src)
			return 0

	return 1

/obj/item/weapon/grab/attack(mob/M, mob/user)
	if(!affecting)
		return

	if(M == affecting)
		s_click(hud)
		return

	if(M == assailant && state >= GRAB_AGGRESSIVE)
		var/can_eat

		if((FAT in user.mutations) && ismonkey(affecting))
			can_eat = 1
		else
			var/mob/living/carbon/human/H = user
			if(istype(H) && iscarbon(affecting) && H.species.gluttonous)
				if(H.species.gluttonous == 2)
					can_eat = 2
				else if(!ishuman(affecting))
					can_eat = 1

		if(can_eat)
			var/mob/living/carbon/attacker = user
			user.visible_message(SPAN_DANGER("[user] is attempting to devour [affecting]!"))
			if(can_eat == 2)
				if(!do_mob(user, affecting) || !do_after(user, 30))
					return
			else
				if(!do_mob(user, affecting) || !do_after(user, 100))
					return
			user.visible_message(SPAN_DANGER("[user] devours [affecting]!"))
			affecting.loc = user
			attacker.stomach_contents.Add(affecting)
			qdel(src)

/obj/item/weapon/grab/dropped()
	loc = null
	if(!destroying)
		qdel(src)

#undef UPGRADE_COOLDOWN
#undef UPGRADE_KILL_TIMER