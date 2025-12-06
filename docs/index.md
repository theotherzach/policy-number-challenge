# Policy OCR API Documentation

API documentation for the Policy OCR library.

## Modules

- [PolicyOcr](PolicyOcr.md) - Main module for parsing OCR files
  - [PolicyOcr::Entry](PolicyOcr/Entry.md) - OCR digit recognition and correction
  - [PolicyOcr::Checksum](PolicyOcr/Checksum.md) - Checksum validation
  - [PolicyOcr::MalformedFile](PolicyOcr/MalformedFile.md) - Error class for invalid files

## Quick Reference

### PolicyOcr.call(filename, output_io)

Parses an OCR file containing policy numbers and writes results to output.

```ruby
PolicyOcr.call("input.txt")           # Output to stdout
PolicyOcr.call("input.txt", file_io)  # Output to file
```

### PolicyOcr::Entry.call(entry)

Parses a 3-row OCR entry and returns the policy number with status.

```ruby
entry = [
  "    _  _     _  _  _  _  _ ",
  "  | _| _||_||_ |_   ||_||_|",
  "  ||_  _|  | _||_|  ||_| _|"
]
PolicyOcr::Entry.call(entry)  # => "123456789"
```

### PolicyOcr::Checksum.valid?(digits)

Validates a 9-digit policy number using a weighted checksum.

```ruby
PolicyOcr::Checksum.valid?("711111111")  # => true
PolicyOcr::Checksum.valid?("123456789")  # => false
```

---

*Generated with [YARD](https://yardoc.org/) and [yard-markdown](https://github.com/skatkov/yard-markdown)*
