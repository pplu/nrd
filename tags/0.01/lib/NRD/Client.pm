package NRD::Client;

use warnings;
use strict;

use IO::Socket;
use NRD::Packet;
use NRD::Serialize;
use Carp;

=item connect_with_serializer( $serializer_name, $serializer_configuration_hash, @options_for_io_socket )

Creates the connection to NRD::Daemon and sends helo information if serializer requires.

Returns the NRD::Client object

=cut

sub connect_with_serializer {
    my ($class, $serializer, $serializer_configuration, @passthrough) = @_;
    my $self = {};
    $self->{serializer} = NRD::Serialize->instance_of( lc($serializer), $serializer_configuration );
    $self->{sock} = IO::Socket::INET->new(@passthrough) || croak "Cannot connect [$!]";
    $self->{sock}->autoflush(1);
    $self->{packer} = NRD::Packet->new();
    if ($self->{serializer}->needs_helo) {
        my $sock = $self->{sock};
        print $sock $self->{packer}->pack( $self->{serializer}->helo );
    }
    bless $self, $class;
}

=item send_result( $data )

Sends the data packet to NRD::Daemon

=cut

sub send_result {
    my $self = shift;
    my $sock = $self->{sock};
    print $sock $self->{packer}->pack( $self->{serializer}->freeze( shift ) );
}

=item send_results_from_lines( $file_descriptor )

Helper function to read the data from file descriptor and then calls $self->send_result.

=cut

sub send_results_from_lines {
    my ($self, $fd) = @_;
    while (my $line = <$fd>) {
        chomp $line;
        my $r = {
            'command' => "result",
            "data" => {
                # This takes current time, but could be changed in future to use time values in the line inputs. 
                # In fact, maybe this should be in from_line instead
                "time" => time(),
                %{ $self->{serializer}->from_line($line) },
            },
        };
        $self->send_result( $r );
    }
}

=item end

Will send a commit message to Daemon. Will check response - errors will be croaked. Returns true otherwise

=cut

sub end {
    my $self = shift;
    my $sock = $self->{sock};
    print $sock $self->{packer}->pack( $self->{serializer}->freeze( { command => "commit" } ) );
    
    my $response = $self->{packer}->unpack( $self->{sock} );
    close $self->{sock};

    croak "No response from server" unless defined $response;

    eval {
        $response = $self->{serializer}->unfreeze( $response );
    };
    croak "Couldn't unserialize a request: $@" if $@;

    unless (ref $response eq "HASH" && exists $response->{command} && $response->{command} eq "finished") {
        require Data::Dumper;
        croak "Bad response from server: ". Data::Dumper->Dump( [ $response ] );
    }
    
    1;
}

1;
