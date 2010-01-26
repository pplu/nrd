package NRD::Serialize;

use strict;
use warnings;

sub new {
  my (undef, $type, @args) = @_;
  my $class = 'NRD::Serialize::' . $type;
  {
   my $file = $class;
   $file =~ s/\:\:/\//g;
   require "$file.pm";
  }

  return $class->new(@args);
}

1;
