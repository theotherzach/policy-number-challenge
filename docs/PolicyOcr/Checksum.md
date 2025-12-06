# Module: PolicyOcr::Checksum
    



# Class Methods
## valid?(digits ) [](#method-c-valid?)
Validates a policy number using a weighted checksum algorithm. A policy number
is valid if:

    (d1 + 2*d2 + 3*d3 + ... + 9*d9) mod 11 == 0

where d1 is the rightmost digit.
**@param** [String] 9-character string of digits "0"-"9"
Example: "123456789", "000000000", "711111111"

**@return** [Boolean] true if checksum validates, false otherwise
Example: valid?("711111111") => true
Example: valid?("123456789") => false


