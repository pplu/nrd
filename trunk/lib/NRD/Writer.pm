package NRD::Writer;

# Base class for components that write results to Nagios
#

use strict;
use warnings;

sub instance_of {
  my (undef, $type, @args) = @_;
  my $class = 'NRD::Writer::' . lc($type);
  {
   my $file = $class;
   $file =~ s/\:\:/\//g;
   require "$file.pm";
  }
  use Module::Load;
  load $class;
  #$class::import;

  return $class->new(@args);
}

1;
