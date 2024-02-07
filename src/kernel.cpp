///////////////////
// INCLUDES
///////////////////

#include "types.h"                                                             // include types just in case
#include "gdt.h"

///////////////////
// PRINTF
///////////////////

void print(char* str){                                                         // custom print function
	uint16_t* videoMemory = (uint16_t*)0xb8000;                                // mem adress for video calls basically (ax with int 0x10)
	for(int i = 0; str[i] != '\0'; ++i){                                       // iterate through string (str)
		videoMemory[i] = (videoMemory[i] & 0xFF00) | str[i];                   // insert the char every 2 bytes (1st byte is color info)
	}
}

///////////////////
// LINKER STUFF
///////////////////

typedef void (*constructor)();                                                 // define a constructor (not sure what some of this does)
extern "C" constructor start_ctors;
extern "C" constructor end_ctors;
extern "C" void callConstructors(){
	for(constructor* i = &start_ctors; i != &end_ctors; i++){                  // iterate through constructors
		(*i)();                                                                // call constructors
	}
}

///////////////////
// MAIN
///////////////////

extern "C" void kernelMain(const void* multiBootStruct, uint32_t magicNum){    // main
	print("Kernel KiwiOS\0");                                                  // print

	while(1);                                                                  // loop to never stop the kernel
}
