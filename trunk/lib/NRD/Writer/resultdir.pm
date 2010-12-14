package NRD::Writer::resultdir;

use strict;
use warnings;

use base 'NRD::Writer';

use File::Temp qw//;
use POSIX;

sub new {
  my ($class, $options) = @_;
  $options = {} if (not defined $options);
  my $self = {
    check_result_path => undef,
    %$options
  };

  die "No check_result_path specified" if (not defined $self->{'check_result_path'});
  die "check_result_path doesn't exist" if (not -d $self->{'check_result_path'});

  bless($self, $class);
}

sub write {
  my ($self, $result) = @_;
  my $config = $self->{'server'};
  my $nagios_str;

  # TODO: Where to put time: file_time? start_time? finish_time?

  $nagios_str  =         "### Passive Check Result File ###\n";
  $nagios_str .= sprintf("file_time=%d\n\n", $result->{'time'});
  $nagios_str .=         "### NRD Check ###\n";
  $nagios_str .= sprintf("# Time: %s\n", scalar(localtime($result->{time})));
  $nagios_str .= sprintf("host_name=%s\n",   $result->{host_name});

  if (defined $result->{svc_description}){
    $nagios_str .= sprintf("service_description=%s\n", $result->{svc_description});
  }

  $nagios_str .=         "check_type=1\n"; # 1 is for passive checks
  $nagios_str .=         "early_timeout=1\n";
  $nagios_str .=         "exited_ok=1\n";
  $nagios_str .= sprintf("return_code=%d\n", $result->{return_code});
  $nagios_str .= sprintf("output=%s\\n\n",   $result->{plugin_output});

  my ($fh, $filename) = File::Temp::tempfile( 'cXXXXXX', DIR => $self->{'check_result_path'});
  print $fh "$nagios_str\n";
  close $fh;

  # Now that we've written the result, we have to signal Nagios that it's OK to process it

  my $signal_file = "$filename.ok";
  sysopen my $signal, $signal_file, POSIX::O_WRONLY|POSIX::O_CREAT|POSIX::O_NONBLOCK|POSIX::O_NOCTTY or die("Can't create signal $signal_file: $!");
  close $signal or die("Can't close signal $signal_file: $!");
  
}

1;
