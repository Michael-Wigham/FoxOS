#include "PrintText.cpp"
#include "IDT.cpp"
#include "Keyboard.hpp"

extern "C" void _startKernal() {

	SetCursorPosition(PositionFromCoords(0, 0));
	InitializeIDT();
	ClearScreen(BACKGROUND_BLACK|FOREGROUND_WHITE);

	MainKeyboardHandler = KeyboardHandler;

	PrintString("Fox OS");
	do
	{
		isr1_handler();
	}
	while(LastScancode != 0x01);
	return;
}