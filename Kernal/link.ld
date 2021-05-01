ENTRY (_startKernal)

OUTPUT_FORMAT(binary)

STARTUP(../objects/boot2.o)

INPUT
(
  ../objects/Kernal.o
)

OUTPUT
(
  ../objects/Kernal.bin
)

SECTIONS
{
  . = 0x07E00;

  .text : ALIGN(0x1000)
  {
    *(.text)
  }

  .idt BLOCK(0x1000) : ALIGN(0x1000)
  {
    _idt = .;
    . = . + 0x1000;
  }

  .data : ALIGN(0x1000)
  {
    *(.data)
  }

  .rodata : ALIGN(0x1000)
  {
    *(.rodata)
  }

  .bss : ALIGN(0x1000)
  {
  *(COMMON)
  *(.bss)
  }
}
