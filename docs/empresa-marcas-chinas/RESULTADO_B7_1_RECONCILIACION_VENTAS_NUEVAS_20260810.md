# Resultado B7-1 — Reconciliación con la equivalencia de Ventas Nuevas

**Fecha:** 10 de agosto de 2026
**Org:** Partial (`RedMotorsSandbox`) exclusivamente.
**Nueva definición aplicada (Luis, 2026-08-10):** Omoda y Jaecoo deben reutilizar la configuración equivalente de
Ventas Nuevas. Este documento aplica ese criterio a los 63 elementos que B7-0 dejó `BLOQUEADO_ASIGNACION_FUNCIONAL`,
usando exclusivamente `MATRIZ_UI_B7_0_20260806.csv` y `MATRIZ_ASIGNACIONES_UI_S3_0_V2_20260806.csv` ya existentes.
**No se auditó de nuevo el universo de 78.** Cero deploys de UI/Layout en este documento — solo lectura.

---

## 1. Qué es "la configuración equivalente de Ventas Nuevas", verificada técnicamente

Se consultó directamente en Partial (`ProfileLayout`, API Tooling) qué Layout usa realmente cada perfil cuyo nombre
contiene "y Nuevos" (el patrón real de los perfiles de venta de vehículos nuevos: "Asesor de Ventas BMW y Nuevos
V2", "Asesor de Ventas MINI y Nuevos V2", etc. — 14343 filas de `ProfileLayout` para esos perfiles, agrupadas por
objeto). Resultado, por objeto:

| Objeto | Layout(s) que usa Ventas Nuevas hoy |
|---|---|
| `Account` | `BMW Cuenta Empresarial`, `BMW Cuenta Empresarial V2` |
| `Product2` | `Articulos sin Editar`, `Artículos`, `Product Layout`, `Product Layout V1.2` (y `Formato Producto Altica`, que no forma parte del universo de 78) |
| `Quote` | `Mostrador y Taller` (Record Type Taller) y `Vehiculos Nuevos V1.2` (Record Type **Nuevos**) |
| `WorkOrder` | `Work Order Main V1.1` |
| `Opportunity` | Los 6 Layouts ya confirmados en B7-0 (`Opportunity-Autos V1.3`, `V1.3 - Inventario`, `V1.4`, `V1.4 Sin Botones`, `Opportunity-Opportunity Layout`, `Opportunity-Vehiculos Nuevos V1.1`) |

---

## 2. Cruce contra los 63 bloqueados — números reales

| Resultado | Cantidad |
|---|---:|
| Total `BLOQUEADO_ASIGNACION_FUNCIONAL` en B7-0 | 63 |
| **Coinciden exactamente con un Layout que ya usa Ventas Nuevas** → reclasificados | **8** |
| Siguen bloqueados, sin coincidencia con Ventas Nuevas | 55 |

**No se declaran los 63 resueltos. No se mantiene "63 pendientes" sin distinción — el criterio sí resuelve una
parte real y verificable, documentada abajo.**

### 2.1 Los 8 reclasificados

| Tipo | Componente | Objeto | Nueva clasificación |
|---|---|---|---|
| Layout | `Account-BMW Cuenta Empresarial` | Account | `RESUELTO_POR_EQUIVALENCIA_VENTAS_NUEVAS` |
| Layout | `Account-BMW Cuenta Empresarial V2` | Account | `RESUELTO_POR_EQUIVALENCIA_VENTAS_NUEVAS` |
| Layout | `Product2-Articulos sin Editar` | Product2 | `RESUELTO_POR_EQUIVALENCIA_VENTAS_NUEVAS` |
| Layout | `Product2-Artículos` | Product2 | `RESUELTO_POR_EQUIVALENCIA_VENTAS_NUEVAS` |
| Layout | `Product2-Product Layout` | Product2 | `RESUELTO_POR_EQUIVALENCIA_VENTAS_NUEVAS` |
| Layout | `Product2-Product Layout V1.2` | Product2 | `RESUELTO_POR_EQUIVALENCIA_VENTAS_NUEVAS` |
| Layout | `Quote-Mostrador y Taller` | Quote | `RESUELTO_POR_EQUIVALENCIA_VENTAS_NUEVAS` |
| Layout | `WorkOrder-Work Order Main V1.1` | WorkOrder | `RESUELTO_POR_EQUIVALENCIA_VENTAS_NUEVAS` |

**Por qué esto es distinto de los 10 originales de B7-0:** los 10 de B7-0 ya tienen una asignación `ProfileLayout`
explícita para el **Record Type** Omoda/Jaecoo (porque Opportunity y Lead sí tienen Record Type por marca). Estos
8, en cambio, son para objetos (`Account`, `Product2`, `Quote` genérico, `WorkOrder`) que **no tienen ningún Record
Type específico de marca** — su Layout se asigna únicamente por **Profile**, nunca por marca. Por eso, ninguno
necesita metadata nueva de Layout: en cuanto exista un perfil de venta Omoda/Jaecoo equivalente a "Asesor de
Ventas ... y Nuevos V2" (el trabajo de perfiles que Diego ya tiene en curso) y quede asignado a estos mismos 8
Layouts —igual que ya lo están los perfiles BMW/MINI/Kawasaki/Motorrad/Polaris "y Nuevos"—, Omoda y Jaecoo verán
exactamente la misma pantalla sin ningún cambio de código ni metadata de Layout. **No queda ningún desarrollo
pendiente de nuestro lado en estos 8; el único pendiente es la asignación de perfil, responsabilidad de Diego.**

**Nota especial — Quote:** el Record Type real de Quote que usan las ventas de autos nuevos es **`Nuevos`**, y su
Layout real es `Vehiculos Nuevos V1.2` — **no `Mostrador y Taller`** (que es el de Taller). `Vehiculos Nuevos V1.2`
no forma parte del universo de 78 elementos auditados en B7-0 (omisión del inventario original, no de este
documento). Se documenta como hallazgo, sin ampliar el alcance de este lote: `Quote-Vehiculos Nuevos V1.2` es el
Layout real y relevante de Ventas Nuevas para Quote, y **ya se confirmó funcionando con datos QA reales Omoda,
Jaecoo y BMW** (ver sección 4).

### 2.2 Los 55 que siguen bloqueados — desglose real, no "pendiente" genérico

| Subgrupo | Cantidad | Motivo real |
|---|---:|---|
| Sin ninguna asignación de perfil demostrada (huérfanos) | 32 (14 Layouts, 17 FlexiPages, 1 Quick Action) | Ningún perfil activo los usa hoy — ni Ventas Nuevas ni ningún otro. Son variantes numeradas sin uso (`Opportunity_Record_Page2`…`14`, `Quote_Record_Page1`,`3`,`4`,`5`, etc.) o Layouts sin asignación (`Product2-Vehiculos Softland System Admin V1.0`, `Product2-Vehiculos V1.2`…`V1.5`, etc.). No requieren decisión urgente — probablemente no se necesitan, pero no se descartan por inferencia. |
| Con asignación real, pero para Taller/Postventa, no para venta de autos nuevos | 14 (`Account-Taller`, `Account-RM Asesor Taller`, `Account-RM Asistente Taller - RO`, `Account-RM Lider Taller - RO`, `Account-RM Lider Taller`, `Account-BMW Cuenta Empresarial - RO`, `Account-Cuenta Empresarial Sin Botones`, `Account-Account Layout` genérico, `WorkOrder-RM Asesor Taller`, `WorkOrder-RM Lider Taller`, `WorkOrder-Work Order Layout`, `WorkOrder-Work Order Layout Copy`, `WorkOrder-Work Order Main`, `WorkOrder-Work Order Main Sin Botones`) | El criterio "Ventas Nuevas" no aplica — son para el flujo de Taller/Postventa (mecánicos, asistentes), un proceso de negocio distinto al de venta, sin definición de si Omoda/Jaecoo tendrán Taller propio todavía. |
| Con asignación real, para Opportunity/Product2/Quote de otros segmentos legacy | 5 (`Opportunity-Autos` genérico sin marca, `Opportunity-Motocicletas`, `Opportunity-Taller Autos`, `Product2-Vehiculos` genérico, `Quote_Record_Page6` de Taller) | Son para motos/taller/mostrador, no para el flujo de venta de autos nuevos que Omoda/Jaecoo replican. |
| Quick Actions que dependen de una plantilla/proceso propio, no de perfil | 3 (`BMW_EnviarCorreoPresupuesto`, `Quote.BMW_ImportarPlantilla`, `WorkOrder.BMW_ImportarPlantilla`) | Necesitan una plantilla de correo o de presupuesto propia de PEKING, aprobada por negocio; el criterio de perfil no resuelve una definición de contenido. |
| `Quote_Record_Page_VN` (FlexiPage, 316 asignaciones) | 1 | Mismo patrón de riesgo que `Opportunity_Record_Page_VN` (nombre `_VN`, cientos de asignaciones por Record Type "Nuevos") — no se auditó su drift en este lote (fuera del alcance de esta tarea), se deja como candidato a revisar en un lote posterior, sin tocar. |

**Total verificado:** 32 + 14 + 5 + 3 + 1 = 55, exacto, coincide con la resta 63 − 8 = 55.

---

## 3. `Opportunity_Record_Page_VN` — análisis con el criterio de Ventas Nuevas (sin desplegar)

**Mecanismo verificado:** la asignación de esta FlexiPage por aplicación es `APP_PROFILE_RECORDTYPE` — combina
**Aplicación + Record Type + Profile** (1200 filas ya demostradas en B7-0, ninguna para Omoda/Jaecoo). Es un
mecanismo distinto del drift ya documentado (que está *dentro* del XML de la FlexiPage, en las `visibilityRule` de
componentes internos como pestañas — ver `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md`).

**Qué metadata necesitaría cambiar para añadir Omoda/Jaecoo respetando la configuración de Ventas Nuevas:** agregar,
para cada aplicación relevante, una fila `APP_PROFILE_RECORDTYPE` nueva con `RecordType = Omoda` (y otra para
`Jaecoo`) apuntando a `Opportunity_Record_Page_VN`, usando el **mismo Profile** que ya usan las filas de `RecordType
= BMW` (paridad exacta con Ventas Nuevas, tal como pide Luis).

**Por qué esto sí depende del renombre de perfiles pendiente:** para escribir esa fila hace falta el nombre exacto
del Profile de destino. Ya está documentado (2026-08-07) que en Partial varios de esos nombres de Profile
cambiaron (`"Asesor de Ventas MINI y Nuevos V2"` → `"New Asesor Ventas"`, y equivalentes). No se sabe todavía:

1. Si ese renombre es el trabajo de perfiles de Diego ya en curso (y si es así, cuál es el nombre final y estable).
2. Si Diego piensa usar **un solo perfil unificado** ("New Asesor Ventas") para todas las marcas — incluyendo
   Omoda/Jaecoo — en cuyo lugar la fila nueva ni siquiera necesitaría distinguir por marca a nivel de Profile, solo
   por Record Type.

Preparar y desplegar la fila `APP_PROFILE_RECORDTYPE` con el nombre de Profile **viejo** (el de Git) arriesga
apuntar a un perfil que ya no existe con ese nombre en Partial, o duplicar trabajo que Diego hará de otra forma.
**No se desplegó nada.** Queda exactamente como:

`PENDIENTE_CONFIRMACION_DIEGO_RENOMBRE_PERFILES` — específicamente: *¿cuál es el nombre final y estable del Profile
de Ventas Nuevas que debo usar para la fila `APP_PROFILE_RECORDTYPE` de Omoda/Jaecoo en `Opportunity_Record_Page_VN`?*

Este punto **no detiene** el resto del lote (los 8 reclasificados de la sección 2.1 no dependen de esto).

---

---

## 4. Diagnóstico dirigido — Quick Action `Quote.BMW_Duplicar_Partidas_de_Presupuesto`

**Dónde está expuesta realmente** (confirmado en `MATRIZ_ASIGNACIONES_UI_S3_0_V2_20260806.csv`, filas UIV2-06335/06336):

- Layout `Quote-Quote Layout` (un Layout que **no forma parte del universo de 78 auditados** en B7-0).
- FlexiPage `Quote_Record_Page` (la App Default ya probada, sección 2 de B7-0).

**Qué Layout usa realmente Ventas Nuevas para Quote (verificado por `ProfileLayout`, ver sección 1):**
`Vehiculos Nuevos V1.2`, para el Record Type `Nuevos` — **no** `Quote Layout`.

**Confirmación con datos reales:** los 3 Quotes QA creados hoy (Omoda, Jaecoo y BMW de regresión) tomaron
automáticamente el Record Type `Nuevos` (`012PH00000FwdmjYAB`) al crearse sin especificar uno — el mismo Record
Type que usa cualquier venta de auto nuevo, de cualquier marca. Es exactamente por esto que la consulta técnica de
acciones disponibles (sección 7.5 de `RESULTADO_QA_PLACEHOLDERS_SPRINT3_20260810.md`) no encontró el botón: el
Quote real usa `Vehiculos Nuevos V1.2`, que nunca tuvo esta Quick Action agregada.

**Diagnóstico para negocio:**

> **En BMW ocurre:** un Presupuesto de auto nuevo BMW usa el Record Type `Nuevos` y el Layout `Vehiculos Nuevos
> V1.2`. Ese Layout **no** incluye el botón "Duplicar Partidas de Presupuesto".
>
> **En Omoda/Jaecoo ocurre:** exactamente lo mismo — mismo Record Type `Nuevos`, mismo Layout `Vehiculos Nuevos
> V1.2`, mismo resultado: el botón no aparece.
>
> **Qué falta:** nada específico de PEKING. El botón está agregado únicamente al Layout `Quote Layout` (uno
> distinto, sin uso demostrado por ningún perfil de venta activo) y a la página `Quote_Record_Page`. **No es una
> diferencia entre BMW y Omoda/Jaecoo — es una realidad ya existente del sistema, previa a este proyecto, para
> cualquier marca que venda autos nuevos.**

**Conclusión:** el criterio "reutilizar la configuración de Ventas Nuevas" **sí resuelve la duda**: confirma que no
hay regresión ni gap específico de Omoda/Jaecoo. La clasificación de B7-0 (`SIN_CAMBIO_REQUIERE_REGRESION`) se
mantiene, con esta precisión añadida: la regresión a validar visualmente es que el botón **tampoco** aparezca para
Omoda/Jaecoo cuando se abre un Quote de auto nuevo — lo cual ya sería el comportamiento correcto y esperado, igual
que BMW. No requiere ninguna decisión de Diego ni de negocio para cerrarse.

---

## 5. Approval Processes de descuento — actualización con la jerarquía de Diego

Luis confirmó: los 8 procesos de descuento de Omoda/Jaecoo deben usar la misma jerarquía/aprobadores que Diego está
preparando. Esto resuelve la duda funcional que quedaba abierta el 2026-08-07 (`CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md`,
hallazgo de jerarquía). Estado actualizado:

| Aspecto | Estado |
|---|---|
| Lógica funcional (qué jerarquía usar) | **RESUELTA** — la misma jerarquía real de Diego, no una jerarquía alterna para PEKING |
| Desarrollo nuevo específico de PEKING | **NO requerido** — los 8 procesos ya son neutrales a marca (confirmado por lectura completa de sus 8 `entryCriteria`, B9-AP0); no hay ninguna condición de Empresa/RecordType que cambiar |
| QA final (envío y aprobación reales) | **Pendiente únicamente de que Diego termine de implementar la jerarquía en Partial** — `PENDIENTE_IMPLEMENTACION_JERARQUIA_DIEGO`. No se creó ninguna jerarquía alternativa; no se fabricó ningún aprobador falso |

**Centro de costo:** sin cambio — se mantiene `QA_FUNCIONAL_COMPLETADO` con placeholders (entrada/submission a
`Pending` confirmada dos veces, 2026-08-07 y 2026-08-10). La aprobación *real* sigue necesitando centro de costo y
aprobador oficiales (Finanzas/negocio), sin relación con la jerarquía de Diego.

**Garantías:** sin cambio — siguen `BLOQUEADO_APROBADOR_NEGOCIO`/`BLOQUEADO_REGLA_NEGOCIO`, pendientes de definición
funcional. No llegó ninguna respuesta nueva sobre Garantía en este lote.

---

## Resumen de reclasificación

| Estado | B7-0 (2026-08-06/07) | B7-1 (2026-08-10, con Ventas Nuevas) |
|---|---:|---:|
| `SIN_CAMBIO_REQUIERE_REGRESION` | 10 | 10 (sin cambio) |
| `RESUELTO_POR_EQUIVALENCIA_VENTAS_NUEVAS` (nuevo) | 0 | **8** |
| `BLOQUEADO_ASIGNACION_FUNCIONAL` (genuino) | 63 | **55** |
| `DRIFT_REQUIERE_CONCILIACION` | 1 | 1 (sin cambio; análisis ampliado en sección 3) |
| `NO_APLICA` | 4 | 4 (sin cambio) |
| **Total** | **78** | **78** |
