all: main.asm
	nasm -f elf64 main.asm
	gcc -no-pie -lX11 main.o

clean:
	rm -f a.out main.o
