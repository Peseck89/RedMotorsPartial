# Contradicciones conocidas y gates

## 1. Inventario Codex 130 vs Plan conjunto

Codex propuso 130 componentes de Marcas Chinas. El Plan conjunto enumera además dependencias de Jerarquización y componentes compartidos, incluyendo 60 Validation Rules, 33 FlexiPages, 4 triggers, 8 LWC, 6 RT Lead/Opp/Order y otros grupos.

**Estado:** no reconciliado. No usar 130 como total definitivo hasta comparar con Partial live + deployment de Diego + Plan oficial.

## 2. `Opportunity_Record_Page_VN`

Codex la excluyó por decisión pendiente. El Plan conjunto la declara dependencia dura porque contiene criterios del Proyecto A y secciones OMODA/JAECOO del Proyecto B.

**Gate:** reconciliar versión final de Partial y asignaciones/perfiles. No excluir automáticamente.

## 3. Datos temporales

Codex propuso no llevar bodega/territorio/productos/precios QA. La reunión indicó que el go-live saldrá con supuestos y que, si falta bodega o Service Territory definitivo, se creará uno de ejemplo; Luis posteriormente indicó que la data puede crearse por Codex si está bien documentada.

**Gate:** definir valores exactos autorizados en una matriz y preparar script idempotente. No copiar ciegamente cualquier QA ni bloquear por principio todo dato provisional.

## 4. RQ329

Codex lo detectó ausente en Producción y propuso release separado. En Partial RQ329 fue corregido y es dependencia del E2E QLI.

**Gate:** determinar quién/qué release lo lleva y el orden frente al pase conjunto. No asumir inclusión ni exclusión.

## 5. 27 fallos de tests

El run Codex fue 276/303 PASS, 27 FAIL. La lista debe cruzarse con las clases reales del deployment conjunto. Algunos fallos observados parecen de setup/datos restringidos y no prueban por sí solos que todo el go-live esté bloqueado.

**Gate:** clasificación test-por-test y Validate Only con lista correcta. No declarar GO hasta verde; no declarar NO-GO definitivo solo por el run amplio anterior.

## 6. QA workbook vs reunión

El workbook contiene casos generados con apoyo de IA y puede incluir pasos que no calzan exactamente con la instancia. La reunión indicó usar la intención del caso y adaptarse al comportamiento real, y señaló Service Community/citas/WhatsApp fuera de esta etapa.

**Gate:** ante paso raro, conservar objetivo del caso y documentar adaptación; no ampliar alcance automáticamente.
