/obj/item/weapon/cell
	name = "power cell"
	desc = "A rechargable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	origin_tech = list(RESEARCH_TECH_POWERSTORAGE = 1)
	force = 5.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	w_class = 3.0
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 1000
	m_amt = 700
	g_amt = 50
	var/rigged = 0		// true if rigged to explode
	var/minor_fault = 0 //If not 100% reliable, it will build up faults.
	var/construction_cost = list(MATERIAL_METAL = 750, MATERIAL_GLASS = 75)
	var/construction_time = 100

/obj/item/weapon/cell/suicide_act(mob/user)
	user.visible_message(SPAN_DANGER("[user] is licking the electrodes of the [src.name]! It looks like \he's trying to commit suicide."))
	return (FIRELOSS)


/obj/item/weapon/cell/crap
	name = "\improper NanoTrasen brand rechargable AA battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	origin_tech = list(RESEARCH_TECH_POWERSTORAGE = 0)
	maxcharge = 500
	g_amt = 40

/obj/item/weapon/cell/crap/empty/New()
	..()
	charge = 0


/obj/item/weapon/cell/secborg
	name = "security borg rechargable D battery"
	origin_tech = list(RESEARCH_TECH_POWERSTORAGE = 0)
	maxcharge = 600	//600 max charge / 100 charge per shot = six shots
	g_amt = 40

/obj/item/weapon/cell/secborg/empty/New()
	..()
	charge = 0


/obj/item/weapon/cell/apc
	name = "APC power cell"
	origin_tech = list(RESEARCH_TECH_POWERSTORAGE = 1)
	maxcharge = 5000
	g_amt = 50

/obj/item/weapon/cell/apc/empty/New()
	..()


/obj/item/weapon/cell/high
	name = "high-capacity power cell"
	origin_tech = list(RESEARCH_TECH_POWERSTORAGE = 2)
	icon_state = "hcell"
	maxcharge = 10000
	g_amt = 60

/obj/item/weapon/cell/high/empty/New()
	..()
	charge = 0


/obj/item/weapon/cell/super
	name = "super-capacity power cell"
	origin_tech = list(RESEARCH_TECH_POWERSTORAGE = 5)
	icon_state = "scell"
	maxcharge = 20000
	g_amt = 70
	construction_cost = list(MATERIAL_METAL = 750, MATERIAL_GLASS = 100)

/obj/item/weapon/cell/super/empty/New()
	..()
	charge = 0


/obj/item/weapon/cell/hyper
	name = "hyper-capacity power cell"
	origin_tech = list(RESEARCH_TECH_POWERSTORAGE = 6)
	icon_state = "hpcell"
	maxcharge = 30000
	g_amt = 80
	construction_cost = list(MATERIAL_METAL = 500, MATERIAL_GLASS = 150, MATERIAL_GOLD = 200, MATERIAL_SILVER = 200)

/obj/item/weapon/cell/hyper/empty/New()
	..()
	charge = 0


/obj/item/weapon/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	origin_tech =  null
	maxcharge = 30000
	g_amt = 80

/obj/item/weapon/cell/infinite/use()
	return 1

/obj/item/weapon/cell/potato
	name = "potato battery"
	desc = "A rechargable starch based power cell."
	origin_tech = list(RESEARCH_TECH_POWERSTORAGE = 1)
	icon = 'icons/obj/power.dmi' //'icons/obj/harvest.dmi'
	icon_state = "potato_cell" //"potato_battery"
	charge = 100
	maxcharge = 300
	m_amt = 0
	g_amt = 0
	minor_fault = 1


/obj/item/weapon/cell/slime
	name = "charged slime core"
	desc = "A yellow slime core infused with plasma, it crackles with power."
	origin_tech = list(RESEARCH_TECH_POWERSTORAGE = 2, RESEARCH_TECH_BIOTECH = 4)
	icon = 'icons/mob/slimes.dmi' //'icons/obj/harvest.dmi'
	icon_state = "yellow slime extract" //"potato_battery"
	maxcharge = 10000
	maxcharge = 10000
	m_amt = 0
	g_amt = 0