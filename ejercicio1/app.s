	.equ SCREEN_WIDTH, 		640
	.equ SCREEN_HEIGH, 		480
	.equ BITS_PER_PIXEL,  	32

	.equ GPIO_BASE,      0x3f200000
	.equ GPIO_GPFSEL0,   0x00
	.equ GPIO_GPLEV0,    0x34

	.globl main

main:
	// x0 contiene la direccion base del framebuffer
 	mov x20, x0	// Guarda la dirección base del framebuffer en x20
	//---------------- CODE HERE ------------------------------------
	
	//FONDO 1

	movz x10, 0xAD, lsl 16
	movk x10, 0xD8E6, lsl 00

	mov x2, SCREEN_HEIGH         // Y Size
loop1:
	mov x1, SCREEN_WIDTH         // X Size
loop0:
	stur w10,[x0]  // Colorear el pixel N
	add x0,x0,4	   // Siguiente pixel
	sub x1,x1,1	   // Decrementar contador X
	cbnz x1,loop0  // Si no terminó la fila, salto
	sub x2,x2,1	   // Decrementar contador Y
	cbnz x2,loop1  // Si no es la última fila, salto
	
	// ---------------------------------------------------
	// DELAY EJERCICIO 7 TP 8
	movz x7, 0x1, lsl 0 //SI 48 32 16
	lsl x7,x7, 27
L1: 	sub x7, x7, 1 // No existe subi asi que modificamos a sub
	cbnz x7, L1


	// ---------------------------------------------------------
	// FONDO 2

	// Reusamos el registro x10 para cambiarle el color
	movz x10, 0x55, lsl 16
	movk x10, 0x6B2F, lsl 00
	mov x0,x20

	// Creamos Direccion
	// EJE Y = 240 , x=640
	
	mov x3, 240
	mov x4, SCREEN_WIDTH
	
	mul x3,x3,x4 //total de pixeles a pintar
	lsl x3,x3,2 //Creacion Direccion
	add x0,x0,x3 //Guardado en x0 tiene la direccion de donde comenzar
	
	mov x1,240
	mul x1,x1,x4 //Creacion del contador i x1
	
	//Aca modifique mi loop del anterior que tenia para que funcione con cbnz
	//Como se muestra es un solo loop directamente facil para pintar cosas de un tiron
tierra_loop:
	stur w11,[x0] //Cargamos color
	add x0,x0,4 //Avanzamos en la direccion 4 bytes 1 pos
	sub x1,x1,1 //Restamos contador
	cbnz x1,tierra_loop // Si x1 es distinto de 0 vuelve



	// Ejemplo de uso de gpios
	mov x9, GPIO_BASE

	// Atención: se utilizan registros w porque la documentación de broadcom
	// indica que los registros que estamos leyendo y escribiendo son de 32 bits

	// Setea gpios 0 - 9 como lectura
	str wzr, [x9, GPIO_GPFSEL0]

	// Lee el estado de los GPIO 0 - 31
	ldr w10, [x9, GPIO_GPLEV0]

	// And bit a bit mantiene el resultado del bit 2 en w10
	and w11, w10, 0b10

	// w11 será 1 si había un 1 en la posición 2 de w10, si no será 0
	// efectivamente, su valor representará si GPIO 2 está activo
	lsr w11, w11, 1
	

	//---------------------------------------------------------------
	// Infinite Loop

InfLoop:
	b InfLoop
