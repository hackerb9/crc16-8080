# CRC-16 for Intel 8080

This assembly routine calculates the 16-bit Cyclic Redundancy Check on
an Intel 8080 processor. It will also run on the 8085 or Z80. 

The main purpose of this was to make a simple routine that could
quickly check the ROM on any of the Model T Computers (The Kyotronic
Sisters): Kyocera Kyotronic KC-85, TRS-80 Model 100, Tandy 102, Tandy
200, Olivetti M10, NEC PC-8201, NEC PC-8201/A, NEC PC-8300. 

## Faster, Better, Stronger (pick one)

There are three versions available:

| Version                      | Compiled Size |     Speed | Features   |
|------------------------------|--------------:|----------:|------------|
| [CRC-bytewise.asm][bytewise] |     548 bytes | 4 seconds | Fastest    |
| [CRC-bitwise.asm][bitwise]   |     110 bytes | 6 seconds | Reasonable |
| [CRC-pushpop.asm][pushpop]   |      34 bytes | 9 seconds | Smallest   |

* "Compiled size" is for the CRC-16 routine and does not count the
  Model T example driver (see below).
* "Speed" is time to calculate the CRC-16 of the 72K ROM on
  a Tandy 200 (8085 @2.46 MHz).

[bytewise]: crc16-bytewise.asm
[bitwise]: crc16-bitwise.asm
[pushpop]: crc16-pushpop.asm

## Usage

Call `CRC16` with the DE register pointing to the address to start
checksumming and the BC register hoding the length of that buffer.
The result will be in HL. 

To checksum multiple parts of a file, simply leave the previous result
in HL and call `CRC16_CONTINUE`, which skips initializing HL to 0.

## Specifics

There are actually many different flavors of CRC-16. This implements
the XMODEM version of CRC-16. In particular, it uses the polynomial
0x1021 (0001 0000 0010 0001) with an initial value of zero.

## Model T driver

Hackerb9 has created an example driver program
[modelt-driver.asm][modelt-driver.asm] that uses the CRC16 routine to
checksum the ROM on any of the Kyotronic Sisters. The following
wrapper programs include that driver file and the appropriate CRC16
backend. Download the .CO file if you simply want to run a check on
your Model T to see if you have a standard ROM installed.

Note that all three version have the same output. The only difference
is in the file size and speed of execution.

| Source                           | .CO executable         | Compiled Size | Features   |
|----------------------------------|------------------------|--------------:|------------|
| [modelt-bytewise.asm][tbytewise] | [CRC16.CO][crc16.co]   |     807 bytes | Fastest    |
| [modelt-bitwise.asm][tbitwise]   | [CRCBIT.CO][crcbit.co] |     369 bytes | Reasonable |
| [modelt-pushpop.asm][tpushpop]   | [CRCPSH.CO][crcpsh.co] |     293 bytes | Smallest   |

## Table of ROM checksums

Here are the CRC-16 values for all of the Model T ROMs which have been
reported so far. If you find one not listed, please open an issue.

| Machine Name                   | CRC-16 | ROM size |
|:-------------------------------|:------:|---------:|
| Kyocera Kyotronic KC-85        | F08D   |      32K |
| TRS-80 Model 100               | 2A64   |      32K |
| Tandy 200                      |        |      72K |
| Tandy 102 (US)                 | 1C6F   |      32K |
| Tandy 102 (UK)                 | 5CF0   |      32K |
| NEC PC-8201A                   | A48D   |      32K |
| NEC PC-8300                    | 9FF5   |     128K |
| Olivetti M10 (Europe)          | 5DD2   |      32K |
| Olivetti M10 (North America)   | 5D9F   |      32K |
| Televerket Modell 100 (Norway) | 34F5   |      32K |


### ROM Variants

Modified ROMs, for example with Y2K patches, will have different
checksums than the original. The Virtual T emulator can also patch the
ROMs to show the Virtual T version on the Menu. You may also see a ROM
with both patches. A directory of sample ROMs downloaded from
tandy.wiki exists in [ROMs](ROMs). 

|            Machine Name | Y2K patched | Virtual T | Y2K + Virtual T | ROM size |
|------------------------:|:-----------:|:---------:|:---------------:|---------:|
| Kyocera Kyotronic KC-85 | 64A8        | E71C      |                 |      32K |
|        TRS-80 Model 100 | F6C1        |           | 554D            |      32K |
|          Tandy 102 (US) | DE5B        |           | 7DD7            |      32K |
|          Tandy 102 (UK) | 9EC4        |           | 7DD7            |      32K |
|               Tandy 200 | 9534        |           | 0665            |      72K |
|            NEC PC-8201A | 8CA0        |           |                 |      32K |
|             NEC PC-8300 | E3A9        |           |                 |     128K |
|   Olivetti M10 (Europe) | 1B13        |           | B753            |      32K |
|       Olivetti M10 (US) | 5E44        |           |                 |      32K |

## C double-check

One can run an included C program to double-check that the assembly
language is getting the right answer. The C code came from Lammert
Bies's excellent web page:
www.lammertbies.nl/comm/info/crc-calculation . The file can be found,
on a full moon, in the [adjunct](file://./adjunct/) directory. 


