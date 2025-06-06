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

	// ----------------- Parte 1: CIELO -----------------
	// Color celeste: 0xFFADD8E6
	movz x10, 0xAD, lsl 16
	movk x10, 0xD8E6, lsl 0
	mov x0, x20
	mov x2, 240          // Altura del cielo

cielo_loop_y:
	mov x1, SCREEN_WIDTH
cielo_loop_x:
	stur w10, [x0]
	add x0, x0, 4
	subs x1, x1, 1
	b.ne cielo_loop_x
	subs x2, x2, 1
	b.ne cielo_loop_y

	// ----------------- Parte 2: TIERRA -----------------
	// Color marrón/verde: 0xFF556B2F
	movz x10, 0x55, lsl 16
	movk x10, 0x6B2F, lsl 0
	mov x0, x20

	// x0 = x20 + (240 * SCREEN_WIDTH * 4)
	mov x3, 240
	mov x4, SCREEN_WIDTH
	mul x3, x3, x4
	lsl x3, x3, 2
	add x0, x0, x3
	mov x2, 240          // Altura de la tierra

tierra_loop_y:
	mov x1, SCREEN_WIDTH
tierra_loop_x:
	stur w10, [x0]
	add x0, x0, 4
	subs x1, x1, 1
	b.ne tierra_loop_x
	subs x2, x2, 1
	b.ne tierra_loop_y

	// ----------------- Parte 3: TRIÁNGULO ASFALTO -----------------
	// Color gris oscuro: 0xFF444444
	movz x10, 0x44, lsl 16
	movk x10, 0x4444, lsl 0

	mov x5, 240              // y desde 240 a 479
	mov x16, 240             // constante 240
	mov x17, SCREEN_WIDTH    // 640
	lsr x18, x17, 1          // 320 = SCREEN_WIDTH / 2

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

	// ----------------- Ejemplo de uso de GPIO -----------------
	// Atención: se utilizan registros w porque la documentación de broadcom
	//           indica que los registros que estamos leyendo y escribiendo son de 32 bits

	mov x9, GPIO_BASE
	str wzr, [x9, GPIO_GPFSEL0]   // GPIOS 0-9 como entrada
	ldr w10, [x9, GPIO_GPLEV0]    // Leer GPIO 0-31
	and w11, w10, 0b10            // Extraer bit 1
	lsr w11, w11, 1				  // w11 será 1 si había un 1 en la posición 2 de w10, si no será 0
                                  // efectivamente, su valor representará si GPIO 2 está activo

	//---------------------------------------------------------------
	// Infinite Loop

InfLoop:
	b InfLoop
