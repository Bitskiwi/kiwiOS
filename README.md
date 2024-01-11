# KiwiOS
---
## Installation
for linux:
- `git clone "https://github.com/bitskiwi/kiwiOS`
- install qemu and nasm
- `cd ~/path/kiwiOS`
- `bash run.sh`

for windows/mac:
- install linux
## Compilation
- `cd ~/path/kiwiOS`
- `make`
## Shell Commands (Once I add shell commands)
- `example <*required param> <optional param>`
---
- `file <*name>`
    - creates a file `<*name>`
    - ex: `file notes.md`
- `dir <*name>`
    - creates a dir `<*name>`
    - ex: `dir stuff`
- `copy <*target> <*dest>`
    - makes a copy of file / dir (and contents) `<*target>` in dir `<*dest>`
    - ex: `copy notes.md stuff`
- `del <*target>`
    - deletes file / dir (and contents) `<*target>`
    - ex: `del notes.md`
- `cd <*target>`
    - navigates into dir `<*target>`
    - ex: `cd stuff`
- `puts <value>`
    - prints <value> to terminal
    - ex: `puts "hello"`
- `calc <*operand> <*operator> <*operand>`
    - prints the result of the two operands in context of `<*operator>`
    - ex: `calc 5 + 5`
