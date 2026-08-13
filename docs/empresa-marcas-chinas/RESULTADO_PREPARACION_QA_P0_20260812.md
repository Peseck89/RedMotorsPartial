# Resultado — preparación dirigida de QA P0 de Sprint 2

**Fecha:** 12 de agosto de 2026

**Ambiente:** `RedMotorsSandbox` (Partial)

**Tipo de bloque:** consulta y preparación de QA; sin ejecución de Flows, DML, deploy ni cambios de metadata

## Resultado ejecutivo

| Flow | Versión activa | Clasificación de QA | Estado alcanzado |
|---|---:|---|---|
| `Opp_flow_V3` | v29 (`301AK00000PCMb4YAH`) | C — manual | **LISTO PARA QA MANUAL** con usuario y datos QA existentes |
| `Opp_Flow_v6` | v80 (`301AK00000PCG7ZYAX`) | C — manual | **LISTO PARA QA MANUAL PARCIAL** en ruta Taller; la ruta Mostrador requiere una sesión funcional autorizada de ese tipo |
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

- La definición activa es v29 y coincide funcionalmente con la metadata validada: selector obligatorio `EmpresaSeleccionada`, persistencia en `Opportunity.Empresa_Operadora__c` y resolución mediante `EmpresaPricebookResolver`.
- La ruta ejecutable no contiene nombres ni identificadores fijos de Pricebook.
- No existen entrevistas registradas de `Opp_flow_V3`; por tanto, no hay evidencia previa suficiente para declarar QA funcional OK.
- El caso PEKING puede ejecutarse con `Control de Calidad`, el Asset QA y sus Account/Contact existentes, sin preparar ni modificar datos.
- Resultado esperado: Opportunity Taller con `Empresa_Operadora__c = PEKING`, `BMW_Compania__c` vacío, moneda `CRC`, Quote creado y Pricebook `PEKING Local`.

## `Opp_Flow_v6`

- La definición activa es v80. La serialización moderna omite propiedades visuales/defaults preexistentes, pero conserva el grafo y los elementos funcionales de Empresa/Pricebook.
- Hay dos entrevistas v80 abandonadas después de la primera pantalla; no constituyen QA.
- Existe una entrevista v80 anterior (`8gZAK000000HEBR2A4`) que terminó en error en `Resolver_Pricebook_Empresa` el 6 de agosto de 2026. No se preservó el mensaje técnico completo y no quedaron Opportunity ni Quote en su ventana de ejecución.
- Esa entrevista no demuestra por sí sola un defecto actual ni autoriza una corrección. La repetición dirigida debe capturar GUID, pantalla, mensaje y hora exacta si el error reaparece.
- La ruta Taller puede validarse con `Control de Calidad`. Las rutas principal y Mostrador mantienen selectores estructurales separados; completar la cobertura Mostrador requiere una sesión funcional autorizada con `Tipo_de_oportunidad__c = Mostrador` o `Todas`.

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

1. **`Opp_flow_V3` — prioridad inmediata.** Iniciar sesión como `Control de Calidad`; abrir `/flow/Opp_flow_V3`; buscar por VIN `VNA00260810051041`; seleccionar el Asset existente; conservar Contact y Cuenta de facturación `QA Prueba`; seleccionar moneda `Colones`, Empresa `PEKING` y la ruta Taller derivada del usuario; elegir un Service Territory de Uruca autorizado para el caso; avanzar una sola vez hasta finalizar. Capturar la pantalla de selección y los Id de Opportunity/Quote. Verificar después `Empresa_Operadora__c = PEKING`, `BMW_Compania__c` vacío, `CurrencyIsoCode = CRC` y `Pricebook2 = PEKING Local`.
2. **`Opp_Flow_v6` — ruta Taller.** Con el mismo usuario y Asset, abrir `/flow/Opp_Flow_v6`; seleccionar `PEKING`, Contact/Cuenta `QA Prueba`, moneda CRC y el territorio autorizado; completar una sola vez. Si reaparece un error en `Resolver_Pricebook_Empresa`, detenerse y registrar el mensaje técnico completo. Si termina, verificar Opportunity/Quote y Pricebook como en el punto 1.
3. **`Opportunity_Flow_V2` — ruta general/Taller.** Con el mismo usuario y Asset, abrir `/flow/Opportunity_Flow_V2`; seleccionar expresamente `PEKING`; conservar Contact/Cuenta QA y CRC; escoger **No** en creación desde plantilla; completar una sola vez. Verificar que PEKING prevalece sobre `User.Empresa__c = Bavarian` y que el Pricebook final es `PEKING Local`.
4. **Rutas Mostrador de v80/v7.** Ejecutarlas únicamente cuando exista una sesión funcional autorizada de un usuario activo con tipo `Mostrador` o `Todas`. Repetir el mismo control PEKING/CRC y verificar que el selector propio de Mostrador persiste `Empresa_Operadora__c`. No modificar usuarios para preparar la prueba.
5. **`PlanDeMantenimientoV2`.** No ejecutar todavía. Proporcionar un Quote QA PEKING/CRC que ya contenga una QuoteLineItem funcional seleccionable y un término de plan válido.
6. **`CreateWoliFromExpense` y `AgregarManoObra`.** No ejecutar todavía. Proporcionar un Work Order QA PEKING con moneda/Pricebook coherentes; para `CreateWoliFromExpense`, además un Expense facturable funcional relacionado. No crear esos datos únicamente para completar evidencia.

## Criterio de estado

Ningún Flow de este bloque cambia a `QA OK`. `Opp_flow_V3` queda listo para ejecución manual completa; `Opp_Flow_v6` y `Opportunity_Flow_V2`, listos de forma parcial en la ruta Taller/general; los tres P0 de planes/mano de obra conservan validación técnica pero requieren datos funcionales de entrada.
