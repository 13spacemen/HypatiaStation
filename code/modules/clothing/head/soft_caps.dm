/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "cargosoft"
	flags = HEADCOVERSEYES
	item_state = "helmet"
	item_color = "cargo"
	var/flipped = 0
	siemens_coefficient = 0.9

/obj/item/clothing/head/soft/dropped()
	icon_state = "[item_color]soft"
	flipped = 0
	..()

/obj/item/clothing/head/soft/attack_self(mob/user)
	if(user.canmove && !user.stat && !user.restrained())
		flipped = !flipped
		if(flipped)
			icon_state = "[item_color]soft_flipped"
			to_chat(user, "You flip the hat backwards.")
		else
			icon_state = "[item_color]soft"
			to_chat(user, "You flip the hat back in normal position.")
		user.update_inv_head()	//so our mob-overlays update

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red color."
	icon_state = "redsoft"
	item_color = "red"

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue color."
	icon_state = "bluesoft"
	item_color = "blue"

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green color."
	icon_state = "greensoft"
	item_color = "green"

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "yellowsoft"
	item_color = "yellow"

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey color."
	icon_state = "greysoft"
	item_color = "grey"

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange color."
	icon_state = "orangesoft"
	item_color = "orange"

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white color."
	icon_state = "mimesoft"
	item_color = "mime"

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple color."
	icon_state = "purplesoft"
	item_color = "purple"

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbowsoft"
	item_color = "rainbow"

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's baseball hat in tasteful red color."
	icon_state = "secsoft"
	item_color = "sec"

/obj/item/clothing/head/soft/sec/corp
	name = "corporate security cap"
	desc = "It's baseball hat in corporate colors."
	icon_state = "corpsoft"
	item_color = "corp"