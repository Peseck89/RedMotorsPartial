# Reconciliación de alcance — información pendiente de Luis

Documento de trabajo. No declara cierre, no publica porcentaje final y no
modifica la evidencia ya enviada a Luis. Complementa a
`MATRIZ_AUTORITATIVA_SPRINT1_33_CLASES_3_TRIGGERS.md`.

Trabajo exclusivamente documental: no se ejecutó Salesforce CLI, no se consultaron
orgs, no se modificó Apex, triggers ni metadata, no se desplegó nada y no se
tocaron componentes que Codex esté implementando.

## 1. Base documental exacta

**25 clases productivas.** La duda 24 vs. 25 quedó resuelta por inspección local
de código.

El documento original agrupa una familia bajo el nombre `BatchGetCatalogoSoftland`
y afirma que hardcodea `RMBAVARIAN` en "5 endpoints de catálogo". No existe una
clase con ese nombre; existen **seis** clases que comparten exactamente los dos
rasgos descritos:

| Clase | Endpoint | Compañía en la URL |
|---|---|---|
| `BatchGetCategoriaClienteSoftland` | `softlandAPI/Catalogs/getCategorias_Cliente` | `compania=RMBAVARIAN` |
| `BatchGetCentroCostoSoftland` | `softlandAPI/Catalogs/getCentroCostos` | `compania=RMBAVARIAN` |
| `BatchGetCondicionPagoSoftland` | `softlandAPI/Catalogs/getCondicionPagos` | `compania=RMBAVARIAN` |
| `BatchGetCuentaContableSoftland` | `softlandAPI/Catalogs/getCuentaContable` | `compania=RMBAVARIAN` |
| `BatchGetImpuestoSoftland` | `softlandAPI/Catalogs/getImpuestos` | `compania=RMBAVARIAN` |
| `BatchGetSubtipoDocumentoSoftland` | `softlandAPI/Catalogs/getSubtiposDocCC` | `compania=RMBAVARIAN` |

Las otras cuatro clases `BatchGet*Softland` del repositorio quedan fuera por
evidencia: `BatchGetActividadComercialSoftland`, `BatchGetAseguradoraSoftland` y
`BatchGetInventorySoftland` no usan la ruta `Catalogs` ni fijan `RMBAVARIAN`;
`BatchGetBodegaSoftland` tampoco, y el documento ya la trata por separado en su
sección 9.

Los seis endpoints son distintos entre sí y cada uno tiene su propio scheduler
dedicado, de modo que "cinco" no se explica por agrupación. `INVENTARIO_APEX_SPRINT1.md`
§5.4 y `PLAN_IMPLEMENTACION_SPRINT1.md` §4 también hablan de seis.

**Conclusión:** el "5" del documento es un error de conteo verificable contra el
código. La base es de 25 clases exactas y la diferencia con la estimación de Luis
es de **8 clases**.

## 2. Candidatas fuertes

| Nombre API | Vínculo con el documento | Estado real | ¿Requiere decisión externa? |
|---|---|---|---|
| `ProductSearcherController` | §5 y §10.4 nombran el LWC `productSearcher` y describen los literales `preciosBavarian`/`preciosFantasia`, que están en esta clase | Implementado y desplegado — Bloque 18, `0AfAK000000vuBx0AI` | No |
| `BusquedaDetalladaController` | §5 ordena "Verificar que el Apex detrás… soporte la 3ra compañía" sobre la fila del LWC `busquedaDetallada` | Bloqueado — Bloque 10, revisado sin cambio productivo | Sí |
| `precioProductoJSON` | Misma fila §5, vía el LWC `pricebookReferenceDetails`; identificada por el Bloque 10 | Bloqueado — Bloque 10, revisado sin cambio productivo | Sí |
| `cT_QuotePDFEmail` | Nota de reunión del 10/07/2026: "PDFs dinámicos para las nuevas marcas, tanto en Ventas como en Taller"; la clase tiene la razón social Bavarian fija | Pendiente de implementar | Sí |

## 3. Candidatas posibles

| Nombre API | Vínculo con el documento | Por qué no alcanza para fuerte |
|---|---|---|
| `WoliGridController` | Define `getSoftlandLocations`, método citado textualmente en §5 | Los LWC listados en esa fila no incluyen `woliGridDespacho`; el plan la clasificó como dependencia indirecta |
| `WoliGridController2` | Igual | Igual |
| `productJSON` | §5 nombra `qoSearchDetailProduct` y `woSearchDetailProduct` | Ningún documento la identifica como el Apex de esos componentes |
| `ProductoLocalizacionHelper` | §5 nombra `localizacionDetails` y "el Apex de localización en Softland" | No define `getSoftlandLocations`; la correspondencia es funcional, no nominal |
| `RM_VN_Inventario_Ctrl` | §5 y §10.4 nombran `rm_vn_inventario` / `rm_vn_inventario_movil` | El texto apunta al mapeo de precios en JS; además no figura entre las 41 del plan |
| `RM_VN_InventarioFantasia_Ctrl` | Igual | Igual |

Cuatro fuertes y seis posibles para una diferencia de 8. **No se propone ninguna
combinación de ocho**: cualquier selección sería arbitraria.

## 4. Trabajos adicionales

Clases trabajadas durante el Sprint que el documento original no incluye. Se
registran para que alcance y trabajo adicional no se sumen como si fueran lo mismo.
La bitácora documenta que desde el Bloque 11 Luis autorizó "cambios claros de bajo
riesgo, documentar el resto", y `CIERRE_SPRINT1_44H.md` §2.2 documenta la
sustitución.

| Clase | Bloque | Estado | Motivo de exclusión |
|---|---:|---|---|
| `TrabajoQuoteController` | 13 | Desplegada | Exclusión textual del documento (ver sección 5) |
| `TrabajoController` | 14 | Desplegada | Misma exclusión textual |
| `BMWVinScanTrabajoGenerator` | 15 | Desplegada | Misma exclusión textual |
| `CrearPlandeVenta` | 7 | Desplegada | Sin mención; recuperada posteriormente desde el Sandbox |
| `QuoterController` | 16 | Desplegada | Sin mención en el documento |
| `RM_VN_CrearOppModeloInteres_Ctrl` | 19 | Local, sin deploy | Sin mención en el documento ni en las 41 del plan |

### 4.1 Tensión textual sobre "trabajos"

El documento original contiene dos frases que apuntan en sentidos opuestos:

- *Postventa/Taller*: "Revisar la configuración de tipos de trabajo, UTS y demás
  catálogos, ya que las nuevas marcas no los incluyen de fábrica."
- *Consideraciones*: "Actualmente, los trabajos a realizar no distinguen entre
  empresas. Esta diferenciación no está incluida en la propuesta; si el negocio la
  requiere, deberá contemplarse como un alcance adicional."

Los bloques 13, 14 y 15 modificaron la resolución de empresa usada para consultar
`TipoDeCargoConManoDeObra__c`. Puede leerse como la revisión de catálogos que sí
está incluida, o como la diferenciación que está excluida. **No se resuelve aquí.**

## 5. Contradicción de triggers

| Fuente | Triggers | Cantidad |
|---|---|---:|
| Documento original, §3 | `ChanceAccountBavarian`, `ChanceAccountOtobai`, `ChanceAccountContado` (una sola fila) + `WorkOrderTrigger` (fila aparte) | 4 nombres, 2 filas |
| Manual | `ChanceAccountBavarian`, `ChanceAccountContado`, `WorkOrderTrigger` | 3 |
| Tabla de Luis | no disponible | 3 |
| RedMotorsSandbox | los cuatro existen y están activos | 4 |

El Manual omite `ChanceAccountOtobai`, que sí existe en el org: esa omisión es
demostrablemente incorrecta. `CIERRE_SPRINT1_44H.md` §1 reproduce la cifra como
"~33 clases y 3 triggers" y remite al plan, que advierte que es una estimación
inicial y no un criterio de aceptación. **Ninguna fuente disponible enumera cuáles
son los tres.**

Ningún bloque del 1 al 21 modificó los tres triggers `ChanceAccount*`: siguen
únicamente recuperados en la línea base `2b9d850`.

## 6. Información mínima faltante

Solo dos datos, ambos en poder de Luis:

1. La lista o archivo del que salió la estimación de aproximadamente 33 clases.
2. Cuáles son exactamente los 3 triggers.

Sin el primero no se pueden identificar las 8 clases restantes sin asumirlas.
Sin el segundo no se puede cerrar si `ChanceAccountOtobai` está dentro o fuera.

### 6.1 Mensaje preparado para Luis (no enviado)

> Hola Luis. Cerrando la reconciliación del Sprint 1 me falta un dato tuyo.
>
> Del documento técnico de alcance pude identificar con precisión 24–25 clases
> Apex y cuatro triggers relacionados (`ChanceAccountBavarian`,
> `ChanceAccountOtobai`, `ChanceAccountContado` y `WorkOrderTrigger`). Tu
> estimación hablaba de ~33 clases y 3 triggers, así que quedan 8 clases que no
> puedo atribuir sin inventarlas, y no me queda claro cuáles son los 3 triggers.
>
> ¿Me puedes pasar la lista o el archivo del que salió el número de ~33 clases, y
> confirmarme cuáles son los 3 triggers? Con eso cierro la matriz con la fuente
> original en vez de asumir los componentes que faltan.
>
> Gracias.

## 7. Componentes que pueden seguirse trabajando sin respuesta

No dependen de la tabla de Luis ni de decisiones externas, y siguen el mismo
patrón ya resuelto y desplegado en bloques anteriores:

| Prioridad | Clase | Est. |
|---:|---|---:|
| 1 | `ServicioConsDispBodegaQuoli` | 2 h |
| 2 | `ServicioEliminarReservaArticuloQuote` | 2 h |
| 3 | `ServicioReservaApartadoArticulosQuote` | 3 h |
| 4 | `ServicioCrearSCQuote` | 3 h |
| 5 | `QuoteSoftlandPedidoService` | 3 h |
| 6 | `servicioReservas` | 2 h |
| 7 | `servicioEliminarReserva` | 2 h |
| 8 | `OpportunityServiceInvoker` | 2 h |

Antes de tomar cualquiera conviene confirmar que Codex no la esté implementando.

## 8. Componentes realmente bloqueados

| Componente | Bloqueo |
|---|---|
| `BusquedaDetalladaController` | El Sandbox no contiene evidencia suficiente para definir una regla única y segura para PEKING (Bloque 10) |
| `precioProductoJSON` | Mismo bloqueo del Bloque 10 |
| `savePDFfile` | Falta decisión de branding, territorios y correos para PEKING |
| `cT_QuotePDFEmail` | Falta la identidad legal y la política documental de PEKING |
| `BMWServiceQuoteApprovalEmailInvocable` | Falta territorio, destinatarios y branding de PEKING |
| Los seis batches de catálogo Softland | Falta confirmar si PEKING integra catálogos con Softland y con qué código |
| `BatchGetBodegaSoftland` | Falta el modelo de Bodega y la confirmación de bodega PEKING |
| `ChanceAccountBavarian`, `ChanceAccountOtobai`, `ChanceAccountContado` | Falta definir si las cuentas protegidas son empresas facturadoras, cuentas técnicas o ambas |
| Las 8 clases no identificadas | Falta la fuente de la estimación de Luis |
