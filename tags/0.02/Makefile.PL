

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'NRD::Daemon',
    LICENSE      => 'gpl',
    VERSION_FROM => 'lib/NRD/Daemon.pm', # finds \$VERSION
    AUTHOR       => 'Jose Luis Martinez (jlmartinez@capside.com)',
    ABSTRACT     => 'Nagios Result Distributor',
    EXE_FILES    => [ 'bin/send_nrd', 'bin/nrd' ],
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,  # for testing only
                     'Clone' => 0,            # for testing only
                     'Parallel::Forker' => 0, # for testing only
		     'Net::Server' => 0,
		     'Net::CIDR' => 0,
		     'Crypt::CBC' => 0,       # for testing. optional for operation
                     'Crypt::Blowfish' => 0,  # for testing. optional for operation
		     'JSON::XS' => 0,
                    },
);
