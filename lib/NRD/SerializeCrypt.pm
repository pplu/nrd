package NRD::SerializeCrypt;

use base 'NRD::Serialize';

sub new {
  my ($class, $options) = @_;
  $options = {} if (not defined $options);
  my $self = {
    'encrypt' => undef,
    'encrypt_key' => undef,
    %$options
  };

  bless($self, $class);

  die 'No encryption specified' if (not defined $self->{'encrypt'});
  die 'No encrypt_key specified' if (not defined $self->{'encrypt_key'});

  require Crypt::CBC or die "Can't load Crypt::CBC";
  $self->{'iv'} = Crypt::CBC->random_bytes(8)
    if (not defined $self->{'iv'});
  my $td = Crypt::CBC->new( -cipher => $self->{'encrypt'},
                            -key => $self->{'encrypt_key'},
                            -iv  => $self->{'iv'},
                            -header => 'none'
           ) or die "Can't load cipher '$self->{'encrypt'}'";

  $self->{'td'} = $td;
  return $self;
}

sub iv {
  my ($self, $iv) = @_;
  return ($self->{'td'}->iv) if (not defined $iv);
  $self->{'td'}->iv($iv);
}

sub freeze {
  my ($self, $result) = @_;
  my $string = $self->SUPER::freeze($result);
  my $td = $self->{'td'};
  return ($td->encrypt($string));
}

sub unfreeze {
  my ($self, $string) = @_;
  #print Dumper($string) . " length:" . length($string);
  my $dec = $self->{'td'}->decrypt($string);
  #$dec =~ s/\x00*^//g;
  #print Dumper($dec) . " length:" . length($dec);
  return ($self->SUPER::unfreeze($dec));
}

1;
