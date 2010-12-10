package NRD::Daemon;

use warnings;
use strict;

use POSIX;
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
      my $helo = $packer->unpack(*STDIN);
      $self->log(4, 'Got HELO: ' . Dumper($helo));
      $serializer->helo($helo);
    };
    if ($@){
      $self->log(2, "Couldn't process helo: $@");
    }
  }
  eval {
    $request = $packer->unpack(*STDIN);
  };
  if ($@){
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
         # The unpack method croaks if the connection is closed
         $request = $packer->unpack(*STDIN);
      }
    };
    if ($@){
      $self->log(2, "Couldn't process request $@");
      $request = undef;
    }
  }
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

  $prop->{'serializer'} ||= undef;
  $template->{'serializer'} = \ $prop->{'serializer'};

  $prop->{'encrypt_key'} ||= undef;
  $template->{'encrypt_key'} = \ $prop->{'encrypt_key'};

  $prop->{'encrypt_type'} ||= undef;
  $template->{'encrypt_type'} = \ $prop->{'encrypt_type'};

  $prop->{'alternate_dump_file'} ||= undef;
  $template->{'alternate_dump_file'} = \ $prop->{'alternate_dump_file'};

}

sub post_configure_hook {
  my ($self) = @_;

  my $config = $self->{'server'};

  die "No nagios_cmd specified" if (not defined $config->{'nagios_cmd'});
  #die "Cannot find $config->{'nagios_cmd'}"
  die "No serializer defined in config" if (not defined $config->{'serializer'});
  #die "No encrypt_type defined in config" if (not defined $config->{'encrypt_type'});
  #die "No encrypt_key defined in config" if (not defined $config->{'encrypt_key'});

  $self->log(0, "Using serializer: $config->{'serializer'}");

  eval {
    my $serializer = NRD::Serialize->instance_of(lc($config->{'serializer'}),$config);
    $self->{'oSerializer'} = $serializer;
  };
  if ($@) {
    $self->log(0, "Error loading the serializer. $@");
    $self->log(0, "Aborting server start");
    die "\n"; 
  }

  eval {
    my $writer = NRD::Writer->instance_of('cmdfile', $config);
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

