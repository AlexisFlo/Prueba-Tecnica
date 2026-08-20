## Ejercicio 5  Reflexión técnica 

 Mínimo 3 oraciones por respuesta. No hay una única respuesta correcta — evaluamos tu criterio y experiencia. Las respuestas genéricas o de manual puntúan bajo: buscamos casos concretos, con nombres, números y consecuencias reales.  Formato requerido: encabeza cada respuesta de REFLEXION.md con la etiqueta [R1] a [R5] segun el numero de pregunta. 

[R1]

Encontré un problema al editar el contacto de una orden de calibración que apareció primero en el ambiente de pruebas y posteriormente también en producción, el cambio se mostraba correctamente, pero al recargar la orden volvía a aparecer el contacto anterior. La causa fue que el estado del contacto estaba siendo manejado desde diferentes partes del formulario y un `useEffect` podía volver a sincronizarlo con el valor original de la orden, además de que el flujo de persistencia no estaba suficientemente aislado. 
Para resolverlo creé un componente específico para manejar el contacto, concentrando ahí la selección, edición y guardado, y evitando que otra parte del formulario sobrescribiera el estado. Esta solución no solo corrigió el bug, sino que también me mostró que cuando una parte de un formulario tiene reglas y estados propios, conviene encapsularla en lugar de seguir agregando condiciones al componente principal.

[R2]
En una integración que realicé con Stripe, el frontend utilizaba los componentes de Stripe para capturar los datos de la tarjeta y el backend recibía el resultado para registrar el pago, por lo que al agregar otro método evitaría modificar directamente ese flujo. Primero revisaría cómo está estructurado actualmente el proceso de cobranza y separaría la lógica específica de cada proveedor mediante una interfaz o servicio común, de forma que el nuevo método pueda incorporarse sin alterar el comportamiento de Stripe. 
También definiría claramente los estados del pago, como pendiente, aprobado y rechazado, y probaría tanto el nuevo método como los flujos existentes antes de liberarlo. De esta manera, el cambio queda aislado y si posteriormente se agrega otro proveedor no sería necesario modificar nuevamente toda la lógica de cobranza.

[R3]

Al diseñar una API que procesa transacciones financieras, primero controlaría el acceso mediante autenticación con JWT y autorización basada en roles y permisos, algo que ya he utilizado en APIs con NestJS mediante Guards. También validaría todos los datos en el backend mediante DTOs y evitaría confiar en información enviada directamente desde el frontend, además de no almacenar datos sensibles de tarjetas si el proveedor de pagos puede encargarse de ellos. Para las operaciones de pago consideraría especialmente la 
idempotencia, el registro de auditoría y la validación de las respuestas o webhooks del proveedor, ya que una petición repetida o manipulada podría terminar generando un cobro incorrecto. Finalmente, cuidaría que los logs no expongan información sensible y utilizaría HTTPS, manejo controlado de errores y permisos mínimos para reducir el impacto de una posible vulnerabilidad.

[R4]

He trabajado en el desarrollo de un sistema administrativo con funcionalidades propias de un ERP, aunque no sobre plataformas comerciales como SAP u Oracle. El módulo más complejo que he desarrollado es el de órdenes de calibración, porque una orden relaciona información de clientes, contactos, direcciones, equipos, diagnósticos, archivos, procesos de calibración, técnicos y diferentes estados del flujo de trabajo. La dificultad principal ha sido mantener la consistencia entre estas entidades y permitir que cada etapa 
de la orden pueda actualizar su información sin afectar los procesos anteriores. Trabajar en este módulo me ha hecho prestar especial atención a las relaciones entre datos, permisos, estados y persistencia, ya que un cambio aparentemente pequeño en una parte de la orden puede tener consecuencias en otras partes del sistema.

[R5]

Si un cliente reportara que una transacción se procesó dos veces, primero identificaría las dos operaciones mediante el ID, referencia, monto y fecha para confirmar si realmente existen dos transacciones o si se trata de un problema de visualización. Después revisaría los registros de la base de datos y los logs del backend para determinar si llegaron dos solicitudes, si hubo algún reintento o si el mismo evento fue procesado más de una vez. También revisaría el registro de la operación con el proveedor de pagos para confirmar 
si el problema ocurrió durante el procesamiento del pago o únicamente al registrar la información en nuestro sistema. Con esa información buscaría reproducir el flujo que generó la duplicidad y corregiría el punto específico donde se está ejecutando nuevamente la operación.

[R6]

Una decisión técnica que hoy considero un error fue concentrar demasiada lógica en componentes grandes de React, porque al principio me parecía más rápido tener el estado, los formularios y las acciones relacionadas dentro del mismo componente. Esta decisión funcionó mientras la funcionalidad era pequeña, pero conforme el sistema creció comenzaron a aparecer más estados, condiciones y `useEffect`, haciendo que fuera más difícil entender qué parte estaba provocando ciertos comportamientos. El problema con el manejo del contacto en 
las órdenes de calibración fue uno de los casos que me hizo cambiar de opinión, ya que tuve que separar esa lógica en un componente específico para evitar que diferentes partes del formulario interfirieran entre sí. Actualmente intento separar responsabilidades antes de que un componente crezca demasiado, aunque inicialmente implique escribir más componentes, porque a largo plazo facilita la depuración y el mantenimiento.

[R7]

Una herramienta que dejé de utilizar fue Zustand para el manejo de estado, principalmente porque en el proyecto y trabajo actual la arquitectura del equipo utiliza principalmente `useState`, `useEffect` y hooks propios para manejar el estado de los módulos. En proyectos anteriores Zustand me había resultado útil para compartir información entre diferentes componentes, pero al incorporarme al proyecto actual tuve que adaptarme a los patrones que ya estaban establecidos en lugar de introducir una nueva dependencia. Esto me enseñó que una herramienta 
no tiene que ser reemplazada porque sea mala, sino que su utilidad depende del contexto y de las necesidades de cada proyecto. Actualmente evaluaría primero la arquitectura existente y el alcance real del estado antes de decidir si es necesario incorporar una solución como Zustand.
