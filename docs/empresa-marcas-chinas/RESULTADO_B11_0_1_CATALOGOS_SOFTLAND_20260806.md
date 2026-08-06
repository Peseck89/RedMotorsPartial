# Resultado B11-0.1 — catálogos y schedulers Softland

**Fecha:** 6 de agosto de 2026
**Estado:** `COMPLETADO_COMO_ANALISIS`
**Alcance:** seis catálogos confirmados y clasificación separada de bodega

## Respuesta ejecutiva

**Sí existe un B11-1 ejecutable**, pero su propósito correcto no es volver a desarrollar el soporte PEKING: Partial ya contiene una implementación parametrizada para los seis catálogos y sus schedulers ya encolan `RMBAVARIAN` y `RMPEKING`. La línea base versionada vigente conserva la versión anterior, limitada a `RMBAVARIAN`.

B11-1 debe reconciliar esa implementación desplegada, incorporar sus pruebas y demostrar equivalencia técnica. No debe ejecutar catálogos reales, programar jobs, crear datos ni incluir bodega.

## Evidencia dirigida

- El documento inicial incluye la verificación de batches/catálogos para las tres empresas dentro del bloque 11.
- Diego confirmó que los seis catálogos deben ejecutarse también para PEKING usando la misma instancia, endpoints y código ERP `RMPEKING`.
- Las 13 clases productivas directamente involucradas en los seis catálogos difieren funcionalmente entre la línea base y Partial: `BatchGetCatalogoSoftland`, seis wrappers y seis schedulers.
- La versión de Partial fue modificada el 29 de julio de 2026 y coincide con una implementación histórica ya realizada en Sprint 1.
- No hay jobs `ScheduledApex` activos en Partial para los siete schedulers revisados.
- La consulta fue exclusivamente de lectura. Producción no fue consultada.

## Matriz de resultado

| Componente | Estado actual | RMPEKING | Clasificación | Qué falta | Evidencia |
|---|---|---|---|---|---|
| `BatchGetCategoriaClienteSoftland` | Baseline: wrapper sin parámetro; Partial: constructor `company` y propagación al helper | Sí en Partial | `CANDIDATO_AJUSTE_TECNICO` / origen `YA_RESUELTO_SPRINT1` | Reconciliar baseline y pruebas; no ejecutar catálogo real | Diff dirigido baseline–Partial; metadata Partial 2026-08-06 |
| `BatchGetCentroCostoSoftland` | Baseline: wrapper sin parámetro; Partial: constructor `company` y propagación al helper | Sí en Partial | `CANDIDATO_AJUSTE_TECNICO` / origen `YA_RESUELTO_SPRINT1` | Reconciliar baseline y pruebas; QA real espera centros oficiales | Diff dirigido baseline–Partial; metadata Partial 2026-08-06 |
| `BatchGetCondicionPagoSoftland` | Baseline: wrapper sin parámetro; Partial: constructor `company` y propagación al helper | Sí en Partial | `CANDIDATO_AJUSTE_TECNICO` / origen `YA_RESUELTO_SPRINT1` | Reconciliar baseline y pruebas | Diff dirigido baseline–Partial; metadata Partial 2026-08-06 |
| `BatchGetCuentaContableSoftland` | Baseline: wrapper sin parámetro; Partial: constructor `company` y propagación al helper | Sí en Partial | `CANDIDATO_AJUSTE_TECNICO` / origen `YA_RESUELTO_SPRINT1` | Reconciliar baseline y pruebas | Diff dirigido baseline–Partial; metadata Partial 2026-08-06 |
| `BatchGetImpuestoSoftland` | Baseline: wrapper sin parámetro; Partial: constructor `company` y propagación al helper | Sí en Partial | `CANDIDATO_AJUSTE_TECNICO` / origen `YA_RESUELTO_SPRINT1` | Reconciliar baseline y pruebas | Diff dirigido baseline–Partial; metadata Partial 2026-08-06 |
| `BatchGetSubtipoDocumentoSoftland` | Baseline: wrapper sin parámetro; Partial: constructor `company` y propagación al helper | Sí en Partial | `CANDIDATO_AJUSTE_TECNICO` / origen `YA_RESUELTO_SPRINT1` | Reconciliar baseline y pruebas | Diff dirigido baseline–Partial; metadata Partial 2026-08-06 |
| `BatchGetCatalogoSoftland` | Baseline fija `RMBAVARIAN` en seis rutas; Partial recibe `company`, conserva overload legacy y construye query dinámica | Sí en Partial | `CANDIDATO_AJUSTE_TECNICO` / origen `YA_RESUELTO_SPRINT1` | Reconciliar helper y test compartido | Diff dirigido; prueba desplegada verifica constructor RMPEKING y fallback legacy |
| Seis `ScheduleGet*Softland` de catálogo | Baseline encola una ejecución sin compañía; Partial encola `RMBAVARIAN` y `RMPEKING` por separado | Sí en Partial | `CANDIDATO_AJUSTE_TECNICO` / origen `YA_RESUELTO_SPRINT1` | Reconciliar schedulers y pruebas; no activarlos | Metadata Partial; cero jobs programados activos |
| `BatchGetBodegaSoftland` | Batch parametrizado y equivalente; scheduler ejecuta Bavarian/Otobai | No se encola PEKING | `BLOQUEADO_DATOS_OPERATIVOS` | Bodegas oficiales y estrategia de clave externa PEKING | Código y describe de `Bodega__c`; metadata Partial |
| `ScheduleGetCatalogoSoftland` | Existe en Partial, falta en baseline; helper genérico para dos empresas legacy | No agrega PEKING | `DEUDA_LEGACY_NO_ABSORBER` en B11-1 | Conciliar junto con bodega solo cuando ese frente se autorice | Metadata Partial; no es dependencia de los seis schedulers directos |

## Comportamiento de los seis catálogos

| Catálogo | Endpoint lógico | Persistencia | Asociación de Empresa |
|---|---|---|---|
| Categoría de cliente | `getCategorias_Cliente` con `compania` | `CategoriaCliente__c`, upsert por `CategoriaCliente__c` | No existe campo Empresa demostrado |
| Centro de costo | `getCentroCostos` con `compania` | `CentroCosto__c`, upsert por `centroCosto__c` | No existe campo Empresa demostrado |
| Condición de pago | `getCondicionPagos` con `compania` | `CondicionPago__c`, upsert por `condicionPago__c` | No existe campo Empresa demostrado |
| Cuenta contable | `getCuentaContable` con `compania` | `CuentaContable__c`, upsert por `CuentaContable__c` | No existe campo Empresa demostrado |
| Impuesto | `getImpuestos` con `compania` | `Impuesto__c`, upsert por `codigoImpuesto__c` | No existe campo Empresa demostrado |
| Subtipo de documento | `getSubtiposDocCC` con `compania` | `SubtipoDocumento__c`, upsert por `subtipo__c` | No existe campo Empresa demostrado |

No se reproducen URL base, credenciales ni valores sensibles. Los seis objetos conservan un catálogo global identificado por código; la versión desplegada no almacena Empresa. Si Bavarian y PEKING devuelven el mismo código con contenido distinto, la última ejecución puede actualizar el mismo registro. Ese riesgo requiere datos reales para medirse, pero no impide reconciliar y validar estructuralmente el comportamiento ya desplegado.

## Schedulers y límites

- Cada uno de los seis schedulers de Partial realiza dos invocaciones separadas: `RMBAVARIAN` y `RMPEKING`.
- No se agrega `RMOTOBAI` por inferencia: estos seis procesos históricos no lo ejecutaban y la confirmación recibida exige incorporar PEKING, no rediseñar el universo legacy.
- La infraestructura genérica del helper acepta `company`; agregar PEKING es una segunda invocación equivalente en los seis schedulers.
- No existen jobs programados activos para estas clases en Partial, por lo que B11-1 no debe incluir programación ni activación.
- La ejecución real consume Apex asíncrono y callouts por catálogo/página. Debe vigilarse el límite diario asíncrono y evitar solapamiento de horarios. Salesforce permite hasta 100 jobs programados concurrentes; este lote no crea ninguno.
- Fuentes de límite: [Scheduled Apex](https://help.salesforce.com/s/articleView?id=sf.code_schedule_batch_apex.htm&language=en_US&type=5) y [ejecuciones Apex asíncronas](https://help.salesforce.com/s/articleView?id=000385816&language=en_US&type=1).

## Bodega

`BatchGetBodegaSoftland` ya acepta `company`. Sin embargo:

- el scheduler actual solo ejecuta `RMBAVARIAN` y `RMOTOBAI`;
- no existen bodegas oficiales PEKING;
- `ID_EXTERNO_BODEGA__c` solo antepone compañía para `RMOTOBAI`; PEKING usaría el código crudo igual que Bavarian;
- no existe campo Empresa demostrado en `Bodega__c`.

Ejecutar RMPEKING sin bodegas oficiales y sin resolver la clave podría mezclar o sobrescribir registros. Bodega queda `BLOQUEADO_DATOS_OPERATIVOS` y fuera de B11-1.

## Sprint 3 frente a deuda histórica

- **`BLOQUE_11_SPRINT3`:** reconciliar los seis catálogos y schedulers que cumplen la decisión confirmada de ejecutar PEKING.
- **`YA_RESUELTO_SPRINT1`:** parametrización y despliegue existentes en Partial; B11-1 preserva ese trabajo en la línea vigente.
- **`DEUDA_LEGACY_NO_ABSORBER`:** rediseñar catálogos para almacenar Empresa, sustituir autenticación legacy, generalizar todos los schedulers o refactorizar endpoints no relacionados.

## ¿Existe B11-1?

**Sí.** Es un candidato técnico seguro para reconciliar el soporte RMPEKING ya desplegado de los seis catálogos, recuperar sus pruebas y validar que Bavarian conserva el overload por defecto. No requiere endpoints nuevos, credenciales, valores de catálogo ni decisión funcional adicional.

B11-1 no autoriza ejecutar los schedulers ni comprobar datos reales. El QA de contenido y colisiones queda pendiente hasta disponer de catálogos oficiales; bodega permanece fuera.

## Controles

- No se reabrió B11-0 ni se auditó Apex completo.
- No se revisaron B7 ni B9.
- No se modificó Salesforce, código ni metadata.
- No hubo deploy, dry-run, DML ni ejecución de schedulers.
- No se inventaron catálogos o bodegas.
- Partial se consultó solo en lectura; Producción no fue consultada.
