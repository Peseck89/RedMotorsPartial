# Resultado — QA y remediación de navegación de `Opportunity_Flow_V2`

**Fecha:** 12 de agosto de 2026

**Ambiente:** `RedMotorsSandbox` (Partial)

**Estado:** **QA CREACIÓN OK — NAVEGACIÓN REMEDIADA EN v8 — QA MANUAL DEL ENLACE PENDIENTE**

## Evidencia de la entrevista v7

La ejecución manual única de la ruta general/Taller quedó identificada de forma inequívoca:

- Flow Version Id: `301AK00000PCMb5YAH`;
- FlowInterviewLog: `8gZAK000000Ih4v2AC`;
- GUID: `31656edfaf899d2705c10b59fc519ff96325cc-61d2`;
- inicio: `2026-08-13 04:37:49 UTC` (`2026-08-12 22:37:49 UTC-6`);
- estado: `Running`, porque la entrevista permanece en la pantalla final;
- pantalla final observada: `Presupuesto`;
- fault: ninguno registrado.

La ausencia de un registro consultable en `FlowInterview` mientras la entrevista continúa en ejecución impide obtener `CurrentElement` directamente. La pantalla final queda demostrada por la evidencia visual y por la secuencia del Flow que alcanza `Presupuesto` después de crear y procesar el Quote.

## Creación funcional

La ejecución creó y conservó los siguientes registros:

### Opportunity

- Id: `006AK00000JTeqQYAT`;
- Name: `QA Prueba-Taller-12/08/2026`;
- Account: `QA Prueba` (`001PH00001O6pqGYAR`);
- `Empresa_Operadora__c`: `PEKING` (`a1UAK0000009wft2AA`);
- `BMW_Compania__c`: vacío;
- Record Type: `Taller`;
- Stage: `Oferta`;
- moneda: `CRC`;
- Pricebook: `PEKING Local` (`01sAK0000006DVdYAM`);
- Asset: `VNA00260810051041` (`02iAK000001xtZNYAY`);
- territorio de servicio: `Uruca - Mecánica General` (`0Hh4U0000010wVFSAY`);
- `IsDeleted = false`.

### Quote

- Id: `0Q0AK000001zZuj0AE`;
- Name: `PT-00080236`;
- Opportunity: `006AK00000JTeqQYAT`;
- Account: `QA Prueba` (`001PH00001O6pqGYAR`);
- moneda: `CRC`;
- Pricebook: `PEKING Local` (`01sAK0000006DVdYAM`);
- `Compania__c`: vacío;
- `IsDeleted = false`.

El Asset reutilizado conserva Account y Contact `QA Prueba`; el Contact seleccionado corresponde a `003PH00001VYijKYAT`. Esta ruta no persiste un Contact directo en Opportunity o Quote. No hubo fault downstream ni rollback: ambos registros existen y la creación funcional queda en **QA OK**.

## Diagnóstico de navegación

La pantalla final `Presupuesto` contenía el campo `btn1`:

- tipo: `ComponentInstance`;
- extensión: `ecflc:flowIdRedirect`;
- `recordId = presupuestoid`;
- etiqueta: `Ir a presupuesto`.

`CreateQuote` asigna el Id creado directamente a `presupuestoid`. En esta entrevista el valor efectivo fue `0Q0AK000001zZuj0AE`, pero el componente no produjo navegación visible.

El defecto coincide exactamente con el patrón legacy ya demostrado en `Opp_Flow_V5`, `Opp_flow_V3` y `Opp_Flow_v6`. Se clasificó como **REMEDIACIÓN TÉCNICA PERMITIDA — CAMBIO LIMITADO**.

## Cambio aplicado

Se sustituyó únicamente `Presupuesto.btn1` por un `DisplayText` estándar con enlace dinámico:

```text
/lightning/r/Quote/{!presupuestoid}/view
```

No se modificaron creación de Opportunity o Quote, Empresa, Pricebook, moneda, Asset, Account, Contact, territorio, plantilla, otras pantallas ni otros Flows. No se agregó LWC, Aura, Apex, paquete, dominio ni Id hardcodeado.

## Validación y despliegue

- round-trip limpio de v7: exitoso, 1/1 (`0AfAK0000014BsL0AU`);
- comparación del cambio: únicamente retiro del componente legacy y alta del enlace estándar;
- dry-run API 67.0: exitoso, 1/1 (`0AfAK0000014BvZ0AU`);
- deploy API 67.0: exitoso, 1/1 (`0AfAK0000014BxB0AU`);
- versión nueva y activa: v8 (`301AK00000PWLPYYA5`);
- recuperación posterior: coincidencia exacta con el artefacto desplegado, enlace estándar presente y cero referencias a `ecflc:flowIdRedirect`.

Las advertencias de validación correspondieron exclusivamente a nodos legacy inalcanzables preexistentes y no modificados.

No debe repetirse el Flow únicamente para obtener evidencia del enlace. La navegación integrada de v8 queda pendiente de confirmación durante la siguiente ejecución funcional normal. La ruta Mostrador continúa pendiente de una sesión funcional autorizada de ese tipo.
