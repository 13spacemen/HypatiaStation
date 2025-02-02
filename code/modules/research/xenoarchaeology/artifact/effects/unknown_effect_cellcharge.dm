//todo
/datum/artifact_effect/cellcharge
	effecttype = "cellcharge"
	effect_type = 3

/datum/artifact_effect/cellcharge/DoEffectTouch(mob/user)
	if(user)
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			for(var/obj/item/weapon/cell/D in R.contents)
				D.charge += rand() * 100 + 50
				to_chat(R, SPAN_INFO("SYSTEM ALERT: Large energy boost detected!"))
			return 1

/datum/artifact_effect/cellcharge/DoEffectAura()
	if(holder)
		for(var/obj/machinery/power/apc/C in range(200, holder))
			for(var/obj/item/weapon/cell/B in C.contents)
				B.charge += 25
		for(var/obj/machinery/power/smes/S in range(src.effectrange, src))
			S.charge += 25
		for(var/mob/living/silicon/robot/M in mob_list)
			for(var/obj/item/weapon/cell/D in M.contents)
				D.charge += 25
				to_chat(M, SPAN_INFO("SYSTEM ALERT: Energy boost detected!"))
		return 1

/datum/artifact_effect/cellcharge/DoEffectPulse()
	if(holder)
		for(var/obj/machinery/power/apc/C in range(200, holder))
			for(var/obj/item/weapon/cell/B in C.contents)
				B.charge += rand() * 100
		for(var/obj/machinery/power/smes/S in range(src.effectrange, src))
			S.charge += 250
		for(var/mob/living/silicon/robot/M in mob_list)
			for(var/obj/item/weapon/cell/D in M.contents)
				D.charge += rand() * 100
				to_chat(M, SPAN_INFO("SYSTEM ALERT: Energy boost detected!"))
		return 1