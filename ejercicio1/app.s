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
	movz x10, 0x99, lsl 16
	movk x10, 0x4C00, lsl 00
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
	stur w10,[x0] //Cargamos color
	add x0,x0,4 //Avanzamos en la direccion 4 bytes 1 pos
	sub x1,x1,1 //Restamos contador
	cbnz x1,tierra_loop // Si x1 es distinto de 0 vuelve

	// ----------------- Parte 3: TRIÁNGULO ASFALTO -----------------
	// Color gris oscuro: 0xFF444444
	movz x10, 0x44, lsl 16
	movk x10, 0x4444, lsl 0

	mov x5, 240              // y desde 240 a 479
	mov x16, 240             // constante 240
	mov x17, SCREEN_WIDTH    // 640
	lsr x18, x17, 1          // 320 = SCREEN_WIDTH / 2

	// ---------------------------------------------------
	// DELAY EJERCICIO 7 TP 8
	movz x7, 0x1, lsl 0 //SI 48 32 16
	lsl x7,x7, 27
L2: 	sub x7, x7, 1 // No existe subi asi que modificamos a sub
	cbnz x7, L2


	// ---------------------------------------------------------
triangulo_loop_y:
	sub x6, x5, x16          // x6 = y - 240

	// x_offset = (x6 * 320) / 240
	mul x8, x6, x18
	udiv x8, x8, x16

	// x_inicio = 320 - x_offset
	mov x11, 320
	sub x11, x11, x8

	// x_fin = 320 + x_offset
	mov x12, 320
	add x12, x12, x8

	// offset = ((y * SCREEN_WIDTH) + x_inicio) * 4
	mul x13, x5, x17
	add x13, x13, x11
	lsl x13, x13, 2
	add x14, x20, x13

triangulo_loop_x:
	cmp x11, x12
	b.gt end_linea_triangulo
	stur w10, [x14]
	add x14, x14, 4
	add x11, x11, 1
	b triangulo_loop_x

end_linea_triangulo:
	add x5, x5, 1
	cmp x5, SCREEN_HEIGH
	b.lt triangulo_loop_y

	// ---------------------------------------------------
	// DELAY EJERCICIO 7 TP 8
	movz x7, 0x1, lsl 0 //SI 48 32 16
	lsl x7,x7, 27
L3: 	sub x7, x7, 1 // No existe subi asi que modificamos a sub
	cbnz x7, L3


	// ---------------------------------------------------------

	// ----------------- Parte 4: TRIÁNGULO AMARILLO (linea asfalto) ----
	// Color amarillo: 0xFFFFFF00
	movz x10, 0xFF, lsl 16      // Parte alta → FF0000
	movk x10, 0xCC33, lsl 0     // Parte baja → +CC33 = FFFFCC33

	mov x5, 240              // y desde 240 a 479
	mov x16, 240             // constante 240
	mov x17, SCREEN_WIDTH    // 640
	mov x19, 5               // ancho base del triángulo (muy angosto)

triangulo_amarillo_loop_y:
	sub x6, x5, x16          // x6 = y - 240
	mul x8, x6, x19          // x6 * 5
	udiv x8, x8, x16         // x_offset angosto

	mov x11, 320
	sub x11, x11, x8         // x_inicio
	mov x12, 320
	add x12, x12, x8         // x_fin

	mul x13, x5, x17
	add x13, x13, x11
	lsl x13, x13, 2
	add x14, x20, x13        // dirección base

triangulo_amarillo_loop_x:
	cmp x11, x12
	b.gt end_linea_amarilla
	stur w10, [x14]
	add x14, x14, 4
	add x11, x11, 1
	b triangulo_amarillo_loop_x

end_linea_amarilla:
	add x5, x5, 1
	cmp x5, SCREEN_HEIGH
	b.lt triangulo_amarillo_loop_y	

	// ---------------------------------------------------
	// DELAY EJERCICIO 7 TP 8
	movz x7, 0x1, lsl 0 //SI 48 32 16
	lsl x7,x7, 27
L5: 	sub x7, x7, 1 // No existe subi asi que modificamos a sub
	cbnz x7, L5


	// ---------------------------------------------------------

	//----------------------RECTANGULOS PARA SIMULAR LINEA PUNTEADA------------
	// Color gris oscuro en x15
	movz x15, 0x44, lsl 16
	movk x15, 0x4444, lsl 0

	mov x0, x20                  // framebuffer base
	mov x1, SCREEN_WIDTH         // ancho pantalla
	mov x2, SCREEN_HEIGH         // alto pantalla
	mov x3, 250                  // y inicial (inicio del punteado)
	mov x4, 8                    // alto del rectángulo
	mov x5, 10                   // ancho del rectángulo
	mov x6, 55                   // espacio entre rectángulos
	mov x7, 315                  // x inicial (320 - 5 para centrar ancho 10)

rect_loop_y:
    	mov x8, 0                // fila local

rect_fill_y:
    	add x9, x3, x8           // y actual
    	cmp x9, x2
    	b.ge rect_exit

    	mul x10, x9, x1
    	add x10, x10, x7
    	lsl x10, x10, 2
    	add x11, x20, x10        // dirección final = framebuffer + offset

    	mov x12, 0
rect_fill_x:
    	cmp x12, x5
    	b.ge rect_next_row
    	stur w15, [x11]          // pintar gris
    	add x11, x11, 4
	add x12, x12, 1
    	b rect_fill_x

rect_next_row:
    	add x8, x8, 1
    	cmp x8, x4
    	b.lt rect_fill_y

    	add x3, x3, x6           // avanzar al siguiente rectángulo
    	cmp x3, x2
    	b.lt rect_loop_y
rect_exit:
	// -------------------------------------------------------------------
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
