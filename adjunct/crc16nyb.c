#include <err.h>		/* for err, errx */
#include <stdio.h>		/* for fopen, fread, feof, perror, printf */
#include <stdint.h>		/* for uint8_t, uint16_t */

int debug = 0;

static uint16_t const table_nybble[] = {
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50A5, 0x60C6, 0x70E7, 
    0x8108, 0x9129, 0xA14A, 0xB16B, 0xC18C, 0xD1AD, 0xE1CE, 0xF1EF
};

uint16_t crc16xmodem_nybble(uint16_t crc, void const *mem, size_t len) {
    uint8_t const *data = mem;
    if (data == NULL)
        return 0;
    for (size_t i = 0; i < len; i++) {
	uint8_t nh, nl;
	nh = (data[i] & 0xF0) >> 4;
	nl = data[i] & 0x0F;
        crc = (crc << 4) ^ table_nybble[((crc >> 12) ^ nh) & 0x0f];
        crc = (crc << 4) ^ table_nybble[((crc >> 12) ^ nl) & 0x0f];
    }
    return crc;
}


int main(int argc, char *argv[]) {
    if (argc == 1) {
	errx(1, "Usage: crc16nyb <filename>");
    }

    while (*++argv) {

	if (debug) printf("Opening %s\n", *argv);
	FILE *fp = fopen(*argv, "r");
	if (!fp) err(2, *argv);
    
	uint8_t buffer[1024*1024];
	int crc = 0;
	int ret = 0;
	while (!feof(fp)) {
	    ret = fread(buffer, 1, sizeof(buffer), fp);
	    if (ferror(fp)) {
		perror("fread");
		return 3;
	    }
	    if (ret == 0) continue;
	    if (debug) printf("Processing %d bytes\n", ret);
	    crc = crc16xmodem_nybble(crc, buffer, ret);
	    if (debug>1) printf("%x\t", crc);
	}
    
	fclose(fp);
	printf("%X\t%s\n", crc, *argv);
    }
    return 0;
}


/**********************************************************/
/* Scaffolding routines used while creating this program. */
/* Probably should delete.				  */
/**********************************************************/
 
uint16_t crc_1nybble(uint16_t crc, uint8_t datum) {
    /* bitwise CRC for four bits */
    crc ^= (uint16_t)datum << 12;
    for (unsigned k = 0; k < 4; k++) {
	crc = crc & 0x8000 ? (crc << 1) ^ 0x1021 : crc << 1;
    }
    return crc;
}

void mknybtable() {
    printf("static uint16_t const table_nybble[] = {\n    ");
    for (auto d=0; d<16; d++) {
	printf("0x%04X", crc_1nybble(0, d));
	if (d<15) printf(", ");
	if (d==7) printf("\n    ");
    }
    printf("\n};\n");
}

