
# PRNG

This repository contains a project to create a Pseudo-Random Number Generator on an 8-bit computer (w65c02sxb).

## Files

| File      | Description                                                   |
|---|---|
| w65c*.inc  | Libraries.                                                      |
| PRNG.asm   | File containing the PRNG procedures with an example driver.     |
| PRNG.SREC  | SREC for compiled PRNG.asm file.                                |
| table.py   | Script to create a table from a LCG.                            |

## Sources and Notes

We recommend to use the [sxb monitor](https://github.com/andrew-jacobs/w65c02sxb-monitor/) by Andrew Jacobs to interact with the system. Information on addresses that cannot be used can be found his repository. For our PRNG, the addresses 0000 - 007f will be used for the table and the contents will not be preserved. Next, in order to compile the project, we use the [vasm assembler](http://www.compilers.de/vasm.html), make sure to modify the make file with the directory of the assembler. Additional sources can be found in each respective file. The program is located at the address $0410

## Overview and Example
The procedures of interest are SRAND and NEXT. SRAND will seed the PRNG based on the contents of the y-register. If the y-register is 0, default behavior is assumed (a specefic address is used as a source for entropy). The NEXT procedure will get the next random number in the sequence and store it in the A-register, and adjust the y-register. An example of seeding the PRNG is shown below:

```
LDY #0     ;default behvaior
JSR SRAND
```

An example of getting the next random number is shown below:

```
JSR NEXT
```


For a more detailed example, checkout the PRNG.asm file's application code.


