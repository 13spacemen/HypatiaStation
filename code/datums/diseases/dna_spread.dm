/datum/disease/dnaspread
	name = "Space Retrovirus"
	max_stages = 4
	spread = "On contact"
	spread_type = CONTACT_GENERAL
	cure = "Ryetalyn"
	cure_id = "ryetalyn"
	curable = 1
	agent = "S4E1 retrovirus"
	affected_species = list("Human")
	desc = "This disease transplants the genetic code of the intial vector into new hosts."
	severity = "Medium"

	var/list/original_dna = list()
	var/transformed = 0

/datum/disease/dnaspread/stage_act()
	..()
	switch(stage)
		if(2, 3) //Pretend to be a cold and give time to spread.
			if(prob(8))
				affected_mob.emote("sneeze")
			if(prob(8))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, SPAN_WARNING("Your muscles ache."))
				if(prob(20))
					affected_mob.take_organ_damage(1)
			if(prob(1))
				to_chat(affected_mob, SPAN_WARNING("Your stomach hurts."))
				if(prob(20))
					affected_mob.adjustToxLoss(2)
					affected_mob.updatehealth()
		if(4)
			if(!src.transformed)
				if((!strain_data["name"]) || (!strain_data["UI"]) || (!strain_data["SE"]))
					qdel(affected_mob.virus)
					return

				//Save original dna for when the disease is cured.
				src.original_dna["name"] = affected_mob.real_name
				src.original_dna["UI"] = affected_mob.dna.UI.Copy()
				src.original_dna["SE"] = affected_mob.dna.SE.Copy()

				to_chat(affected_mob, SPAN_WARNING("You don't feel like yourself.."))
				var/list/newUI = strain_data["UI"]
				var/list/newSE = strain_data["SE"]
				affected_mob.UpdateAppearance(newUI.Copy())
				affected_mob.dna.SE = newSE.Copy()
				affected_mob.dna.UpdateSE()
				affected_mob.real_name = strain_data["name"]
				domutcheck(affected_mob)

				src.transformed = 1
				src.carrier = 1 //Just chill out at stage 4

	return

/datum/disease/dnaspread/Destroy()
	if((original_dna["name"]) && (original_dna["UI"]) && (original_dna["SE"]))
		var/list/newUI = original_dna["UI"]
		var/list/newSE = original_dna["SE"]
		affected_mob.UpdateAppearance(newUI.Copy())
		affected_mob.dna.SE = newSE.Copy()
		affected_mob.dna.UpdateSE()
		affected_mob.real_name = original_dna["name"]

		to_chat(affected_mob, SPAN_INFO("You feel more like yourself."))
	return ..()