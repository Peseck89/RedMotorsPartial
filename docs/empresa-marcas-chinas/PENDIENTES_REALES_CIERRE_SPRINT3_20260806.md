# Pendientes reales para el cierre de Sprint 3

**Fecha:** 6 de agosto de 2026  
**Estado:** Sprint 3 no cerrado

## Ya terminado técnicamente

| Componente/proceso | Resultado | Evidencia |
|---|---|---|
| S3-0 | Inventario y análisis completados con limitaciones | Matrices nominales y cierre de integridad vigentes |
| B9-1 | Cuatro Validation Rules implementadas y equivalentes en Partial | Resultado B9-1, dry-run, deploy y retrieve posterior |
| B7-0 | 78 componentes clasificados; diez sin cambio técnico | Matriz UI B7-0 |
| B9-AP0 | 12 Approval Processes incluidos clasificados; ocho sin cambio técnico | Matriz B9-AP0 |
| B11-0 y B11-0.1 | Arquitectura y catálogos/schedulers identificados | Resultados B11-0 y B11-0.1 |
| B11-1 | 13 productivas y 13 pruebas reconciliadas; pruebas y dry-run exitosos; Partial ya equivalente | Test Run `707AK00000I2ACX`, Validation `0AfAK0000011hWz0AI` |

## Pendiente solo QA

| Componente/proceso | Qué falta | Responsable | Evidencia del bloqueo | Acción cuando esté disponible |
|---|---|---|---|---|
| Cuatro Validation Rules B9-1 | Positivo, negativo y regresión con Opportunities autorizadas | QA / Ventas | `DATOS_QA_NO_DISPONIBLES` y plan B9-1 | Ejecutar matriz y grabar evidencias |
| Ocho Approval Processes de descuento | Aprobación, rechazo, recall y regresión | QA / Ventas | Faltan usuarios relacionados y registros QA autorizados | Ejecutar plan de regresión sin cambiar metadata |
| Diez componentes UI B7 | Regresión visual Omoda/Jaecoo y legacy | QA / responsables UI | Faltan perfiles y registros QA autorizados | Ejecutar checklist manual y videos |
| Seis catálogos B11-1 | Validar contenido real y segregación con datos oficiales | Negocio / Softland / QA | Las pruebas técnicas usan mocks; no se ejecutaron catálogos reales | Ejecutar QA controlado cuando existan datos y autorización |

## Pendiente negocio/datos

| Componente/proceso | Qué falta exactamente | Responsable | Evidencia del bloqueo | Acción posterior |
|---|---|---|---|---|
| UI restante del bloque 7 | Asignaciones exactas por aplicación, perfil y Record Type | Negocio / responsables de Ventas y Taller | 63 componentes bloqueados por asignación y un drift no autorizado | Proponer lote limitado tras confirmar asignaciones |
| Centro de costo y aprobaciones | Centros de costo y responsables PEKING oficiales | Finanzas / negocio | No existen referencias autorizadas para poblar QA | Validar reglas y procesos bloqueados |
| Garantía | Cobertura, excepciones, regla y aprobador | Garantías / Taller | Dos Approval Processes permanecen bloqueados | Definir ajuste o confirmar sin cambio y probar |
| Bodega | Bodegas oficiales y estrategia de clave/segregación | Operaciones / Softland | No existen bodegas PEKING oficiales; clave actual no separa Empresa | Diseñar lote de Bodega sin inventar datos |
| Catálogos y operación | Productos, precios, monedas, cuentas y valores oficiales aplicables | Negocio / Finanzas / Softland | B11-1 no valida contenido real | Preparar y ejecutar QA autorizado |
| Pricebook por defecto | Regla comercial cuando no hay selección explícita | Ventas / negocio | Existen dos Pricebooks PEKING; no hay precedencia autorizada | Ajustar solo el consumidor que la decisión determine |

## Dependencia Diego

| Componente/proceso | Qué falta | Responsable | Evidencia del bloqueo | Acción posterior |
|---|---|---|---|---|
| Jerarquía y perfiles | Creación, disponibilidad y evidencia | Diego | Decisión registrada del 6 de agosto | Ejecutar QA de seguridad y UI; no duplicar configuración |
| Registros operativos mínimos | Referencia exacta para asesores, territorios, centros de costo y equivalentes | Diego / responsable que indique | Diego confirmó ausencia de registros y falta de referencia | Coordinar datos QA autorizados sin inventarlos |

## No pertenece a Sprint 3

| Frente | Estado |
|---|---|
| Bloques 8, 12, 13 y 14 | `FUERA_DE_SPRINT3_CONFIRMADO`; no cancelados |
| Bloque 10 amplio | `NA` para Profiles y Permission Sets amplios |
| Requisitos adicionales fuera de bloques 7, 9 y 11 | No se absorben desde documentos posteriores |
| Refactor global de endpoints, autenticación o modelo de catálogos | Deuda o proyecto separado; no ampliar Sprint 3 |

## Conclusión

`TRABAJO_TECNICO_AISLABLE_AGOTADO_CON_INFORMACION_ACTUAL`

Lo restante es QA, una definición de negocio/datos o una dependencia externa. Esto no equivale a `SPRINT3_CERRADO`.

## Actualización QA B9-1 — 2026-08-07

Tres de las cuatro Validation Rules completaron QA positivo, negativo y regresión. El pendiente B9-1 se reduce a:

| Componente/proceso | Qué falta | Responsable | Evidencia | Acción posterior |
|---|---|---|---|---|
| `Campo_Gustos_y_aficiones_Obligatorio` | Analizar por qué Omoda no bloquea con el campo vacío; repetir Omoda, Jaecoo y BMW/MINI | Desarrollo / QA, previa autorización | Validation `0AfAK0000012Ah30AE`; resultado QA del 2026-08-07 | Auditar fórmula/orden de ejecución, proponer corrección limitada y repetir matriz |
| `Cambiar_Oportunidad_a_Finalizado_VH` | Video/E2E solo si el cierre general exige probar el proceso real de reserva | Negocio / QA | QA de la Validation Rule pasó sin crear reserva | Ejecutar posteriormente con datos seguros y autorización específica |

El estado consolidado es `B9-1 — QA_FUNCIONAL_PARCIAL`; Sprint 3 no está cerrado.
