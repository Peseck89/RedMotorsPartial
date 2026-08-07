# Resultado B11-1 — catálogos Softland

**Fecha:** 6 de agosto de 2026  
**Org validada:** Partial (`RedMotorsSandbox`)  
**Estado:** `B11-1 — RECONCILIADO_Y_VALIDADO_TECNICAMENTE`

## Alcance ejecutado

Se incorporó a la línea versionada el estado ya existente en Partial de 13 clases productivas y sus 13 pruebas, junto con sus archivos `.cls-meta.xml`:

- `BatchGetCatalogoSoftland`.
- Seis wrappers: categoría de cliente, centro de costo, condición de pago, cuenta contable, impuesto y subtipo de documento.
- Seis schedulers correspondientes.
- Trece clases de prueba asociadas.

No se incluyó `BatchGetBodegaSoftland`, no se ejecutaron catálogos reales y no se programaron schedulers.

## Comportamiento conciliado

- `BatchGetCatalogoSoftland` conserva y propaga el parámetro `company` en las rutas confirmadas y en la paginación.
- El overload legacy conserva `RMBAVARIAN` para compatibilidad; no se cambió su contrato.
- Cada uno de los seis schedulers productivos encola separadamente `RMBAVARIAN` y `RMPEKING`.
- Ninguno de los seis schedulers productivos agrega `RMOTOBAI` a la ejecución operativa.
- Las pruebas recuperadas de Partial se conservaron sin reinterpretación funcional.

## Pruebas Apex

| Evidencia | Resultado |
|---|---|
| Test Run ID | `707AK00000I2ACX` |
| Clases de prueba solicitadas | 13 |
| Métodos ejecutados | 36 |
| Aprobados | 36 |
| Fallidos | 0 |
| Omitidos | 0 |
| Cobertura de la ejecución | 75% |
| Cobertura global informada por la org | 40% |

Cobertura dirigida de las clases productivas:

| Clase | Cobertura |
|---|---:|
| `BatchGetCatalogoSoftland` | 84% |
| Cada uno de los seis wrappers | 100% |
| Cada uno de los seis schedulers | 100% |

Advertencia real: la cobertura global de la org es 40%; no corresponde a un fallo del lote. La ejecución dirigida alcanzó 75% y todos sus métodos aprobaron.

## Dry-run dirigido

| Evidencia | Resultado |
|---|---|
| Validation ID | `0AfAK0000011hWz0AI` |
| Estado | `Succeeded` |
| Componentes | 26/26 |
| Errores de componentes | 0 |
| Métodos de prueba | 36/36 |
| Errores de prueba | 0 |

El dry-run se limitó a las 13 clases productivas y las 13 pruebas de B11-1.

## Conciliación Git–Partial

Después de las pruebas y el dry-run se recuperaron nuevamente desde Partial las 13 clases productivas y sus metadatos. La comparación normalizada de finales de línea resultó equivalente en 26 de 26 archivos, sin diferencias semánticas.

**Decisión de despliegue:** `DEPLOY_NO_NECESARIO_PARTIAL_YA_EQUIVALENTE`.

No se realizó deploy real porque Partial ya contiene el comportamiento conciliado.

## Control de ejecución

- Jobs `ScheduledApex` relevantes antes de las pruebas: 0.
- Jobs `ScheduledApex` relevantes después de las pruebas y del dry-run: 0.
- Catálogos reales ejecutados: ninguno.
- Schedulers programados: ninguno.
- Datos creados o modificados: ninguno.
- Producción consultada o modificada: no.

## Límites y pendientes

La evidencia demuestra reconciliación, compilación, pruebas con mocks y equivalencia con Partial. No demuestra la validez funcional del contenido real de los catálogos PEKING.

Permanecen pendientes:

- validación funcional con datos oficiales de catálogo;
- definición y datos oficiales de bodegas;
- validación de colisiones o segregación entre empresas donde la clave del objeto no incluya Empresa;
- evidencia de QA funcional autorizada.

Sprint 3 no se declara cerrado.
