

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'NSCA2::Daemon',
    VERSION_FROM => 'lib/NSCA2/Daemon.pm', # finds \$VERSION
    AUTHOR       => 'Jose Luis Martinez (jlmartinez@capside.com)',
    ABSTRACT     => 'NSCA version 2',
    EXE_FILES    => [ 'bin/send_nsca', 'bin/nsca' ],
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
		     'Net::Server' => 0,
		     'Net::CIDR' => 0,
		     #'Mcrypt' => 0,
		     'Crypt::CBC' => 0,
		     'JSON::XS' => 0,
                    },
);
