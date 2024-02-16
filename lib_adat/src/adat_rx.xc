// Copyright 2011-2024 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.

#ifndef ADAT_REF
#define ADAT_REF 100
//#warning "Assuming 100 MHz reference clock"
#endif

#if (ADAT_REF == 100)
#include "adatReceiver-100.h"
#elif (ADAT_REF == 999375)
#include "adatReceiver-99-9375.h"
#else
#error "Unknown ADAT reference specified - only 100 and 999375 are supported"
#endif
