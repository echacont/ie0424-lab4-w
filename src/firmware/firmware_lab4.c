#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LOOP_WAIT_LIMIT 1000000

#define LISTADDR 0x4000
#define LISTSIZE 6144
//#define LISTSIZE 16

static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;
}

static void writeMem(uint32_t address, uint32_t data) {
	*((volatile uint32_t *)address) = data;
}

static uint32_t readMem(uint32_t address) {
	return *((volatile uint32_t *)address);
}

void main() {
	uint32_t number_to_display = 0;
	uint32_t counter = 0;

	uint32_t address = LISTADDR;
	uint32_t data = 0;
	uint32_t numeros[8];
	uint32_t puntero = 0;
	uint32_t next_address = 0;

	putuint(0xA0);

	// escribir tabla
	for (uint32_t i = 0; i < LISTSIZE; i++) {
		next_address = address + 8;
		writeMem(address, next_address);
		writeMem(address+4, i);
		address = next_address;
	}
	// leer tabla
	putuint(0xC0);
	address = LISTADDR;
	for (uint32_t i = 0; i < LISTSIZE; i++) {
		next_address = readMem(address);
		data = readMem(address+4);
		if (data%2 == 0) {
			numeros[puntero] = data;
			puntero++;
			if (puntero == 8) puntero = 0;		
		}
		address = next_address;

	}	
	putuint(0xE0);
	while (1) {
		for (puntero = 0; puntero < 8; puntero++) {
			putuint(numeros[puntero]);
			counter = 0;
			while (counter < LOOP_WAIT_LIMIT) {
				counter++;
			}
		}
	}
}
