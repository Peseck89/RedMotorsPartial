# TD-RQ308 — Revisión de alcance y autorización de Sprint 3

## 1. Objetivo de la asignación documental

PortalNet presentó inicialmente el documento “DEV Evaluación - Alcance - Inclusión de nueva Empresa - Marcas chinas RedMotors”, que fue aprobado por Red Motors y utilizado como base del proyecto.

Posteriormente, Red Motors compartió el documento “RQ Integración Peking Eco Drive Salesforce Softland”, versión 0.13, con un alcance funcional más amplio.

Luis solicitó comparar ambos documentos para identificar qué reglas, controles, entregables o procesos del documento nuevo no estaban contemplados expresamente en el alcance inicial de PortalNet.

El propósito no era estimar horas detalladas, sino dejar claro qué elementos representan una ampliación del alcance inicial.

## 2. Documento elaborado

Se elaboró el documento [`TD-RQ308_Diferencias_Alcance_Entrega_Oficial.docx`](TD-RQ308_Diferencias_Alcance_Entrega_Oficial.docx).

El documento se organizó en tres bloques:

1. Diferencias de alcance validadas.
2. Temas que ya estaban contemplados de forma general y no deben volver a contarse como extras.
3. Dependencias y definiciones que Red Motors todavía debe proporcionar.

El documento oficial no incluye referencias a herramientas internas, metodología de comparación, conteos internos, conclusión ejecutiva, estado técnico detallado de Sprint 2 ni explicaciones sobre cómo se construyó el análisis. Esos elementos se excluyeron porque no eran relevantes para el documento que PortalNet presentará a Red Motors.

## 3. Criterio de redacción “humanizado”

Para documentación y mensajes de este proyecto, “humanizado” significa:

- español natural y directo;
- explicaciones entendibles;
- términos técnicos únicamente cuando son necesarios;
- evitar frases que parezcan generadas automáticamente;
- evitar lenguaje exageradamente formal o rebuscado;
- evitar repetir conclusiones;
- evitar conteos o clasificaciones internas que no aporten al destinatario;
- no mencionar IA ni el proceso interno de análisis en documentos dirigidos al cliente.

El documento oficial aprobado es la referencia de estilo.

## 4. Resultado general de la comparación

La conclusión correcta es que el documento nuevo de Red Motors incorpora reglas, controles y entregables que no estaban contemplados expresamente en el alcance inicial presentado por PortalNet y aprobado por Red Motors. No debe afirmarse que todo el documento nuevo es adicional.

El alcance inicial ya contemplaba de forma general:

- objeto configurable Empresa;
- soporte para PEKING, OMODA y JAECOO;
- refactor de Apex, triggers, Flows, LWC y Aura;
- Pricebooks;
- inventario;
- bodegas;
- Softland;
- PDF dinámicos;
- perfiles y permisos;
- comunidades;
- talleres;
- calendarios;
- Work Orders;
- pruebas de integración, E2E y regresión.

El documento nuevo amplía esos frentes con reglas más detalladas de:

- obligatoriedad e inmutabilidad de Empresa y Marca;
- derivación por VIN, placa o vehículo;
- auditoría;
- seguridad real más allá de filtros visuales;
- aislamiento y reproceso de errores;
- notificaciones;
- carga inicial;
- conciliación;
- criterios de aceptación;
- UAT formal;
- Go/No-Go;
- soporte posterior;
- mejora transversal del módulo de productos y catálogos.

## 5. Aprobación de Luis

El 5 de agosto de 2026, Luis revisó el documento y confirmó: “Sí, en general me parece bien el documento.”

También solicitó:

- mantenerlo como archivo Word editable;
- subirlo al Drive personal de Claudia;
- configurar el documento para que pueda consultarse o editarse mediante enlace;
- informar a Diego y María que el análisis está disponible en Drive.

No existe en el repositorio evidencia de que el mensaje ya se haya enviado al grupo. Su envío permanece pendiente de confirmación.

## 6. Estado de Sprint 2

Sprint 2 está pausado y no está cerrado.

Se esperan respuestas funcionales para cinco Flows:

- `Work_Order_from_Quote`;
- `Work_Order_from_Quote_Selective`;
- `SegregateWOLIs`;
- `aperturaCaseWorOrderEvent`;
- `ct_newCaseWorkOrderEvent`.

Las preguntas pendientes abarcan bodegas, territorios, talleres, reservas, devoluciones, agenda, sucursales, servicios, asesores, mecánicos, garantías, segregación de cargos y WOLI, y reglas específicas de PEKING en postventa. Estas definiciones no deben inferirse ni inventarse.

PEKING no aplica a procesos exclusivos de vehículos usados. Un Flow inactivo tampoco debe modificarse.

La trazabilidad detallada permanece en [`PREGUNTAS_BLOQUEOS_SPRINT2.md`](PREGUNTAS_BLOQUEOS_SPRINT2.md), [`MATRIZ_CIERRE_SPRINT2.csv`](MATRIZ_CIERRE_SPRINT2.csv) y [`LOTES_PROPUESTOS_REMEDIACION_SPRINT2.md`](LOTES_PROPUESTOS_REMEDIACION_SPRINT2.md).

## 7. Autorización para comenzar Sprint 3

El 5 de agosto de 2026, Claudia preguntó a Luis si debía continuar o esperar las respuestas de Sprint 2. Luis respondió: “Puedes continuar con Sprint 3 con lo que tenemos del documento original. Era lo que te decía de que ellos dicen de momento detener, pero es mejor continuar para ganar tiempo, aunque luego cambie un poco la definición.”

Por lo tanto:

- Sprint 3 está autorizado para comenzar;
- se debe trabajar usando el alcance original de PortalNet;
- el objetivo es avanzar trabajo seguro y claramente respaldado para ganar tiempo;
- algunas definiciones pueden cambiar posteriormente;
- no deben implementarse supuestos funcionales;
- Sprint 2 queda pausado, no cerrado;
- comenzar Sprint 3 no sustituye ni elimina los pendientes de Sprint 2;
- los extras identificados en TD-RQ308 no se incorporan automáticamente a Sprint 3;
- cualquier ampliación requiere autorización o control de cambios.

## 8. Regla operativa para Sprint 3

Antes de implementar cada bloque de Sprint 3:

1. Relacionarlo con el documento inicial de PortalNet.
2. Confirmar que pertenece al alcance original.
3. Revisar si depende de una decisión pendiente del negocio.
4. Evitar implementar elementos de la versión 0.13 que sean ampliaciones no aprobadas.
5. Registrar requerimiento, componente, estado y evidencia.
6. Detener únicamente el componente afectado cuando falte una definición.
7. Continuar con los componentes independientes y técnicamente seguros.

## 9. Evidencias pendientes

Continúan pendientes:

- videos funcionales de lo ya desarrollado para PEKING;
- respuestas de Diego, María o negocio;
- QA funcional positivo para Bavarian, Otobai y PEKING;
- QA negativo por configuración ausente o ambigua;
- catálogos, productos y precios oficiales;
- bodegas, sucursales y territorios oficiales;
- datos legales, logos y términos documentales;
- permisos definitivos;
- cierre final de Sprint 2.

## 10. Fuentes internas de trazabilidad

Las fuentes internas son:

- documento inicial de PortalNet;
- requerimiento PEKING versión 0.13 de Red Motors;
- [`TD-RQ308_Diferencias_Alcance_Entrega_Oficial.docx`](TD-RQ308_Diferencias_Alcance_Entrega_Oficial.docx);
- transcripción de reunión con Luis del 5 de agosto de 2026;
- conversaciones de aprobación y autorización de Sprint 3;
- documentación técnica y matrices existentes de Sprint 2.

Estas fuentes se registran para trazabilidad interna del repositorio y no necesariamente deben mostrarse en el documento oficial entregado al cliente.
