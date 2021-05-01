#include "IO.hpp"

void outb(unsigned short port, unsigned char val){
  asm volatile ("outb %1, %0" : : "dN"(port), "a"(val));
}

unsigned char inb(unsigned short port){
  unsigned char returnVal;
  asm volatile ("inb %1, %0"
                            : "=a"(returnVal)
                            : "dN"(port));
  return returnVal;
}

void RemapPic(){
  uint_8 a1, a2;

  a1 = inb(PIC1_DATA);
  a2 = inb(PIC2_DATA);

  outb(PIC1_COMMAND, ICW1_INIT | ICW1_ICW4);
  io_wait();
  outb(PIC2_COMMAND, ICW1_INIT | ICW1_ICW4);
  io_wait();

  outb(PIC1_DATA, 0x20);
  io_wait();
  outb(PIC2_DATA, 0x28);
  io_wait();

  outb(PIC1_DATA, 4);
  io_wait();
  outb(PIC2_DATA, 2);
  io_wait();
  outb(PIC1_DATA, ICW4_8086);
  io_wait();
  outb(PIC2_DATA, ICW4_8086);
  io_wait();

  outb(PIC1_DATA, a1);
  outb(PIC2_DATA, a2);
}

void pic_set_mask(unsigned char irq_line)
{
	uint_16 port;
	uint_8 value;

	if (irq_line < 8)
	{
		port = PIC1_DATA;
	}
	else
	{
		port = PIC2_DATA;
		irq_line -= 8;
	}
	value = inb(port) | (1 << irq_line);
	outb(port, value);
}

void pic_clear_mask(unsigned char irq_line)
{
	uint_16 port;
	uint_8 value;

	if (irq_line < 8)
	{
		port = PIC1_DATA;
	}
	else
	{
		port = PIC2_DATA;
		irq_line -= 8;
	}
	value = inb(port) & ~(1 << irq_line);
	outb(port, value);
}