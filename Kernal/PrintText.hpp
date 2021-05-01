#pragma once
#include "IO.cpp"
#include "Types.hpp"
#include "TextModeColorCodes.hpp"

#define VGA_MEMORY (uint_8*)0xb8000
#define VGA_WIDTH 80

extern uint_16 CursorPosition;
void PrintString(const char* str, uint_8 color = BACKGROUND_BLACK|FOREGROUND_WHITE);
void PrintChar(char chr, uint_8 color = BACKGROUND_BLACK|FOREGROUND_WHITE);
