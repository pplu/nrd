#!/usr/bin/perl

use Test::More;
use NSCA2::Serialize;
use NSCA2::SerializeCrypt;

use Data::Dumper;

plan tests => 2;

my $un = NSCA2::Serialize->new({'encrypt' => 'none' });
my $s = NSCA2::SerializeCrypt->new({'encrypt' => 'Blowfish', 'encrypt_key' => 'xxxx' });

#diag('will use IV ' . $s->{'iv'} . ' length ' . length($s->{'iv'}));

my $uns = NSCA2::SerializeCrypt->new({'encrypt' => 'Blowfish', 'encrypt_key' => 'xxxx', 'iv' => $s->{'iv'} });

my $r = {'hostname' => 'this is a string'};
my $no_crypt = $un->freeze($r);
my $crypted = $s->freeze($r);

cmp_ok($crypted, 'ne', $no_crypt, 'Crypted and no_crypt versions are different');

my $uncrypted = $uns->unfreeze($crypted);
is_deeply($uncrypted, $r, 'Unencrypted and no_crypt versions are equal');

