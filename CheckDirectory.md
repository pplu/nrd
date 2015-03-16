# Check Dir #

Can't find any official documentation, as I don't know how Nagios calls this feature officially...

Found a CPAN module that implements the logic in Perl:

http://cpansearch.perl.org/src/DATA/Nagios-Passive-v0.2.2/lib/Nagios/Passive/ResultPath.pm

Found how to do it in another project called NRDP (sends results in XML though Apache + PHP, and into Nagios). See nagioscorepassivecheck.php in http://assets.nagios.com/downloads/nrdp/nrdp.tar.gz

```
////// WRITE THE CHECK RESULT //////
// create a temp file to write to
$tmpname=tempnam($cfg["check_results_dir"],"c");
$fh=fopen($tmpname,"w");

fprintf($fh,"### NRDP Check ###\n");
fprintf($fh,"# Time: %s\n",date('r'));
fprintf($fh,"host_name=%s\n",$hostname);
if($type=="service")
	fprintf($fh,"service_description=%s\n",$servicename);
fprintf($fh,"check_type=1\n"); // 0 for active, 1 for passive
fprintf($fh,"early_timeout=1\n");
fprintf($fh,"exited_ok=1\n");
fprintf($fh,"return_code=%d\n",$state);
fprintf($fh,"output=%s\\n\n",$output);

// close the file
fclose($fh);

// change ownership and perms
chgrp($tmpname,$cfg["nagios_command_group"]);
chmod($tmpname,0770);
		
// create an ok-to-go, so Nagios Core picks it up
$fh=fopen($tmpname.".ok","w+");
fclose($fh); 
```