/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/obj/screen
	name = ""
	icon = 'icons/mob/screen1.dmi'
	layer = 20.0
	unacidable = 1
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/gun_click_time = -100 //I'm lazy.

/obj/screen/Destroy()
	master = null
	return ..()

/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = 0
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.

/obj/screen/close
	name = "close"

/obj/screen/close/Click()
	if(master)
		if(istype(master, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = master
			S.close(usr)
	return 1

/obj/screen/item_action
	var/obj/item/owner

/obj/screen/item_action/New(obj/item/O)
	..()
	owner = O

/obj/screen/item_action/Destroy()
	owner = null
	return ..()

/obj/screen/item_action/Click()
	if(!usr || !owner)
		return 1
	if(usr.next_move >= world.time)
		return
	usr.next_move = world.time + 6

	if(usr.stat || usr.restrained() || usr.stunned || usr.lying)
		return 1

	if(!(owner in usr))
		return 1

	owner.ui_action_click()
	return 1

//This is the proc used to update all the action buttons. It just returns for all mob types except humans.
/mob/proc/update_action_buttons()
	return

/obj/screen/grab
	name = "grab"

/obj/screen/grab/Click()
	var/obj/item/weapon/grab/G = master
	G.s_click(src)
	return 1

/obj/screen/grab/attack_hand()
	return

/obj/screen/grab/attackby()
	return

/obj/screen/storage
	name = "storage"

/obj/screen/storage/Click()
	if(world.time <= usr.next_move)
		return 1
	if(usr.stat || usr.paralysis || usr.stunned || usr.weakened)
		return 1
	if(istype(usr.loc, /obj/mecha)) // stops inventory actions in a mech
		return 1
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			master.attackby(I, usr)
			usr.next_move = world.time + 2
	return 1

/obj/screen/gun
	name = "gun"
	icon = 'icons/mob/screen1.dmi'
	master = null
	dir = 2

/obj/screen/gun/move
	name = "Allow Walking"
	icon_state = "no_walk0"
	screen_loc = ui_gun2

/obj/screen/gun/run
	name = "Allow Running"
	icon_state = "no_run0"
	screen_loc = ui_gun3

/obj/screen/gun/item
	name = "Allow Item Use"
	icon_state = "no_item0"
	screen_loc = ui_gun1

/obj/screen/gun/mode
	name = "Toggle Gun Mode"
	icon_state = "gun0"
	screen_loc = ui_gun_select
	//dir = 1

/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = "chest"

/obj/screen/zone_sel/Click(location, control,params)
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/old_selecting = selecting //We're only going to update_icon() if there's been a change

	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					selecting = "r_foot"
				if(17 to 22)
					selecting = "l_foot"
				else
					return 1
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					selecting = "r_leg"
				if(17 to 22)
					selecting = "l_leg"
				else
					return 1
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					selecting = "r_hand"
				if(12 to 20)
					selecting = "groin"
				if(21 to 24)
					selecting = "l_hand"
				else
					return 1
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					selecting = "r_arm"
				if(12 to 20)
					selecting = "chest"
				if(21 to 24)
					selecting = "l_arm"
				else
					return 1
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				selecting = "head"
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							selecting = "mouth"
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							selecting = "eyes"
					if(25 to 27)
						if(icon_x in 15 to 17)
							selecting = "eyes"

	if(old_selecting != selecting)
		update_icon()
	return 1

/obj/screen/zone_sel/update_icon()
	overlays.Cut()
	overlays += image('icons/mob/zone_sel.dmi', "[selecting]")

/obj/screen/Click(location, control, params)
	if(!usr)
		return 1

	switch(name)
		if("toggle")
			if(usr.hud_used.inventory_shown)
				usr.hud_used.inventory_shown = 0
				usr.client.screen -= usr.hud_used.other
			else
				usr.hud_used.inventory_shown = 1
				usr.client.screen += usr.hud_used.other

			usr.hud_used.hidden_inventory_update()

		if("equip")
			if(istype(usr.loc, /obj/mecha)) // stops inventory actions in a mech
				return 1
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.quick_equip()

		if("resist")
			if(isliving(usr))
				var/mob/living/L = usr
				L.resist()

		if("mov_intent")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				if(C.legcuffed)
					to_chat(C, SPAN_NOTICE("You are legcuffed! You cannot run until you get [C.legcuffed] removed!"))
					C.m_intent = "walk"	//Just incase
					C.hud_used.move_intent.icon_state = "walking"
					return 1
				switch(usr.m_intent)
					if("run")
						usr.m_intent = "walk"
						usr.hud_used.move_intent.icon_state = "walking"
					if("walk")
						usr.m_intent = "run"
						usr.hud_used.move_intent.icon_state = "running"
		if("m_intent")
			if(!usr.m_int)
				switch(usr.m_intent)
					if("run")
						usr.m_int = "13,14"
					if("walk")
						usr.m_int = "14,14"
					if("face")
						usr.m_int = "15,14"
			else
				usr.m_int = null
		if("walk")
			usr.m_intent = "walk"
			usr.m_int = "14,14"
		if("face")
			usr.m_intent = "face"
			usr.m_int = "15,14"
		if("run")
			usr.m_intent = "run"
			usr.m_int = "13,14"
		if("Reset Machine")
			usr.unset_machine()
		if("internal")
			usr.ui_toggle_internals()
		if("act_intent")
			usr.a_intent_change("right")
		if("help")
			usr.a_intent = "help"
			usr.hud_used.action_intent.icon_state = "intent_help"
		if("harm")
			usr.a_intent = "hurt"
			usr.hud_used.action_intent.icon_state = "intent_hurt"
		if("grab")
			usr.a_intent = "grab"
			usr.hud_used.action_intent.icon_state = "intent_grab"
		if("disarm")
			usr.a_intent = "disarm"
			usr.hud_used.action_intent.icon_state = "intent_disarm"

		if("pull")
			usr.stop_pulling()
		if("throw")
			if(!usr.stat && isturf(usr.loc) && !usr.restrained())
				usr:toggle_throw_mode()
		if("drop")
			usr.drop_item_v()

		if("module")
			if(issilicon(usr))
				if(usr:module)
					return 1
				usr:pick_module()

		if("radio")
			if(issilicon(usr))
				usr:radio_menu()
		if("panel")
			if(issilicon(usr))
				usr:installed_modules()

		if("store")
			if(issilicon(usr))
				usr:uneq_active()

		if("module1")
			if(isrobot(usr))
				usr:toggle_module(1)

		if("module2")
			if(isrobot(usr))
				usr:toggle_module(2)

		if("module3")
			if(isrobot(usr))
				usr:toggle_module(3)

		if("Allow Walking")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.equipped(), /obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetMove()
			gun_click_time = world.time

		if("Disallow Walking")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.equipped(), /obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetMove()
			gun_click_time = world.time

		if("Allow Running")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.equipped(), /obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetRun()
			gun_click_time = world.time

		if("Disallow Running")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.equipped(), /obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetRun()
			gun_click_time = world.time

		if("Allow Item Use")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.equipped(), /obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetClick()
			gun_click_time = world.time

		if("Disallow Item Use")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.equipped(), /obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetClick()
			gun_click_time = world.time

		if("Toggle Gun Mode")
			usr.client.ToggleGunMode()

		else
			return 0
	return 1

/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.stat || usr.paralysis || usr.stunned || usr.weakened)
		return 1
	if(istype(usr.loc, /obj/mecha)) // stops inventory actions in a mech
		return 1
	switch(name)
		if("r_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("r")
				usr.next_move = world.time + 2
		if("l_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("l")
				usr.next_move = world.time + 2
		if("swap")
			usr:swap_hand()
		if("hand")
			usr:swap_hand()
		else
			if(usr.attack_ui(slot_id))
				usr.update_inv_l_hand(0)
				usr.update_inv_r_hand(0)
				usr.next_move = world.time + 6
	return 1