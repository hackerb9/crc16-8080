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
| [modelt-bytewise.asm][tbytewise] | [CRC16.CO](CRC16.CO)   |     807 bytes | Fastest    |
| [modelt-bitwise.asm][tbitwise]   | [CRCBIT.CO](CRCBIT.CO) |     369 bytes | Reasonable |
| [modelt-pushpop.asm][tpushpop]   | [CRCPSH.CO](CRCPSH.CO) |     293 bytes | Smallest   |

## Table of ROM checksums

Here are the CRC-16 values for all of the original Model T ROMs which
have been reported so far. If you find one not listed, please open an
issue.

| Machine Name                   | ROM size | CRC-16 |
|:-------------------------------|---------:|:------:|
| Kyocera Kyotronic KC-85        |      32K | F08D   |
| TRS-80 Model 100               |      32K | 2A64   |
| Tandy 200                      |      72K |        |
| Tandy 102 (US)                 |      32K | 1C6F   |
| Tandy 102 (UK)                 |      32K | 5CF0   |
| NEC PC-8201A                   |      32K | A48D   |
| NEC PC-8300                    |     128K | 9FF5   |
| Olivetti M10 (Europe)          |      32K | 5DD2   |
| Olivetti M10 (North America)   |      32K | 5D9F   |
| Televerket Modell 100 (Norway) |      32K | 34F5   |


### ROM Variants

Modified ROMs, for example with Y2K patches, will have different
checksums than the original. The Virtual T emulator can also patch the
ROMs to show the Virtual T version on the Menu. You may also see a ROM
with both patches. See also the directory of sample ROMs downloaded
from tandy.wiki in [ROMs](ROMs).

|            Machine Name | ROM size | Y2K patched | Virtual T | Y2K + Virtual T |
|------------------------:|---------:|:-----------:|:---------:|:---------------:|
| Kyocera Kyotronic KC-85 |      32K | 64A8        | E71C      |                 |
|        TRS-80 Model 100 |      32K | F6C1        |           | 554D            |
|          Tandy 102 (US) |      32K | DE5B        |           | 7DD7            |
|          Tandy 102 (UK) |      32K | 9EC4        |           | 7DD7            |
|               Tandy 200 |      72K | 9534        |           | 0665            |
|            NEC PC-8201A |      32K | 8CA0        |           |                 |
|             NEC PC-8300 |     128K | E3A9        |           |                 |
|   Olivetti M10 (Europe) |      32K | 1B13        |           | B753            |
|       Olivetti M10 (US) |      32K | 5E44        |           |                 |

## C double-check

One can run an [included C program](adjunct/crc16.c) to double-check
that the assembly language is getting the right answer. The underlying
C code came from Lammert Bies's excellent web page:
https://www.lammertbies.nl/comm/info/crc-calculation .


<details><summary>CRC16 checksums for the various ROMs</summary><ul>

```shell
crc16-8080$ ./crc16 ROMs/*
F08D    ROMs/KC-85.orig.bin
64A8    ROMs/KC-85.y2k.bin
5DD2    ROMs/M10_System_ROM_EU.orig.bin
1B13    ROMs/M10_System_ROM_EU.y2k.bin
5D9F    ROMs/M10_System_ROM_NorthAmerica.orig.bin
5E44    ROMs/M10_System_ROM_NorthAmerica.y2k.bin
A48D    ROMs/NEC_PC-8201A.orig.bin
8CA0    ROMs/NEC_PC-8201A.y2k.bin
4793    ROMs/NEC_PC-8300_Beckman-E3.2.bin
9FF5    ROMs/NEC_PC-8300.orig.bin
E3A9    ROMs/NEC_PC-8300.y2k.bin
A2B3    ROMs/TANDY_600_BASIC.bin
5CF0    ROMs/TANDY_Model_102.uk.orig.bin
9EC4    ROMs/TANDY_Model_102.uk.y2k.bin
1C6F    ROMs/TANDY_Model_102.us.orig.bin
DE5B    ROMs/TANDY_Model_102.us.y2k.bin
3D1A    ROMs/TANDY_Model_200.M13.orig.bin
25C3    ROMs/TANDY_Model_200.M15.orig.bin
67AB    ROMs/TANDY_Model_200.M15.y2k.bin
2A64    ROMs/Televerket-Modell100.orig.bin
34F5    ROMs/TRS-80_Model_100.orig.bin
F6C1    ROMs/TRS-80_Model_100.y2k.bin
```

</ul></details>

## Determining hardware architecture via PEEK of ROM

Distinguishing the different Kyocera Kyotronic Sisters by ROM values
requires at least two PEEKs. The following peeks have (so far) worked
properly regardless of ROM patches, such as Y2K or Virtual T.

<details><summary>Output from ./crc16 ROMs/*</summary><ul>

| PEEK(1) | (21358) | ROM FILE                             |
|--------:|--------:|--------------------------------------|
|      35 |      35 | M10_System_ROM_EU.orig.bin           |
|      35 |      35 | M10_System_ROM_EU.y2k.bin            |
|      51 |      83 | TRS-80_Model_100.orig.bin            |
|      51 |      83 | TRS-80_Model_100.y2k.bin             |
|      72 |     209 | NEC_PC-8300_Beckman-E3.2.bin         |
|     125 |     205 | M10_System_ROM_NorthAmerica.orig.bin |
|     125 |     205 | M10_System_ROM_NorthAmerica.y2k.bin  |
|     144 |     254 | TANDY_600_BASIC.bin                  |
|     148 |     101 | NEC_PC-8201A.orig.bin                |
|     148 |     101 | NEC_PC-8201A.y2k.bin                 |
|     148 |     235 | NEC_PC-8300.orig.bin                 |
|     148 |     235 | NEC_PC-8300.y2k.bin                  |
|     167 |      83 | TANDY_Model_102.us.orig.bin          |
|     167 |      83 | TANDY_Model_102.us.y2k.bin           |
|     167 |      96 | TANDY_Model_102.uk.orig.bin          |
|     167 |      96 | TANDY_Model_102.uk.y2k.bin           |
|     167 |     123 | Televerket-Modell100.orig.bin        |
|     171 |       9 | TANDY_Model_200.M15.orig.bin         |
|     171 |       9 | TANDY_Model_200.M15.y2k.bin          |
|     225 |     194 | KC-85.orig.bin                       |
|     225 |     194 | KC-85.y2k.bin                        |

</ul></details>


|  Model | PEEK(1) | PEEK(21358) |
|-------:|--------:|------------:|
|   kc85 |     225 |         167 |
|    m10 |      35 |          56 |
|   m100 |      51 |         230 |
|   m102 |     167 |         230 |
|   t200 |     171 |          83 |
| pc8201 |     148 |          66 |
| pc8300 |     148 |          64 |
