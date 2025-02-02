/*
	Datum based languages. Easily editable and modular.
*/

/datum/language
	var/name = "an unknown language" // Fluff name of language if any.
	var/desc = "A language."         // Short description for 'Check Languages'.
	var/speech_verb = "says"         // 'says', 'hisses', 'farts'.
	var/colour = "body"         // CSS style to use for strings in this language.
	var/key = "x"                    // Character used to speak in language eg. :o for Soghun.
	var/flags = 0                    // Various language flags.
	var/native                       // If set, non-native speakers will have trouble speaking.

/datum/language/proc/broadcast(var/mob/living/speaker, var/message, var/speaker_mask)
	log_say("[key_name(speaker)] : ([name]) [message]")

	for(var/mob/player in player_list)
		var/understood = 0
		if(istype(player, /mob/dead))
			understood = 1
		else if(src in player.languages)
			understood = 1

		if(understood)
			if(!speaker_mask) speaker_mask = speaker.name
			player << "<i><span class='game say'>[name], <span class='name'>[speaker_mask]</span> <span class='message'>[speech_verb], \"<span class='[colour]'>[message]</span><span class='message'>\"</span></span></i>"

/datum/language/human
	name = "Sol Common"
	desc = "A bastardized hybrid of informal English and elements of Mandarin Chinese; the common language of the Sol system."
	colour = "rough"
	key = "1"
	flags = RESTRICTED

/datum/language/soghun
	name = "Sinta'unathi"
	desc = "The common language of Moghes, composed of sibilant hisses and rattles. Spoken natively by Soghun."
	speech_verb = "hisses"
	colour = "soghun"
	key = "o"
	flags = RESTRICTED

/datum/language/tajaran
	name = "Siik'maas"
	desc = "The traditionally employed tongue of Ahdomai, composed of expressive yowls and chirps. Native to the Tajaran."
	speech_verb = "mrowls"
	colour = "tajaran"
	key = "j"
	flags = RESTRICTED

/datum/language/tajaran_sign
	name = "Siik'tajr"
	desc = "An expressive language that combines yowls and chirps with posture, tail and ears. Native to the Tajaran."
	speech_verb = "mrowls"
	colour = "tajaran_signlang"
	key = "y"
	flags = RESTRICTED | NONVERBAL

/datum/language/skrell
	name = "Skrellian"
	desc = "A melodic and complex language spoken by the Skrell of Qerrbalak. Some of the notes are inaudible to humans."
	speech_verb = "warbles"
	colour = "skrell"
	key = "k"
	flags = RESTRICTED

/datum/language/vox
	name = "Vox-Pidgin"
	desc = "The common tongue of the various Vox ships making up the Shoal. It sounds like chaotic shrieking to everyone else."
	speech_verb = "shrieks"
	colour = "vox"
	key = "v"
	flags = RESTRICTED

/datum/language/diona
	name = "Rootspeak"
	desc = "A creaking, subvocal language spoken instinctively by the Dionaea. Due to the unique makeup of the average Diona, a phrase of Rootspeak can be a combination of anywhere from one to twelve individual voices and notes."
	speech_verb = "creaks and rustles"
	colour = "soghun"
	key = "q"
	flags = RESTRICTED

/datum/language/obsedai
	name = "Obsedaian"
	desc = "The common tongue of the Obsedai. It sounds like deep rumbling and resonant notes to everyone else."
	speech_verb = "rumbles"
	colour = "vox"
	key = "r"
	flags = RESTRICTED

/datum/language/plasmalin
	name = "Plasmalin"
	desc = "A rattling, clunky 'language' spoken natively by Plasmalins."
	speech_verb = "rattles"
	colour = "vox"
	key = "p"
	flags = RESTRICTED

/datum/language/machine
	name = "Binary Audio Language"
	desc = "Series of beeps, boops, blips and blops representing encoded binary data, frequently used for efficient Machine-Machine communication."
	speech_verb = "emits"
	colour = "vox"
	key = "l"
	flags = RESTRICTED

// Galactic common languages (systemwide accepted standards).
/datum/language/trader
	name = "Tradeband"
	desc = "Maintained by the various trading cartels in major systems, this elegant, structured language is used for bartering and bargaining."
	speech_verb = "enunciates"
	colour = "say_quote"
	key = "2"

/datum/language/gutter
	name = "Gutter"
	desc = "Much like Standard, this crude pidgin tongue descended from numerous languages and serves as Tradeband for criminal elements."
	speech_verb = "growls"
	colour = "rough"
	key = "3"

// Broadcast languages
/datum/language/xenos
	name = "Hivemind"
	desc = "Xenomorphs have the strange ability to commune over a psychic hivemind."
	speech_verb = "hisses"
	colour = "alien"
	key = "a"
	flags = RESTRICTED | HIVEMIND

/datum/language/ling
	name = "Changeling"
	desc = "Although they are normally wary and suspicious of each other, changelings can commune over a distance."
	speech_verb = "says"
	colour = "changeling"
	key = "g"
	flags = RESTRICTED | HIVEMIND

/datum/language/ling/broadcast(var/mob/living/speaker, var/message, var/speaker_mask)
	if(speaker.mind && speaker.mind.changeling)
		..(speaker, message, speaker.mind.changeling.changelingID)
	else
		..(speaker, message)

/datum/language/binary
	name = "Robot Talk"
	desc = "Most human stations support free-use communications protocols and routing hubs for synthetic use."
	speech_verb = "transmits"
	colour = "say_quote"
	key = "b"
	flags = RESTRICTED | HIVEMIND
	var/drone_only

/datum/language/binary/broadcast(var/mob/living/speaker, var/message, var/speaker_mask)
	if(!speaker.binarycheck())
		return
	if (!message)
		return

	var/message_start = "<i><span class='game say'>[name], <span class='name'>[speaker.name]</span>"
	var/message_body = "<span class='message'>[speaker.say_quote(message)], \"[message]\"</span></span></i>"

	for (var/mob/M in dead_mob_list)
		if(!istype(M, /mob/new_player) && !istype(M, /mob/living/carbon/brain)) //No meta-evesdropping
			M.show_message("[message_start] [message_body]", 2)

	for (var/mob/living/S in living_mob_list)
		if(drone_only && !istype(S, /mob/living/silicon/robot/drone))
			continue
		if(istype(S, /mob/living/silicon/ai))
			message_start = "<i><span class='game say'>[name], <a href='byond://?src=\ref[S];track2=\ref[S];track=\ref[src];trackname=[html_encode(speaker.name)]'><span class='name'>[speaker.name]</span></a>"
		else if (!S.binarycheck())
			continue

		S.show_message("[message_start] [message_body]", 2)

	var/list/listening = hearers(1, src)
	listening -= src

	for (var/mob/living/M in listening)
		if(istype(M, /mob/living/silicon) || M.binarycheck())
			continue
		M.show_message("<i><span class='game say'><span class='name'>synthesised voice</span> <span class='message'>beeps, \"beep beep beep\"</span></span></i>",2)

/datum/language/binary/drone
	name = "Drone Talk"
	desc = "A heavily encoded damage control coordination stream."
	speech_verb = "transmits"
	colour = "say_quote"
	key = "d"
	flags = RESTRICTED | HIVEMIND
	drone_only = 1

// Cult languages
/datum/language/cultcommon
	name = "Cult"
	desc = "The chants of the occult, the incomprehensible."
	speech_verb = "intones"
	//ask_verb = "intones"
	//exclaim_verb = "chants"
	colour = "cult"
	key = "n"
	flags = RESTRICTED
	//space_chance = 100
	/*syllables = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri", \
		"orkan", "allaq", "sas'so", "c'arta", "forbici", "tarem", "n'ath", "reth", "sh'yro", "eth", "d'raggathnor", \
		"mah'weyh", "pleggh", "at", "e'ntrath", "tok-lyr", "rqa'nap", "g'lt-ulotf", "ta'gh", "fara'qha", "fel", "d'amar det", \
		"yu'gular", "faras", "desdae", "havas", "mithum", "javara", "umathar", "uf'kal", "thenar", "rash'tla", \
		"sektath mal'zua", "zasan", "therium", "viortia", "kla'atu", "barada", "nikt'o", "fwe'sh", "mah", "erl", "nyag", "r'ya", \
		"gal'h'rfikk", "harfrandid", "mud'gib")*/

/datum/language/cult
	name = "Occult"
	desc = "The initiated can share their thoughts, by means defying reason."
	speech_verb = "intones"
	//ask_verb = "intones"
	//exclaim_verb = "chants"
	colour = "cult"
	key = "m"
	flags = RESTRICTED | HIVEMIND

// Language handling.
/mob/proc/add_language(var/language)
	var/datum/language/new_language = global.all_languages[language]

	if(!istype(new_language) || (new_language in languages))
		return 0

	languages.Add(new_language)
	return 1

/mob/proc/remove_language(var/rem_language)
	languages.Remove(global.all_languages[rem_language])

	return 0

// Can we speak this language, as opposed to just understanding it?
/mob/proc/can_speak(datum/language/speaking)
	return (universal_speak || (speaking in src.languages))

//TBD
/mob/verb/check_languages()
	set name = "Check Known Languages"
	set category = "IC"
	set src = usr

	var/dat = "<b><font size = 5>Known Languages</font></b><br/><br/>"

	for(var/datum/language/L in languages)
		dat += "<b>[L.name] (:[L.key])</b><br/>[L.desc]<br/><br/>"

	src << browse(dat, "window=checklanguage")
	return