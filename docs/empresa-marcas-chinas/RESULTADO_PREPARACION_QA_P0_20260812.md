# Resultado — preparación dirigida de QA P0 de Sprint 2

**Fecha:** 12 de agosto de 2026

**Ambiente:** `RedMotorsSandbox` (Partial)

**Tipo de bloque:** consulta y preparación de QA; sin ejecución de Flows, DML, deploy ni cambios de metadata

## Resultado ejecutivo

| Flow | Versión activa | Clasificación de QA | Estado alcanzado |
|---|---:|---|---|
| `Opp_flow_V3` | v30 (`301AK00000PW6LeYAL`) | C — manual | **QA DE CREACIÓN OK — NAVEGACIÓN REMEDIADA; QA MANUAL DEL ENLACE PENDIENTE** |
| `Opp_Flow_v6` | v82 (`301AK00000PWE36YAH`) | C — manual | **QA CREACIÓN OK — NAVEGACIÓN REMEDIADA; QA MANUAL DEL ENLACE PENDIENTE** en ruta Taller; Mostrador requiere una sesión funcional autorizada de ese tipo |
| `Opportunity_Flow_V2` | v7 (`301AK00000PCMb5YAH`) | C — manual | **LISTO PARA QA MANUAL PARCIAL** en ruta Taller/general; la ruta Mostrador requiere una sesión funcional autorizada de ese tipo |
| `PlanDeMantenimientoV2` | v24 (`301AK00000PC2ngYAD`) | C — manual | **NO LISTO**: existe Quote PEKING, pero no contiene líneas seleccionables |
| `CreateWoliFromExpense` | v15 (`301AK00000PC2nfYAD`) | B/C — disparo por registro | **NO LISTO**: no existe Work Order PEKING ni Expense facturable relacionado reutilizable |
| `AgregarManoObra` | v2 (`301AK00000PC2neYAD`) | C — manual | **NO LISTO**: no existe Work Order PEKING reutilizable |

No se encontró un defecto técnico nuevo y demostrable que autorizara modificar o desplegar metadata en este bloque.

## Evidencia común reutilizable

El caso listo utiliza únicamente registros QA ya existentes:

- usuario funcional QA activo `Control de Calidad` (`0050P0000074Bf7QAE`), perfil `New Asesor Postventa`;
- configuración del usuario: tipo de oportunidad `Taller`, sucursal `Uruca`, moneda `CRC` y Empresa legacy `Bavarian`;
- Permission Set `Empresa_Consulta_Flows` asignado;
- Asset `02iAK000001xtZNYAY`, placa/VIN `VNA00260810051041`;
- Account y Contact asociados: `QA Prueba`;
- `Marca_Nvo__c = BMW Automovil`;
- Empresa estructural `PEKING` activa;
- Pricebook `PEKING Local` activo, moneda `CRC`.

La diferencia entre `User.Empresa__c = Bavarian` y la selección estructural `PEKING` permite comprobar expresamente que el lookup nuevo prevalece sin extender el mecanismo legacy.

## `Opp_flow_V3`

- La ejecución funcional de v29 creó y conservó la Opportunity `006AK00000JTVVJYA5` y el Quote `0Q0AK000001zPyb0AE` con Empresa `PEKING`, moneda `CRC`, Pricebook `PEKING Local`, Cuenta y Asset correctos.
- La creación funcional queda en **QA OK**: `Empresa_Operadora__c = PEKING`, `BMW_Compania__c` vacío y sin fault ni rollback.
- El único defecto observado fue la falta de navegación del componente legacy `ecflc:flowIdRedirect` en la pantalla final, aun cuando `presupuestoid` contenía el Quote correcto.
- La navegación fue remediada de forma aislada mediante el enlace estándar `/lightning/r/Quote/{!presupuestoid}/view`; v30 (`301AK00000PW6LeYAL`) está activa.
- La ruta ejecutable no contiene nombres ni identificadores fijos de Pricebook.
- La integración del enlace dentro de v30 queda pendiente de una comprobación manual en la siguiente ejecución funcional normal. No debe crearse otra Opportunity únicamente para repetir evidencia.
- Evidencia completa: [`RESULTADO_QA_REMEDIACION_OPP_FLOW_V3_20260812.md`](RESULTADO_QA_REMEDIACION_OPP_FLOW_V3_20260812.md).

## `Opp_Flow_v6`

- La definición activa es v82 (`301AK00000PWE36YAH`). La serialización moderna omite propiedades visuales/defaults preexistentes, pero conserva el grafo y los elementos funcionales de Empresa/Pricebook.
- Hay dos entrevistas v80 abandonadas después de la primera pantalla; no constituyen QA.
- La nueva entrevista v80 (`8gZAK000000IgaH2AS`) falló en `CreateQuote` porque `Quote.Compania__c`, picklist legacy restringido, recibió `PEKING`. Opportunity y Quote fueron revertidos.
- Se sustituyó únicamente la fuente por `EmpresaLegacySeleccionada`: Bavarian/Otobai conservan sus valores y PEKING deja el campo legacy vacío. El dry-run `0AfAK0000014Amb0AE` y el deploy `0AfAK0000014AoD0AU` fueron exitosos.
- El QA v81 creó y conservó Opportunity `006AK00000JTWT1YAP` y Quote `0Q0AK000001zNQZ0A2` con PEKING, CRC, `PEKING Local`, Cuenta, Contacto, Asset y territorio correctos; la creación queda en **QA OK**.
- La pantalla final usaba el mismo `ecflc:flowIdRedirect` defectuoso de los Flows ya remediados. Se sustituyó únicamente por el enlace estándar al Quote; v82 está activa y la navegación integrada queda pendiente de QA manual.
- `Empresa_Operadora__c` y `Resolver_Pricebook_Empresa` permanecen intactos. Mostrador requiere una sesión funcional autorizada con tipo `Mostrador` o `Todas`.
- Evidencia completa: [`RESULTADO_REMEDIACION_OPP_FLOW_V6_20260812.md`](RESULTADO_REMEDIACION_OPP_FLOW_V6_20260812.md).

## `Opportunity_Flow_V2`

- La definición activa es v7 y coincide funcionalmente con la metadata validada.
- Los selectores `EmpresaSeleccionada` y `EmpresaSeleccionadaMostrador` están en las rutas general y Mostrador respectivamente.
- No existen entrevistas registradas; no hay evidencia previa que permita cerrar QA.
- La ruta general/Taller puede validarse con `Control de Calidad`, seleccionando PEKING aunque el valor legacy del usuario sea Bavarian.
- Durante este caso debe elegirse **No** cuando se ofrezca crear desde plantilla; la rama opcional requiere catálogo de plantillas y no forma parte del caso mínimo preparado.

## P0 de planes y mano de obra

Los cuatro `PricebookEntry` provisionales de `SAD001` y `SUB` para PEKING continúan activos y resuelven N1 a nivel técnico. Sin embargo, esa configuración no sustituye los registros funcionales de entrada:

- `PlanDeMantenimientoV2`: el Quote `PT-00080233` (`0Q0AK000001zL5N0AU`) tiene PEKING, `PEKING Local`, CRC y el Asset QA, pero contiene **cero QuoteLineItem**. La primera pantalla del Flow exige seleccionar una línea del Quote; no puede ejecutarse un caso positivo sin crear o disponer de una línea funcional válida.
- `CreateWoliFromExpense`: no se encontró ningún Work Order con `empresaFactura__c = RMPEKING`, ni un Expense facturable relacionado. El Flow es record-triggered y no debe activarse mediante DML artificial.
- `AgregarManoObra`: tampoco se encontró un Work Order PEKING reutilizable para el parámetro `recordId`.

Estos tres Flows permanecen técnicamente validados, pero **no están listos para QA manual positivo** hasta que el equipo proporcione los registros funcionales de entrada. No se crearon registros para suplirlos.

## Acciones manuales ordenadas

Ejecutar cada caso una sola vez. Si aparece un fault, detenerse y conservar captura, hora, GUID y elemento; no repetir para obtener evidencia redundante.

1. **`Opp_flow_V3`.** No repetir el Flow únicamente para obtener evidencia. La creación PEKING ya quedó validada. Verificar el destino del Quote existente abriendo `/lightning/r/Quote/0Q0AK000001zPyb0AE/view`; confirmar el enlace integrado en v30 durante la siguiente ejecución funcional normal.
2. **`Opp_Flow_v6`.** No repetir el Flow únicamente para obtener evidencia. La creación PEKING ya quedó validada. Confirmar el enlace integrado en v82 durante la siguiente ejecución funcional normal.
3. **`Opportunity_Flow_V2` — ruta general/Taller.** Con el mismo usuario y Asset, abrir `/flow/Opportunity_Flow_V2`; seleccionar expresamente `PEKING`; conservar Contact/Cuenta QA y CRC; escoger **No** en creación desde plantilla; completar una sola vez. Verificar que PEKING prevalece sobre `User.Empresa__c = Bavarian` y que el Pricebook final es `PEKING Local`.
4. **Rutas Mostrador de v80/v7.** Ejecutarlas únicamente cuando exista una sesión funcional autorizada de un usuario activo con tipo `Mostrador` o `Todas`. Repetir el mismo control PEKING/CRC y verificar que el selector propio de Mostrador persiste `Empresa_Operadora__c`. No modificar usuarios para preparar la prueba.
5. **`PlanDeMantenimientoV2`.** No ejecutar todavía. Proporcionar un Quote QA PEKING/CRC que ya contenga una QuoteLineItem funcional seleccionable y un término de plan válido.
6. **`CreateWoliFromExpense` y `AgregarManoObra`.** No ejecutar todavía. Proporcionar un Work Order QA PEKING con moneda/Pricebook coherentes; para `CreateWoliFromExpense`, además un Expense facturable funcional relacionado. No crear esos datos únicamente para completar evidencia.

## Criterio de estado

`Opp_flow_V3` y `Opp_Flow_v6` quedan con **QA de creación OK** y navegación remediada técnicamente, pendiente únicamente de validar manualmente el enlace integrado. `Opportunity_Flow_V2` continúa listo de forma parcial en la ruta general/Taller; los tres P0 de planes/mano de obra conservan validación técnica pero requieren datos funcionales de entrada.
