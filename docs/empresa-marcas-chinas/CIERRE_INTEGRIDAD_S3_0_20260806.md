# Cierre de integridad S3-0.3 — 2026-08-06

**Estado:** `S3-0 — COMPLETADO_COMO_ANALISIS_CON_LIMITACIONES`

## Inconsistencias corregidas

1. Se agregó una única fila nominal para `Opportunity_Record_Page_VU`: `Aplica_PEKING = No`, `Exclusivo_Usados = Sí` y `Clasificacion = NO_APLICA`. No autoriza modificación y conserva regresión separada.
2. Se alinearon seis Approval Processes excluidos: uno de `AprobacionCentroCosto__c` y cinco de `Oportunidad_de_Financiamiento__c`. Permanecen `NO_REQUIERE_CAMBIO`, ahora con `Aplica_PEKING = No`, sin bloqueo ni decisión funcional de Sprint 3.
3. Las asignaciones ProfileLayout se reconstruyeron con una referencia estable por perfil. Los identificadores originales se usaron solo durante el cálculo y no se registran.

## Conteos finales

- Matriz V3: 225 filas, 224 nominales y un placeholder.
- Matriz V4: 226 filas, 225 nominales y un placeholder.
- FlexiPages nominales finales: 27.
- Approval Processes: 18; seis exclusiones corregidas.
- ProfileLayouts brutos seleccionados: 4735.
- Asignaciones ProfileLayout únicas demostrables: 4735.
- Filas con perfil resuelto: 4655.
- Filas con perfil no resuelto identificable: 80, correspondientes a 6 referencias estables.
- Nombres de perfil compartidos por IDs distintos: 1; sus 2 IDs se distinguen con `PROFILE_REFERENCE`.
- Duplicados reales eliminados: 0.
- Asignaciones distintas conservadas: 4735.

## Validaciones

- IDs de asignación y componentes API únicos.
- Combinación `Perfil_Referencia + RecordType + Layout` única para ProfileLayout.
- `Opportunity_Record_Page_VU` y `Quote_Record_Page_VU` aparecen una vez cada una.
- Ningún Approval Process `NO_REQUIERE_CAMBIO` conserva aplicabilidad indeterminada sin justificación.
- El placeholder Softland sigue fuera del conteo nominal.
- Ninguna FlexiPage del universo relevante falta sin motivo documentado.

## Alcance del cierre

El cierre es exclusivamente analítico. Persisten la identificación del mecanismo Softland, decisiones de negocio y validación funcional. No hay lote funcional listo, baseline autorizado ni permiso sobre `Opportunity_Record_Page_VN`. Salesforce no fue modificado; no hubo deploy, dry-run ni consulta a Producción.
