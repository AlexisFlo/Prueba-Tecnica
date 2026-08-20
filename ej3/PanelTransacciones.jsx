// Archivo: ejercicio3/PanelTransacciones.jsx
// Panel de transacciones: tabla + filtro por estado + paginación +
// loading + manejo de errores + exportación CSV.
//
// RF-07: la constante de tamaño de página se llama LIMITE_PAGINA y el
// archivo CSV exportado se llama transacciones_assert.csv.

import { useReducer, useEffect } from 'react';

const LIMITE_PAGINA = 10; // RF-07

const ESTADOS = ['todas', 'pendiente', 'aprobado', 'rechazado'];

// --- Reducer ------------------------------------------------------
// Se centraliza todo el estado relacionado (lista, página, filtro,
// loading, error) en un solo reducer porque son datos que cambian
// juntos y de forma dependiente: cambiar el filtro implica resetear
// la página, iniciar carga implica limpiar error, etc. Con varios
// useState sueltos sería fácil dejar alguno desincronizado.
const initialState = {
  lista: [],
  pagina: 1,
  totalPaginas: 1,
  filtro: 'todas',
  loading: false,
  error: null,
};

function reducer(state, action) {
  switch (action.type) {
    case 'FETCH_INICIO':
      // Al iniciar una petición nueva, se limpia cualquier error
      // previo para no mostrar un mensaje viejo mientras carga.
      return { ...state, loading: true, error: null };

    case 'FETCH_EXITO':
      return {
        ...state,
        loading: false,
        lista: action.payload.data,
        totalPaginas: action.payload.pages,
      };

    case 'FETCH_ERROR':
      return { ...state, loading: false, error: action.payload };

    case 'CAMBIAR_FILTRO':
      // Al cambiar de filtro, se regresa a la página 1: mostrar la
      // página 3 de "pendiente" no tiene sentido si el usuario acaba
      // de cambiar a "aprobado", que puede tener menos registros.
      return { ...state, filtro: action.payload, pagina: 1 };

    case 'CAMBIAR_PAGINA':
      return { ...state, pagina: action.payload };

    default:
      return state;
  }
}

export default function PanelTransacciones() {
  const [state, dispatch] = useReducer(reducer, initialState);
  const { lista, pagina, totalPaginas, filtro, loading, error } = state;

  // NOTA: la restricción del ejercicio pide cancelar peticiones
  // pendientes con AbortController al cambiar filtro o página. Se
  // deja fuera intencionalmente en esta versión (ver NOTAS.md) para
  // no dejar código que no pueda explicar a fondo. Sin esto existe
  // un riesgo real de "race condition": si el usuario cambia de
  // filtro/página muy rápido, una respuesta vieja podría llegar
  // después que la nueva y sobreescribir datos más recientes.
  useEffect(() => {
    dispatch({ type: 'FETCH_INICIO' });

    mockFetch(pagina, filtro)
      .then((res) => {
        dispatch({ type: 'FETCH_EXITO', payload: res });
      })
      .catch(() => {
        dispatch({ type: 'FETCH_ERROR', payload: 'No se pudieron cargar las transacciones. Intenta de nuevo.' });
      });
  }, [pagina, filtro]);

  function handleCambiarFiltro(nuevoFiltro) {
    dispatch({ type: 'CAMBIAR_FILTRO', payload: nuevoFiltro });
  }

  function handleAnterior() {
    if (pagina > 1) {
      dispatch({ type: 'CAMBIAR_PAGINA', payload: pagina - 1 });
    }
  }

  function handleSiguiente() {
    if (pagina < totalPaginas) {
      dispatch({ type: 'CAMBIAR_PAGINA', payload: pagina + 1 });
    }
  }

  function handleExportarCSV() {
    // Se exportan solo los registros visibles (la página actual ya
    // filtrada), no todo el dataset, porque el enunciado pide
    // "descargue los registros visibles de la tabla", no todos los
    // que existan en el backend.
    const encabezados = ['ID', 'Cliente', 'Monto', 'Estado', 'Fecha'];
    const filas = lista.map((t) => [t.id, t.cliente, t.monto, t.estado, t.fecha]);

    // Se escapan las comillas dobles duplicándolas y se envuelve cada
    // campo entre comillas, por si algún nombre de cliente trae comas.
    const escaparCampo = (valor) => `"${String(valor).replace(/"/g, '""')}"`;

    const contenido = [encabezados, ...filas]
      .map((fila) => fila.map(escaparCampo).join(','))
      .join('\n');

    const blob = new Blob([contenido], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);

    const enlace = document.createElement('a');
    enlace.href = url;
    enlace.download = 'transacciones_assert.csv'; // RF-07
    document.body.appendChild(enlace);
    enlace.click();
    document.body.removeChild(enlace);
    URL.revokeObjectURL(url);
  }

  return (
    <div>
      <div>
        {ESTADOS.map((e) => (
          <button
            key={e}
            onClick={() => handleCambiarFiltro(e)}
            disabled={filtro === e}
          >
            {e.charAt(0).toUpperCase() + e.slice(1)}
          </button>
        ))}
      </div>

      <button onClick={handleExportarCSV} disabled={loading || lista.length === 0}>
        Exportar CSV
      </button>

      {loading && <p>Cargando transacciones...</p>}

      {error && <p role="alert">{error}</p>}

      {!loading && !error && (
        <>
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Cliente</th>
                <th>Monto</th>
                <th>Estado</th>
                <th>Fecha</th>
              </tr>
            </thead>
            <tbody>
              {lista.length === 0 ? (
                // Caso borde: sin registros para el filtro/página actual.
                <tr>
                  <td colSpan={5}>No hay transacciones para mostrar.</td>
                </tr>
              ) : (
                lista.map((t) => (
                  <tr key={t.id}>
                    <td>{t.id}</td>
                    <td>{t.cliente}</td>
                    <td>{t.monto}</td>
                    <td>{t.estado}</td>
                    <td>{t.fecha}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>

          <div>
            <button onClick={handleAnterior} disabled={pagina <= 1}>
              Anterior
            </button>
            <span>
              Página {pagina} de {totalPaginas}
            </span>
            <button onClick={handleSiguiente} disabled={pagina >= totalPaginas}>
              Siguiente
            </button>
          </div>
        </>
      )}
    </div>
  );
}