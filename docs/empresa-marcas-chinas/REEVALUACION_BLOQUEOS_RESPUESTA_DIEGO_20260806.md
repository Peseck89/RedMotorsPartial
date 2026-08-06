# Reevaluación de bloqueos por respuesta de Diego

**Fecha:** 6 de agosto de 2026  
**Alcance:** Sprint 2 y Sprint 3; análisis documental únicamente.

La respuesta se aplicó sin asumir valores operativos ni considerar autorizado el QA. “Mismo comportamiento” confirma la regla funcional general, pero no sustituye la revisión nominal de fórmulas, aprobadores, datos ni referencias de Empresa.

## Sprint 2

| Frente | Componente/Proceso | Estado anterior | Respuesta Diego | Estado nuevo | Qué falta |
|---|---|---|---|---|---|
| Quote → Work Order | `Work_Order_from_Quote` | Bloqueado por operación Quote→WO, bodega y taller | Procesos equivalentes operan con la Empresa enviada | `PARCIALMENTE_RESPONDIDA` | Condiciones y líneas de Quote→WO; bodegas, territorios y talleres; datos y QA |
| Quote → Work Order selectivo | `Work_Order_from_Quote_Selective` | Bloqueado por operación selectiva, reserva y despacho | Reserva/devolución depende de la Empresa recibida | `PARCIALMENTE_RESPONDIDA` | Selección de líneas, bodegas, territorios, talleres y validaciones de detención |
| WOLI y cargos | `SegregateWOLIs` | Bloqueado por garantía y segregación PEKING | PEKING conserva las reglas generales existentes | `PARCIALMENTE_RESPONDIDA` | Criterios nominales de garantía, cargos y centros de costo; datos y regresión |
| Caso, Work Order y Event | `aperturaCaseWorOrderEvent` | Bloqueado por servicios, agenda y operación territorial | La Empresa correcta debe gobernar procesos equivalentes | `PARCIALMENTE_RESPONDIDA` | Servicios, agendas, sucursales, territorios, asesores, mecánicos y datos QA |
| Caso, Work Order y Event | `ct_newCaseWorkOrderEvent` | Bloqueado por servicios, agenda y operación territorial | La Empresa correcta debe gobernar procesos equivalentes | `PARCIALMENTE_RESPONDIDA` | Servicios, agendas, sucursales, territorios, asesores, mecánicos y datos QA |

La definición reduce el bloqueo de enrutamiento empresarial en los cinco Flows, pero ninguno queda totalmente ejecutable: todos conservan decisiones o datos operativos que no pueden inventarse. Los Flows no fueron modificados.

## Sprint 3

### Validation Rules

La matriz nominal vigente contiene 94 Validation Rules: 55 estaban `BLOQUEADO_NEGOCIO` y 39 `REQUIERE_REGRESION`. Las 55 bloqueadas fueron reevaluadas bajo estos criterios:

| Grupo nominal | Estado anterior | Respuesta Diego | Estado nuevo | Qué falta |
|---|---|---|---|---|
| Reglas genéricas sin Empresa, marca o Record Type explícito | Bloqueo por aplicabilidad general | PEKING debe mantener el comportamiento existente | `PARCIALMENTE_DESBLOQUEADO` | Confirmar fórmula nominal, actividad y regresión con Empresa correcta; una regla neutral puede concluir sin cambio técnico |
| Reglas que enumeran BMW, MINI, marcas, perfiles o Record Types | Aplicabilidad PEKING no confirmada | La regla funcional debe ser equivalente | `PARCIALMENTE_DESBLOQUEADO` | Determinar si deben incluir Omoda/Jaecoo/PEKING; no basta la confirmación general |
| Reglas de descuentos | Política y QA pendientes | Se confirma paridad de comportamiento | `PARCIALMENTE_DESBLOQUEADO` | Umbrales, niveles y aprobadores cuando la fórmula/proceso los requiera; QA nominal |
| Reglas de centro de costo en Quote y WorkOrder | Centro de costo y responsable no definidos | Se confirma paridad; no existen registros PEKING | `SIGUE_BLOQUEADO` | Registros, valores, referencia, responsable y QA |
| Reglas de WorkOrder/taller/garantía | Operación y datos pendientes | Se confirma paridad general | `PARCIALMENTE_DESBLOQUEADO` | Talleres, garantía, servicios, territorios, asesores y datos QA según cada fórmula |

No se reclasifican automáticamente las 55 reglas como ejecutables. La fórmula y el estado activo/inactivo de cada una siguen siendo evidencia obligatoria.

### Approval Processes

| Frente | Estado anterior | Respuesta Diego | Estado nuevo | Qué falta |
|---|---|---|---|---|
| Criterio general de aprobación | Regla PEKING pendiente | Mismo comportamiento existente | `PARCIALMENTE_DESBLOQUEADO` | Verificar criterios nominales y Record Types |
| Aprobaciones de descuento | Niveles y aprobadores pendientes | No define aprobadores | `SIGUE_BLOQUEADO` | Umbrales, niveles, responsable y QA |
| Centro de costo | Regla, registros y aprobador pendientes | Confirma paridad y ausencia de registros | `SIGUE_BLOQUEADO` | Centros de costo oficiales, referencia y aprobador |
| Garantía | Criterio y rol pendientes | No define garantía | `SIGUE_BLOQUEADO` | Cobertura, criterio y aprobador funcional |

Una regla confirmada no equivale a un aprobador confirmado.

### Roles y Profiles

| Frente | Estado anterior | Respuesta Diego | Estado nuevo | Qué falta |
|---|---|---|---|---|
| Jerarquía y perfiles | Definición pendiente | Diego los creará | `DEPENDENCIA_DIEGO` | Disponibilidad y evidencia para QA; no implementar ni duplicar |

### Custom Metadata y Softland

| Frente | Estado anterior | Respuesta Diego | Estado nuevo | Qué falta |
|---|---|---|---|---|
| Configuración Softland autoritativa | Tipo y nombre lógico pendientes | La respuesta cubre reservas/devoluciones, no configuración | `SIGUE_BLOQUEADO` | Tipo y nombre lógico, consumidores RMPEKING y separación de responsabilidades |

## Ya no requiere pregunta

- Si PEKING debe usar reglas generales diferentes: no; mantiene el comportamiento existente.
- Si reservas y devoluciones deben decidirse por una regla nueva independiente: no; se gestionan por la Empresa enviada.
- Quién creará jerarquía y perfiles: Diego. No se vuelve a solicitar su definición al negocio por ahora.

## Parcialmente desbloqueado

- Los cinco Flows pendientes de Sprint 2 reducen la incertidumbre sobre enrutamiento por Empresa, pero conservan dependencias operativas.
- Las Validation Rules pueden revisarse nominalmente con la regla de paridad; las fórmulas con marcas, perfiles o Record Types explícitos todavía requieren decisión técnica y QA.
- El criterio general de Approval Processes se reduce, pero no sus aprobadores ni datos.

## Sigue bloqueado

- Bodegas, sucursales, talleres, servicios, agenda, mecánicos y garantías.
- Valores y referencias para asesores, territorios y centros de costo.
- Productos, precios, monedas, catálogos, documentos y datos legales.
- Aprobadores, niveles y responsables funcionales.
- Configuración autoritativa y alcance nominal de Softland.
- QA integral hasta disponer de datos mínimos y autorización para crearlos.

## Dependencia a cargo de Diego

- Creación de jerarquía.
- Creación de perfiles.
- Disponibilidad y evidencia posterior para ejecutar QA con esos elementos.

## Evaluación de siguiente lote

No existe todavía un subconjunto funcional que cumpla simultáneamente pertenencia a los bloques 7, 9 u 11, baseline suficiente, independencia de perfiles/jerarquía, ausencia de datos operativos faltantes y prueba aislada completa. La respuesta permite una revisión nominal preparatoria de Validation Rules, pero no autoriza ni sustenta un lote de implementación. Por ello no se crea una propuesta funcional posterior.

