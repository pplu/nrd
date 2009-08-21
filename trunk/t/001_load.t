# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 5;

BEGIN {
  use_ok( 'NSCA2::Daemon' );
  use_ok( 'NSCA2::Serialize' );  
  use_ok( 'NSCA2::SerializeCrypt' ); 
  use_ok( 'NSCA2::Packet' );
}

my $object = NSCA2::Daemon->new ();
isa_ok ($object, 'NSCA2::Daemon');


