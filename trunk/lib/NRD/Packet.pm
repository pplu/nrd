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
   my $packet = length($content)."\n".$content;
   return $packet;
}

# Expect either: END or 1234 to be size of next record
# Needs a line terminator because of buffered input/output
sub unpack {
   my ($self, $fd) = @_;
   my $command = <$fd>;
   chomp $command;
   if ($command eq "END") {
     # Possible clash if $buffer=="END"
     return $command;
   } elsif ($command !~ /^\d+$/) {
     # Unknown
     croak "Can't read packet header";
   }
   my $bytes = $command;
   croak "NRD packet bigger than expected ($bytes bytes). Are you getting trash?" if ($bytes > $self->{'max_packet_size'});
   croak "NRD packet with zero length. Are you getting trash?" if ($bytes <= 0);
   read($fd, my $buffer, $bytes) == $bytes or croak "Didn't receive whole packet";
   return $buffer;
}

1;
