//CONTAINS: Evidence bags and fingerprint cards

/obj/item/weapon/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidenceobj"
	item_state = ""
	w_class = 1

/obj/item/weapon/evidencebag/afterattack(obj/item/I, mob/user as mob, proximity)
	if(!proximity)
		return
	if(!in_range(I, user))
		return

	if(!istype(I) || I.anchored == 1)
		return ..()

	if(istype(I, /obj/item/weapon/evidencebag))
		to_chat(user, SPAN_NOTICE("You find putting an evidence bag in another evidence bag to be slightly absurd."))
		return

	if(I.w_class > 3)
		to_chat(user, SPAN_NOTICE("[I] won't fit in [src]."))
		return

	if(contents.len)
		to_chat(user, SPAN_NOTICE("[src] already has something inside it."))
		return ..()

	if(!isturf(I.loc)) //If it isn't on the floor. Do some checks to see if it's in our hands or a box. Otherwise give up.
		if(istype(I.loc,/obj/item/weapon/storage))	//in a container.
			var/obj/item/weapon/storage/U = I.loc
			user.client.screen -= I
			U.contents.Remove(I)
		else if(user.l_hand == I)					//in a hand
			user.drop_l_hand()
		else if(user.r_hand == I)					//in a hand
			user.drop_r_hand()
		else
			return

	user.visible_message(
		"[user] puts [I] into [src]",
		"You put [I] inside [src].",
		"You hear a rustle as someone puts something into a plastic bag."
	)

	icon_state = "evidence"

	var/xx = I.pixel_x	//save the offset of the item
	var/yy = I.pixel_y
	I.pixel_x = 0		//then remove it so it'll stay within the evidence bag
	I.pixel_y = 0
	var/image/img = image("icon" = I, "layer" = FLOAT_LAYER)	//take a snapshot. (necessary to stop the underlays appearing under our inventory-HUD slots ~Carn
	I.pixel_x = xx		//and then return it
	I.pixel_y = yy
	overlays += img
	overlays += "evidence"	//should look nicer for transparent stuff. not really that important, but hey.

	desc = "An evidence bag containing [I]. [I.desc]"
	I.loc = src
	w_class = I.w_class
	return

/obj/item/weapon/evidencebag/attack_self(mob/user as mob)
	if(contents.len)
		var/obj/item/I = contents[1]
		user.visible_message(
			"[user] takes [I] out of [src]",
			"You take [I] out of [src].",
			"You hear someone rustle around in a plastic bag, and remove something."
		)
		overlays.Cut()	//remove the overlays
		user.put_in_hands(I)
		w_class = 1
		icon_state = "evidenceobj"
		desc = "An empty evidence bag."

	else
		to_chat(user, "[src] is empty.")
		icon_state = "evidenceobj"
	return


/obj/item/weapon/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."
	
/obj/item/weapon/storage/box/evidence/New()
	new /obj/item/weapon/evidencebag(src)
	new /obj/item/weapon/evidencebag(src)
	new /obj/item/weapon/evidencebag(src)
	new /obj/item/weapon/evidencebag(src)
	new /obj/item/weapon/evidencebag(src)
	new /obj/item/weapon/evidencebag(src)
	..()
	return

/obj/item/weapon/f_card
	name = "finger print card"
	desc = "Used to take fingerprints."
	icon = 'icons/obj/card.dmi'
	icon_state = "fingerprint0"
	var/amount = 10.0
	item_state = "paper"
	throwforce = 1
	w_class = 1.0
	throw_speed = 3
	throw_range = 5


/obj/item/weapon/fcardholder
	name = "fingerprint card case"
	desc = "Apply finger print card."
	icon = 'icons/obj/items.dmi'
	icon_state = "fcardholder0"
	item_state = "clipboard"
