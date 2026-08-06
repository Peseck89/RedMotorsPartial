# Resultado B9-AP0 — Approval Processes y dependencias de roles

**Fecha:** 6 de agosto de 2026
**Estado:** `COMPLETADO_COMO_ANALISIS`
**Org revisada:** Partial, exclusivamente en lectura

## Resultado ejecutivo

El documento inicial estimó **~6 Approval Processes**. S3-0 demostró un universo real de **18**: **12 incluidos** por relación nominal con Opportunity, Quote o WorkOrder y **6 excluidos** por pertenecer a objetos financieros o auxiliares fuera del cambio PEKING.

No existía una línea base versionada suficiente para los 12 incluidos; se recuperaron de forma dirigida a una ubicación temporal externa al repositorio. No se consultó Producción.

| Clasificación | Procesos |
|---|---:|
| `SIN_CAMBIO_REQUIERE_REGRESION` | 8 |
| `CANDIDATO_AJUSTE_TECNICO` | 0 |
| `DEPENDENCIA_DIEGO` | 0 |
| `BLOQUEADO_APROBADOR_NEGOCIO` | 1 |
| `BLOQUEADO_REGLA_NEGOCIO` | 1 |
| `BLOQUEADO_DATOS_OPERATIVOS` | 2 |
| `NO_APLICA` dentro de los 12 incluidos | 0 |
| **Total incluido** | **12** |

## Universo exacto

### Incluidos

1. `Opportunity.Aprobacion_descuento_Director_con_Jefe`
2. `Opportunity.Aprobacion_descuento_Director_Full_Team`
3. `Opportunity.Aprobacion_descuento_Director_Gerente4`
4. `Opportunity.Aprobacion_descuento_gerente_con_Jefe`
5. `Opportunity.Aprobacion_descuento_Gerente_sin_Gerente`
6. `Opportunity.Aprobacion_descuento_Gerente_sin_jefe`
7. `Opportunity.Aprobacion_descuento_Jefe_con_jefe`
8. `Opportunity.Aprobacion_descuento_Jefe_sin_Jefe`
9. `Quote.CPAprobacionCargoInternoQuote`
10. `WorkOrder.AprobacionCentroDeCostos`
11. `WorkOrder.PROCESO_DE_APROB_GARANTIA`
12. `WorkOrder.PROCESO_DE_APROB_GARANTIA_CITA_TALLER`

Los primeros once están activos en Partial; el proceso de garantía de cita de taller está inactivo y fue revisado sin descartarlo automáticamente.

### Excluidos del cambio PEKING

S3-0 ya demostró seis exclusiones nominales: `AprobacionCentroCosto__c.Aprobacion_por_Centro_de_Costo` y cinco procesos de `Oportunidad_de_Financiamiento__c`. Se conservan como `NO_REQUIERE_CAMBIO` fuera del subconjunto de 12; no se reclasifican como `NO_APLICA` dentro de esta matriz dirigida.

## Criterios y aprobadores

### Descuentos de Opportunity

Los ocho procesos son neutrales a Empresa, Marca y RecordType. Sus criterios combinan `Descuento_Total__c > 0`, indicadores de nivel y presencia/ausencia de los campos `JefeSucursal__c`, `GerenteSucursal__c` y `DirectorVentas__c`. La paridad confirmada por Diego permite concluir que PEKING entra sin extender metadata.

Todos los pasos usan `relatedUserField`; no contienen User, Role ni Queue fijos. La identidad se resuelve desde los campos del registro. Por ello no debe preguntarse a negocio por el criterio técnico actual ni modificarse estos procesos: requieren datos QA autorizados y regresión.

### Centros de costo

Los procesos de Quote y WorkOrder son neutrales y usan, respectivamente, `CPAprobadorCentroDeCostos__c` y `Aprobador_Centro_de_Costos__c`. El aprobador es dinámico, pero los centros de costo y responsables PEKING todavía no existen o no tienen referencia oficial. El bloqueo es de datos operativos, no de Approval Process.

### Garantía

`PROCESO_DE_APROB_GARANTIA` está activo y contiene cuatro aprobadores User fijos. La regla vigente se basa en etapa y tipo de gasto, pero no define cobertura ni aprobador PEKING. No se puede reutilizar silenciosamente a los aprobadores legacy.

`PROCESO_DE_APROB_GARANTIA_CITA_TALLER` está inactivo, usa un User fijo y condiciona etapa/tipo de servicio. No se infiere activación ni aplicabilidad futura; requiere decisión funcional antes de cualquier cambio.

## Acciones y campos afectados

- Los ocho procesos de descuento no tienen acciones iniciales; al aprobar actualizan descuento aprobado, pendiente y último descuento aprobado; rechazo y recall restauran el indicador pendiente.
- Quote y WorkOrder de centro de costo actualizan estado/pulse al enviar y estados/campos de aprobador al aprobar o rechazar.
- Garantía actualiza etapa y estado de aprobación/rechazo; la variante de cita también contiene alertas de correo.
- No se detectaron referencias nominales a Empresa, Marca, BMW, MINI, Motorrad, Otobai, Omoda, Jaecoo, PEKING, territorio, perfil ni RecordType en los 12 procesos.

## Roles y jerarquía

Ningún paso de los 12 Approval Processes asigna un `Role` o `RoleAndSubordinates`. Quote y WorkOrder de centro de costo permiten el tipo genérico `roleSubordinatesInternal` como submitter, sin nombrar un rol concreto.

Los 15 Roles inventariados por S3-0 no son dependencias directas de estos procesos. La creación o adaptación de jerarquía queda `DEPENDENCIA_DIEGO_POR_JERARQUIA`, conforme a la confirmación de Diego. No existe evidencia de un Role técnico que deba crear este frente y no se proponen nombres ni IDs.

La clasificación nominal de los Roles existentes es:

- **Genérico:** `View_All`.
- **Funcionales por línea Autos/Motos:** `Vendedores_Autos`, `Vendedores_Motos`, `Asesores_y_Mecanicos_de_Servicio_Autos`, `Asesores_y_Mecanicos_de_Servicio_Motos`, `Call_Center_Asistente_de_Motos`, `Call_Center_Asistente_de_ventas`, `Direccion_de_Postventa_Autos`, `Direccion_de_Postventa_Motos`, `Direccion_de_Ventas_Autos`, `Direccion_de_Ventas_Motos`, `Jefatura_de_Postventa_Autos`, `Jefatura_de_Postventa_Motos`, `Jefe_de_Ventas_Autos` y `Jefe_de_Ventas_Motos`.
- **Específicos de Empresa o marca:** ninguno demostrado por el nombre o por una referencia desde los 12 Approval Processes.

Esta clasificación no autoriza reutilizar los Roles para PEKING ni crear equivalentes; esa decisión forma parte de la jerarquía a cargo de Diego.

## Preguntas técnicas eliminadas

- Existencia, actividad, criterios y pasos actuales de los 12 procesos.
- Tipo de aprobador y campos relacionados usados por los ocho procesos de descuento.
- Umbral técnico actual de entrada: `Descuento_Total__c > 0`.
- Campos dinámicos usados por los procesos de centro de costo.
- Referencia directa a Roles: no existe en los pasos auditados.

## Preguntas genuinas restantes

- Datos oficiales y fuente de población de responsables/centros de costo PEKING para Quote y WorkOrder.
- Cobertura, criterio excepcional y aprobador autorizado de garantía PEKING.
- Si la aprobación de garantía de cita de taller debe permanecer inactiva; una respuesta futura no autoriza activación por sí sola.

## ¿Existe B9-AP1?

**No.** Los ocho procesos que pueden operar con PEKING ya son neutrales y no requieren ajuste técnico. Los cuatro restantes están bloqueados por datos o decisiones funcionales. No existe un proceso que solo necesite extender Omoda/Jaecoo/PEKING con aprobador reutilizable. Por ello no se crea una propuesta B9-AP1.

## Controles de ejecución

- No se revisaron nuevamente las 94 Validation Rules.
- No se modificó metadata ni datos.
- No hubo deploy, dry-run, DML, activación ni desactivación.
- Partial se consultó únicamente mediante retrieve dirigido de lectura.
- Producción no fue consultada.
- Las identidades de usuarios fijos no se registraron en los entregables.
