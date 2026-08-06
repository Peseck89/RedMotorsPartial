# Propuesta B11-1 — catálogos Softland PEKING

**Estado:** `CANDIDATO_PENDIENTE_REVISION`
**Fecha:** 6 de agosto de 2026

## Objetivo

Reconciliar en la línea vigente la implementación ya desplegada en Partial que parametriza los seis catálogos Softland confirmados y ejecuta `RMBAVARIAN` y `RMPEKING` mediante invocaciones separadas. No desarrollar una variante nueva ni ejecutar catálogos reales.

## Componentes exactos

### Productivos

- `BatchGetCatalogoSoftland`
- `BatchGetCategoriaClienteSoftland`
- `BatchGetCentroCostoSoftland`
- `BatchGetCondicionPagoSoftland`
- `BatchGetCuentaContableSoftland`
- `BatchGetImpuestoSoftland`
- `BatchGetSubtipoDocumentoSoftland`
- `ScheduleGetCategoriaClienteSoftland`
- `ScheduleGetCentroCostoSoftland`
- `ScheduleGetCondicionPagoSoftland`
- `ScheduleGetCuentaContableSoftland`
- `ScheduleGetImpuestoSoftland`
- `ScheduleGetSubtipoDocumentoSoftland`

### Pruebas

- `BatchGetCatalogoSoftlandTest`
- los seis `BatchGet*SoftlandTest` correspondientes;
- los seis `ScheduleGet*SoftlandTest` correspondientes.

No incluye `BatchGetBodegaSoftland`, `ScheduleGetBodegaSoftland`, `ScheduleGetCatalogoSoftland`, inventario, aseguradora, actividad comercial ni consumidores Softland ajenos.

## Cambio conceptual

1. Usar la versión desplegada de Partial como base técnica dirigida.
2. Conservar overloads sin `company` que usan `RMBAVARIAN` para compatibilidad legacy.
3. Propagar `company` por wrapper, helper, paginación y query de cada catálogo.
4. Conservar en cada scheduler las dos invocaciones actualmente desplegadas: `RMBAVARIAN` y `RMPEKING`.
5. Incorporar las pruebas desplegadas y completar aserciones de endpoint `compania=RMPEKING` para cada uno de los seis catálogos.
6. No cambiar el modelo global de persistencia ni inventar asociación Empresa.

## Por qué pertenece al bloque 11

El documento inicial exige verificar batches/catálogos para las empresas del alcance. Diego confirmó expresamente los seis catálogos, la misma instancia/endpoints y `RMPEKING`. La implementación ya existe en Partial y fue realizada históricamente en Sprint 1; reconciliarla evita perder el comportamiento desplegado y completa la trazabilidad del bloque 11 sin absorber otros refactors.

## Validación técnica propuesta

- Diff dirigido contra Partial de los 13 componentes productivos.
- Compilación y análisis estático.
- Pruebas unitarias de los 13 componentes de prueba.
- Mock por catálogo que confirme `compania=RMBAVARIAN` y `compania=RMPEKING`.
- Verificar paginación conservando `company`.
- Verificar que el overload legacy sin compañía sigue usando `RMBAVARIAN`.
- Verificar que no se incorpora `RMOTOBAI` a estos seis catálogos por inferencia.
- Dry-run limitado a los componentes exactos solo después de autorización.
- Deploy solo si se autoriza y el diff demuestra que Partial ya contiene el mismo comportamiento; no programar jobs.

## QA posible sin datos oficiales

- Construcción del endpoint mediante mocks.
- Propagación de compañía en primera página y páginas siguientes.
- Deserialización y upsert controlado de un código ficticio generado únicamente dentro de tests.
- Regresión del fallback legacy Bavarian.
- Ausencia de selección silenciosa de Otobai.

## QA bloqueado por datos

- Contenido real de los seis catálogos PEKING.
- Colisiones de códigos entre Bavarian y PEKING.
- Validación funcional de centros de costo y cuentas contables.
- Volumen, paginación y tiempos reales del endpoint.
- Programación operativa y horario autorizado.

## Regresión Bavarian/Otobai

- Bavarian debe conservar los endpoints, códigos y upserts existentes.
- Otobai no debe agregarse a estos seis schedulers sin evidencia específica; su ausencia histórica se conserva.
- Los otros catálogos parametrizados que sí trabajan con Otobai no forman parte del lote.

## Riesgos

- Los objetos no almacenan Empresa y usan códigos externos globales; una colisión real puede actualizar un registro compartido.
- Ejecutar simultáneamente ambos contextos puede aumentar callouts y consumo asíncrono.
- Programar schedulers sin autorización convertiría una conciliación técnica en carga de datos; queda expresamente excluido.

## Reversión

- Revertir únicamente los archivos del lote a la línea base anterior.
- Si hubiera deploy autorizado, redeplegar el baseline previo de los mismos componentes.
- No existe reversión de datos en este lote porque no se autoriza ejecutar schedulers ni catálogos.

## Criterio de terminado

- Los 13 componentes productivos coinciden semánticamente con Partial.
- Las pruebas relacionadas pasan y cubren ambas compañías autorizadas.
- El dry-run dirigido resulta exitoso, si se autoriza.
- No se ejecutó ni programó ningún catálogo.
- Bodega y deuda legacy permanecen fuera.
