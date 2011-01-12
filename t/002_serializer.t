#!/usr/bin/perl

use Test::More;
use NRD::Serialize;

use Data::Dumper;

plan tests => 2;

my $un = NRD::Serialize->instance_of('plain', { });
my $s = NRD::Serialize->instance_of('crypt', {'encrypt_type' => 'Blowfish', 'encrypt_key' => 'xxxx' });

#diag('will use IV ' . $s->{'iv'} . ' length ' . length($s->{'iv'}));

my $uns = NRD::Serialize->instance_of('crypt', {'encrypt_type' => 'Blowfish', 'encrypt_key' => 'xxxx'});
$uns->helo($s->helo);

my $r = {'hostname' => 'this is a string'};
my $no_crypt = $un->freeze($r);
my $crypted = $s->freeze($r);

cmp_ok($crypted, 'ne', $no_crypt, 'Crypted and no_crypt versions are different');

my $uncrypted = $uns->unfreeze($crypted);
is_deeply($uncrypted, $r, 'Unencrypted and no_crypt versions are equal');

