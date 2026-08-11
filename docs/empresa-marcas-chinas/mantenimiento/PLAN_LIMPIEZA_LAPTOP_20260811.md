# Plan propuesto de limpieza de la laptop — 2026-08-11

## Estado

**PROPUESTA NO EJECUTADA.** Este documento no autoriza borrados, movimientos, renombrados, compresión, despliegues, cambios en Salesforce ni modificaciones de configuración.

Objetivo: recuperar espacio con riesgo controlado, preservando primero toda información única y manteniendo intactos Google Drive, OneDrive, credenciales, perfiles, configuración activa y el entorno autoritativo de Sprint 4.

## Condiciones previas obligatorias

Antes de iniciar cualquier fase futura:

1. Obtener aprobación explícita del lote exacto de rutas.
2. Repetir tamaño, hash y fecha de cada candidato.
3. Repetir estado, worktrees y verificación remota de todos los repositorios afectados.
4. Confirmar que `RedMotors-Sprint2-Flows-Components` sigue siendo el entorno autoritativo y está limpio.
5. Confirmar que el alias de trabajo sigue siendo `RedMotorsSandbox`; no usar Producción.
6. Preservar primero `INFORMACION_UNICA_NO_RESPALDADA`.
7. No tocar `G:\Mi unidad`, OneDrive, `.sf`, `.sfdx`, `.ssh`, `.env`, certificados, perfiles de navegador ni `AppData`.
8. No ejecutar limpieza masiva, vaciado de Papelera ni operaciones destructivas sobre repositorios.

## FASE A — Riesgo casi cero

### A1. ZIP pequeños de auditoría

Alcance propuesto: cuatro ZIP que son copias exactas, entrada por entrada, de carpetas homónimas.

- Ahorro máximo: ≈ 0.515 MiB.
- Requisito: decidir si la carpeta o el ZIP será la copia autoritativa.
- Acción futura: retirar solo la copia redundante aprobada.
- Validación posterior: confirmar que la copia conservada abre y mantiene los hashes registrados.

### A2. Instaladores y `node_modules`

No se encontraron instaladores EXE/MSI ni carpetas `node_modules`. No hay acción.

### A3. Cachés y temporales visibles

No borrar automáticamente.

- `.cache\codex-runtimes`: 1,050.18 MiB.
- `.codex\.tmp`: 130.45 MiB.

Aunque parecen reconstruibles o temporales, pueden estar en uso. Una fase futura requeriría cerrar las aplicaciones relacionadas, validar su función y aprobar rutas concretas. `.vscode\extensions`, plugins, sesiones y datos de aplicación quedan fuera de limpieza automática.

### A4. Duplicados exactos en Drive

Solo después de aprobación explícita:

- `Downloads\Evidencia_Sprint2_Empresa_Pricebook_Corregido.docx`: 1.098 MiB.
- Evidencias locales VN-RQ106: 856.91 MiB.

Los hashes contra Drive ya coinciden. La copia en Drive no se toca. Para VN-RQ106, validar nuevamente los 24 pares inmediatamente antes de cualquier retiro local.

La evidencia local de Marcas Chinas Sprint 3 también está respaldada, pero se conserva durante Sprint 4 por conveniencia operativa.

**Ahorro previsto de Fase A sin cachés:** ≈ 858.52 MiB.

## FASE B — Proyectos respaldados

### B1. Dieciocho worktrees históricos RedMotors

Estado actual: limpios, cada HEAD exacto en remoto, sin archivos no rastreados. Tamaño conjunto: 738.1 MiB.

Procedimiento futuro propuesto:

1. Revalidar estado limpio y HEAD remoto exacto de cada worktree.
2. Confirmar que ninguno es necesario para Sprint 4.
3. Retirar los worktrees mediante el mecanismo controlado del repositorio común; no borrar carpetas directamente.
4. Mantener las ramas remotas.
5. Confirmar que el worktree activo y la base común siguen operativos.

Excluir expresamente:

- `RedMotors-Sprint2-Flows-Components` — activo.
- `RedMotors-Sprint1-Next8-Reconcile` — contiene documento no rastreado.
- `RedMotorsPartial-Sandbox` — contiene modificación local, `stash` único y la base común.
- `RedMotors-Empresa-Marcas-Chinas` — enlace roto y respaldo no demostrable.

### B2. VN-RQ106

VN-RQ106 no puede eliminarse por completo en su estado actual.

Orden obligatorio:

1. Inventariar el `stash` del 2026-06-16.
2. Respaldar de forma autorizada los documentos de contexto, borradores, dos hojas QA, respaldos técnicos y registros únicos.
3. Determinar si la modificación de `jsconfig.json` es útil o descartable; no revertirla sin autorización.
4. Confirmar que todos los entregables versionados siguen en remoto.
5. Repetir hashes de las evidencias locales contra Drive.
6. Retirar, si se aprueba, únicamente la carpeta local de evidencias.
7. Reorganizar la base común de worktrees antes de considerar retirar `RedMotorsPartial-Sandbox`.

El código y la documentación versionada son reconstruibles; el `stash` y el cambio local no lo son todavía.

**Ahorro previsto de Fase B inicialmente autorizable:** 738.1 MiB. El repositorio principal de VN-RQ106 no se suma.

## FASE C — Revisión humana

### C1. Recuperación de archivos

`Documents\Archivos perdidos (65660)` ocupa ≈ 1.08 GiB.

- Los 41 ZIP recuperados (992.38 MiB) son inválidos o incompletos.
- Hay 1,840 JPG recuperados; se detectaron ocho pares exactos, pero puede existir contenido único.
- No borrar por extensión, numeración ni fecha.

Decisión requerida: confirmar el origen de la recuperación, si ya fue revisada y si existe respaldo externo. Solo después podría prepararse un lote específico.

### C2. Worktree roto

`RedMotors-Empresa-Marcas-Chinas` ocupa 44.1 MiB y apunta a una ruta Git inexistente. Tiene 43 rutas ausentes del activo, principalmente `describe-*.json` y `tmp-partial`.

Propuesta:

1. Comparar esas 43 rutas con ramas remotas o respaldos autorizados.
2. Conservar únicamente cualquier artefacto realmente único.
3. Confirmar que el resto corresponde a una base antigua.
4. Solicitar aprobación separada antes de retirar la carpeta.

### C3. Documento no rastreado

Preservar y decidir el destino de:

`RedMotors-Sprint1-Next8-Reconcile\docs\empresa-marcas-chinas\CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`.

Hasta entonces, no tocar ese worktree.

### C4. Auditorías externas al repositorio

`Documents\Auditorias-RedMotors-PEKING` ocupa 5.03 MiB y contiene inventarios y matrices históricas. Propuesta: conservar como respaldo o consolidar solo después de confirmar que el índice maestro del repositorio cubre la información necesaria. No asumir que Etapa 1, 2 y 3 son duplicadas.

### C5. Archivo único de Pictures

Respaldar el icono RedMotors antes de cualquier limpieza de Pictures; no se encontró copia exacta en repositorios.

## FASE D — Optimización final

Después de A, B y C:

1. Repetir inventario de tamaños y ranking.
2. Confirmar espacio libre real del volumen.
3. Verificar que el worktree activo abre, mantiene su rama y sigue limpio.
4. Verificar que todas las evidencias necesarias para Sprint 4 siguen accesibles en Drive.
5. Revisar extensiones del editor desde su administrador y desinstalar únicamente versiones no usadas, si se aprueba.
6. Actualizar auditoría y matriz con decisiones ejecutadas y evidencia de validación.
7. Mantener la Papelera sin vaciar hasta una aprobación posterior independiente.

## Orden de aprobación sugerido

| Lote | Contenido | Ahorro aprox. | Riesgo |
|---|---|---:|---|
| A-1 | DOCX de Downloads + ZIP exactos pequeños | 1.61 MiB | Muy bajo |
| A-2 | Evidencias locales VN-RQ106 con hash en Drive | 856.91 MiB | Bajo, con verificación previa |
| B-1 | 18 worktrees históricos respaldados | 738.1 MiB | Bajo/medio por estructura compartida |
| C-1 | Cachés visibles | hasta 1.15 GiB | Medio; depende de uso activo |
| C-2 | Recuperación de archivos | hasta 1.08 GiB | Alto |
| C-3 | Worktree roto | hasta 44.1 MiB | Alto |

## Resultado esperado

- Recuperación segura total identificada: ≈ 1.59 GiB. La primera ejecución propuesta, manteniendo los videos locales de Sprint 3 durante Sprint 4, sería ≈ 1.56 GiB.
- Recuperación adicional posible tras revisión: hasta ≈ 2.42 GiB, no garantizada.
- Google Drive, OneDrive, Sprint 4, información única y configuraciones activas permanecen intactos.

## Confirmación

Ninguna fase de este plan fue ejecutada durante la auditoría.
