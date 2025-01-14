//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/fix_vein
	priority = 2
	allowed_tools = list(
		/obj/item/weapon/FixOVein = 100,
		/obj/item/stack/cable_coil = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = 70
	max_duration = 90

/datum/surgery_step/fix_vein/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/internal_bleeding = 0
	for(var/datum/wound/W in affected.wounds)
		if(W.internal)
			internal_bleeding = 1
			break

	return affected.open == 2 && internal_bleeding

/datum/surgery_step/fix_vein/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] starts patching the damaged vein in [target]'s [affected.display_name] with \the [tool].",
		"You start patching the damaged vein in [target]'s [affected.display_name] with \the [tool]."
	)
	target.custom_pain("The pain in [affected.display_name] is unbearable!",1)
	..()

/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_INFO("[user] has patched the damaged vein in [target]'s [affected.display_name] with \the [tool]."),
		SPAN_INFO("You have patched the damaged vein in [target]'s [affected.display_name] with \the [tool].")
	)

	for(var/datum/wound/W in affected.wounds)
		if(W.internal)
			affected.wounds -= W
			affected.update_damages()
	if(ishuman(user) && prob(40))
		user:bloody_hands(target, 0)

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!"),
		SPAN_WARNING("Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!")
	)
	affected.take_damage(5, 0)