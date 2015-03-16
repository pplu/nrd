#Testing NRD.

NRD has all its tests shipped with it in its CPAN distribution. Thanks to CPAN testers, it's tested on a lot of platforms for free!

Link to CPAN testers:

http://www.cpantesters.org/distro/N/NRD-Daemon.html

http://pass.cpantesters.org/distro/N/NRD-Daemon.html

Perl/Platform Version Matrix

http://matrix.cpantesters.org/?dist=NRD-Daemon

http://matrix.cpantesters.org/?dist=NRD-Daemon+0.01

http://matrix.cpantesters.org/?dist=NRD-Daemon+0.02

http://matrix.cpantesters.org/?dist=NRD-Daemon+0.03

# How to test NRD #

You can test NRD in your platform with:

```
nrd-test:~# cpan
cpan> test NRD::Daemon
```

If you would wish to contribute your tests to CPAN testers:

```
cpan> install CPAN::Reporter
cpan> reload cpan
cpan> o conf init test_report
```

Give it your mail, and then:

```
cpan> o conf commit
```

You're ready to test with

```
cpan> test NRD::Daemon
```

BTW, feel free to test more CPAN distributions :)