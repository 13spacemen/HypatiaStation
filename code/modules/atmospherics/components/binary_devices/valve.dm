/obj/machinery/atmospherics/binary/valve
	icon = 'icons/obj/atmospherics/valve.dmi'
	icon_state = "valve0"

	name = "manual valve"
	desc = "A pipe valve"

	var/open = 0
	var/openDuringInit = 0

/obj/machinery/atmospherics/binary/valve/initialize()
	normalize_dir()

	var/node1_dir
	var/node2_dir

	for(var/direction in cardinal)
		if(direction & initialize_directions)
			if(!node1_dir)
				node1_dir = direction
			else if(!node2_dir)
				node2_dir = direction

	for(var/obj/machinery/atmospherics/target in get_step(src, node1_dir))
		if(target.initialize_directions & get_dir(target, src))
			node1 = target
			break
	for(var/obj/machinery/atmospherics/target in get_step(src, node2_dir))
		if(target.initialize_directions & get_dir(target, src))
			node2 = target
			break

	build_network()

	if(openDuringInit)
		close()
		open()
		openDuringInit = 0

/*
	var/connect_directions
	switch(dir)
		if(NORTH)
			connect_directions = NORTH|SOUTH
		if(SOUTH)
			connect_directions = NORTH|SOUTH
		if(EAST)
			connect_directions = EAST|WEST
		if(WEST)
			connect_directions = EAST|WEST
		else
			connect_directions = dir

	for(var/direction in cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					connect_directions &= ~direction
					node1 = target
					break
			if(node1)
				break

	for(var/direction in cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					node2 = target
					break
			if(node1)
				break
*/

/obj/machinery/atmospherics/binary/valve/open
	open = 1
	icon_state = "valve1"

/obj/machinery/atmospherics/binary/valve/update_icon(animation)
	if(animation)
		flick("valve[src.open][!src.open]", src)
	else
		icon_state = "valve[open]"

/obj/machinery/atmospherics/binary/valve/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network1 = new_network
		if(open)
			network2 = new_network
	else if(reference == node2)
		network2 = new_network
		if(open)
			network1 = new_network

	if(new_network.normal_members.Find(src))
		return 0

	new_network.normal_members += src

	if(open)
		if(reference == node1)
			if(node2)
				return node2.network_expand(new_network, src)
		else if(reference == node2)
			if(node1)
				return node1.network_expand(new_network, src)

	return null

/obj/machinery/atmospherics/binary/valve/proc/open()
	if(open)
		return 0

	open = 1
	update_icon()

	if(network1 && network2)
		network1.merge(network2)
		network2 = network1

	if(network1)
		network1.update = TRUE
	else if(network2)
		network2.update = TRUE

	return 1

/obj/machinery/atmospherics/binary/valve/proc/close()
	if(!open)
		return 0

	open = 0
	update_icon()

	if(network1)
		qdel(network1)
	if(network2)
		qdel(network2)

	build_network()

	return 1

/obj/machinery/atmospherics/binary/valve/proc/normalize_dir()
	if(dir == 3)
		dir = 1
	else if(dir == 12)
		dir = 4

/obj/machinery/atmospherics/binary/valve/attack_ai(mob/user as mob)
	return

/obj/machinery/atmospherics/binary/valve/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/atmospherics/binary/valve/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	update_icon(1)
	sleep(10)
	if(src.open)
		src.close()
	else
		src.open()

/obj/machinery/atmospherics/binary/valve/process()
	..()
	. = PROCESS_KILL

/*	if(open && (!node1 || !node2))
		close()
	if(!node1)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if (!node2)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if (nodealert)
		nodealert = 0
*/

	return

/obj/machinery/atmospherics/binary/valve/digital		// can be controlled by AI
	name = "digital valve"
	desc = "A digitally controlled valve."
	icon = 'icons/obj/atmospherics/digital_valve.dmi'

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/binary/valve/digital/initialize()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/binary/valve/digital/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/atmospherics/binary/valve/digital/attack_hand(mob/user as mob)
	if(!src.allowed(user))
		to_chat(user, SPAN_WARNING("Access denied."))
		return
	..()

//Radio remote control
/obj/machinery/atmospherics/binary/valve/digital/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/binary/valve/digital/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || signal.data["tag"] != id)
		return 0

	switch(signal.data["command"])
		if("valve_open")
			if(!open)
				open()

		if("valve_close")
			if(open)
				close()

		if("valve_toggle")
			if(open)
				close()
			else
				open()

/obj/machinery/atmospherics/binary/valve/digital/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!istype(W, /obj/item/weapon/wrench))
		return ..()
	if(istype(src, /obj/machinery/atmospherics/binary/valve/digital))
		to_chat(user, SPAN_WARNING("You cannot unwrench this [src], it's too complicated."))
		return 1

	var/turf/T = src.loc
	if(level == 1 && isturf(T) && T.intact)
		to_chat(user, SPAN_WARNING("You must remove the plating first."))
		return 1

	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	if((int_air.return_pressure() - env_air.return_pressure()) > 2 * ONE_ATMOSPHERE)
		to_chat(user, SPAN_WARNING("You cannot unwrench this [src], it too exerted due to internal pressure."))
		add_fingerprint(user)
		return 1

	playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, SPAN_INFO("You begin to unfasten \the [src]..."))
	if(do_after(user, 40))
		user.visible_message(
			"[user] unfastens \the [src].",
			SPAN_INFO("You have unfastened \the [src]."),
			"You hear a ratchet."
		)
		new /obj/item/pipe(loc, make_from = src)
		qdel(src)