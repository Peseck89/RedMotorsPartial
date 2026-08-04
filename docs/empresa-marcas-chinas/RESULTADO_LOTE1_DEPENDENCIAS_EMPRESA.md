# Resultado Lote 1 — dependencias compartidas y resolución de Empresa

## Resultado

El Lote 1 implementó y desplegó en Partial la ampliación del contrato compartido `EmpresaPricebookResolver`. El lookup de Empresa es prioritario; el valor legacy solo se consulta cuando el lookup está vacío. Los únicos fallbacks temporales admitidos son Bavarian y Otobai hacia sus códigos ERP ya confirmados. PEKING requiere un lookup explícito y nunca entra por una rama residual.

No se modificaron Flows, componentes, datos, campos, permisos, Apex consumidor ni recursos de despacho o usados.

## Recursos previstos y decisión

| Recurso | Estado | Motivo |
|---|---|---|
| `EmpresaPricebookResolver` | Modificado | Centraliza prioridad del lookup, fallback temporal y resolución de Pricebook. |
| `EmpresaPricebookResolverTest` | Modificado | Agrega regresión y casos negativos obligatorios. |
| `EmpresaResolver` | Sin cambio | Ya rechaza códigos nulos, desconocidos, duplicados, inactivos e incompletos sin fallback arbitrario. |
| `EmpresaContext` | Sin cambio | Ya valida configuración empresarial explícita. |
| `EmpresaConfigurationException` | Sin cambio | Contrato de error vigente suficiente. |
| Consumidores de inventario, búsqueda, Quote/WO, garantía y Community | Omitidos | Su adopción corresponde a los lotes funcionales posteriores. |
| Despacho y usados indicados en las exclusiones | Omitidos | Fuera del alcance expreso del Lote 1. |

## Comportamiento anterior y nuevo

Antes, el resolver requería `empresaId`; los Flows que necesitaban compatibilidad traducían el picklist legacy por separado. Ahora `PricebookResolutionRequest` admite `legacyCompany`, y el resultado informa también el `empresaId` efectivo:

1. Si existe `empresaId`, se usa siempre y se ignora el legacy.
2. Si el lookup está vacío, solo `Bavarian` y `Otobai` pueden buscar Empresa mediante `Codigo_ERP__c`.
3. Un legacy vacío o desconocido devuelve error controlado.
4. Cero coincidencias devuelve `NO_CONFIGURADO`; varias coincidencias devuelven `ERROR`.
5. PEKING se resuelve por su lookup y sus Pricebooks relacionados, nunca mediante el fallback.
6. Cero Pricebooks válidos devuelve `NO_CONFIGURADO`; varias opciones devuelven `SELECCION_REQUERIDA`.
7. Un Pricebook actual solo se conserva si está activo, pertenece a la Empresa y cumple la moneda solicitada.

La búsqueda sigue usando `Pricebook2.Empresa__c`, `IsActive` y `CurrencyIsoCode`. No usa nombres ni IDs fijos.

## Compatibilidad

- **Bavarian y Otobai:** mantienen resolución por lookup. Cuando el lookup está vacío, conservan el fallback temporal confirmado. Si hay varias opciones válidas, no se elige una por defecto.
- **PEKING:** el lookup explícito prevalece incluso si se recibe un legacy diferente. No se agregó PEKING al mapa legacy.
- **Desconocidos:** no caen en Bavarian, Otobai ni PEKING.

## Pruebas y cobertura

Se ejecutó `EmpresaPricebookResolverTest` en dry-run y deploy real:

- 19 pruebas ejecutadas, 19 exitosas, 0 fallos.
- Cobertura de `EmpresaPricebookResolver`: 134 de 140 líneas, **95,7 %**.
- Casos cubiertos: Bavarian, Otobai, PEKING, Empresa vacía/inexistente/inactiva, Pricebook inexistente/inactivo/de otra Empresa, moneda incompatible, varias opciones, lookup vacío con fallback, fallback ausente/ambiguo y valor desconocido sin empresa por defecto.
- Prueba bulk: 50 Empresas en una llamada, sin SOQL dentro del bucle de solicitudes.
- Regresión conjunta posterior: `EmpresaResolverTest`, `EmpresaContextTest` y `EmpresaPricebookResolverTest`; 37/37 pruebas exitosas, 0 fallos, ejecución `707AK00000HraVV`, cobertura combinada de la ejecución 91 %.

El análisis estático disponible no reportó hallazgos de archivos. PMD, CPD y SFGE no pudieron iniciarse porque el entorno local no dispone de Java 11 o superior; esta es una limitación del entorno, no un fallo de compilación. La compilación real de Salesforce fue exitosa.

## Validación y despliegue

| Operación | Id | Estado | Componentes |
|---|---|---|---|
| Dry-run Partial | `0AfAK0000010Q6n0AE` | Exitoso | 2/2 |
| Deploy Partial | `0AfAK0000010QBd0AM` | Exitoso | 2/2 |

La consulta de solo lectura posterior confirmó Empresas activas para `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`. PEKING tiene una opción activa CRC y una USD. Bavarian y Otobai tienen múltiples opciones USD; el comportamiento correcto es conservar una selección compatible o devolver `SELECCION_REQUERIDA`.

## Bloqueos y evidencias pendientes

- Los consumidores todavía deben adoptar `resolveForSource` en sus lotes respectivos; este lote solo entrega la API compartida.
- La prueba funcional visual corresponde a los Flows y componentes consumidores. Las utilidades internas no requieren video independiente.
- Los datos oficiales de bodega, sucursal, territorio, catálogo, precios, permisos y Softland permanecen pendientes donde aplique; no fueron inferidos.
- Despacho sigue bloqueado por sus dependencias faltantes y no fue tocado.

## Riesgos siguientes

- Un consumidor que continúe traduciendo legacy localmente puede conservar lógica duplicada hasta ser migrado.
- Los consumidores deben detenerse ante `NO_CONFIGURADO`, `SELECCION_REQUERIDA` o `ERROR`; no deben continuar con `Pricebook2Id` nulo.
- La ambigüedad actual de opciones USD para Bavarian y Otobai exige que la UI o el proceso conserve una selección compatible o solicite elección.

## Recomendación

Continuar con el Lote 2 únicamente para Flows activos no bloqueados, adoptando el contrato compartido sin incorporar configuración funcional no confirmada. No iniciar automáticamente ningún recurso de despacho o usados.
