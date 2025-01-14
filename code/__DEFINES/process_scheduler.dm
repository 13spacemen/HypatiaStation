// Process status defines
#define PROCESS_STATUS_IDLE				1
#define PROCESS_STATUS_QUEUED			2
#define PROCESS_STATUS_RUNNING			3
#define PROCESS_STATUS_MAYBE_HUNG		4
#define PROCESS_STATUS_PROBABLY_HUNG	5
#define PROCESS_STATUS_HUNG				6

// Process time thresholds
#define PROCESS_DEFAULT_HANG_WARNING_TIME	300 // 30 seconds
#define PROCESS_DEFAULT_HANG_ALERT_TIME		600 // 60 seconds
#define PROCESS_DEFAULT_HANG_RESTART_TIME	900 // 90 seconds
#define PROCESS_DEFAULT_SCHEDULE_INTERVAL	50  // 50 ticks
#define PROCESS_DEFAULT_SLEEP_INTERVAL		8	// 1/8th of a tick

// SCHECK macros
// This references src directly to work around a weird bug with try/catch
#define SCHECK_EVERY(this_many_calls) if(++src.calls_since_last_scheck >= this_many_calls) sleepCheck()
#define SCHECK sleepCheck()

#define TICKS_IN_DAY	864000
#define TICKS_IN_SECOND 10

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list