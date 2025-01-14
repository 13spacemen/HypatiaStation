#define PI 3.1415

#define R_IDEAL_GAS_EQUATION	8.31 	//kPa*L/(K*mol)
#define ONE_ATMOSPHERE			101.325	//kPa

// Radiation constants.
#define STEFAN_BOLTZMANN_CONSTANT		5.6704e-8	// W/(m^2*K^4).
#define IDEAL_GAS_ENTROPY_CONSTANT		1164		//(mol^3 * s^3) / (kg^3 * L). Equal to (4*pi/(avrogadro's number * planck's constant)^2)^(3/2) / (avrogadro's number * 1000 Liters per m^3).
#define COSMIC_RADIATION_TEMPERATURE	3.15		// K.
#define AVERAGE_SOLAR_RADIATION			200			// W/m^2. Kind of arbitrary. Really this should depend on the sun position much like solars.
#define RADIATOR_OPTIMUM_PRESSURE		3771		// kPa at 20 C. This should be higher as gases aren't great conductors until they are dense. Used the critical pressure for air.
#define GAS_CRITICAL_TEMPERATURE		132.65		// K. The critical point temperature for air.

#define RADIATOR_EXPOSED_SURFACE_AREA_RATIO 0.04 // (3 cm + 100 cm * sin(3deg))/(2*(3+100 cm)). Unitless ratio.

#define T0C 273.15					// 0degC
#define T20C 293.15					// 20degC
#define TCMB 2.7					// -270.3degC

#define SPEED_OF_LIGHT		3e8 //not exact but hey!
#define SPEED_OF_LIGHT_SQ	9e+16
#define INFINITY			1.#INF

// New lighting
#define CLAMP01(x)			(Clamp(x, 0, 1))
#define CLAMP02(x, y, z)	(x <= y ? y : (x >= z ? z : x))

// XGM stuff
#define QUANTIZE(variable)	(round(variable, 0.0001))

#define SIMPLE_SIGN(X)	((X) < 0 ? -1 : 1)
#define SIGN(X)			((X) ? SIMPLE_SIGN(X) : 0)