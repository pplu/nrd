# Introduction #

NRD has a set of serializers to match a series of needs for different types of users.

# Serializers #

## plain ##

This serializer sends everything over the net as plain text. Intercepted packets can be sniffed, results seen, and manipulated. On the other hand, this is the fastest serializer and the easiest to configure (no config required). Clients permitted to send results can be limited with accept and deny rules.

Use it in trusted environments. If security is of concern, see the next serializers.

## digest ##

This serializer sends data over the wire in plain text too, but signs the data, hashing the result contents with a secret key that only clients and server should know.

Contents of intercepted packets can be seen, but cannot be manipulated, as the attacker will not know the secret, so he cannot sign it with the correct digest.

## crypt ##

The crypt serializer encrypts the whole contents of the packets with a configurable encryption algorithm. Only client and server know a shared secret to encrypt and decrypt the information.

Intercepted information cannot be seen,


# others #

Do you have an idea for a serializer? NRD should be able to adapt to new serializers (in fact, the digest serializer was not in the initial design). Feel free to propose your serializer!