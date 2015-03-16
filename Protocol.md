# Transfer Protocol #

When a connection is initiated between send\_nrd and nrd, depending on the encryption chosen, a HELO message may be sent.

Packets are then sent.

A packet consists of a header in text which is the number of bytes to read (with a linefeed), with the rest to be deserialised. The rest is in the following structure:
```
{command=>$command,...}
```

Possible commands:
  * result - this is a passive result to pass to Nagios
  * commit - this is a command to commit all previous results in one batch, if the server supports it

If command=result, a data field is expected which can have the format:
```
{
time=>utime,
host_name=>$hostname,
svc_description => $service_description, # If this is a service. Miss out this key if it is a host
return_code => $return_code,
plugin_output => $plugin_output,
}
```

Once the client has sent a command=commit, it should expect a response to be sent from the nrd server. This will reply will reply with:
```
{ command => "committed" }
```

At this point, it is confirmed that the data has been received.

If you use _batch\_results_ on the server, it is guaranteed that the data has been processed correctly.