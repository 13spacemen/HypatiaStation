/obj/structure/closet/secure_closet/bar
	name = "Booze"
	req_access = list(ACCESS_BAR)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"

/obj/structure/closet/secure_closet/bar/New()
	..()
	new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)

/obj/structure/closet/secure_closet/bar/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened