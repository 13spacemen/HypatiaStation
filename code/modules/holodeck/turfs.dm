// Contains: Holographic Turfs
// Base
/turf/simulated/floor/holofloor
	thermal_conductivity = 0

/turf/simulated/floor/holofloor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return	// HOLOFLOOR DOES NOT GIVE A FUCK

// Grass
/turf/simulated/floor/holofloor/grass
	name = "Lush Grass"
	icon_state = "grass1"
	floor_type = /obj/item/stack/tile/grass

/turf/simulated/floor/holofloor/grass/New()
	icon_state = "grass[pick("1", "2", "3", "4")]"
	..()
	spawn(4)
		update_icon()
		for(var/direction in cardinal)
			if(istype(get_step(src, direction), /turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src, direction)
				FF.update_icon() //so siding get updated properly