#This page covers the components in the code for better understanding

# NRD::Packet #

The NRD packet class handles how to encode data that needs to be transmitted over the net. This class doesn't handle the transmission over the wire, it just

**pack**

> Prepares the data passed to it and returns the encoded version

**unpack**.

> Takes the encoded version of data, and returns what is contained in it.

To date, NRD::Packet is just a 4 byte header with the number of bytes of data that follows.

# NRD::Serializer #

This class only loads, and returns an instance of a subclass of Nagios::Serializer.

# NRD::Serializer subclasses #

Clients and servers can serialize Nagios results in whatever format they choose. Serializers have two main methods **freeze** and **unfreeze**.

**freeze**

Takes a hashref and converts it to a string representation

**unfreese**

Takes a string representation and converts it to a hashref

An extra method **from\_line** is capable of taking a line of input (read by the caller), and returns a hashref with the data that it will want transmitted over the net.

Right now there are two serializers: none and crypt:

> - "none" uses JSON string representations of the data.

> - "crypt" uses the "none" serializer, but encrypts the result before returning it