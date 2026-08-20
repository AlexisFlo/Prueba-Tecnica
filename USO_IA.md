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


# Uso de IA — Ejercicio 3

## Qué generé con IA
- Estructura del useReducer (estado, acciones, reducer).
- Lógica de escape de comillas en el CSV.

## Qué entendí/decidí yo
- El flujo general del componente: tabla con columnas, filtros por
  botones, loading, manejo de error, paginación y exportación CSV
  como partes separadas que se conectan entre sí.
- Detecté que el código generado recibía mockFetch como prop, cuando
  el enunciado deja claro que la función ya está disponible
  directamente y pide explícitamente no modificar su firma. Corregí
  el componente para usar mockFetch directo, sin prop ni argumentos
  extra.
- No agregué AbortController porque no tenía una idea clara de cómo
  integrarlo con mockFetch.
- Al probar el componente me salió ReferenceError: mockFetch is not
  defined, porque el archivo de entrega solo usa la función, no la
  define. Decidí, después de revisar el enunciado, que el archivo de
  entrega no debe importar ni definir mockFetch — se asume que el
  evaluador la provee.

## Cómo verifiqué
- Comparé el componente contra la firma exacta del mockFetch dado en
  el enunciado (page, estado) y corregí el mismatch que tenía.
- Probé el componente en local usando un mockFetch de prueba con datos
  falsos (mockFetch.jsx), pero ese archivo se dejó fuera
  del entregable final — el componente de entrega usa mockFetch
  directo, sin importarlo, asumiendo que el evaluador lo provee.
- No revisé a fondo la estructura del reducer ni la lógica del CSV,
  son las dos partes que menos domino de este ejercicio.
