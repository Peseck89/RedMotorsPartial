# Índice documentación VN-RQ106

Este índice organiza la documentación local del proyecto VN-RQ106 y define qué archivo usar como fuente principal, borrador interno o archivo temporal.

| Archivo | Tipo | Uso | Estado | ¿Fuente principal? | ¿Commit recomendado? | Observaciones |
|---|---|---|---|---|---|---|
| `ENTREGA_TECNICA_OFICIAL.md` | Documentación oficial local | Fuente principal para entrega técnica | Borrador actualizado, pendiente cierre Helios/QA | Sí | Sí | Usar como base técnica oficial local. Mantener QA y Producción con estado real. |
| `PENDIENTES_Y_ESTADO_ACTUAL.md` | Control interno | Seguimiento de pendientes, bloqueos y estado actual | Actualizado | Sí para seguimiento interno | Sí | Documento operativo de continuidad y control. |
| `ESTADO_QA_Y_EVIDENCIAS_20260611.md` | QA/evidencias | Estado de evidencias y bloqueo actual | Actualizado | Sí para QA | Sí | Resume qué puede avanzar y qué sigue bloqueado. |
| `QA_PEDRO_BMW_CASOS_C-L.md` | Guía QA Pedro | Instrucciones para evidencia básica/no destructiva y casos bloqueados | Actualizado | Sí para Pedro cuando aplique | Sí | No liberar flujo completo hasta resolver bloqueo Helios/Softland. |
| `PLAN_QA_EXCEL_20260611.md` | Plan QA Excel | Guía para actualizar Excel cuando Helios se desbloquee | Actualizado | Sí para Excel | Sí | No modifica Excel; sirve como plan de carga futura. |
| `IMPLEMENTATION_LOG.md` | Bitácora técnica | Trazabilidad de implementación | Histórico/soporte | No | Revisar/sí si no contiene datos sensibles | Revisar antes de versionar. |
| `CONTEXTO_CODEX_VN_RQ106.md` | Contexto operativo interno | Continuidad técnica | Interno | No | Revisar; si menciona herramientas internas, decidir si se excluye | No usar como documentación oficial externa. |
| `CONTINUAR_MANANA_20260611.md` | Continuidad operativa | Retomar trabajo | Interno | No | Revisar | Puede quedar obsoleto después del cierre. |
| `VN-RQ106_TABLAS_PARA_GOOGLE_DOC.md` | Contenido para documentación formal | Copiar tablas a Google Doc | Soporte | No | Sí/revisar | Revisar vigencia antes de usar porque la documentación oficial local fue actualizada después. |
| `VN-RQ106 - Entrega Técnica Salesforce - BORRADOR.docx` | Binario Word | Borrador local | Revisar | No | No por ahora, salvo decisión explícita | Evitar versionar binarios si no es necesario. |
| `backup_vn_rq106_20260610.patch` | Backup técnico | Respaldo | Temporal | No | No por ahora; puede contener ruido o código sensible | Revisar antes de conservar o versionar. |

## Fuente principal recomendada

- Oficial técnico: `ENTREGA_TECNICA_OFICIAL.md`.
- Estado actual: `PENDIENTES_Y_ESTADO_ACTUAL.md`.
- QA/evidencia: `ESTADO_QA_Y_EVIDENCIAS_20260611.md`.
- Plan Excel: `PLAN_QA_EXCEL_20260611.md`.

## Archivos que no deberían incluirse en commit por ahora

- `.docx`.
- `.patch`.
- Cualquier backup temporal.
- Archivos que mencionen herramientas internas si se decide mantener documentación oficial limpia.

## Pendiente antes de cierre final

- Confirmar respuesta Luis/Diego.
- Reintentar Helios/Softland.
- Completar QA funcional.
- Actualizar Excel.
- Subir evidencia oficial.
- Definir qué documentos se versionan.
