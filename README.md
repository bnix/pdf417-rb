# PDF417-rb
PDF417-rb implements a PDF417 encoder based on *freely* available PDF417
specification documentation, and therefore may not be fully compliant with ISO 15438.

## PDF417 Encoding overview
Codewords - A codeword is the encoding unit used to represent the contents of
a PDF417 symbol.
There are 929 codeword values available for data encoding. All codewords exist
in 3 mutually-exclusive sets, or "clusters", of bar-space patterns. Which cluster
is used for representing a codeword is based on the row index of the codeword.

High-level encoding - process for converting data into codewords which are
mapped to a bar-space pattern, known as low-level encoding.

Error correction -
