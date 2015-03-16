### These instructions are intended for people that want to test out NRD (early adopters) ###

Definitive version should not imply getting an SVN client installed on your system :p

This has been written for a Debian Etch system.

> - Install an svn client
```
apt-get install subversion
```
> - Check out the code
```
svn checkout http://nsca2.googlecode.com/svn/trunk/ nrd
cd nrd
```

> - Install pre-requisites (note: the next step may tell you that you are lacking some modules. Install them with your SO package manager, and if they aren't available: use cpan MODULE::NAME to install them)
```
apt-get install libnet-server-perl libnet-cidr-perl libcrypt-cbc-perl
```
> - Install the encryption you will use (you can get a list with `aptitude search libcrypt.*-perl`)
```
apt-get install libcrypt-blowfish-perl
```
> - Build and test
```
perl Makefile.PL
make
make test
make install
```
> - configure the server: create /etc/nrd.conf. Customize to your needs.
```

#server_type = PreFork

### user and group to become
user        nagios
group       nagios

### logging ?
#log_file    /tmp/server.log
log_level   2
pid_file    /tmp/nrd.pid

## optional syslog directive
### used in place of log_file above
#log_file       Sys::Syslog
#syslog_logsock unix
#syslog_ident   myserver
#syslog_logopt  pid|cons

### access control
#allow       .+\.(net|com)
#allow       domain\.com
#deny        a.+
#cidr_allow  127.0.0.0/8
#cidr_allow  192.0.2.0/24
#cidr_deny   192.0.2.4/30

### background the process?
background  0

### ports to bind (this should bind
### 127.0.0.1:20205 and localhost:20204)
### See Net::Server::Proto
#host        127.0.0.1
port        5669

### reverse lookups ?
# reverse_lookups off

nagios_cmd /usr/local/nagios/var/rw/nagios.cmd
alternate_dump_file /tmp/nrd.dump

serializer crypt
encrypt_type Blowfish
encrypt_key dekjr+34lkr
```
> - configure the client: create /etc/send\_nrd.cfg with. Customize to your needs.
```
host 127.0.0.1
serializer crypt
encrypt_type Blowfish
encrypt_key dekjr+34lkr
```