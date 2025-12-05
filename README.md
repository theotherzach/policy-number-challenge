# Policy Number Challenge


## `po.rb` – OCR Policy Number Parser

`po.rb` reads OCR-encoded policy numbers from a file and outputs the decoded
values along with validation results.

### Usage

```bash
./po.rb -h
./po.rb INPUT_FILE [OUTPUT_FILE]


./po.rb sample.txt
./po.rb sample.txt output.txt
```

### Running Specs

```bash
bundle install
rubocop
rspec
```

### User Stories

- [X] User Story 1
We have just recently purchased an ingenious machine to assist in reading policy
report documents. The machine scans the paper documents for policy numbers,
and produces a file with a number of entries which each look like this:
```
    _  _     _  _  _  _  _
  | _| _||_||_ |_   ||_||_|
  ||_  _|  | _||_|  ||_| _|
```

Each entry is 4 lines long, and each line has 27 characters. The first 3 lines of each
entry contain a policy number written using pipes and underscores, and the fourth
line is blank. Each policy number should have 9 digits, all of which should be in the
range 0-9. A normal file contains around 500 entries.
Your first task is to write a program that can take this file and parse it into actual
numbers.
  -  [X] Task 1-1: Take an empty file as an argument & output nothing to stdout with an exit status of 0
  -  [X] Task 1-2: Take a well formed file as an argument & output `?` to stdout
  -  [X] Task 1-3: Parse file into rows, ouput `?` followed by a line break for each detected row to stdout
  -  [X] Task 1-4: Split each row into character blocks. Count the blocks and output 1 `?` per block. Ideally `?????????` for each row
  -  [X] Task 1-5: Handle malformed files with an exit code of 1 and a helpful error message if possible
  -  [X] Task 1-6: Detect the number 1 from a file containing every number. Output `1` whenever detected, otherwise output `?`.
  -  [X] Task 1-7: Detect every number 0-9 from a file and properly output to stdout. Use `?` as a fallback if no number is detected, but use clean files so any appearance of `?` at this point should be a bug.

---

- [X] User Story 2
Having done that, you quickly realize that the ingenious machine is not in fact
infallible. Sometimes it goes wrong in its scanning. So the next step is to validate
that the numbers you read are in fact valid policy numbers. A valid policy number
has a valid checksum. This can be calculated as follows:
```
policy number: 3 4 5 8 8 2 8 6 5
position names: d9 d8 d7 d6 d5 d4 d3 d2 d1
checksum calculation:
(d1+(2*d2)+(3*d3)+...+(9*d9)) mod 11 = 0
```
Your second task is to write some code that calculates the checksum for a given
number, and identifies if it is a valid policy number.
-  [X] Task 2-1: Using a file containing a row that parses to `000000050`, output it as `000000050 ERR`.
-  [X] Task 2-2: Using a file containing a row that parses to `000000051`, output it as `000000051`.

---

- [X] User Story 3
Your boss is keen to see your results. They ask you to write out a file of your findings,
one for each input file, in this format:
```
457508000
664371495 ERR
86110??36 ILL
```
-  [X] Task 3-1: Allow the user to pass in a output file parameter and write to that file rather than stdout.
-  [X] Task 3-2: Using a file with characters that don't match the number blocks, output `?` for unrecognized characters and append `ILL` to the output line, like this: `86110??36 ILL`

---

- [X] User Story 4
It turns out that often when a number comes back as ERR or ILL it is because the
scanner has failed to pick up on one pipe or underscore for one of the figures. For
example

```
490067715
```

The 9 could be an 8 if the scanner had missed one |. Or the 0 could be an 8. Or the 1
could be a 7. The 5 could be a 9 or 6. So your next task is to look at numbers that
have come back as ERR or ILL, and try to guess what they should be, by adding or
removing just one pipe or underscore. If there is only one possible number with a
valid checksum, then use that. If there are several options, the status should be
AMB. If you still can't work out what it should be, the status should be reported ILL.
Your final task is to write code that does the guess work described above to remove
as many ERR and ILL as can safely be done.
