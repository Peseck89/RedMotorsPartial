# Resultado — remediación técnica de `Opp_Flow_v6`

**Fecha:** 12 de agosto de 2026

**Ambiente:** `RedMotorsSandbox` (Partial)

**Estado:** **QA CREACIÓN OK — NAVEGACIÓN REMEDIADA EN v82 — QA MANUAL DEL ENLACE PENDIENTE**

## Evidencia del fallo funcional

La ejecución manual dirigida de `Opp_Flow_v6` v80 quedó identificada de forma inequívoca:

- Flow Version Id: `301AK00000PCG7ZYAX`;
- FlowInterview: `0FoAK000001d9aj0AA`;
- FlowInterviewLog: `8gZAK000000IgaH2AS`;
- GUID: `1096ffa67691e21665d43c649a7719ff92ea8b2-680a`;
- inicio: `2026-08-13 03:51:00 UTC` (`2026-08-12 21:51:00 UTC-6`);
- fin: `2026-08-13 03:52:29 UTC`;
- estado: `Error`;
- elemento: `CreateQuote`.

Salesforce preservó el siguiente error:

```text
INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST: Compañía: valor inapropiado para el campo de lista de selección restringida: PEKING.
```

`CreateOpportunity` se ejecutó antes del fault, pero `CreateQuote` falló dentro de la misma transacción. No persistieron Opportunity ni Quote; la transacción fue revertida.

El error es distinto del antecedente del 6 de agosto de 2026 en `Resolver_Pricebook_Empresa`. En esta ejecución el resolver no llegó a ejecutarse.

## Causa raíz

La v80 asignaba:

```text
CreateQuote.Compania__c = EmpresaUsuario
```

Después de la selección estructural, `EmpresaUsuario` podía contener `PEKING`. Sin embargo, `Quote.Compania__c` es un picklist legacy restringido que admite únicamente `Bavarian` y `Otobai`.

La Empresa y el Pricebook estaban configurados correctamente:

- Empresa: `PEKING` (`a1UAK0000009wft2AA`);
- código ERP: `RMPEKING`;
- moneda: `CRC`;
- Pricebook esperado: `PEKING Local` (`01sAK0000006DVdYAM`), activo y relacionado con PEKING.

El fallo no fue causado por datos QA, permisos, Pricebook, Apex ni automatización posterior.

## Clasificación y cambio

Clasificación: **REMEDIACIÓN TÉCNICA PERMITIDA — CAMBIO LIMITADO**.

Se modificó exclusivamente la fuente del campo legacy en `CreateQuote`:

```text
Quote.Compania__c = EmpresaUsuario
→
Quote.Compania__c = EmpresaLegacySeleccionada
```

La fórmula existente conserva el comportamiento:

| Empresa estructural | `Quote.Compania__c` |
|---|---|
| Bavarian | `Bavarian` |
| Otobai | `Otobai` |
| PEKING | vacío/null |

No se agregó `PEKING` al picklist legacy. No se modificaron `EmpresaUsuario`, `EmpresaLegacySeleccionada`, `CreateOpportunity`, `Empresa_Operadora__c`, el resolver, Pricebook, Account, Contact, Asset, pantallas ni otros Flows.

## Validación y despliegue

La representación source local conserva metadata visual que la serialización moderna omite. Para no eliminar ni reinterpretar propiedades visuales, se utilizó la representación MDAPI canónica recuperada de la v80 activa.

- round-trip limpio de v80: exitoso, 1/1 (`0AfAK0000014Akz0AE`);
- comparación semántica del artefacto modificado: una única referencia sustituida;
- dry-run API 67.0: exitoso, 1/1 (`0AfAK0000014Amb0AE`);
- deploy API 67.0: exitoso, 1/1 (`0AfAK0000014AoD0AU`);
- versión nueva y activa: v81 (`301AK00000PW25AYAT`);
- verificación posterior: `CreateQuote.Compania__c = EmpresaLegacySeleccionada`, `CreateOpportunity.Empresa_Operadora__c = EmpresaSeleccionadaId` y `Resolver_Pricebook_Empresa = EmpresaPricebookResolver`.

Las advertencias de validación correspondieron únicamente a nodos legacy inalcanzables preexistentes y no modificados.

## Resultado del QA funcional v81

La repetición manual de v81 confirmó la creación funcional con PEKING:

- FlowInterviewLog: `8gZAK000000IgnB2AS`;
- GUID: `682248cd0259e6fd65a18a1c5219ff95111ad-4896`;
- inicio: `2026-08-13 04:19:47 UTC` (`2026-08-12 22:19:47 UTC-6`);
- estado: `Running`, porque la entrevista permanece en la pantalla final `Presupuesto`;
- fault: ninguno registrado;
- Opportunity: `006AK00000JTWT1YAP`, `QA Prueba-Taller-12/08/2026`;
- Quote: `0Q0AK000001zNQZ0A2`, `PT-00080235`.

La Opportunity persistió con Cuenta `QA Prueba`, `Empresa_Operadora__c = PEKING`, `BMW_Compania__c = null`, Record Type `Taller`, Stage `Oferta`, moneda `CRC`, Pricebook `PEKING Local`, Asset `VNA00260810051041` y territorio `Uruca - Mecánica General`.

El Quote persistió relacionado con esa Opportunity, con Contacto y Cuenta de facturación `QA Prueba`, `Compania__c = null`, moneda `CRC`, Pricebook `PEKING Local` y estado `Nuevo`. No hubo fault ni rollback. La creación funcional queda en **QA OK**.

## Defecto y remediación de navegación

La pantalla final `Presupuesto` conservaba el campo `btn1` de tipo `ComponentInstance`, extensión `ecflc:flowIdRedirect`, con `recordId = presupuestoid`. El valor efectivo de ese recurso era el Quote `0Q0AK000001zNQZ0A2`, pero el componente no produjo navegación visible.

El defecto coincide exactamente con el patrón ya demostrado y corregido en `Opp_Flow_V5` y `Opp_flow_V3`. Se clasificó como **REMEDIACIÓN TÉCNICA PERMITIDA — CAMBIO LIMITADO**.

Se sustituyó únicamente `Presupuesto.btn1` por un `DisplayText` con enlace estándar dinámico:

```text
/lightning/r/Quote/{!presupuestoid}/view
```

No se modificaron `CreateOpportunity`, `CreateQuote`, Empresa, resolver, Pricebook, Cuenta, Contacto, Asset, moneda, territorio, otras pantallas ni otros Flows.

Validación y despliegue de navegación:

- comparación semántica: únicamente el componente legacy retirado y el enlace estándar agregado;
- dry-run API 67.0: exitoso, 1/1 (`0AfAK0000014At30AE`);
- deploy API 67.0: exitoso, 1/1 (`0AfAK0000014Auf0AE`);
- versión nueva y activa: v82 (`301AK00000PWE36YAH`);
- recuperación posterior: equivalencia semántica completa con el artefacto desplegado, cero componentes `ecflc:flowIdRedirect`, enlace estándar presente y lógica funcional intacta.

No debe crearse otra Opportunity únicamente para repetir evidencia. La integración del enlace en v82 queda pendiente de confirmación durante la siguiente ejecución funcional normal.
