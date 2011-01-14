package NRD::Client;

use warnings;
use strict;

use IO::Socket;
use NRD::Packet;
use NRD::Serialize;
use Carp;

=item new( \%options )

Creates a new NRD::Client object. Options include
  * serializer - required
  * timeout - defaults to no, otherwise number of seconds. This is a timeout per send/receive of data
  * timeout_handler - sub to call on timeout. Defaults to CORE::die

=cut

sub new {
    my ($class, $options) = @_;
    $options ||= {};
    my $self = { 
        timeout => 0,
        timeout_handler => sub { CORE::die(@_) },
        serializer => undef,
        %$options,
    };
    foreach my $var (qw(serializer)) {
        die "$var not set" unless defined $self->{$var};
    }
    $self->{serializer} = NRD::Serialize->instance_of( lc($options->{serializer}), $options );
    $self->{packer} = NRD::Packet->new();
    bless $self, $class;
}

=item connect( @options )

Creates the connection to NRD::Daemon and sends helo information if serializer requires.

@options is passed through to IO::Socket::INET.

Will croak if failures occur.

=cut

sub connect {
    my ($self, @passthrough) = @_;
    my $sock = IO::Socket::INET->new(@passthrough) || croak "Cannot connect [$!]";
    $sock->autoflush(1);
    $self->{send_sock} = sub {
        my $data = shift;
        print $sock $data;
    };
    $self->{sock} = $sock;
    if ($self->{serializer}->needs_helo) {
        $self->{send_sock}->($self->{packer}->pack( $self->{serializer}->helo ));
    }
}

=item send_result( $data )

Sends the data packet to NRD::Daemon

=cut

sub send_result {
    my $self = shift;
    $self->{send_sock}->( $self->{packer}->pack( $self->{serializer}->freeze( shift ) ) );
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

    $self->{send_sock}->($self->{packer}->pack( $self->{serializer}->freeze( { command => "commit" } ) ) );
    
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
