#ifndef SYSCLK_H
#define SYSCLK_H

#include "stdint.h"

void initializeSystemFor48MHz();
uint64_t micros();

#endif