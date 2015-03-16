Note: I started this project out as "NSCA2". Community requested to rename as another thing to not cause confusion. So it got renamed to NRD: Nagios Result Distributor.

**News** [Opsview](http://www.opsview.com/) is oficially using NRD to communicate slaves to masters: http://labs.opsview.com/2011/01/next-generation-distributed-monitoring-the-opsview-way/.

This project is an attempt to overcome the actual Nagios NSCA protocol shortcomings:

The motto of the NRD daemon would be "distributed monitoring should not impose additional restrictions on the functionality of Nagios".

The actual restrictions of using NSCA are:

> - Packet length limited: Data returned from plugins is tending to get bigger and bigger. Current NSCA truncates output of the plugin data. NRD should not be a limiting factor in the size of the output of a plugin, and should at least evolve with Nagios limits (so that there is no difference between using NRD or not). **IMPLEMENTED**

> - No support for multiline output: Nagios 3 introduced multiline plugin output. NRD should support multiline plugin output. **IMPLEMENTED**

> - Hostnames limited to 63 characters **IMPLEMENTED**

> - Service names limited to 127 characters **IMPLEMENTED**

Enhancements

> - Timestamp from client. The NRD client will send the timestamp of execution of the plugin to the server, together with the result. This will impose a restriction of syncing clocks between master and slave servers, but really... your servers clocks should already be synched with ntp :) **IMPLEMENTED**

> - Confirmation from the server that result(s) have been successfully passed to Nagios. **IMPLEMENTED**

> - Result queueing. If the NRD client cannot connect to the server, it will be able to spool results and send them when communication is possible again (because the timestamp is saved, the result can be injected later into nagios with the correct time). Although Nagios will discard results that are too old, maybe we can convince the Nagios developers to do something with them :) _NOT IMPLEMENTED YET_

> - The server could have additional logic for doing special operations with "too old for Nagios" results. _NOT IMPLEMENTED YET_

> - Ability to set client allow / deny rules (as another access method) **IMPLEMENTED**

> - Use of different encryption keys for different clients _NOT IMPLEMENTED YET_
> > - Instead of encrypting in the application, maybe we can take advantage of http://search.cpan.org/dist/Net-Server/lib/Net/Server/Proto/SSLEAY.pm


> - Ability to send Nagios Commands _NOT IMPLEMENTED YET_