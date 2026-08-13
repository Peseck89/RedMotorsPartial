# Resultado — QA funcional y remediación de navegación de `Opp_flow_V3`

**Fecha:** 12 de agosto de 2026

**Ambiente:** `RedMotorsSandbox` (Partial)

**Estado:** **QA DE CREACIÓN OK — NAVEGACIÓN REMEDIADA EN v30 — QA MANUAL DEL ENLACE PENDIENTE**

## Evidencia de la ejecución funcional

La entrevista más reciente de `Opp_flow_V3` v29 fue ejecutada por un perfil funcional QA y permanece en estado `Running` porque la pantalla final no se cerró:

- versión: v29 (`301AK00000PCMb4YAH`);
- entrevista: `8gZAK000000IgOz2AK`;
- GUID: `96010061b22932e5cc1210b9d45c19ff91937fa-5b3d`;
- inicio: `2026-08-13 03:18:53 UTC` (`2026-08-12 21:18:53 UTC-6`);
- último elemento observable: pantalla `Presupuesto`;
- fault: ninguno registrado.

La ejecución creó y conservó los siguientes registros:

| Registro | Id | Evidencia principal |
|---|---|---|
| Opportunity | `006AK00000JTVVJYA5` | `QA Prueba-Taller-12/08/2026`; Cuenta `QA Prueba`; Empresa `PEKING`; Record Type `Taller`; Stage `Oferta`; moneda `CRC`; Pricebook `PEKING Local`; Asset `VNA00260810051041`; territorio `Uruca - Mecánica General` |
| Quote | `0Q0AK000001zPyb0AE` | `PT-00080234`; relacionado con la Opportunity anterior; Contacto y Cuenta de facturación `QA Prueba`; moneda `CRC`; Pricebook `PEKING Local`; estado `Nuevo` |

`Opportunity.Empresa_Operadora__c` quedó poblado con `PEKING` y `BMW_Compania__c` quedó vacío. Opportunity y Quote persistieron; no hubo rollback. Por tanto, la creación funcional con PEKING queda validada.

## Defecto de navegación

La pantalla final `Presupuesto` mostraba el componente `btn1` de tipo `ecflc:flowIdRedirect`. El componente recibía correctamente el recurso `presupuestoid`, cuyo valor efectivo era el Quote `0Q0AK000001zPyb0AE`, pero al pulsar **Ir a presupuesto** no producía navegación visible.

El defecto coincide con el patrón ya comprobado en `Opp_Flow_V5`: la creación del presupuesto es correcta y el fallo está aislado a la navegación posterior. Se clasificó como **REMEDIACIÓN TÉCNICA PERMITIDA — CAMBIO LIMITADO** porque no agrega funcionalidad, no cambia reglas de negocio y no altera la creación de registros.

## Corrección aplicada

Se sustituyó exclusivamente `btn1` en la pantalla `Presupuesto` por un enlace estándar y portable de Salesforce:

```text
/lightning/r/Quote/{!presupuestoid}/view
```

No se modificaron conectores, asignaciones, lógica de Empresa, Pricebook, Account, Opportunity, Quote ni otros Flows.

## Validación y despliegue

- representación recuperada de v29: equivalencia semántica completa con la metadata local previa;
- validación aislada API 67.0: exitosa, 1/1 componente (`0AfAK0000014AUr0AM`);
- despliegue aislado API 67.0: exitoso, 1/1 componente (`0AfAK0000014AWT0A2`);
- versión nueva y activa: v30 (`301AK00000PW6LeYAL`);
- recuperación posterior: v30 activa, sin `ecflc:flowIdRedirect`, con un único enlace relativo al Quote y equivalencia semántica completa con la corrección validada.

Las advertencias de validación correspondieron únicamente a nodos legacy inalcanzables preexistentes; no se modificaron.

## Pendiente manual acotado

No debe crearse otra Opportunity únicamente para repetir evidencia. La entrevista abierta pertenece a v29 y no puede convertirse en una entrevista v30.

Sin repetir el Flow, puede verificarse el destino y el acceso al Quote existente abriendo:

```text
/lightning/r/Quote/0Q0AK000001zPyb0AE/view
```

La integración del enlace dentro de la pantalla v30 debe confirmarse en la siguiente ejecución funcional normal de `Opp_flow_V3`. Hasta entonces, no corresponde declarar la navegación como QA funcional OK.
