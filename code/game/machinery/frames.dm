/obj/item/frame
	name = "frame"
	desc = "Used for building machines."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm_bitem"
	flags = CONDUCT
	var/build_machine_type
	var/refund_amt = 2
	var/refund_type = /obj/item/stack/sheet/metal
	var/reverse = 0 // if resulting object faces opposite its dir (like light fixtures)

/obj/item/frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		new refund_type(get_turf(src.loc), refund_amt)
		qdel(src)
		return
	..()

/obj/item/frame/proc/try_build(turf/on_wall)
	if(get_dist(on_wall, usr) > 1)
		return

	var/ndir = get_dir(on_wall, usr)
	if(!(ndir in cardinal))
		return

	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if(!istype(loc, /turf/simulated/floor))
		to_chat(usr, SPAN_WARNING("\The [src] cannot be placed on this spot."))
		return
	if(A.requires_power == 0 || istype(A, /area/space))
		to_chat(usr, SPAN_WARNING("\The [src] cannot be placed in this area."))
		return

	if(gotwallitem(loc, ndir))
		to_chat(usr, SPAN_WARNING("There's already an item on this wall!"))
		return

	new build_machine_type(loc, ndir, src)
	qdel(src)

/*
AIR ALARM ITEM
Handheld air alarm frame, for placing on walls
Code shamelessly copied from apc_frame
*/
/obj/item/frame/alarm
	name = "air alarm frame"
	desc = "Used for building Air Alarms"
	build_machine_type = /obj/machinery/alarm

/*
FIRE ALARM ITEM
Handheld fire alarm frame, for placing on walls
Code shamelessly copied from apc_frame
*/
/obj/item/frame/firealarm
	name = "fire alarm frame"
	desc = "Used for building Fire Alarms"
	icon_state = "fire_bitem"
	build_machine_type = /obj/machinery/firealarm

/*
TUBE LIGHT FIXTURE ITEM
Handheld tube light fixture, for placing on walls.
Code not shamelessly copied from apc_frame. -Frenjo
*/
/obj/item/frame/light_fixture
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	build_machine_type = /obj/machinery/light_construct
	reverse = 1

/*
BULB LIGHT FIXTURE ITEM
Handheld bulb light fixture, for placing on walls.
Code not shamelessly copied from apc_frame. -Frenjo
*/
/obj/item/frame/light_fixture/small
	name = "small light fixture frame"
	desc = "Used for building small lights."
	icon_state = "bulb-construct-item"
	build_machine_type = /obj/machinery/light_construct/small
	refund_amt = 1