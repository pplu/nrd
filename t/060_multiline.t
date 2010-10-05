#!/usr/bin/perl
#
# DESCRIPTION:
#	Test sending basic passive results to nrd
#
# COPYRIGHT:
#	Copyright (C) 2007 Altinity Limited
#	Copyright is freely given to Ethan Galstad if included in the NSCA distribution
#
# LICENCE:
#	GNU GPLv2

use lib 't';

use strict;
use NSCATest;
use Test::More;

plan tests => 6;

my $mlh_output = <<ML_OUTPUT;
PING OK - Packet loss = 0%, RTA = 0.46 ms | rta=0.462000ms;3000.000000;5000.000000;0.000000 pl=0%;80;100;0
LINE 1
LINE 2
LINE 3
ML_OUTPUT

my $mls_output = <<ML_OUTPUT;
DISK OK - free space: / 3326 MB (56%); | /=2643MB;5948;5958;0;5968
/ 15272 MB (77%);
/boot 68 MB (69%);
/home 69357 MB (27%);
/var/log 819 MB (84%); | /boot=68MB;88;93;0;98
/home=69357MB;253404;253409;0;253414
/var/log=818MB;970;975;0;980
ML_OUTPUT

my $data = [ 
	["multi_output", 0, $mlh_output ],
	["multi_output", "service1", 0, $mls_output ],
	];
SKIP: {
skip "Implement with temporary check results dir", 6;
  foreach my $config ('basic', 'encrypt'){
    foreach my $type ('--server_type=Single', '--server_type=Fork', '--server_type=PreFork') {
	my $nsca = NSCATest->new( config => $config );

	$nsca->start($type);
	$nsca->send($data);
	sleep 1;		# Need to wait for --daemon to finish processing

	my $output = $nsca->read_cmd;
	is_deeply($data, $output, "Got all data as expected");

	$nsca->stop;
    }
  }
}
