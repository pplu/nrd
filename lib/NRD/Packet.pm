package NRD::Packet;

use strict;
use warnings;

use Carp;

#length needs to count bytes. not characters
use bytes;

sub new {
  my ($class, $options) = @_;
  my $self = {};
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
   read($fd, my $buffer, $bytes) == $bytes or croak "Didn't recieve whole packet";
   return $buffer;
}

1;
