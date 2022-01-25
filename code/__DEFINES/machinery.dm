var/global/defer_powernet_rebuild = 0		// true if net rebuild will be called manually after an event

#define CELLRATE	0.002	// multiplier for watts per tick <> cell storage (eg: 0.02 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
#define CHARGELEVEL	0.0005	// Cap for how fast cells charge, as a percentage-per-tick (0.01 means cellcharge is capped to 1% per second)

#define SMESRATE 0.05			// rate of internal charge to external power

// Doors!
#define DOOR_CRUSH_DAMAGE 10

// channel numbers for power
#define EQUIP	1
#define LIGHT	2
#define ENVIRON	3
#define TOTAL	4	//for total power used only

// bitflags for machine stat variable
#define BROKEN		1
#define NOPOWER		2
#define POWEROFF	4		// tbd
#define MAINT		8			// under maintaince
#define EMPED		16		// temporary broken by EMP pulse

//bitflags for door switches.
#define OPEN	1
#define IDSCAN	2
#define BOLTS	4
#define SHOCK	8
#define SAFE	16

#define ENGINE_EJECT_Z	3

var/list/RESTRICTED_CAMERA_NETWORKS = list( //Those networks can only be accessed by preexisting terminals. AIs and new terminals can't use them.
	"thunder",
	"ERT",
	"NUKE"
)

// Door stuff.
#define DOOR_OPEN 1
#define DOOR_CLOSED 2

// Reference list for disposal sort junctions. Set the sortType variable on disposal sort junctions to
// the index of the sort department that you want. For example, sortType set to 2 will reroute all packages
// tagged for the Cargo Bay.
var/list/TAGGERLOCATIONS = list(
	"Disposals", "Cargo Bay", "QM Office", "Engineering",
	"CE Office", "Atmospherics", "Security", "HoS Office",
	"Medbay", "CMO Office", "Chemistry", "Research",
	"RD Office", "Robotics", "HoP Office", "Library",
	"Chapel", "Theatre", "Bar", "Kitchen", "Hydroponics",
	"Janitor Closet", "Genetics"
)