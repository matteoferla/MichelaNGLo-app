# SSL certificate
Verisign certificates provided by the university.

# Passwords
Passwords are sent to the server regularly (SSL layer). There is cryptographic nonce or OAuth2 tokens.

Passwords are hashed: the hash is stored in the DB and compared, not the password. The hashing is done using bcrypt (Blowfish cypher).

# Encrypted pages
For a page to be encrypted it needs to be symmetrical. That is it needs to be decrypted.

For this AES encryption is used. The user provided password is made into the correct length key by sha256 hashing it.
The initial vector is chosen randomly and is prepended to the encrypted message.

The request is strictly Post to avoid URL strings getting unwittingly logged. The logs do not output passwords (or URL strings).
