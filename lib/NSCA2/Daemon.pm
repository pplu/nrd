package NSCA2::Daemon;

use warnings;
use strict;
use POSIX;
use Data::Dumper;
use NSCA2::Packet;

use vars qw($VERSION);
$VERSION = '0.01';

use base qw/Net::Server::MultiType/;

sub process_request {
  my $self = shift;
  my $config = $self->{'server'};
  my ($iv);
  
  $self->log(4, 'Process Request start');
  my $serializer = $self->{'oSerializer'}; 

  my $packer = NSCA2::Packet->new();

  if (lc($config->{'encrypt'}) ne 'none'){
    my $iv = $packer->unpack(*STDIN);
    $self->log(4, 'Got IV: ' . Dumper($iv));
    $serializer->iv($iv);
  }

  my $request = $packer->unpack(*STDIN);
  while ($request){
    #$self->log(4, "Got Data: " . Dumper($request));
    eval {
      $request = $serializer->unfreeze($request);
    };
    if ($@){
      $self->log(0, "Couldn't unserialize a request: $@");
      next;
    }
    
    $self->process_result($request);
    
    eval {
      $request = $packer->unpack(*STDIN);
    };
    if ($@) {
      $request = undef;
    }
  }
}

sub process_result {
  my ($self, $result) = @_;

  die "Unexpected result format" if (not ref($result) eq 'HASH');
  
  my $config = $self->{'server'};
  my $nagios_str;
  if ( defined $result->{svc_description} ) {
     $nagios_str = sprintf('[%d] PROCESS_SERVICE_CHECK_RESULT;%s;%s;%d;%s',
                           $result->{time},
                           $result->{host_name},
                           $result->{svc_description},
                           $result->{return_code}, 
                           $result->{plugin_output});
# Format got from POE-Component-Server-NSCA documentation
#     $string = "[$time] PROCESS_SERVICE_CHECK_RESULT";
#     $string = join ';', $string, $message->{host_name}, $message->{svc_description}, 
#                 $message->{return_code}, $message->{plugin_output};
  } else {
      $nagios_str = sprintf('[%d] PROCESS_HOST_CHECK_RESULT;%s;%d;%s',
                            $result->{time},
                            $result->{host_name},
                            $result->{return_code},
                            $result->{plugin_output});
# Format got from POE-Component-Server-NSCA documentation
#     $string = "[$time] PROCESS_HOST_CHECK_RESULT";
#     $string = join ';', $string, $message->{host_name}, $message->{return_code},
#                 $message->{plugin_output};
  }

  $self->log(4, $nagios_str);
  
  if (sysopen (my $fh , $config->{'nagios_cmd'}, POSIX::O_WRONLY)){
    print $fh "$nagios_str\n";
    close $fh;
  } else {
    open (my $alt, '>>', $config->{'alternate_dump_file'}) or $self->log(0, "Couldn't write to alternate_dump_file $!");
    print $alt "$nagios_str\n";
    close $alt;
  }
#  print { sysopen (my $fh , $self->{'server'}->{'nagios_cmd'}, POSIX::O_WRONLY) or die "$!\n"; $fh } $nagios_str, "\n";
}

sub options {
  my ($self, $template) = @_;
  my $prop = $self->{'server'};
  $self->SUPER::options($template);

  $prop->{'nagios_cmd'} ||= undef;
  $template->{'nagios_cmd'} = \ $prop->{'nagios_cmd'};

  $prop->{'encrypt'} ||= undef;
  $template->{'encrypt'} = \ $prop->{'encrypt'};

  $prop->{'encrypt_key'} ||= undef;
  $template->{'encrypt_key'} = \ $prop->{'encrypt_key'};

  $prop->{'alternate_dump_file'} ||= undef;
  $template->{'alternate_dump_file'} = \ $prop->{'alternate_dump_file'};

}

sub post_configure_hook {
  my ($self) = @_;

  my $config = $self->{'server'};

  die "No nagios_cmd specified" if (not defined $config->{'nagios_cmd'});
  #die "Cannot find $config->{'nagios_cmd'}"
  die "No encryption defined in config" if (not defined $config->{'encrypt'});
  die "No encryption_key defined in config" if (not defined $config->{'encrypt_key'});

  $self->log(0, "Using encryption: $config->{'encrypt'}");

  my $class;
  if (lc($config->{'encrypt'}) eq 'none'){
    $self->log(4, 'Configuring for unencrypted clients');
    require NSCA2::Serialize;
    $class = 'NSCA2::Serialize';
  } else {
    $self->log(4, "Configuring for $config->{'encrypt'} encrypted Clients");
    require NSCA2::SerializeCrypt;
    $class = 'NSCA2::SerializeCrypt';
  }
  eval {
    my $serializer = $class->new({
       'encrypt' => $config->{'encrypt'},
       'encrypt_key' => $config->{'encrypt_key'}
    });

    $self->{'oSerializer'} = $serializer;
  };
  if ($@) {
    $self->log(0, "Error loading the serializer. You probably don't have the appropiate Crypt:: module installed:\n$@");
    $self->log(0, "Aborting server start");
    die "\n"; 
  }

  return 1;
}


#################### main pod documentation begin ###################

=head1 NAME

NSCA2::Daemon - NSCA version 2

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

