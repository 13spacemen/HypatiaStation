/obj/machinery/atmospherics/trinary/filter
	icon = 'icons/obj/atmospherics/filter.dmi'
	icon_state = "intact_off"
	//density = 1
	density = 0 // Made filters and mixers not-dense so you can walk over them. -Frenjo

	name = "Gas filter"

	var/on = 0
	var/temp = null // -- TLE

	var/target_pressure = ONE_ATMOSPHERE

	var/filter_type = 0
/*
Filter types:
-1: Nothing
 0: Carbon Molecules: Plasma Toxin, Oxygen Agent B
 1: Oxygen: Oxygen ONLY
 2: Nitrogen: Nitrogen ONLY
 3: Carbon Dioxide: Carbon Dioxide ONLY
 4: Sleeping Agent (N2O)
*/
	var/frequency = 0
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/trinary/filter/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/trinary/filter/New()
	..()

/obj/machinery/atmospherics/trinary/filter/update_icon()
	if(stat & NOPOWER)
		icon_state = "intact_off"
	else if(node2 && node3 && node1)
		icon_state = "intact_[on?("on"):("off")]"
	else
		icon_state = "intact_off"
		on = 0

	return

/obj/machinery/atmospherics/trinary/filter/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/trinary/filter/process()
	..()
	if(!on)
		return 0

	var/output_starting_pressure = air3.return_pressure()

	if(output_starting_pressure >= target_pressure || air2.return_pressure() >= target_pressure )
		//No need to mix if target is already full!
		return 1

	//Calculate necessary moles to transfer using PV=nRT

	var/pressure_delta = target_pressure - output_starting_pressure
	var/transfer_moles

	if(air1.temperature > 0)
		transfer_moles = pressure_delta * air3.volume / (air1.temperature * R_IDEAL_GAS_EQUATION)

	//Actually transfer the gas

	if(transfer_moles > 0)
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)

		if(!removed)
			return
		var/datum/gas_mixture/filtered_out = new
		filtered_out.temperature = removed.temperature

		switch(filter_type)
			if(0) //removing hydrocarbons
				filtered_out.gas["plasma"] = removed.gas["plasma"]
				removed.gas["plasma"] = 0

				filtered_out.gas["oxygen_agent_b"] = removed.gas["oxygen_agent_b"]
				removed.gas["oxygen_agent_b"] = 0

			if(1) //removing O2
				filtered_out.gas["oxygen"] = removed.gas["oxygen"]
				removed.gas["oxygen"] = 0

			if(2) //removing N2
				filtered_out.gas["nitrogen"] = removed.gas["nitrogen"]
				removed.gas["nitrogen"] = 0

			if(3) //removing CO2
				filtered_out.gas["carbon_dioxide"] = removed.gas["carbon_dioxide"]
				removed.gas["carbon_dioxide"] = 0

			if(4)//removing N2O
				filtered_out.gas["sleeping_agent"] = removed.gas["sleeping_agent"]
				removed.gas["sleeping_agent"] = 0

			else
				filtered_out = null


		air2.merge(filtered_out)
		air3.merge(removed)

	if(network2)
		network2.update = 1

	if(network3)
		network3.update = 1

	if(network1)
		network1.update = 1

	return 1

/obj/machinery/atmospherics/trinary/filter/initialize()
	set_frequency(frequency)
	..()

/obj/machinery/atmospherics/trinary/filter/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!istype(W, /obj/item/weapon/wrench))
		return ..()
	var/turf/T = src.loc
	if(level == 1 && isturf(T) && T.intact)
		to_chat(user, span("warning", "You must remove the plating first."))
		return 1

	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	if((int_air.return_pressure()-env_air.return_pressure()) > 2 * ONE_ATMOSPHERE)
		to_chat(user, span("warning", "You cannot unwrench this [src], it too exerted due to internal pressure."))
		add_fingerprint(user)
		return 1

	playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, span("info", "You begin to unfasten \the [src]..."))
	if(do_after(user, 40))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			span("info", "You have unfastened \the [src]."), \
			"You hear ratchet.")
		new /obj/item/pipe(loc, make_from=src)
		qdel(src)

/obj/machinery/atmospherics/trinary/filter/attack_hand(user as mob) // -- TLE
	if(..())
		return

	if(!src.allowed(user))
		to_chat(user, span("warning", "Access denied."))
		return

	/*var/dat
	var/current_filter_type
	switch(filter_type)
		if(0)
			current_filter_type = "Carbon Molecules"
		if(1)
			current_filter_type = "Oxygen"
		if(2)
			current_filter_type = "Nitrogen"
		if(3)
			current_filter_type = "Carbon Dioxide"
		if(4)
			current_filter_type = "Nitrous Oxide"
		if(-1)
			current_filter_type = "Nothing"
		else
			current_filter_type = "ERROR - Report this bug to the admin, please!"

	dat += {"
			<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"On":"Off"]</a><br>
			<b>Filtering: </b>[current_filter_type]<br><HR>
			<h4>Set Filter Type:</h4>
			<A href='?src=\ref[src];filterset=0'>Carbon Molecules</A><BR>
			<A href='?src=\ref[src];filterset=1'>Oxygen</A><BR>
			<A href='?src=\ref[src];filterset=2'>Nitrogen</A><BR>
			<A href='?src=\ref[src];filterset=3'>Carbon Dioxide</A><BR>
			<A href='?src=\ref[src];filterset=4'>Nitrous Oxide</A><BR>
			<A href='?src=\ref[src];filterset=-1'>Nothing</A><BR>
			<HR><B>Desirable output pressure:</B>
			[src.target_pressure]kPa | <a href='?src=\ref[src];set_press=1'>Change</a>
			"}
/*
		user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD>[dat]","window=atmo_filter")
		onclose(user, "atmo_filter")
		return

	if (src.temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];temp=1'>Clear Screen</A>", src.temp, src)
	//else
	//	src.on != src.on
*/
	user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_filter")
	onclose(user, "atmo_filter")*/

	// Edited this to reflect NanoUI port. -Frenjo
	usr.set_machine(src)
	ui_interact(user)
	return

obj/machinery/atmospherics/trinary/filter/Topic(href, href_list) // -- TLE
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	/*if(href_list["filterset"])
		src.filter_type = text2num(href_list["filterset"])
	if (href_list["temp"])
		src.temp = null
	if(href_list["set_press"])
		var/new_pressure = input(usr,"Enter new output pressure (0-4500kPa)","Pressure control",src.target_pressure) as num
		src.target_pressure = max(0, min(4500, new_pressure))
	if(href_list["power"])
		on=!on*/

	// Edited this to reflect NanoUI port. -Frenjo
	switch(href_list["power"])
		if("off")
			on = 0
		if("on")
			on = 1

	if(href_list["filterset"])
		src.filter_type = text2num(href_list["filterset"])

	switch(href_list["pressure"])
		if("set_press")
			var/new_pressure = input(usr, "Enter new output pressure (0-4500kPa)", "Pressure control", src.target_pressure) as num
			src.target_pressure = max(0, min(4500, new_pressure))

	src.update_icon()
	src.updateUsrDialog()
/*
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.attack_hand(M)
*/
	return

// Porting this to NanoUI, it looks way better honestly. -Frenjo
/obj/machinery/atmospherics/trinary/filter/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if(stat & BROKEN)
		return

	var/current_filter_type
	switch(filter_type)
		if(0)
			current_filter_type = "Carbon Molecules"
		if(1)
			current_filter_type = "Oxygen"
		if(2)
			current_filter_type = "Nitrogen"
		if(3)
			current_filter_type = "Carbon Dioxide"
		if(4)
			current_filter_type = "Nitrous Oxide"
		if(-1)
			current_filter_type = "Nothing"
		else
			current_filter_type = "ERROR - Report this bug to the admin, please!"

	var/data[0]
	data["on"] = on
	data["current_filter"] = current_filter_type
	data["target_pressure"] = round(target_pressure, 0.1) // Need to fix this later so it doesn't output 101.3xxxxxxxx. -Frenjo

	// Ported most of this by studying SMES code. -Frenjo
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "gas_filter.tmpl", "Gas Filter", 520, 380)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)