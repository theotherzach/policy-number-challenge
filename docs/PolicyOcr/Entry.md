# Module: PolicyOcr::Entry
    



# Class Methods
## call(entry ) [](#method-c-call)
Parses a 3-row OCR entry and returns the policy number with status.
**@param** [Array<String>] 3-element array of 27-char OCR rows
Example: [
  "    _  _     _  _  _  _  _ ",
  "  | _| _||_||_ |_   ||_||_|",
  "  ||_  _|  | _||_|  ||_| _|"
]

**@return** [String] policy number, optionally with error suffix
Example: "123456789", "1234?6789 ILL", "123456789 ERR", "123456789 AMB"


