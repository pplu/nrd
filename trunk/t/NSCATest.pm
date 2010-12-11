#
# DESCRIPTION:
#	Helper object class for NSCA testing
#
# COPYRIGHT:
#	Copyright (C) 2007 Altinity Limited
#	Copyright is freely given to Ethan Galstad if included in the NSCA distribution
#
# LICENCE:
#	GNU GPLv2

package NSCATest;

use strict;
use Class::Struct;
use IO::File;

struct NSCATest => {
	config => '$',
	pid => '$',
	timeout => '$',
	};

$| = 1;	# Autoflush on

sub start {
	my ($self, $mode) = @_;
	$mode ||= "--server_type=Single";

	printf "Starting nrd with $mode\n";
	system("perl -I blib/lib bin/nrd --conf_file=t/nrd_".$self->config.".cfg $mode");

	sleep 2;	# Let daemon start
	open F, "/tmp/nrd.pid" or die "No pid file found";
	chop(my $pid = <F>);
	close F;
	$self->pid($pid);

	open(F, "> var/nagios.cmd") or die "Cannot create var/nagios.cmd";
	close F;
	return $pid;
}

sub stop {
	my $self = shift;
	print "Stopping nrd: ".$self->pid.$/;
	kill "TERM", $self->pid;
	$self->pid(undef);
	unlink "/tmp/nrd.cmd", "/tmp/nrd.dump";
	sleep 2;	# Let daemon die
}

sub send {
	my ($self, $data) = @_;
	my @output = map { join("\t", @$_)."\n" } @$data;
	open SEND, "| ".$self->send_cmd;
	print SEND @output;
	close SEND;
}

sub send_cmd {
	my ($self) = @_;
	my $timeout = $self->timeout || 2;
	return "bin/send_nrd -c t/send_" . $self->config . ".cfg";
}

sub read_cmd {
	my ($self, $file) = @_;
	$file ||= "/tmp/nrd.dump";
	my $fh = IO::File->new($file) or die "Can't open $file";
	$self->process_data($fh);
}

sub process_data {
	my ($self, $fh) = @_;
	my $data = [];
	while(<$fh>) {
		chop;
		my @bits = /\[\d+\] PROCESS_(?:HOST|SERVICE)_CHECK_RESULT;([^;]+);(?:([^;]+);)?([0123]);(.*)$/o;

		# Remove the service name if doesn't exist
		splice @bits, 1, 1 unless defined $bits[1];

		push @$data, [ @bits ];
	}
	return $data;
}

# Was thinking of calling $self->stop in DESTROY, but with the forking
# going on, this wouldn't work

1;