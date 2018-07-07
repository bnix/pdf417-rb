# PDF417-rb
PDF417-rb implements a PDF417 encoder based on *freely* available PDF417
specification documentation, and therefore may not be fully compliant with ISO 15438.

## PDF417 Encoding overview
### Definitions
- __Codeword__ - A codeword is the encoding unit used to represent the contents of
a PDF417 symbol.
There are 929 codeword values, 0 to 928, for data encoding. Each numeric codeword
value corresponds to bar-space patterns in three sets, or "clusters", of bar-space patterns.
Which cluster is used to lookup a codeword is based on the row index of the codeword.
Bar-space patterns have four bars and four spaces, and can be divided into
seventeen "modules" with each module representing one unit of a bar or space.
Bars and spaces can be one to six modules wide, but the total width will always
be seventeen modules per codeword.
- __High-level encoding__ - process of converting data into numeric codewords (0 - 928).
Three encoding modes exist: Text, Numeric, and Binary.
- __Low-level encoding__ - process of converting numeric codewords into
corresponding bar-space representation.
