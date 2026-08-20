## Qué generé con IA
## Ejercicio 1
- Estructura completa de las 3 consultas (a, b, c): JOINs, WHEREs,
  agregaciones y funciones usadas.

### Qué verifiqué / entendí yo, no solo copié
Ejercicio 1
- Para la condición t2.transaccion_id > t1.transaccion_id en la
  consulta c), no la entendí a la primera; pedí que me la explicaran
  con un ejemplo de datos concreto hasta poder repetir la razón con
  mis propias palabras (evita comparar una fila consigo misma y evita
  pares duplicados A-B/B-A).
- Revisé constraints faltantes en conceptos_pago y decidí cuáles
  agregar y cuáles no.
- Revisé una versión de índices con redundancia y decidí cuál quitar.

## Ejercicio 2

### Qué identifiqué y corregí yo
- Bug 1 (falta la llave "{"): lo detecté y corregí solo.
- Bug 2 (SQL Injection por concatenación de $clienteId): lo identifiqué
  solo y apliqué la corrección con parámetro preparado (?) sin ayuda.
- Bug 3 (Mass Assignment en $request->all()): identifiqué el riesgo
  general ("puede insertar datos que no debería"), aunque no conocía
  el término técnico "Mass Assignment" hasta que se me explicó.
- Detecté que se me había quedado un foreach muerto (código sobrante)
  al corregir el Bug 5, antes de dejarlo en el archivo final.

### Qué generé/expliqué con IA
- Bug 4 (falta de validación en store()): no lo identifiqué por mi
  cuenta; se me explicó el riesgo y la sintaxis de $request->validate().
- Bug 5 (problema N+1 en resumenClientes): no conocía el concepto,
  se me explicó con ejemplo (100 clientes = 101 queries) y la solución
  con with().
- La sintaxis completa de las reglas de validación en store().

### Cómo verifiqué
- Revisé que cada bug corregido correspondiera exactamente a la línea
  señalada en el enunciado original.

