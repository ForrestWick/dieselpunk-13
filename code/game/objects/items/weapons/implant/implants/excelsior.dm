/obj/item/weapon/implant/excelsior
	name = "excelsior implant"
	implant_color = "r"
	allowed_organs = list(BP_HEAD)

	var/antag_id = ROLE_EXCELSIOR_REV
	var/faction_id = FACTION_EXCELSIOR


/obj/item/weapon/implantcase/excelsior
	name = "glass case - 'complant'"
	desc = "A case containing an excelsior complant."
	implant = /obj/item/weapon/implant/excelsior


/obj/item/weapon/implanter/excelsior
	name = "implanter-complant"
	implant = /obj/item/weapon/implant/excelsior


//The excelsior implant converts humans into antags, but it also protects mobs from excelsior turrets and shields
/obj/item/weapon/implant/excelsior/can_install(var/mob/living/carbon/human/target, var/obj/item/organ/external/E)
	//First of all, handling of human players
	if(istype(target))
		//Human players have minds. If it doesnt have a mind, its probably a monkey
		if (target.mind)
			//We'll check if the target is already excelsior, return false if so, waste of an implant
			for(var/datum/antagonist/A in target.mind.antagonist)
				if(A.id == antag_id)
					return FALSE

	//Secondly, cruciforms.
	//This is handled seperately to account for the future possibility of non-humans having cruciforms. Like holy dogs!
	if (is_neotheology_disciple(target))
		//Cruciform blocks other implants
		return FALSE


	//Thirdly an organic check. No implanting robots
	//Any other organic creature is fine. This allows you to implant your pets so the turrets dont shoot them
	var/types = target.get_classification()
	if (!(types & CLASSIFICATION_ORGANIC))
		return FALSE

	//All good, return true
	return TRUE



/obj/item/weapon/implant/excelsior/on_install(var/mob/living/target)
	var/datum/faction/F = get_faction_by_id(faction_id)

	if(!wearer || !wearer.mind)
		return

	if(!F)
		target << SPAN_WARNING("You feel nothing.")

	for(var/datum/antagonist/A in target.mind.antagonist)
		if(A.id == antag_id && A.faction && A.faction.id == faction_id)
			return

	make_antagonist_faction(wearer.mind, antag_id, F)


/obj/item/weapon/implant/excelsior/on_uninstall()
	if(!istype(wearer) || !wearer.mind)
		return

	for(var/datum/antagonist/A in wearer.mind.antagonist)
		if(A.id == antag_id)
			A.remove_antagonist()

	if(prob(66))
		wearer.adjustBrainLoss(200)
		part.droplimb(FALSE, DROPLIMB_BLUNT)