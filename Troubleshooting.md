# Introduction #

Common error messages that you may get

## Client ##

### No data received ###
This is a catch all error message when the client does not get a response back from the server. Error messages on the server will give more information about the specific failure.

Possible errors:
  * encrypt\_key does not match between client and server
  * In an SSH tunnelling setup, this could be because the server is not responding

## Server ##

### Couldn't process packet: Couldn't unserialize a request: malformed JSON string ###
This means the data from the client was not in the expected format. Possible reasons:
  * encrypt\_key does not match between client and server