    .global loop_delay       // exportamos la etiqueta
    .text

// loop_delay: delay simple con bucle en x7
// Entrada: x7 = cantidad de iteraciones
loop_delay:
    subs x7, x7, #1
    cbnz x7, loop_delay
    ret
