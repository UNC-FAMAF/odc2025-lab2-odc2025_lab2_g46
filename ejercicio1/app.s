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

//-----------------FONDO 1-------------------------------------------
	movz x10, 0xa1, lsl 16
	movk x10, 0xd1ed, lsl 00

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
	// --------------------------------------------------------------
	// DELAY EJERCICIO 7 TP 8
	movz x7, 0x1, lsl 0 //SI 48 32 16
	lsl x7,x7, 27
	bl loop_delay

//-----------------FONDO 2---------------------------------------
	// Reusamos el registro x10 para cambiarle el color
	movz x10, 0x11, lsl 16
	movk x10, 0x9111, lsl 00
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


//---------------- TRIÁNGULO ASFALTO-----------------------------
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

	// DELAY EJERCICIO 7 TP 8
	movz x7, 0x1, lsl 0 //SI 48 32 16
	lsl x7,x7, 27
L3: 	sub x7, x7, 1 // No existe subi asi que modificamos a sub
	cbnz x7, L3

//--------TRIÁNGULOS AMARILLOS (linea asfalto)-------------------

	// Color amarillo: 0xFFFFFF00
	movz x10, 0xFF, lsl 16      // Parte alta → FF0000
	movk x10, 0xCC33, lsl 0     // Parte baja → +CC33 = FFFFCC33

	mov x5, 240              // y desde 240 a 479
	mov x16, 240             // constante 240
	mov x17, SCREEN_WIDTH    // 640
	mov x19, 5               // ancho base del triángulo 

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
	
	bl loop_delay

	// ---------------------------------------------------------

//--------RECTANGULOS PARA SIMULAR LINEA PUNTEADA----------------

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

// ---------------------------------------------------
	// DELAY EJERCICIO 7 TP 8
	movz x7, 0x1, lsl 0 //SI 48 32 16
	lsl x7,x7, 27
	
	bl loop_delay

// ---------------------------------------------------------


// ----------------------------- nubes -------------------------------
movz x6, 0xF0FF
movk x6, 0xF0, lsl 16

mov x2, #560
mov x3, #10
mov x4, #80
mov x5, #50

b draw_cloud
draw_cloud:
    bl draw_rectangle

b move_cloud_x
move_cloud_x:
    movz x7, 0x1
    lsl x7, x7, 23
    bl delay
    
    movz x6, 0xD8E6
    movk x6, 0xAD, lsl 16
    bl draw_cloud               // borra la existente
    
    add x2, x2, #1
    movz x6, 0xF0FF
    movk x6, 0xF0, lsl 16
    bl draw_cloud               // crea la nueva en posición
    
    bl move_cloud_y
    b move_cloud_x

move_cloud_y:
    lsl x29, x2, 60
    cbnz x29, shift_y

shift_y:
    lsr x29, x2, 4
    lsl x29, x29, 59
    cbnz x29, shift_y_up
    cbz x29, shift_y_down

shift_y_up:
    add x3, x3, #1

shift_y_down:
    sub x3, x3, #1

delay:
    sub x7, x7, #1 // { PRE: x7 tiene el tiempo del delay }
    cbnz x7, delay

	// ---------------------------------------------------
	// DELAY EJERCICIO 7 TP 8
	movz x7, 0x1, lsl 0 //SI 48 32 16
	lsl x7,x7, 27
	
	bl loop_delay

	// ---------------------------------------------------------

//-------------------- Cartel -------------------
// Palo izquierdo
mov x2, #120      // x
mov x3, #200      // y
mov x4, #20       // ancho
mov x5, #120      // alto
movz x6, 0x2a, lsl 16
movk x6, 0x2b2a, lsl 0 
bl draw_rectangle

// Palo derecho
mov x2, #500     // x
mov x3, #200      // y
mov x4, #20       // ancho
mov x5, #120      // alto
movz x6, 0x2a, lsl 16
movk x6, 0x2b2a, lsl 0     
bl draw_rectangle

// Cartel (parte horizontal superior)
// Borde marrón
mov x2, #72        // x borde = 80 - 8
mov x3, #102       // y borde = 110 - 8
mov x4, #496       // ancho borde = 480 + 28
mov x5, #116       // alto borde = 100 + 28
movz x6, 0x8B, lsl 16
movk x6, 0x4513, lsl 0
bl draw_rectangle

// Cartel blanco
mov x2, #80        // x
mov x3, #110       // y
mov x4, #480       // ancho
mov x5, #100       // alto
movz x6, 0xd4, lsl 16
movk x6, 0xc68e, lsl 0     // color blanco roto
bl draw_rectangle

	// ---------------------------------------------------
	// DELAY EJERCICIO 7 TP 8
	movz x7, 0x1, lsl 0 //SI 48 32 16
	lsl x7,x7, 27
	
	bl loop_delay

	// ---------------------------------------------------------

// ----------------- Árbol 1 ----------------------------------
// Tronco marrón
mov x2, #40          // x corregido
mov x3, #300         // y
mov x4, #15          // ancho
mov x5, #60          // alto
movz x6, 0x2e, lsl 16
movk x6, 0x1611, lsl 0
bl draw_rectangle

mov x2, #40          // x corregido
mov x3, #300         // y
mov x4, #5          // ancho
mov x5, #60          // alto
movz x6, 0x4d, lsl 16
movk x6, 0x271c, lsl 0
bl draw_rectangle

// Copa verde parte alta
mov x2, #27
mov x3, #210
mov x4, #30
mov x5, #20
movz x6, 0x09, lsl 16
movk x6, 0x7d12, lsl 0
bl draw_rectangle

// Copa verde parte baja
mov x2, #27
mov x3, #300
mov x4, #40
mov x5, #20
movz x6, 0x05, lsl 16
movk x6, 0x5c18, lsl 0
bl draw_rectangle

// Copa verde parte media alta
mov x2, #20
mov x3, #220
mov x4, #50
mov x5, #70
movz x6, 0x04, lsl 16
movk x6, 0x701c, lsl 0
bl draw_rectangle

// Copa verde parte media baja
mov x2, #15
mov x3, #270
mov x4, #60
mov x5, #40
movz x6, 0x04, lsl 16
movk x6, 0x701c, lsl 0
bl draw_rectangle

// ----------------- Flecha blanca hacia arriba -----------------
// Color blanco
movz x6, 0xFF, lsl 16
movk x6, 0xFFFF, lsl 0     // 0xFFFFFFFF blanco

// Cuerpo vertical
mov x2, #260
mov x3, #150
mov x4, #10
mov x5, #40
bl draw_rectangle

// Punta base (más ancha)
mov x2, #250     // x
mov x3, #145     // y
mov x4, #30      // ancho
mov x5, #6       // alto
bl draw_rectangle

// Punta intermedia
mov x2, #255
mov x3, #140
mov x4, #20
mov x5, #5
bl draw_rectangle

// Punta superior
mov x2, #260
mov x3, #135
mov x4, #10
mov x5, #6
bl draw_rectangle

	// ---------------------------------------------------
	// DELAY EJERCICIO 7 TP 8
	movz x7, 0x1, lsl 0 //SI 48 32 16
	lsl x7,x7, 27
	
	bl loop_delay

	// ---------------------------------------------------------

//------------------ PARTE 5: Letra O -------------------------------
mov x2, #130
mov x3, #140

// { PRE: en x2 el valor x inicial, en x3 el valor y inicial }
draw_O:
    mov x27, x2
    mov x28, x3
    
    // Parte superior 
    add x2, x2, #5         // x actual
    add x3, x3, #0         // y actual
    mov x4, #20        // ancho
    mov x5, #5         // alto
    movz x6, 0xFF, lsl 16
	movk x6, 0xFFFF, lsl 0
    bl draw_rectangle

    // Parte inferior
    mov x2, x27
    mov x3, x28
    add x2, x2, #5         // x actual
    add x3, x3, #40        // y actual
    mov x4, #20        // ancho
    mov x5, #5         // alto
    bl draw_rectangle

    // Lateral izquierdo
    mov x2, x27
    mov x3, x28
    add x2, x2, #0         // x actual
    add x3, x3, #5         // y actual
    mov x4, #5         // ancho
    mov x5, #35        // alto
    bl draw_rectangle

    // Lateral derecho
    mov x2, x27
    mov x3, x28
    add x2, x2, #25        // x actual
    add x3, x3, #5         // y actual
    mov x4, #5         // ancho
    mov x5, #35        // alto
    bl draw_rectangle

//------------------ Letra d ----------------------------------------
mov x2, #130
mov x3, #140

draw_1:
    mov x27, x2
    mov x28, x3
	
	//Parte superior
    add x2, x2, #40         // x actual
    add x3, x3, #20         // y actual
	mov x4, #20        // ancho
	mov x5, #4         // alto
	mov x6, 0xFFFFFF
	bl draw_rectangle

	// Parte inferior
	mov x2, x27         
	mov x3, x28			
	add x2, x2, #40     // x actual
	add x3, x3, #40     // y actual
	mov x4, #16         // ancho
	mov x5, #4          // alto
	bl draw_rectangle

	// Lateral izquierdo
	mov x2, x27         
	mov x3, x28     
	add x2, x2, #36     // x actual
	add x3, x3, #24     // y actual    
	mov x4, #4          // ancho
	mov x5, #16         // alto
	bl draw_rectangle

	// Lateral derecho
	mov x2, x27         // x actual
	mov x3, x28          // y actual
	add x2, x2, #56
	add x3, x3, #2
	mov x4, #4          // ancho
	mov x5, #40         // alto
	bl draw_rectangle

//------------------ Letra C ----------------------------------------
mov x2, #130
mov x3, #140

draw_2:
	mov x27, x2
	mov x28, x3

// Parte superior 
    add x2, x2, #75         // x actual
    add x3, x3, #0         // y actual
	mov x4, #15         // ancho
	mov x5, #5          // alto
	mov x6, 0xFFFFFF
	bl draw_rectangle

	// Parte inferior
	mov x2, x27
	mov x3, x28
	add x2, x2, #75
	add x3, x3, #40
	mov x4, #15
	mov x5, #5
	bl draw_rectangle

	// Lateral izquierdo 1
	mov x2, x27
	mov x3, x28
	add x2, x2, #65
	add x3, x3, #10
	mov x4, #5
	mov x5, #25
	bl draw_rectangle

	// Lateral izquierdo 2a
	mov x2, x27
	mov x3, x28
	add x2, x2, #70
	add x3, x3, #5
	mov x4, #5
	mov x5, #5
	bl draw_rectangle

	// Lateral Derecho 3a
	mov x2, x27
	mov x3, x28
	add x2, x2, #90
	add x3, x3, #5
	mov x4, #5
	mov x5, #5
	bl draw_rectangle

	// Lateral izquierdo 2a
	mov x2, x27
	mov x3, x28
	add x2, x2, #70
	add x3, x3, #35
	mov x4, #5
	mov x5, #5
	bl draw_rectangle

	// Lateral derecho 3b
	mov x2, x27
	mov x3, x28
	add x2, x2, #90
	add x3, x3, #35
	mov x4, #5
	mov x5, #5
	bl draw_rectangle
//------------------ Numero 2 ---------------------------------------
mov x2, #260
mov x3, #140

draw_3:
	mov x27, x2
	mov x28, x3

// Parte superior
	add x2, x2, #105         // x actual
    add x3, x3, #0         // y actual
	mov x4, #25        // ancho
	mov x5, #5         // alto
	movz x6, 0xFF, lsl 16
	movk x6, 0xFFFF, lsl 0
	bl draw_rectangle

// Lateral derecho arriba
	mov x2, x27 
	mov x3, x28
	add x2, x2, #125         // x actual
    add x3, x3, #5         // y actual
	mov x4, #5
	mov x5, #15
	bl draw_rectangle

// Barra horizontal media
	mov x2, x27 
	mov x3, x28
	add x2, x2, #105         // x actual
    add x3, x3, #20         // y actual
	mov x4, #20
	mov x5, #5
	bl draw_rectangle

// Lateral izquierdo abajo
	mov x2, x27 
	mov x3, x28
	add x2, x2, #100         // x actual
    add x3, x3, #25         // y actual	
	mov x4, #5
	mov x5, #15
	bl draw_rectangle

// Parte inferior
	mov x2, x27 
	mov x3, x28
	add x2, x2, #100         // x actual
    add x3, x3, #40         // y actual
	mov x4, #30
	mov x5, #5
	bl draw_rectangle
//------------------ Numero 0 ---------------------------------------
mov x2, #260
mov x3, #140

draw_4:
	mov x27, x2
	mov x28, x3

// Parte superior 
	mov x2, x27 
	mov x3, x28
	add x2, x2, #140         // x actual
    add x3, x3, #0         // y actual	
	mov x4, #20        // ancho
	mov x5, #5         // alto
	movz x6, 0xFF, lsl 16
	movk x6, 0xFFFF, lsl 0
	bl draw_rectangle

// Parte inferior
	mov x2, x27 
	mov x3, x28
	add x2, x2, #140         // x actual
    add x3, x3, #40         // y actual
	mov x4, #20        // ancho
	mov x5, #5         // alto
	bl draw_rectangle

// Lateral izquierdo
	mov x2, x27 
	mov x3, x28
	add x2, x2, #135         // x actual
    add x3, x3, #0         // y actual
	mov x4, #5         // ancho
	mov x5, #45        // alto
	bl draw_rectangle

// Lateral derecho
	mov x2, x27 
	mov x3, x28
	add x2, x2, #160         // x actual
    add x3, x3, #0         // y actual
	mov x4, #5         // ancho
	mov x5, #45        // alto
	bl draw_rectangle

//------------------ Numero 2 ---------------------------------------
mov x2, #260
mov x3, #140

draw_5:
	mov x27, x2
	mov x28, x3
// Parte superior
	mov x2, x27 
	mov x3, x28
	add x2, x2, #175         // x actual
    add x3, x3, #0         // y actual	
	mov x4, #25          // ancho
	mov x5, #5           // alto
	movz x6, 0xFF, lsl 16
	movk x6, 0xFFFF, lsl 0
	bl draw_rectangle

// Lateral derecho arriba
	mov x2, x27 
	mov x3, x28
	add x2, x2, #195         // x actual
    add x3, x3, #5         // y actual	
	mov x4, #5
	mov x5, #15
	bl draw_rectangle

// Barra horizontal media
	mov x2, x27 
	mov x3, x28
	add x2, x2, #175         // x actual
    add x3, x3, #20         // y actual	
	mov x4, #20
	mov x5, #5
	bl draw_rectangle

// Lateral izquierdo abajo
	mov x2, x27 
	mov x3, x28
	add x2, x2, #170         // x actual
    add x3, x3, #25         // y actual	
	mov x4, #5
	mov x5, #15
	bl draw_rectangle

// Parte inferior
	mov x2, x27 
	mov x3, x28
	add x2, x2, #170         // x actual
    add x3, x3, #40         // y actual	
	mov x4, #30
	mov x5, #5
	bl draw_rectangle
//------------------ Numero 5 ---------------------------------------
mov x2, #260
mov x3, #140

draw_6:
	mov x27, x2
	mov x28, x3
// Parte superior
	mov x2, x27 
	mov x3, x28
	add x2, x2, #205         // x actual
    add x3, x3, #0         // y actual	
	mov x4, #25          // ancho
	mov x5, #5           // alto
	movz x6, 0xFF, lsl 16
	movk x6, 0xFFFF, lsl 0
	bl draw_rectangle

// Lateral izquierdo arriba
	mov x2, x27 
	mov x3, x28
	add x2, x2, #205         // x actual
    add x3, x3, #5         // y actual	
	mov x4, #5
	mov x5, #10
	bl draw_rectangle

// Barra horizontal media
	mov x2, #205
	mov x3, #15
	mov x2, x27 
	mov x3, x28
	add x2, x2, #205         // x actual
    add x3, x3, #15         // y actual	
	mov x4, #20
	mov x5, #5
	bl draw_rectangle

// Lateral derecho abajo
	mov x2, #225         
	mov x3, #20
	mov x2, x27 
	mov x3, x28
	add x2, x2, #225         // x actual
    add x3, x3, #20         // y actual	
	mov x4, #5
	mov x5, #20
	bl draw_rectangle

// Parte inferior
	mov x2, #205         
	mov x3, #40
	mov x2, x27 
	mov x3, x28
	add x2, x2, #205         // x actual
    add x3, x3, #40         // y actual	
	mov x4, #20
	mov x5, #5
	bl draw_rectangle
// ----------------- Letra M en blanco -----------------
// Columna izquierda
mov x2, #520      // x
mov x3, #165      // y
mov x4, #5        // ancho
mov x5, #20       // alto
movz x6, 0xFF, lsl 16
movk x6, 0xFFFF, lsl 0
bl draw_rectangle

// Columna central
mov x2, #510      // x (separado un poco de la izquierda)
mov x3, #165
mov x4, #5
mov x5, #20
bl draw_rectangle

// Columna derecha
mov x2, #500      // x (separado igual)
mov x3, #165
mov x4, #5
mov x5, #20
bl draw_rectangle

// Rectángulo superior 
mov x2, #500      // x empieza igual que columna izquierda
mov x3, #160      // y arriba, mismo que columnas
mov x4, #20       // ancho que cubre las 3 columnas y los espacios (aprox)
mov x5, #5        // alto pequeño (grosor de la barra superior)
bl draw_rectangle
// ---------------------- draw_rectangle ----------------------------
draw_rectangle:
    mov x7, #0              // fila local
draw_rect_loop_y:
    add x8, x3, x7          // y actual
    mul x9, x8, x1          // y * SCREEN_WIDTH
    add x9, x9, x2          // + x inicial
    lsl x9, x9, #2          // * 4 bytes por píxel
    add x10, x0, x9         // dirección base del píxel

    mov x11, #0             // columna local
draw_rect_loop_x:
    cmp x11, x4
    b.ge next_row
    stur w6, [x10]
    add x10, x10, #4
    add x11, x11, #1
    b draw_rect_loop_x

next_row:
    add x7, x7, #1
    cmp x7, x5
    b.lt draw_rect_loop_y
    ret

// -------------------------------------------------------------------

// -------------------------------------------------------------------
	// ----------------- Ejemplo de uso de GPIO --------------------------
	// Atención: se utilizan registros w porque la documentación de broadcom
	//           indica que los registros que estamos leyendo y escribiendo son de 32 bits

	mov x9, GPIO_BASE
	str wzr, [x9, GPIO_GPFSEL0]   // GPIOS 0-9 como entrada
	ldr w10, [x9, GPIO_GPLEV0]    // Leer GPIO 0-31
	and w11, w10, 0b10            // Extraer bit 1
	lsr w11, w11, 1				  // w11 será 1 si había un 1 en la posición 2 de w10, si no será 0
                                  // efectivamente, su valor representará si GPIO 2 está activo
	
	//-------------------------------------------------------------------
	// Infinite Loop

InfLoop:
	b InfLoop
