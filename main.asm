	;; Author: boredcoder411
	;; Date: 2024-09-05
	;; Description: A simple X11 program that creates a window and displays "Hello, World!" in it.
	;; Note: This program is written for x86-64 Linux systems and requires the X11 library.
	;;       To compile and run the program, use the following commands:
	;;       nasm -f elf64 -o main.o main.asm
	;;       ld main.o -lX11 -o main
	;;       ./main

extern XDrawString                         ; Declare external function XDrawString (used for drawing text in a window)
extern XNextEvent                          ; Declare external function XNextEvent (used for handling events in the window)
extern XSelectInput                        ; Declare external function XSelectInput (used to select input event types to listen for)
extern XMapWindow                          ; Declare external function XMapWindow (used to make the window visible on the screen)
extern XCreateSimpleWindow                 ; Declare external function XCreateSimpleWindow (used to create a simple window)
extern XOpenDisplay                        ; Declare external function XOpenDisplay (used to open a connection to the X server)

section .text
global main                                ; Mark the entry point of the program

main:
        push    r12                        ; Save the r12 register on the stack
        push    rbp                        ; Save the rbp (base pointer) register on the stack
        push    rbx                        ; Save the rbx register on the stack
        sub     rsp, 208                   ; Allocate 208 bytes of space on the stack

        mov     rdi, qword [fs:abs 28H]    ; Get some value (probably a system-specific one) and move it into rdi
        mov     qword [rsp+0C8H], rdi      ; Store the value in rdi at [rsp + 0C8H]
        xor     edi, edi                   ; Zero out the edi register (argument for XOpenDisplay)
        call    XOpenDisplay               ; Call XOpenDisplay to connect to the X server

        sub     rsp, 8                     ; Adjust stack pointer (align stack)
        mov     r9d, 250                   ; Set width of window (250 pixels)
        mov     r8d, 250                   ; Set height of window (250 pixels)
        mov     rbx, rax                   ; Store the return value of XOpenDisplay (display pointer) in rbx
        mov     rax, qword [rax+0E8H]      ; Get some value from the display structure and move it to rax
        mov     ecx, 50                    ; Set X coordinate of the window
        movsxd  rdx, dword [rbx+0E0H]      ; Sign-extend and move the display-specific value to rdx
        mov     rdi, rbx                   ; Set the first argument (display pointer) for XCreateSimpleWindow
        shl     rdx, 7                     ; Shift left rdx by 7 (likely used to calculate some offset)
        mov     rsi, qword [rax+rdx+10H]   ; Load a window parameter (root window) from display structure
        push    qword [rax+58H]            ; Push the border width (probably) to the stack
        mov     edx, 50                    ; Set Y coordinate of the window
        push    qword [rax+60H]            ; Push the depth (probably) to the stack
        push    1                          ; Push another argument (for window creation flags)
        call    XCreateSimpleWindow        ; Call XCreateSimpleWindow to create the window

        add     rsp, 32                    ; Adjust the stack pointer back after function call
        mov     rdi, rbx                   ; Set the first argument (display pointer) for XMapWindow
        mov     r12, rax                   ; Store the window handle returned from XCreateSimpleWindow
        mov     rsi, rax                   ; Set the second argument (window handle) for XMapWindow
        mov     rbp, rsp                   ; Save the stack pointer to rbp
        call    XMapWindow                 ; Call XMapWindow to map (make visible) the window

        mov     edx, 32768                 ; Set the event mask (type of events to listen for)
        mov     rsi, r12                   ; Set the second argument (window handle) for XSelectInput
        mov     rdi, rbx                   ; Set the first argument (display pointer) for XSelectInput
        call    XSelectInput               ; Call XSelectInput to specify events to listen to (e.g., keyboard, mouse)

window_loop:                               ; Main event loop
        mov     rsi, rbp                   ; Move the saved stack pointer into rsi
        mov     rdi, rbx                   ; Set the first argument (display pointer) for XNextEvent
        call    XNextEvent                 ; Call XNextEvent to wait for and retrieve the next event

        cmp     dword [rsp], 12            ; Compare the event type with 12 (probably an expose event)
        jnz     window_loop                ; If the event is not type 12, jump back to window_loop

        sub     rsp, 8                     ; Adjust stack pointer (align)
        mov     r8d, 100                   ; Set the Y position for the text (100 pixels from top)
        mov     rsi, r12                   ; Set the second argument (window handle) for XDrawString
        mov     rdi, rbx                   ; Set the first argument (display pointer) for XDrawString
        mov     rax, qword [rbx+0E8H]      ; Load some value from the display structure
        lea     r9, [rel main_string]      ; Load the address of the "Hello, World!" string into r9
        mov     ecx, 100                   ; Set the X position for the text (100 pixels from left)
        mov     rdx, qword [rax+48H]       ; Load the Graphics Context (GC) from the display structure
        push    20                         ; Push the length of the string to be drawn (20 characters)
        call    XDrawString                ; Call XDrawString to draw "Hello, World!" in the window

        pop     rax                        ; Clean up the stack
        pop     rdx                        ; Clean up the stack
        jmp     window_loop                ; Jump back to window_loop to handle the next event

section .data

section .bss

section .rodata
main_string:
        db "Hello, World!", 0              ; Null-terminated string "Hello, World!" to be displayed in the window

