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
  
  $self->log(4, 'Process Request start');
  my $config = $self->{'server'};

  eval {
    local $SIG{ALRM} = sub { die "timeout" };
    alarm $config->{'timeout'};
    $self->_process_request();
  };
  alarm(0);
  if ($@) {
    if ($@ =~ m/timeout/){ 
      $self->log(1, 'Client timeout');
    } else {
      $self->log(2, "Couldn't process packet: $@");
    }
  } else {
    # Confirmation of packet processing
    my $packer = NRD::Packet->new();
    my $serializer = $self->{'oSerializer'}; 
    print $packer->pack($serializer->freeze({'command'=>'finished'}));

  }
  $self->log(4, 'Disconnected client');
}

# This routine could croak at any time
sub _process_request {
  my ($self) = @_;

  my $serializer = $self->{'oSerializer'}; 
  $self->log(4, "Serializer $self->{'oSerializer'}");

  my $config = $self->{'server'};
  my $request = undef;
  my $packer = NRD::Packet->new();

  if ($serializer->needs_helo){
    my $helo = $packer->unpack( $config->{client} );
    $self->log(4, 'Got HELO: ' . Dumper($helo));
    $serializer->helo($helo);
  }
  my @request_batch;
  while ($request = $packer->unpack( $config->{client} )){
    $self->log(4, "Got Data: " . Dumper($request));

    eval {
      $request = $serializer->unfreeze($request);
    };
    if ($@){
      die "Couldn't unserialize a request: $@";
    }

    #$self->log(4, "After unfreeze: " . Dumper($request));

    my $command = lc($request->{command});
    if ($command eq "commit") {
        last;
    }
    elsif ($command eq "result") {
      my $data = $request->{data};
      if ($config->{batch_results}) {
        push @request_batch, $data;
      } else {
        $self->process_result($data);
      }
    }
    else {
      die "Bad command: $command";
    }
  }
  if (@request_batch) {
    $self->process_result(\@request_batch);
  }
}

sub process_result {
  my ($self, $result) = @_;

  # This is not true if used in a batch_results is set
  #die "Couldn't process a non-hash result" if (ref($result) ne 'HASH');

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

  $prop->{'batch_results'} ||= undef;
  $template->{'batch_results'} = \ $prop->{'batch_results'};

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

