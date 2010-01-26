package NRD::Serialize::none;

use strict;
use warnings;

use JSON::XS;

sub new {
  my ($class, $options) = @_;
  $options = {} if (not defined $options);
  my $self = {
    %$options
  };

  bless($self, $class);
}

sub from_line {
  my ($self, $line) = @_;
  my $r = {};
  my @parts = split /\t/, $line;

  if (scalar(@parts) == 3){
    ($r->{'host_name'}, $r->{'return_code'}, $r->{'plugin_output'}) = @parts;
  } elsif(scalar(@parts) == 4) {
    ($r->{'host_name'}, $r->{'svc_description'}, $r->{'return_code'}, $r->{'plugin_output'}) = @parts;
  } else {
    die "Input in incorrect format. Format hostname<TAB>[svc_description<TAB>]return_code<TAB>plugin_output<NEWLINE>";
  }
  return $r;
}

sub needs_helo { 0 }

sub helo {
   return undef;
}

sub unfreeze {
   my ($self, $recieved) = @_;
   return decode_json($recieved);
}

sub freeze {
   my ($self, $result) = @_;
   return encode_json($result);
}

1;
