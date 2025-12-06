# Module: PolicyOcr
    



# Class Methods
## call(filename , output_io $stdout) [](#method-c-call)
Parses an OCR file containing policy numbers and writes results to output.
**@param** [String] path to the input file containing OCR data
Example: "data/policy_numbers.txt"

**@param** [IO] the IO object to write parsed results to (default: $stdout)
Example: $stdout, File.open("output.txt", "w"), StringIO.new

**@raise** [MalformedFile] if the file format is invalid

**@return** [void] 

## fail(message , error_class MalformedFile) [](#method-c-fail)
Raises an error with the given message.
**@param** [String] the error message
Example: "Line 1: expected 27 characters, got 25"

**@param** [Class] the exception class to raise (default: MalformedFile)
Example: MalformedFile, ArgumentError

**@raise** [MalformedFile, error_class] always raises


