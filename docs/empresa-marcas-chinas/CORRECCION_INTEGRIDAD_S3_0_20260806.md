# Corrección de integridad S3-0.2 — 2026-08-06

**Estado:** `S3-0 — EN_PROGRESO_CON_BRECHAS_DE_COBERTURA`

## Resultado

- Universo histórico conservado: 563 filas; universo V2: 563 componentes semánticamente únicos.
- Inclusión: 195 incluidos y 368 excluidos, sin motivos contradictorios.
- Existencia Git: 2 `SI`, 560 `NO`, 0 `NO_VERIFICADO` y 1 `NO_VERSIONABLE`.
- Matriz nominal anterior: 226 filas (225 nominales y un placeholder).
- Matriz V3: 225 filas (224 nominales y un placeholder).
- Duplicados semánticos fusionados: 1 (`Product2-Product Layout V1.1` / ruta codificada `Product2-Product Layout V1%2E1`).
- Filas normalizadas o reclasificadas: 17 en la matriz V3; el universo normalizó todos los nombres de Layout con `%2E`.

## Correcciones principales

1. `Encontrado_Git` se recalculó en las 563 filas por ruta/tipo. `Opportunity_Record_Page_VN` figura `SI`; los datos o placeholders no versionables se distinguen.
2. Se eliminaron 175 contradicciones entre inclusión y motivo de exclusión.
3. Se normalizaron 19 identificadores de Layout codificados con `%2E` y se conservó su ruta original en Notas.
4. El fullName autoritativo de la acción global es `BMW_EnviarCorreoPresupuesto`, según List Metadata y archivo recuperado; `Global.BMW_EnviarCorreoPresupuesto` queda como alias histórico.
5. `RM_Config.Flag_OPI` y `RM_Config.PAGE_SIZE_VN` quedan `PENDIENTE_EVIDENCIA` porque no se identificó consumidor en el alcance.
6. Usados conserva `NO_APLICA` para adaptación PEKING y registra `REQUIERE_REGRESION` como obligación separada.
7. El placeholder Softland continúa `PENDIENTE_IDENTIFICAR_COMPONENTE_AUTORITATIVO` y fuera del conteo nominal.

## Evidencia de asignaciones

- Layouts: 4735 combinaciones relevantes Profile–Record Type–Layout obtenidas por `ProfileLayout`; 6 Layouts tienen relación aparente con Record Types Omoda/Jaecoo/PEKING y 14 Layouts seleccionados quedaron registrados sin asignación demostrada.
- FlexiPages: 1580 activaciones declaradas y 17 páginas sin asignación demostrada. Se separaron aplicación, perfil, Record Type y form factor.
- Quick Actions: 10 exposiciones declaradas y una acción sin exposición demostrada en el universo revisado.

## Limitaciones

Una asignación metadata no demuestra acceso efectivo, uso real ni resultado funcional. No se identificó el mecanismo Softland. Las relaciones marcadas PEKING se basan en nombres de Record Type Omoda/Jaecoo/PEKING y requieren validación funcional. No se modificó Salesforce, no hubo deploy/dry-run y no se consultó Producción.
