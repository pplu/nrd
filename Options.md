# Options in nrd.conf #

  * server\_type
    * Single: Only one process to attend connections. Only one connection can be handled at a time.
    * Fork: Fork a server child every time that a client connects.
    * PreFork: Maintain a pool of server children to attend to connections

  * user
    * name of the user the server drops privileges to. This user should have to be able to write results to Nagios.
  * group
    * group that the server drops privileges

### logging ?
#log\_file    /tmp/server.log
log\_level   2
pid\_file    /tmp/nrd.pid

## optional syslog directive
### used in place of log\_file above
#log\_file       Sys::Syslog
#syslog\_logsock unix
#syslog\_ident   myserver
#syslog\_logopt  pid|cons

### access control
#allow       .+\.(net|com)
#allow       domain\.com
#deny        a.+
cidr\_allow  127.0.0.0/8
#cidr\_allow  192.0.2.0/24
#cidr\_deny   192.0.2.4/30

### background the process?
background  0

### ports to bind (this should bind
### 127.0.0.1:20205 and localhost:20204)
### See Net::Server::Proto
#host        127.0.0.1
port        7669

### reverse lookups ?
# reverse\_lookups off

  * timeout
    * number of seconds a client is able to be connected to a server without interacting with it.

  * writer
    * cmdfile
    * resultdir

  * nagios\_cmd /tmp/nagios
  * alternate\_dump\_file /tmp/nrd.dump

  * check\_result\_path /usr/local/nagios/var/spool/checkresults/

  * serializer
    * crypt
    * digest
    * plain

  * encrypt\_type
    * Blowfish
    * Any module in Crypt:: namespace

  * encrypt\_key

  * digest\_type
    * MD5
    * SHA1
    * Any module in Digest:: namespace