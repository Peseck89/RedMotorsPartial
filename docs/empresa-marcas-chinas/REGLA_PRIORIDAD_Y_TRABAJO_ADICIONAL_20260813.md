# Regla de prioridad operativa y de trabajo adicional — Empresa / Marcas Chinas

**Vigente desde:** 2026-08-13
**Aplica a:** todo agente de IA (Claude Code, Codex, Cowork, ChatGPT) y a cualquier persona que ejecute trabajo técnico sobre el proyecto Empresa / Marcas Chinas (PEKING), en cualquier Sprint o worktree.
**Relación con otras reglas:** esta regla no sustituye ni relaja [`REGLAS_ALCANCE_AUTORIZADO.md`](REGLAS_ALCANCE_AUTORIZADO.md). La autorización de alcance sigue siendo la puerta obligatoria de entrada para tocar cualquier componente. Esta regla define, además, el **orden de trabajo** y el **tratamiento económico** una vez que algo ya está autorizado técnicamente o se descubre durante el trabajo autorizado.

---

## 1. Orden de prioridad operativa (obligatorio)

El trabajo sobre este proyecto debe seguir, en este orden, las siguientes cuatro fases. No se salta una fase para adelantar la siguiente, salvo instrucción explícita de Luis o Diego.

### Fase 1 — Urgencias reales en clases y Flows

Se atienden primero las regresiones y defectos confirmados que **bloquean funcionalmente** un flujo de negocio vigente (creación de Work Order, Opportunity, Quote, Pricebook, catálogo Softland, etc.) para cualquiera de las tres compañías (Bavarian, Otobai, PEKING). Una urgencia real se confirma por evidencia directa (lectura de metadata, trazado de conectores, QA funcional), nunca por sospecha o por aparecer mencionada en un documento.

### Fase 2 — Lista actualizada de elementos trabajados

Antes de reportar o de abrir nuevo trabajo, se mantiene y se entrega una lista exacta y verificable (sin aproximaciones tipo "~20") de qué se tocó: Flows, clases Apex, triggers, metadata, datos de QA. Esta lista debe distinguir claramente qué fue **corregido**, qué fue **solo documentado sin cambio de código**, y qué **QA** se realizó y con qué resultado.

### Fase 3 — Hallazgos adicionales para aprobación

Todo hallazgo que no sea una urgencia bloqueante de Fase 1 (deuda técnica, mejoras, componentes "ya contemplan PEKING pero no son escalables", candidatos ambiguos, etc.) se documenta y se somete a aprobación explícita de Luis o Diego **antes** de convertirse en trabajo. No se ejecuta por iniciativa propia solo porque quedó identificado durante una auditoría o una reconciliación.

### Fase 4 — Reporte consolidado para María

El cierre de cada bloque de trabajo relevante debe quedar disponible en un reporte consolidado apto para entregar a María, con el estado técnico, el estado de QA, y — cuando aplique — la marca de trabajo adicional definida en la sección 2. Este reporte se construye a partir de las Fases 1-3, no las reemplaza.

---

## 2. Regla económica: autorización técnica ≠ cobertura económica

**La autorización técnica para trabajar en un componente no implica automáticamente que ese trabajo esté cubierto por el alcance u horas originalmente presupuestados.**

Estas son dos decisiones distintas, tomadas por personas distintas, en momentos distintos:

- **Autorización técnica:** decide *si* se puede tocar un componente (Luis o Diego, ver `REGLAS_ALCANCE_AUTORIZADO.md`).
- **Cobertura económica:** decide *si ese trabajo ya estaba pagado* dentro del alcance/horas contratados, o si constituye trabajo adicional a reconocer aparte. Esta decisión es exclusivamente de Luis (o de quien Luis delegue para temas de facturación), nunca del agente que ejecuta el trabajo.

### 2.1 Marca obligatoria

Toda actividad técnica que se identifique, se documente o se ejecute **fuera del alcance/horas originalmente contemplados** debe marcarse, de forma literal, en negrita y mayúsculas, exactamente así:

**TRABAJO EXTRA — NO CONTEMPLADO EN EL ALCANCE/HORAS ORIGINALES**

Esta marca:

- Se coloca junto a cada componente individual afectado, no como una nota genérica al final del documento.
- No se mezcla ni se diluye con deuda técnica ordinaria — es una etiqueta económica, no una etiqueta de calidad de código.
- No se aplica solo por relación funcional con un componente en alcance. La inclusión en alcance debe estar respaldada por documentación oficial explícita (lista nominal, presupuesto de horas por ítem) o por una autorización posterior explícita y documentada (commit, cierre de bloque, instrucción citada de Luis/Diego).
- No se aplica a un componente que **sí** recibió autorización posterior explícita, aunque no estuviera en el alcance inicial — en ese caso se indica que no estaba en el alcance inicial, pero **no** se etiqueta como trabajo extra, porque ya fue reconocido y autorizado como parte de un bloque posterior.
- No se aplica por default a hallazgos ambiguos (documentados como candidatos durante una investigación previa pero nunca seleccionados formalmente en el alcance pagado). Esos casos se marcan como **pendientes de confirmación**, no como trabajo extra, hasta que Luis resuelva si entran o no en el alcance ya cubierto.

### 2.2 Estándar de evidencia

Antes de marcar algo como trabajo extra, se debe poder responder, con evidencia verificable (no suposición):

1. ¿Aparece este componente en la lista nominal del alcance/horas oficial? (documento de alcance, cierre de Sprint con conteo nominal de componentes)
2. Si no aparece, ¿existe una autorización posterior explícita y documentada?
3. Si no aparece y no hay autorización posterior, ¿fue al menos documentado como candidato analizado durante la investigación original (ambiguo), o es genuinamente nuevo/desconocido hasta ahora?

Solo el caso 3 sin antecedente de análisis previo — o el caso de un candidato conocido con exclusión explícita y documentada, sobre el que ahora se pide trabajo real — se marca como trabajo extra genuino.

### 2.3 Precedente aplicado

Esta regla fue aplicada por primera vez el 2026-08-13 al reconciliar las ~64 clases Apex de la auditoría de Luis contra el alcance oficial de 33 clases + 3 triggers de Sprint 1. De ese ejercicio: 24 clases resultaron ya incluidas en el alcance original, 9 tenían autorización posterior explícita (no se marcaron como extra), 21 quedaron como ambiguas pendientes de confirmación, y únicamente 2 (`ServicioCitas`, `ServicioCitasFieldService`) cumplieron el estándar de evidencia para marcarse como **TRABAJO EXTRA — NO CONTEMPLADO EN EL ALCANCE/HORAS ORIGINALES**, ambas con una exclusión de negocio documentada en su momento, no como hallazgo invisible. Ese análisis completo quedó entregado en conversación de trabajo (no en un archivo del repositorio); esta regla documenta el criterio para que se aplique de forma consistente en adelante, no repite ese análisis línea por línea.

---

## 3. Resumen operativo

1. Urgencias reales primero (Fase 1).
2. Lista exacta y verificable de lo trabajado (Fase 2).
3. Hallazgos adicionales van a aprobación, no a ejecución directa (Fase 3).
4. Reporte consolidado para María al cierre de cada bloque relevante (Fase 4).
5. Autorización técnica y cobertura económica son decisiones distintas; la segunda es exclusiva de Luis.
6. Todo lo fuera de alcance/horas se marca con la etiqueta literal en negrita/mayúsculas definida en la sección 2.1 — sin excepción y sin diluirla en deuda técnica genérica.

Ver también [`REGLAS_ALCANCE_AUTORIZADO.md`](REGLAS_ALCANCE_AUTORIZADO.md) para la puerta de autorización técnica, y [`RECONCILIACION_AUDITORIA_LUIS_20260813.md`](RECONCILIACION_AUDITORIA_LUIS_20260813.md) para el precedente técnico completo citado en la sección 2.3.
