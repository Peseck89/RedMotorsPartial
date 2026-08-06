# Auditoría documental — Empresa / Marcas Chinas / PEKING

## Propósito de esta carpeta

Esta carpeta contiene el **índice versionado** que resume, de forma permanente y dentro del control
de versiones de este repositorio, el estado de vigencia de la documentación del proyecto Empresa /
Marcas Chinas / PEKING: qué documento es la fuente autoritativa de cada tema, cuáles fueron
sustituidos, y dónde encontrar la evidencia completa que respalda cada determinación.

## Diferencia entre este índice versionado y las auditorías externas

Este índice **no es** una auditoría completa ni un inventario exhaustivo. Es un resumen concentrado,
pensado para que cualquier agente de IA o colaborador entienda el estado vigente sin necesidad de
abrir inventarios de más de mil filas.

La auditoría documental completa (inventario archivo por archivo, mapas de duplicados, matrices de
clasificación completas, comparación de cada worktree contra el repositorio autoritativo) vive
**fuera de este repositorio**, en:

```
C:\Users\dokur\Documents\Auditorias-RedMotors-PEKING\Etapa1-Inventario-20260805-193325\
C:\Users\dokur\Documents\Auditorias-RedMotors-PEKING\Etapa2-Revision-Clasificacion-20260805-200727\
C:\Users\dokur\Documents\Auditorias-RedMotors-PEKING\Etapa3-Consolidacion-Contexto-20260805-205625\
```

**Los inventarios completos de esas auditorías externas no se copian a este repositorio.** Esta
carpeta solo contiene el índice maestro y una matriz concisa de documentos clave, derivados de esas
auditorías pero mantenidos aquí de forma independiente y versionada.

## Qué archivos debe leer Codex / Claude Code

Para trabajo nuevo en Empresa / Marcas Chinas / PEKING, el orden de lectura es:

1. `AGENTS.md` (raíz del repositorio)
2. `CLAUDE.md` (raíz del repositorio)
3. `docs/empresa-marcas-chinas/REGLAS_ALCANCE_AUTORIZADO.md`
4. `docs/empresa-marcas-chinas/README_CONTEXTO_ACTIVO.md`
5. `docs/empresa-marcas-chinas/auditoria/INDICE_MAESTRO_AUDITORIA.md` (este índice)

Para verificar la vigencia de un documento específico antes de citarlo o usarlo como base de trabajo,
consultar `docs/empresa-marcas-chinas/auditoria/MATRIZ_DOCUMENTOS_CLAVE_VIGENCIA.csv`.

## Qué autoriza y qué NO autoriza esta carpeta

Esta carpeta y su contenido son **exclusivamente documentación de índice y contexto**. Su existencia
**no autoriza**:

- eliminar, mover, renombrar ni archivar ningún documento existente;
- reparar, mover ni eliminar el worktree roto (`RedMotors-Empresa-Marcas-Chinas`);
- ningún cambio en Salesforce, metadata, datos, Partial ni Producción;
- ejecutar Salesforce CLI, deploy, retrieve ni source tracking;
- iniciar limpieza física de archivos en este repositorio ni en ningún otro.

Cualquier acción de limpieza, archivado o reorganización física requiere una etapa separada,
explícitamente autorizada por el usuario, siguiendo el plan reversible documentado en las auditorías
externas (`PLAN_LIMPIEZA_REVERSIBLE.md`, `PLAN_ETAPA3_SIN_EJECUTAR.md`).
