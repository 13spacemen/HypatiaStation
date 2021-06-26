//Damage things	//TODO: merge these down to reduce on defines
//Way to waste perfectly good damagetype names (BRUTE) on this... If you were really worried about case sensitivity, you could have just used lowertext(damagetype) in the proc...
#define CUT			"cut"
#define BRUISE		"bruise"
#define BRUTE		"brute"
#define BURN		"fire"
#define TOX			"tox"
#define OXY			"oxy"
#define CLONE		"clone"
#define HALLOSS		"halloss"

#define STUN		"stun"
#define WEAKEN		"weaken"
#define PARALYZE	"paralize"
#define IRRADIATE	"irradiate"
#define AGONY		"agony" // Added in PAIN!
#define STUTTER		"stutter"
#define EYE_BLUR	"eye_blur"
#define SLUR		"slur"
#define DROWSY		"drowsy"

#define FIRE_DAMAGE_MODIFIER	0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
#define AIR_DAMAGE_MODIFIER		2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)

//I hate adding defines like this but I'd much rather deal with bitflags than lists and string searches
#define BRUTELOSS	1
#define FIRELOSS	2
#define TOXLOSS		4
#define OXYLOSS		8

///////////////////ORGAN DEFINES///////////////////

#define ORGAN_CUT_AWAY 1
#define ORGAN_GAUZED 2
#define ORGAN_ATTACHABLE 4
#define ORGAN_BLEEDING 8
#define ORGAN_BROKEN 32
#define ORGAN_DESTROYED 64
#define ORGAN_ROBOT 128
#define ORGAN_SPLINTED 256
#define SALVED 512
#define ORGAN_DEAD 1024
#define ORGAN_MUTATED 2048

//Germs and infection
#define GERM_LEVEL_AMBIENT		110		//maximum germ level you can reach by standing still
#define GERM_LEVEL_MOVE_CAP		200		//maximum germ level you can reach by running around

#define INFECTION_LEVEL_ONE		100
#define INFECTION_LEVEL_TWO		500
#define INFECTION_LEVEL_THREE	1000