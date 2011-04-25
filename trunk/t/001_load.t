# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 10;

BEGIN {
  use_ok( 'NRD::Daemon' );
  use_ok( 'NRD::Serialize' );  
  use_ok( 'NRD::Serialize::plain' );  
  use_ok( 'NRD::Serialize::crypt' ); 
  use_ok( 'NRD::Serialize::digest' ); 
  use_ok( 'NRD::Writer' ); 
  use_ok( 'NRD::Writer::cmdfile' ); 
  use_ok( 'NRD::Writer::resultdir' ); 
  use_ok( 'NRD::Packet' );
}

my $object = NRD::Daemon->new ();
isa_ok ($object, 'NRD::Daemon');


