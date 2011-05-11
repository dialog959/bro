##! Script for logging passive DNS replication-type data.
##! For a definition of what passive DNS repliction is, see here::
##!     https://sie.isc.org/

## NOTE: This is a major hack job.
## TODO: two queries within the create_expire with different results will
##       cause only one to be logged.

@load dns/base

module DNS;

export {
	global recent_requests: set[string] = set() &create_expire=10secs &synchronized;
}

event bro_init()
	{
	Log::add_filter(DNS, [
		$name="dns-passive-replication",
		$path="dns-passive-replication",
		$pred=function(rec: DNS::Info): bool 
			{ 
			if ( rec?$query && rec$query !in recent_requests )
				{
				add recent_requests[rec$query];
				return T;
				}
			return F;
			},
		$include=set("ts", "query", "answers")
		]);
	}