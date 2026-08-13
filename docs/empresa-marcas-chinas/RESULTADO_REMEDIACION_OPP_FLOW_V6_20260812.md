# Resultado — remediación técnica de `Opp_Flow_v6`

**Fecha:** 12 de agosto de 2026

**Ambiente:** `RedMotorsSandbox` (Partial)

**Estado:** **VALIDACIÓN TÉCNICA OK — QA FUNCIONAL MANUAL PENDIENTE**

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

## QA manual pendiente

Repetir el caso Taller una sola vez con el perfil funcional QA, el Asset `VNA00260810051041`, Contacto y Cuenta de facturación `QA Prueba`, Empresa `PEKING`, moneda Colones y taller `Uruca - Mecánica General`.

Verificar que:

- se creen y persistan Opportunity y Quote;
- `Opportunity.Empresa_Operadora__c = PEKING`;
- los campos legacy de compañía queden vacíos para PEKING;
- moneda `CRC` y Pricebook `PEKING Local`;
- no exista fault ni rollback.

Si aparece otro error, especialmente en `Resolver_Pricebook_Empresa`, detener la prueba, preservar GUID, hora, elemento y mensaje técnico, y abrir un diagnóstico separado. No modificar automáticamente otro componente.
