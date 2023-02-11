--set the constants for this class
local IOTA 					= enum.prep("IOTA");
IOTA.YEARS					= "years";
IOTA.DAYS 					= "days";
IOTA.HOURS 					= "hours";
IOTA.MINUTES 				= "minutes";
IOTA.SECONDS 				= "seconds";
IOTA.MAX					= enum.prep("MAX", true);
IOTA.MAX.YEARS				= 999999; --if you make this value larger, be sure to reduce the precache years max
IOTA.MAX.DAYS 				= 365;
IOTA.MAX.HOURS 				= 24;
IOTA.MAX.MINUTES 			= 60;
IOTA.MAX.SECONDS			= 60;
IOTA.CALLBACK				= enum.prep("CALLBACK", true);
IOTA.CALLBACK.ON_SECOND		= 'onSecond';
IOTA.CALLBACK.ON_MINUTE		= 'onMinute';
IOTA.CALLBACK.ON_HOUR		= 'onHour';
IOTA.CALLBACK.ON_DAY		= 'onDay';
IOTA.CALLBACK.ON_YEAR		= 'onYear';

--finalize the enum
IOTA();
