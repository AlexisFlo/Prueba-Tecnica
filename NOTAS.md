# Notas — Ejercicio 1

## Dudas que surgieron
- ¿Debía usar BOOLEAN o un status con catálogo de estados para el
  estado de la cuenta? Ver alternativa descartada abajo.
- ¿Vale la pena un CHECK (TRIM(nombre) <> '') en tablas catálogo
  pequeñas, o es sobre-ingeniería? Lo dejé fuera por no ser el riesgo
  prioritario del ejercicio.
- No me quedó claro en qué momento is_delinquent debería actualizarse
  (¿manual desde cobranza? ¿un job automático?) — el esquema no lo
  resuelve, solo asume que existe un proceso externo que lo marca.

## Supuestos que tomé
- "Cuenta vencida" es un estado calculado (fecha_limite < hoy AND
  saldo > 0), no un campo guardado — evita que se desincronice de
  la realidad.
- "Volumen transaccionado" se mide en valor absoluto del monto, no
  en suma neta, porque notas de crédito también representan actividad.
- Una transacción con monto = 0 no tiene sentido de negocio, se
  bloquea con CHECK.
- cliente_id y cuenta_id en una transacción deben ser consistentes
  entre sí (no puede haber una transacción con una cuenta que no
  pertenezca al cliente indicado) — se resuelve con FK compuesta
  hacia UNIQUE(cuenta_id, cliente_id) en cuentas.

## Alternativa que descarté
Para el estado de la cuenta, consideré:
```sql
status VARCHAR(20) CHECK (status IN ('active', 'delinquent'))
```
en vez de `is_delinquent BOOLEAN`. La descarté porque en este
ejercicio el negocio real es binario (en quebranto o no) y todo lo
demás ("vencida", "al corriente") ya se calcula dinámicamente con
fecha_limite y saldo. Un VARCHAR con más estados sería más flexible
a futuro, pero implicaría guardar un estado que en realidad es
derivable, con riesgo de desincronizarse de la realidad. Si el
negocio necesitara más estados a futuro (reestructura, jurídico),
la alternativa correcta no sería ampliar el CHECK sino crear una
tabla catálogo `estados_cuenta` con FK.

# Notas — Ejercicio 2
 
## Dudas que surgieron
- No conocía el término "Mass Assignment" antes de este ejercicio,
  aunque sí notaba que $request->all() sin filtro era riesgoso.
- No tenía claro el concepto de "N+1 queries" ni por qué acceder a una
  relación dentro de un foreach sin with() es un problema real de
  rendimiento (lo entendí con el ejemplo de 100 clientes = 101 queries).
- Duda abierta: ¿qué tan estrictas deberían ser las reglas de
  validación en store() (ej. rangos de monto, formato de referencia)?
  Dejé reglas básicas (required, tipo, exists) sin reglas de negocio
  más finas por no tener esa información del enunciado.

## Supuestos que tomé
- Una transacción de $0 no significa nada, no representa dinero real
  que se movió, por eso no dejo crearla.
- No quiero que se pueda crear una transacción de un cliente, cuenta
  o concepto que no existe — sería un dato falso.
- No siempre hay un número de referencia en una transacción, por eso
  no lo hago obligatorio.
- Me aseguro de que el id del cliente sea un número y no letras, para
  que no metan algo raro ahí.

## Alternativa que descarté
Para el Bug 5, pensé en solo quitar la línea que causaba el problema
(sin usar with()). No lo hice porque no arreglaba nada de raíz: si
después se necesita mostrar las transacciones, el problema iba a
volver a aparecer. Usar with() lo resuelve desde ahora.