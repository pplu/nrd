package NRD::Daemon;

use warnings;
use strict;

use Data::Dumper;
use NRD::Packet;
use NRD::Serialize;

use NRD::Writer;

use vars qw($VERSION);
$VERSION = '0.01';

use base qw/Net::Server::MultiType/;

sub process_request {
  my $self = shift;
  my $config = $self->{'server'};
  
  $self->log(4, 'Process Request start');
  my $serializer = $self->{'oSerializer'}; 
  $self->log(4, "Serializer $self->{'oSerializer'}");

  my $packer = NRD::Packet->new();

  my $request = undef;

  if ($serializer->needs_helo){
    eval {
      local $SIG{ALRM} = sub { die "timeout" };
      alarm $config->{'timeout'};
      my $helo = $packer->unpack(*STDIN);
      alarm 0;
      $self->log(4, 'Got HELO: ' . Dumper($helo));
      $serializer->helo($helo);
    };
    if ($@){
      if ($@ =~ m/timeout/){ $self->log(1, 'Client timeout'); return; }
      $self->log(2, "Couldn't process helo: $@");
      $@ = undef;
    }
  }
  eval {
    local $SIG{ALRM} = sub { die "timeout" };
    alarm $config->{'timeout'};
    $request = $packer->unpack(*STDIN);
    alarm 0;
  };
  if ($@){
    if ($@ =~ m/timeout/){ $self->log(1, 'Client timeout'); return; }
    $self->log(2, "Couldn't process packet: $@");
  }
  while ($request){
    $self->log(4, "Got Data: " . Dumper($request));
    eval {
      eval {
        $request = $serializer->unfreeze($request);
      };
      if ($@){
        die "Couldn't unserialize a request: $@";
      }
    
      #$self->log(4, "After unfreeze: " . Dumper($request));
      $self->process_result($request);

      # Done processing the request.
      $request = undef;
      eval {
         local $SIG{ALRM} = sub { die "timeout" };
         alarm $config->{'timeout'};
         # The unpack method croaks if the connection is closed
         $request = $packer->unpack(*STDIN);
         alarm 0;
      }
    };
    if ($@){
      if ($@ =~ m/timeout/){ $self->log(1, 'Client timeout'); return; }
      $self->log(2, "Couldn't process request $@");
      $request = undef;
    }
  }
  $self->log(4, 'Disconnected client');
}

sub process_result {
  my ($self, $result) = @_;
  die "Couldn't process a non-hash result" if (ref($result) ne 'HASH');

  eval {
    $self->{'oWriter'}->write($result);
  };
  if ($@){
    # Error in the write
    $self->log(0, "NRD Writer error: $@");
  }
}

sub options {
  my ($self, $template) = @_;
  my $prop = $self->{'server'};
  $self->SUPER::options($template);

  $prop->{'nagios_cmd'} ||= undef;
  $template->{'nagios_cmd'} = \ $prop->{'nagios_cmd'};

  $prop->{'timeout'} ||= undef;
  $template->{'timeout'} = \ $prop->{'timeout'};

  $prop->{'serializer'} ||= undef;
  $template->{'serializer'} = \ $prop->{'serializer'};

  $prop->{'writer'} ||= undef;
  $template->{'writer'} = \ $prop->{'writer'};

  $prop->{'encrypt_key'} ||= undef;
  $template->{'encrypt_key'} = \ $prop->{'encrypt_key'};

  $prop->{'encrypt_type'} ||= undef;
  $template->{'encrypt_type'} = \ $prop->{'encrypt_type'};

  $prop->{'alternate_dump_file'} ||= undef;
  $template->{'alternate_dump_file'} = \ $prop->{'alternate_dump_file'};

  $prop->{'check_result_path'} ||= undef;
  $template->{'check_result_path'} = \ $prop->{'check_result_path'};

}

sub post_configure_hook {
  my ($self) = @_;

  my $config = $self->{'server'};

  if (not defined $config->{'timeout'}){
    $config->{'timeout'} = 30;
  }

  die "No serializer defined in config" if (not defined $config->{'serializer'});
  $self->log(0, "Using serializer: $config->{'serializer'}");

  eval {
    my $serializer = NRD::Serialize->instance_of($config->{'serializer'},$config);
    $self->{'oSerializer'} = $serializer;
  };
  if ($@) {
    $self->log(0, "Error loading the serializer. $@");
    $self->log(0, "Aborting server start");
    die "\n"; 
  }

  die "No writer defined in config" if (not defined $config->{'writer'});
  $self->log(0, "Using writer: $config->{'writer'}");

  eval {
    my $writer = NRD::Writer->instance_of($config->{'writer'}, $config);
    $self->{'oWriter'} = $writer;
  };
  if ($@) {
    $self->log(0, "Error loading the result writer. $@");
    $self->log(0, "Aborting server start");
    die "\n";
  }

  return 1;
}


#################### main pod documentation begin ###################

=head1 NAME

NRD::Daemon - NRD Nagios Result Distributor

=head1 SYNOPSIS


=head1 DESCRIPTION



=head1 USAGE



=head1 BUGS



=head1 SUPPORT



=head1 AUTHOR

    Jose Luis Martinez
    CPAN ID: JLMARTIN
    CAPSiDE
    jlmartinez@capside.com
    http://www.pplusdomain.net

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

perl(1).

=cut

#################### main pod documentation end ###################


1;
# The preceding line will help the module return a true value

