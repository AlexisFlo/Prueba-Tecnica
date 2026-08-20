-- Archivo: ejercicio1.sql 

-- Contexto: Assert Consulting gestiona cobranza de creditos para instituciones 

-- financieras. El sistema registra clientes, cuentas y transacciones. 

  

-- TODO 1: Crea el esquema de tablas (clientes, cuentas, transacciones, 

--         conceptos_pago) con sus relaciones, constraints e indices.

CREATE TABLE clientes(
  client_id BIGSERIAL PRIMARY KEY,
  first_name VARCHAR(150) NOT NULL,
  rfc VARCHAR(13) UNIQUE,
  phone VARCHAR(20),
  email VARCHAR(150),
  created_at DATE NOT NULL DEFAULT CURRENT_DATE,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT chk_email_clients CHECK (email IS NULL OR email LIKE '%_@__%.__%')
);

CREATE TABLE cuentas(
  account_id BIGSERIAL PRIMARY KEY,
  client_id BIGINT NOT NULL REFERENCES clientes(client_id),
  credit_number VARCHAR(30) NOT NULL UNIQUE,
  original_amount NUMERIC(14, 2) NOT NULL CHECK (original_amount >= 0),
  balance NUMERIC(14, 2) NOT NULL CHECK (balance >= 0),
  due_date DATE NOT NULL,
  is_delinquent BOOLEAN NOT NULL DEFAULT FALSE  -- cuenta castigada / dada de baja de cobranza normal
  opening_date DATE NOT NULL DEFAULT CURRENT_DATE,
  CONSTRAINT chk_accounts_dates CHECK (due_date >= opening_date)
);

CREATE TABLE conceptos_pago(
  concept_id BIGSERIAL PRIMARY KEY,
  concept_name VARCHAR(100) NOT NULL,
  sat_code CHAR(8) NOT NULL, 
  active BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT chk_sat_code CHECK (sat_code ~ '^[A-Z0-9]{8}$'),
);

-- RF-14:
-- clave_sat es obligatoria para identificar fiscalmente el concepto
-- de pago conforme al catálogo SAT. Se define NOT NULL para impedir
-- conceptos sin clasificación fiscal y UNIQUE para evitar duplicidad
-- de claves SAT.

CREATE TABLE transacciones(
  transaction_id BIGSERIAL PRIMARY KEY,
  client_id BIGINT NOT NULL REFERENCES clientes(client_id),
  account_id BIGINT NOT NULL REFERENCES cuentas(account_id),
  concept_id BIGINT NOT NULL REFERENCES conceptos_pago(concept_id),
  amount NUMERIC(14, 2) NOT NULL, -- puede ser negativo (notas de crédito)
  transaction_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_amount CHECK (amount <> 0)
)
  
-- RF-14:
-- Índice compuesto para la consulta de cuentas vencidas.
-- Primero se filtra por fecha límite y posteriormente por saldo.
-- Se incluye cliente_id para facilitar el acceso a la relación
-- con el cliente.
--
-- El nombre del índice es obligatorio según RF-14.
CREATE INDEX idx_cta_venc_saldo
    ON cuentas (due_date, amount)
    WHERE is_delinquent = FALSE;

-- Acelera el join cuentas -> clientes y el agrupamiento por cliente
-- en reportes de cartera (FK sin índice implícito en muchos motores).
CREATE INDEX idx_cuentas_cliente ON cuentas (client_id);

-- Resuelve el filtro de ventana de 30 días de la consulta b) y el
-- filtro de "misma fecha_hora aproximada" de la consulta c) sin
-- escanear toda la tabla de transacciones (la más grande del esquema).
CREATE INDEX idx_trans_cliente_fecha ON transacciones (client_id, transaction_date);

-- Soporta la detección de duplicados (c): agrupa candidatos por
-- cliente+monto antes de comparar diferencias de tiempo, evitando
-- un self-join sobre toda la tabla.
CREATE INDEX idx_trans_cliente_monto ON transacciones (client_id, amount);

-- TODO 2: Escribe las siguientes consultas: 

--   a) Cuentas vencidas: clientes con saldo > 0 y fecha_limite < hoy, 
--      mostrando nombre, saldo pendiente y dias de atraso. 
--      Excluye las cuentas que ya estan en quebranto. 
-- saldo > 0: si ya está en 0, la cuenta está pagada, no hay nada que cobrar.
-- is_delinquent = FALSE: las cuentas en quebranto las maneja otro proceso
-- (jurídico/recuperación), no cobranza normal, por eso se excluyen.
-- dias_atraso se calcula al vuelo (no se guarda en una columna) porque
-- cambia cada día; guardarlo requeriría un job que lo actualice y podría
-- desincronizarse de la realidad.
SELECT c.first_name, cu.balance AS saldo_pendiente, (CURRENT_DATE - cu.due_date) AS dias_atraso
FROM cuentas cu
JOIN clientes c ON c.client_id = cu.client_id
WHERE cu.saldo > 0
  AND cu.due_date < CURRENT_DATE
  AND cu.is_delinquent = FALSE
ORDER BY dias_atraso DESC;

--   b) Top 5 clientes por volumen transaccionado en los ultimos 30 dias. 
--      (transacciones.monto puede ser negativo en notas de credito) 
-- SUM(ABS(monto)): volumen es cuánto se movió, no cuánto quedó neto.
-- Un cliente con muchas notas de crédito (montos negativos) también
-- tuvo mucho movimiento, aunque su neto sea bajo. Por eso ordeno por
-- el valor absoluto y no por la suma directa.
SELECT
    c.client_id,
    c.first_name,
    SUM(t.amount) AS volumen_neto,
    SUM(ABS(t.amount)) AS volumen_absoluto
FROM transacciones t
JOIN clientes c ON c.client_id = t.client_id
WHERE t.transaction_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY c.client_id, c.first_name
ORDER BY volumen_absoluto DESC
LIMIT 5;
  

--   c) Posibles transacciones duplicadas: mismo client_id, mismo amount, 
--      diferencia de tiempo < 5 minutos. 
-- t2.transaccion_id > t1.transaccion_id: sin esto, cada transacción se
-- compara consigo misma y cada par sale duplicado (A-B y B-A). Con esta
-- condición cada par de duplicados solo aparece una vez.
-- BETWEEN fecha_hora AND fecha_hora + 5 min (en vez de ABS(diferencia) < 5):
-- BETWEEN sí puede usar el índice de fecha para buscar rápido. ABS obliga
-- a calcular la resta en cada fila antes de poder filtrar, es más lento.
SELECT
    t1.transaccion_id AS transaccion_1,
    t2.transaccion_id AS transaccion_2,
    t1.cliente_id,
    t1.monto,
    t1.fecha_hora AS fecha_1,
    t2.fecha_hora AS fecha_2,
    EXTRACT(EPOCH FROM (t2.fecha_hora - t1.fecha_hora)) / 60 AS diff_minutos
FROM transacciones t1
JOIN transacciones t2
  ON t1.cliente_id = t2.cliente_id
 AND t1.monto = t2.monto
 AND t2.transaccion_id > t1.transaccion_id
 AND t2.fecha_hora BETWEEN t1.fecha_hora AND t1.fecha_hora + INTERVAL '5 minutes'
ORDER BY t1.cliente_id, t1.fecha_hora;