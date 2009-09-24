# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 5;

BEGIN {
  use_ok( 'NRD::Daemon' );
  use_ok( 'NRD::Serialize' );  
  use_ok( 'NRD::SerializeCrypt' ); 
  use_ok( 'NRD::Packet' );
}

my $object = NRD::Daemon->new ();
isa_ok ($object, 'NRD::Daemon');


