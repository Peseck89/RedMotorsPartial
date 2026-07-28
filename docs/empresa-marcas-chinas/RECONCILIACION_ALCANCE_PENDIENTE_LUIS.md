# Reconciliación de alcance — estado y dato pendiente

Documento de trabajo. No declara cierre, no publica porcentaje final y no modifica
la evidencia ya enviada a Luis. Complementa a
`MATRIZ_AUTORITATIVA_SPRINT1_33_CLASES_3_TRIGGERS.md`, cuya sección 10 contiene el
detalle completo.

Trabajo exclusivamente documental: no se ejecutó Salesforce CLI, no se consultaron
orgs, no se modificó Apex, triggers ni metadata, no se desplegó nada.

## 1. Base documental

La jerarquía de fuentes coloca al Manual por encima del documento inicial. El
Manual resuelve el conteo que antes estaba abierto.

| Conjunto | Cantidad | Origen |
|---|---:|---|
| Manual §7.1 "Clases de mayor prioridad" | **30** | Tabla de 31 filas: 1 encabezado + 30 datos. Sin tests ni triggers |
| Documento inicial, sección Apex | **25** | Derivación de la sección 1 de la matriz |
| Presentes en ambos | 19 | |
| Solo en el Manual | 11 | |
| Solo en el documento inicial | 6 | Los seis batches de catálogo Softland |
| Unión | 36 | |

Las seis que solo aparecen en el documento inicial son la expansión del nombre
conceptual `BatchGetCatalogoSoftland`. Ese conteo quedó resuelto previamente: son
seis, no cinco, verificado por endpoint (`softlandAPI/Catalogs/…` con
`compania=RMBAVARIAN` fijo) y por scheduler dedicado.

## 2. Cómo se llega a 33

La tabla de horas describe el Apex como "incluye las 8 clases de Pricebook/Softland
encontradas después". La aritmética que encaja es **25 + 8 = 33**.

Las ocho tienen que salir de las 11 que el Manual agrega sobre el documento
inicial. Aplicando el calificador "Pricebook/Softland" del propio enunciado, siete
quedan determinadas:

`precioProductoJSON`, `productJSON`, `HttpCalloutCreateKit`,
`ProductSearcherController`, `QuoteService`, `QuoteSoftlandQueryService`,
`RM_VN_CambiarUbicacion_Ctrl`.

Las cuatro restantes no pertenecen a ese dominio: `ServicioCitasFieldService` y
`ServicioCitas` son agenda y taller, `RM_VN_CrearOportunidad_Ctrl` es creación de
Opportunity y `TrabajoQuoteController` es configuración de mano de obra.

**32 de 33 quedan determinadas.** La lectura alternativa —base 30 más 8 con cinco
solapamientos— no se sostiene: ninguna combinación de cinco está documentada, y
las únicas clases registradas como recuperadas posteriormente que están dentro de
las 30 son dos, no cinco.

### 2.1 Estado sobre las 32 determinadas

| Estado | Clases |
|---|---:|
| Implementada y desplegada | **13** |
| Implementada, pendiente de integrar | 0 |
| Pendiente ejecutable | **8** |
| Bloqueada por definición externa | **11** |
| Revisada, sin cambio necesario | 0 |

Lote validado incorporado en esta revisión — cinco clases que pasaron de
pendientes ejecutables a implementadas y desplegadas:

| Clase | Commit | Deploy | Post-deploy | Pruebas |
|---|---|---|---|---|
| `RM_VN_CambiarUbicacion_Ctrl` | `db73bed` | `0AfAK000000x0Ll0AI` | `707AK00000H9YSw` | 77/77 en deploy; 7/7 post-deploy |
| `ServicioConsDispBodegaQuoli` | `f9571d7` | `0AfAK000000x1Hp0AI` | `707AK00000H9Xcl` | — |
| `ServicioEliminarReservaArticuloQuote` | `4e07987` | `0AfAK000000wxqx0AA` | `707AK00000H9CIw` | — |
| `ServicioReservaApartadoArticulosQuote` | `69dc466` | `0AfAK000000x0gk0AA` | `707AK00000H9jrT` | — |
| `ServicioCrearSCQuote` | `27a2213` | `0AfAK000000x2PB0AY` | `707AK00000H9lER` | Cobertura 125/134 = 93.28% |

No se publica porcentaje: el denominador no está cerrado mientras falte la clase 33.

## 3. Triggers — resuelto

El Manual, Anexo **A.2 Triggers (3)**, enumera literalmente los tres:

| Trigger | Estado | Deploy |
|---|---|---|
| `ChanceAccountBavarian` | Bloqueada por definición externa | — |
| `ChanceAccountContado` | Bloqueada por definición externa | — |
| `WorkOrderTrigger` | Implementada y desplegada | `0AfAK000000vnon0AA`, `0AfAK000000vo4v0AA` |

`ChanceAccountOtobai` queda como **trigger relacionado, fuera del conteo de 3**:
aparece en el documento inicial y existe activo en Partial, pero el Manual no lo
incluye en A.2.

Ya no hay pregunta abierta sobre triggers.

## 4. Trabajos adicionales

Clases trabajadas durante el Sprint que no están en las 30 del Manual ni en las 25
del documento inicial. Se registran para que alcance y trabajo adicional no se
sumen como si fueran lo mismo. La bitácora documenta que desde el Bloque 11 Luis
autorizó "cambios claros de bajo riesgo, documentar el resto".

| Clase | Bloque | Estado | Observación |
|---|---:|---|---|
| `TrabajoController` | 14 | Desplegada | No está en Manual §7.1; sí en Anexo A.1 |
| `BMWVinScanTrabajoGenerator` | 15 | Desplegada | Igual |
| `CrearPlandeVenta` | 7 | Desplegada | Igual |
| `QuoterController` | 16 | Desplegada | Igual |
| `RM_VN_CrearOppModeloInteres_Ctrl` | 19 | Local, sin deploy | No aparece en ninguna fuente documental |

Corrección respecto de la versión anterior de este documento:
`TrabajoQuoteController` **sí** está en el Manual §7.1 y deja de considerarse
trabajo adicional.

## 5. Información mínima faltante

Un solo dato: **cuál de estas cuatro clases contó Luis como la octava**.

- `ServicioCitasFieldService`
- `ServicioCitas`
- `RM_VN_CrearOportunidad_Ctrl`
- `TrabajoQuoteController`

Ninguna fuente interna lo resuelve. La frase "Apex (incluye las 8 clases de
Pricebook/Softland encontradas después)" y la cifra "~33 clases + 3 triggers" no
aparecen en el Manual, ni en el documento inicial, ni en ningún documento del
repositorio. Se verificó por búsqueda de texto sobre el Manual completo
(208 párrafos, 43 tablas) y sobre `docs/empresa-marcas-chinas`. La sección 12 del
Manual estima en persona-semanas (30–45 y 55–85), no en el presupuesto de Sprint de
30 h + 14 h.

Esa frase pertenece a la tabla de horas consolidada y a la transcripción con Luis,
que no forman parte del repositorio.

### 5.1 Mensaje preparado para Luis (no enviado)

> Hola Luis. Ya cerré la reconciliación del Sprint 1 contra el Manual y el
> documento de alcance. Tengo identificadas 32 de las 33 clases y los 3 triggers
> (`ChanceAccountBavarian`, `ChanceAccountContado` y `WorkOrderTrigger`, tal como
> los lista el Manual en A.2).
>
> Me falta un solo dato: cuál de estas cuatro contaste como la clase 33.
>
> - `ServicioCitasFieldService`
> - `ServicioCitas`
> - `RM_VN_CrearOportunidad_Ctrl`
> - `TrabajoQuoteController`
>
> Con eso cierro la lista completa y te paso el avance exacto.
>
> Gracias.

## 6. Componentes que pueden seguirse trabajando sin respuesta

Pendientes ejecutables dentro de las 32 determinadas, sin decisión externa. Antes
de tomar cualquiera conviene confirmar que Codex no la esté implementando.

| Prioridad | Clase | Est. |
|---:|---|---:|
| 1 | `QuoteSoftlandPedidoService` | 3 h |
| 2 | `QuoteSoftlandQueryService` | 2 h |
| 3 | `servicioReservas` | 2 h |
| 4 | `servicioEliminarReserva` | 2 h |
| 5 | `OpportunityServiceInvoker` | 2 h |
| 6 | `Registrar_Anticipo_Controller` | 3 h |
| 7 | `QuoteService` | 2 h |
| 8 | `productJSON` | 4 h |

Secuencia sugerida: 1 y 2 juntas (pedido Softland), luego 3 y 4 (par
reservar/liberar de vehículos), luego 5 y 6 (anticipos).

`RM_VN_CrearOportunidad_Ctrl` también es ejecutable, pero pertenece al espacio 33
todavía sin determinar.

## 7. Componentes realmente bloqueados

| Componente | Bloqueo |
|---|---|
| `precioProductoJSON` | El Sandbox no contiene evidencia suficiente para una regla única y segura para PEKING (Bloque 10) |
| `savePDFfile` | Falta decisión de branding, territorios y correos para PEKING |
| `BMWServiceQuoteApprovalEmailInvocable` | Falta territorio, destinatarios y branding de PEKING |
| `HttpCalloutCreateKit` | Falta la decisión de relación marca–empresa |
| `BatchGetBodegaSoftland` | Falta el modelo de Bodega y la confirmación de bodega PEKING |
| Los seis batches de catálogo Softland | Falta confirmar si PEKING integra catálogos con Softland y con qué código |
| `ServicioCitas`, `ServicioCitasFieldService` | Falta confirmar si posventa, taller, FSL y portal entran en Sprint 1 |
| `ChanceAccountBavarian`, `ChanceAccountContado` | Falta definir si las cuentas protegidas son empresas facturadoras, cuentas técnicas o ambas |

## 8. Fuera del conteo pero relacionado

| Componente | Motivo |
|---|---|
| `ChanceAccountOtobai` | Trigger relacionado presente en el documento inicial y activo en Partial; el Manual no lo incluye en A.2 |
| `BusquedaDetalladaController` | No está en Manual §7.1 ni en el documento inicial como nombre Apex; sí en Anexo A.1. Bloqueado en el Bloque 10 |
| `cT_QuotePDFEmail`, `WoliGridController`, `WoliGridController2`, `ProductoLocalizacionHelper` | En Anexo A.1 del Manual, fuera de las 30 de mayor prioridad |
| `HttpCalloutGetProductRefPrices`, `HttpCalloutGetProductFreshRefPrices`, los tres `ScheduleGet*Softland`, `ServicioEnvioEncuestaSoftland` | En Anexo A.1, fuera de las 30 |
