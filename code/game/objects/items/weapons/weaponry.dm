/obj/item/weapon/banhammer
	desc = "A banhammer"
	name = "banhammer"
	icon = 'icons/obj/items.dmi'
	icon_state = "toyhammer"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	attack_verb = list("banned")

/obj/item/weapon/banhammer/suicide_act(mob/user)
	user.visible_message(SPAN_DANGER("[user] is hitting \himself with the [src.name]! It looks like \he's trying to ban \himself from life."))
	return (BRUTELOSS | FIRELOSS | TOXLOSS | OXYLOSS)


/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of paranormal phenomenae."
	icon_state = "nullrod"
	item_state = "nullrod"
	slot_flags = SLOT_BELT
	force = 15
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	w_class = 1

/obj/item/weapon/nullrod/suicide_act(mob/user)
	user.visible_message(SPAN_DANGER("[user] is impaling \himself with the [src.name]! It looks like \he's trying to commit suicide."))
	return (BRUTELOSS | FIRELOSS)

/obj/item/weapon/nullrod/attack(mob/M as mob, mob/living/user as mob) //Paste from old-code to decult with a null rod.
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	msg_admin_attack("[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	if(!(ishuman(user) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, SPAN_WARNING("You don't have the dexterity to do this!"))
		return

	if(CLUMSY in user.mutations && prob(50))
		to_chat(user, SPAN_WARNING("The rod slips out of your hand and hits your head."))
		user.take_organ_damage(10)
		user.Paralyse(20)
		return

	if(M.stat != DEAD)
		if(M.mind in ticker.mode.cult && prob(33))
			to_chat(M, SPAN_WARNING("The power of [src] clears your mind of the cult's influence!"))
			to_chat(user, SPAN_WARNING("You wave [src] over [M]'s head and see their eyes become clear, their mind returning to normal."))
			ticker.mode.remove_cultist(M.mind)
			M.visible_message(SPAN_WARNING("[user] waves [src] over [M]'s head."))
		else if(prob(10))
			to_chat(user, SPAN_WARNING("The rod slips in your hand."))
			..()
		else
			to_chat(user, SPAN_WARNING("The rod appears to do nothing."))
			M.visible_message(SPAN_WARNING("[user] waves [src] over [M]'s head."))

/obj/item/weapon/nullrod/afterattack(atom/A, mob/user as mob)
	if(istype(A, /turf/simulated/floor))
		to_chat(user, SPAN_INFO("You hit the floor with the [src]."))
		call(/obj/effect/rune/proc/revealrunes)(src)


/obj/item/weapon/sord
	name = "\improper SORD"
	desc = "This thing is so unspeakably shitty you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	slot_flags = SLOT_BELT
	force = 2
	throwforce = 1
	sharp = 1
	edge = 1
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/sord/suicide_act(mob/user)
	user.visible_message(SPAN_DANGER("[user] is impaling \himself with the [src.name]! It looks like \he's trying to commit suicide."))
	return(BRUTELOSS)

/obj/item/weapon/sord/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()


/obj/item/weapon/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 40
	throwforce = 10
	sharp = 1
	edge = 1
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/claymore/IsShield()
	return 1

/obj/item/weapon/claymore/suicide_act(mob/user)
	user.visible_message(SPAN_DANGER("[user] is falling on the [src.name]! It looks like \he's trying to commit suicide."))
	return(BRUTELOSS)

/obj/item/weapon/claymore/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()


/obj/item/weapon/katana
	name = "katana"
	desc = "Woefully underpowered in D20"
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 40
	throwforce = 10
	sharp = 1
	edge = 1
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/katana/suicide_act(mob/user)
	user.visible_message(SPAN_DANGER("[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku."))
	return(BRUTELOSS)

/obj/item/weapon/katana/IsShield()
	return 1

/obj/item/weapon/katana/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()


/obj/item/weapon/harpoon
	name = "harpoon"
	sharp = 1
	edge = 0
	desc = "Tharr she blows!"
	icon_state = "harpoon"
	item_state = "harpoon"
	force = 20
	throwforce = 15
	w_class = 3
	attack_verb = list("jabbed", "stabbed", "ripped")