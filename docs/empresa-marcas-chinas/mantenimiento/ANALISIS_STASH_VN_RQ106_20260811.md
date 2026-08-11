# Análisis interno del stash VN-RQ106 — 2026-08-11

## Estado y alcance

Análisis de solo lectura de `stash@{0}` en `RedMotorsPartial-Sandbox`. No es documentación oficial de entrega. No se aplicó, restauró, eliminó ni modificó el stash; tampoco se modificaron archivos del repositorio, Salesforce o Drive.

El stash fue creado el 2026-06-16 como respaldo de archivos no rastreados. No contiene cambios sobre archivos que ya estuvieran rastreados. La rama local de VN-RQ106 coincide directamente con su rama remota actual.

## Resultado ejecutivo

| Indicador | Resultado |
|---|---:|
| Archivos | 69 |
| Tamaño total | 2,538,741 bytes / 2.4211 MiB |
| Conservar fuera de Git | 4 archivos / 0.2721 MiB |
| Conservar y versionar sin depuración | 0 |
| Potencialmente descartables después de confirmación | 57 archivos / 1.3788 MiB |
| Requieren revisión humana | 8 archivos / 0.7703 MiB |

## Inventario por categoría

| Categoría | Archivos | Tamaño aproximado |
|---|---:|---:|
| `LOG` | 46 | 1,282.08 KiB |
| `PATCH_DIFF` | 11 | 602.76 KiB |
| `QA` | 2 | 439.02 KiB |
| `DOCUMENTACION` | 2 | 52.38 KiB |
| `BACKUP_TECNICO` | 3 | 41.40 KiB |
| `CODIGO` | 2 | 35.95 KiB |
| `CONTEXTO` | 2 | 21.71 KiB |
| `CONFIGURACION` | 1 | 3.94 KiB |

La matriz CSV asociada contiene los 69 archivos, ruta, tipo, tamaño, categoría, utilidad, subproyecto, clasificación, justificación, equivalencia y riesgo sensible.

## A. Archivos que sí debemos conservar

### 1. `docs/VN-RQ106/CONTEXTO_CODEX_VN_RQ106.md`

- Clasificación: `CONSERVAR_FUERA_DE_GIT`.
- Valor: contexto operativo compacto de pantallas, notificaciones, permisos, QA y pendientes.
- Comparación: aproximadamente 75.5% de su vocabulario está cubierto por la documentación actual, pero no existe un archivo equivalente completo en la rama.
- Riesgo: contiene correo, identificadores y referencias internas. No debe versionarse crudo; conviene extraer después un resumen sanitizado.

### 2. `docs/VN-RQ106/VN-RQ106-Entrega-Tecnica-Final.docx`

- Clasificación: `CONSERVAR_FUERA_DE_GIT`.
- Valor: no es la misma plantilla que el entregable oficial. Es un informe interno de 230 párrafos y 8 tablas sobre alcance, hotfixes, QA y pendientes.
- Comparación: sus temas están mayormente reflejados en los Markdown actuales, pero no existe un equivalente binario ni textual completo.
- Riesgo: contiene correo, identificadores y términos potencialmente sensibles. Debe preservarse fuera de Git hasta una revisión/redacción.

### 3. `docs/VN-RQ106/qa/Template_QA_Equipo-RedMotors_VN-RQ106_LOCAL_REVIEW_20260613.xlsx`

- Clasificación: `CONSERVAR_FUERA_DE_GIT`.
- Valor: 12 hojas, 3,643 celdas no vacías y anotaciones locales distribuidas en checklist, Ready for QA, casos de prueba, sign-off, regresión y UAT.
- Comparación: Drive cubre aproximadamente 90.7% de sus valores, pero quedan múltiples celdas locales no cubiertas en nueve hojas.
- Riesgo: contiene identificadores, URLs y metadatos de autor. No debe subirse a Git.

### 4. `docs/VN-RQ106/redm-mail-template.html`

- Clasificación: `CONSERVAR_FUERA_DE_GIT`.
- Valor: artefacto HTML único relacionado con notificaciones; no se encontró equivalente por nombre en la rama actual.
- Riesgo: contiene identificadores y URLs. Debe revisarse y sanitizarse antes de decidir si se convierte en metadata versionable o se conserva solo como referencia.

## B. Archivos que podemos descartar después

### Superados por la versión actual — 10 archivos

- `AGENTS.md`: configuración/contexto antiguo; el repositorio activo tiene reglas actuales autoritativas.
- `VN-RQ106 - Entrega Técnica Salesforce - BORRADOR.docx`: sus 16 secciones coinciden con la estructura del entregable oficial actual, que es más reciente y está respaldado en remoto y Drive.
- `SolicitudAprobacionTesoreria_SANDBOX.cls`: 98.03% similar a la clase actual; es una instantánea anterior.
- `VN_RQ106_Notificaciones_Anticipo_before_luis_emails.flow-meta.xml`: respaldo explícitamente anterior a los cambios de correos; el flow actual está versionado.
- Seis parches: todos apuntan a rutas presentes en HEAD y entre 94.74% y 100% de sus líneas agregadas ya están en los archivos actuales. Dos parches son duplicados exactos entre sí.

### Reconstruibles — 6 archivos

- Cinco TXT de estado, listas de diferencias o estadísticas.
- `validate_softland_endpoint.apex`, script de validación de 71 bytes. No debe versionarse ni ejecutarse como parte de esta preservación.

### Logs sin señal de error — 41 archivos

Son depuración histórica. Uno está vacío; los demás no muestran excepciones o fallos relevantes con los criterios de esta auditoría. Pueden descartarse después de confirmación. No deben subirse a Git.

## C. Archivos que requieren decisión humana

### `docs/VN-RQ106/CONTINUAR_MANANA_20260611.md`

Documento de continuidad con validaciones, despliegues históricos, datos de prueba y pasos de retoma. Aproximadamente 82% de su vocabulario está cubierto por documentación actual. Revisar si algún dato histórico no quedó consolidado; después podría descartarse o resumirse de forma sanitizada.

### `Template_QA_Equipo-RedMotors_VN-RQ106_CL_ONLY_REVIEW_20260613.xlsx`

Tiene 12 hojas y 3,329 celdas no vacías. Frente a la versión `(2)` de Drive, solo una celda difiere; los valores tienen 99.83% de cobertura mutua. Confirmar esa única diferencia y, si no es relevante, clasificar como superado. Contiene identificadores y URLs; no subir a Git.

### `SolicitudAprobacionTesoreria_LOCAL_MOCK_BACKUP.cls`

Es una variante local/mock cuya similitud con la clase actual es de 14.87%. Constituye código único, pero no se demostró que sea necesario para el producto actual. Por tratarse de un componente sensible, revisar sin publicar ni mezclar con la clase vigente.

### Cinco logs con señal de error

- `tmp/rafael_anticipo_error.log`
- `tmp/vn_rq106_diego_logs/vn_rq106_diego_07LNq00000cKLXOMA4.log`
- `tmp/vn_rq106_diego_logs/vn_rq106_diego_07LNq00000cKR7tMAG.log`
- `tmp/vn_rq106_diego_logs/vn_rq106_diego_07LNq00000cLNeuMAG.log`
- `tmp/vn_rq106_diego_logs/vn_rq106_diego_07LNq00000cLSbJMAW.log`

Conservar temporalmente solo para extraer un resumen sanitizado de causa, resultado y referencia de evidencia. Después, el raw puede descartarse con aprobación.

## DOCX

### Borrador de entrega técnica

- 36,490 bytes, 453 párrafos, 14 tablas.
- Misma estructura de 16 secciones que el entregable oficial actual.
- El DOCX oficial actual es posterior, válido, está versionado y tiene copia exacta en Drive.
- Clasificación: `SUPERADO_POR_VERSION_ACTUAL`.
- La copia de borrador localizada en Drive no pudo validarse como ZIP/DOCX completo; no se utilizó como prueba de equivalencia.

### Informe interno llamado “Final”

- 17,143 bytes, 230 párrafos, 8 tablas.
- Contiene una narrativa diferente sobre hotfixes y QA.
- Los temas principales aparecen en documentos Markdown actuales, pero el documento contiene detalles internos y sensibles.
- Clasificación: `CONSERVAR_FUERA_DE_GIT` hasta revisión/redacción.

## XLSX

### CL_ONLY_REVIEW

- 223,582 bytes; 12 hojas; 3,329 celdas no vacías; sin fórmulas.
- Solo una celda difiere frente a la versión `(2)` de Drive.
- Clasificación: `REQUIERE_REVISION`; probablemente superado después de confirmar esa celda.

### LOCAL_REVIEW

- 225,976 bytes; 12 hojas; 3,643 celdas no vacías; sin fórmulas.
- Contiene numerosas anotaciones locales no presentes en Drive.
- Clasificación: `CONSERVAR_FUERA_DE_GIT`.

Ambos libros contienen identificadores, URLs y metadatos de autor. No deben versionarse.

## Código y respaldos técnicos

| Archivo | Comparación | Decisión |
|---|---|---|
| `redm-mail-template.html` | Sin equivalente por nombre; artefacto único | Conservar fuera de Git y sanitizar |
| `SolicitudAprobacionTesoreria_LOCAL_MOCK_BACKUP.cls` | Variante única; 14.87% similar al actual | Revisión humana |
| `SolicitudAprobacionTesoreria_SANDBOX.cls` | 98.03% similar al actual | Superado |
| `VN_RQ106_Notificaciones_Anticipo_before_luis_emails.flow-meta.xml` | Instantánea anterior al flow actual | Superado |
| `validate_softland_endpoint.apex` | Script mínimo y reconstruible | No versionar; descartar después de confirmar |

Conclusión sobre código: sí existen dos artefactos técnicos únicos —el HTML y la variante local/mock—, pero no se identificó un cambio único que deba incorporarse directamente al código actual. Ambos requieren sanitización o decisión humana.

## Parches y TXT

- `backup_vn_rq106_20260610.patch`: 14/14 rutas presentes; 98.08% de líneas agregadas presentes en HEAD.
- `diff_before_luis_emails.patch` y `diff_fixes_before_luis_emails.patch`: duplicados exactos; 100% de líneas agregadas presentes.
- `diff_docs_flow_pause_20260612.patch`: 94.74% presente; documentación posterior cubre el cierre.
- `diff_hotfixes_and_dotscontacto_before_luis_flow.patch`: 99.94% presente.
- `full_diff_pause_20260612.patch`: 97.78% presente.
- Los cinco TXT son estados o estadísticas reconstruibles.

No se recomienda conservar estos archivos como respaldo primario cuando la rama remota ya contiene el estado consolidado.

## Logs

| Indicador | Resultado |
|---|---:|
| Logs | 46 |
| Tamaño | 1,312,855 bytes / 1.2520 MiB |
| Con señal de error | 5 |
| Sin señal de error | 41 |
| Vacíos | 1 |
| Con correos | 44 |
| Con identificadores | 45 |
| Con URLs | 29 |
| Con términos potencialmente secretos | 3 |
| Duplicados exactos | 0 |

Los logs no constituyen por sí solos evidencia oficial de cierre y no deben subirse masivamente a Git. La mayor parte es prescindible. Para los cinco logs con error, conservar temporalmente el raw, producir un resumen sanitizado y confirmar que el resultado funcional ya aparece en la documentación de cierre. Luego también podrían descartarse.

## Propuesta mínima de preservación

### Conservar ahora fuera de Git

1. Contexto operativo.
2. Informe interno DOCX llamado “Final”.
3. XLSX `LOCAL_REVIEW`.
4. Plantilla HTML de correo.

### Revisar antes de decidir

1. Documento de continuidad.
2. XLSX `CL_ONLY_REVIEW` y su única celda distinta.
3. Clase local/mock.
4. Cinco logs con error para generar un resumen sanitizado.

### Descartar después de confirmación

1. Borrador DOCX superado.
2. Configuración antigua.
3. Clase SANDBOX y flow anterior.
4. Seis parches y cinco TXT.
5. Script Apex reconstruible.
6. Cuarenta y un logs sin error.

## Qué conviene versionar

Ninguno de los 69 archivos debe versionarse crudo. Después de revisión podrían versionarse únicamente:

- Un resumen sanitizado de hechos todavía vigentes del contexto y continuidad.
- La plantilla de correo, solo si sigue siendo funcionalmente necesaria y se convierte a una forma adecuada sin identificadores, URLs sensibles ni datos de usuarios.
- Un resumen sanitizado de los cinco errores, si aporta trazabilidad no cubierta por la documentación actual.

## Qué debe quedar fuera de Git

- XLSX de QA.
- DOCX internos con datos de QA o integración.
- Logs raw.
- Scripts de validación de endpoints.
- Backups, parches y snapshots temporales.
- Cualquier archivo con correos, identificadores, URLs internas o términos potencialmente secretos.

## Confirmación

No se aplicó, restauró, eliminó ni modificó `stash@{0}`. No se modificó el repositorio base, Drive, Salesforce ni ningún archivo existente. Solo se creó esta documentación y su matriz asociada en la carpeta de mantenimiento autorizada.
