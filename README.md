# CRC-16 for Intel 8080

This assembly routine calculates the 16-bit Cyclic Redundancy Check
(XMODEM variant) on an Intel 8080 processor. It also runs on the Intel
8085 and Zilog Z80.

## Faster, Better, Stronger (pick one)

There are three versions available:

| Version                      | Assembled Size |     Speed | Features   |
|------------------------------|---------------:|----------:|------------|
| [CRC-bytewise.asm][bytewise] |      548 bytes | 4 seconds | Fastest    |
| [CRC-bitwise.asm][bitwise]   |      110 bytes | 6 seconds | Reasonable |
| [CRC-pushpop.asm][pushpop]   |       34 bytes | 9 seconds | Smallest   |

* "Speed" is time to calculate the CRC-16 of the 72K ROM on a Tandy
  200 (8085 @2.4576 MHz).

[bytewise]: crc16-bytewise.asm
[bitwise]: crc16-bitwise.asm
[pushpop]: crc16-pushpop.asm

## Compiling

If you have the `asmx` assembler installed, simply run `make` to
compile the `crc16` executable and assembly code fragments.

## Usage

In your own code, call `CRC16` with the DE register pointing to a
buffer and the BC register set to the buffer's size. The result will
be in HL.

``` assembly
	LXI D, 0     ; DE: Address of buffer to checksum
	LXI B, 8000H ; BC: Length of buffer (8000H for 32K)

	;; Calculate checksum of BC bytes at addr DE and put result in HL.
	CALL CRC16
```

## Advanced Usage

To checksum multiple parts as a single file, simply leave the previous
stage's result in HL and call `CRC16_CONTINUE`.

``` assembly
	LXI D, 0     ; DE: ROM M15 from 0000 to 7FFF
	LXI B, 8000H ; BC: 32K
	CALL CRC16

	LXI D, 8000H ; DE: ROM M13 from 8000 to A000
	LXI B, 2000H ; BC: 8K
	CALL CRC16_CONTINUE

	;; Bank selection: Replace M15 with M14
	DI
	IN 0D8h
	ANI 00001100b		; keep the ram bits, zero out the rom bits
	ORI 00000001b		; enable multiplan rom
	OUT 0D8H
	
	LXI D, 0     ; DE: ROM M14 from 0000 to 7FFF
	LXI B, 8000H ; BC: 32K
	CALL CRC16_CONTINUE

	;; Switch back to normal BASIC ROM 
	IN  0D8h
	ANI 00001100b		; keep the ram bits, zero out the rom bits
	OUT 0D8H	
	EI
```

The above excerpt is from a [related project][crc16-modelt] that uses
the CRC16-8080 routine to checksum the ROM on the TRS-80 Model 100 and
kindred devices.

[crc16-modelt]: https://github.com/hackerb9/crc16-modelt "Calculate the ROM checksum on the TRS-80 Model 100 family of computers" 

## Algorithm Specifics

There are actually many different flavors of CRC-16 which all produce
different results based on certain parameters: the polynomial, initial
conditions, bit reflection, etc.. This code implements the XMODEM
variant of CRC-16 because its parameters and implementation were well
known at the time when Intel 8080 compatible processors were
prevalent. XMODEM checksums can be easily tested on other machines —
see below for a C program. There are also [online web
implementations][online], but you need to first convert the file to
ASCII hex using `xxd -p -c0`.

[online]: https://crccalc.com/?crc=&method=CRC-16/XMODEM&datatype=hex&outtype=hex "Calculate CRC-16/XMODEM in your web browser"


The details of how cyclic redundancy checksums work is deep and
labyrinthine. If you want to understand the algorithm as implemented
here, I suggest looking first at [crc16-bitwise.asm][bitwise] as the
[bytewise][bytewise] algorithm is optimized using a precomputed lookup
table.

The selection of CRC parameters is a black art, which is why using a
well known flavor was important. XMODEM's most significant choice is
that it uses the "polynomial" 0x1021. What does it mean for a number
to be a polynomial? Including the implicit $1$ to make it a 17-bit
number, 0x1021 can be construed as a polynomial like so,

$$ 
\begin{align*}
   11021_{16} &= 1\ 0001\ 0000\ 0010\ 0001_2\\
              &= x^{16} + x^{12} + x^5 + x^0
\end{align*}
$$

<details><summary>Delve deeper</summary><ul>

Knowing that the number 0x1021 is mathematically a polynomial is
enlightening as it defines the rules for "CRC arithmetic": Polynomial
arithmetic mod 2. One neat feature of that arithmetic is that Addition
and Subtraction are equal to each other and both are simply Exclusive
Or:

| a | b | a+b | a-b | a⊕b |
|---|---|:---:|:---:|:---:|
| 0 | 0 | 0   | 0   | 0   |
| 0 | 1 | 1   | 1   | 1   |
| 1 | 0 | 1   | 1   | 1   |
| 1 | 1 | 0   | 0   | 0   |

Polynomial arithmetic mod 2 is isomorphic to binary arithmetic with no
carry, which is much simpler. Therefore, CRC implementations treat the
polynomial as a binary number despite calling it "the polynomial". 

In particular, the polynomial is used as the divisor for the binary
message. The remainder of that division is the checksum. Due to the
peculiar rules of CRC arithmetic, long division can be expressed as
simply a series of XOR (⊕) and shift operations, which happen to be
easily implemented on early CPUs, such as the 8080.

For more information, I found most helpful Ross Williams' "Painless
Guide", aka ["Everything you wanted to know about CRC algorithms, but
were afraid to ask for fear that errors in your understanding might be
detected"](adjunct/crc_v3.txt).

Also of help are Lammert Bies's excellent web page:
[https://www.lammertbies.nl/comm/info/crc-calculation](https://www.lammertbies.nl/comm/info/crc-calculation)
and the RF-Wireless World's CRC16 calculator:
[https://www.rfwireless-world.com/calculators/crc16-calculator-and-formula](https://www.rfwireless-world.com/calculators/crc16-calculator-and-formula).

</ul></details>

## C double-check

One can run an [included C program](adjunct/crc16.c) to double-check
that the assembly language is getting the right answer. The underlying
C code came from [crcany](https://github.com/madler/crcany).

