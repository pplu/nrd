package NRD::Packet;

use strict;
use warnings;

use Carp;

#length needs to count bytes. not characters
use bytes;

sub new {
  my ($class, $options) = @_;
  my $self = {
    'max_packet_size' => 256*1024
  };
  bless ($self, $class);
  return $self;
}


sub pack {
   my ($self, $content) = @_;
   my $packet = pack("N", length($content)) . $content;
   return $packet;
}

sub unpack {
   my ($self, $fd) = @_;
   read($fd, my $bytes, 4) == 4 or croak "Can't read packet header";
   $bytes = unpack("N", $bytes);
   croak "NRD packet bigger than expected ($bytes bytes). Are you getting trash?" if ($bytes > $self->{'max_packet_size'});
   croak "NRD packet with zero length. Are you getting trash?" if ($bytes <= 0);
   read($fd, my $buffer, $bytes) == $bytes or croak "Didn't recieve whole packet";
   return $buffer;
}

1;
