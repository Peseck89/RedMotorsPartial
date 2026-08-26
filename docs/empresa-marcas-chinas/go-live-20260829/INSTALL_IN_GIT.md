# Instalación del paquete en el repositorio

Este directorio fue preparado fuera del repositorio para ahorrar tokens de Code/Codex.

## Acción mecánica requerida en el equipo del usuario

1. Code/Work debe hacer un precheck read-only del repositorio autoritativo: repo, worktree, branch, HEAD, status, remote, divergencia.
2. Copiar el directorio `docs/empresa-marcas-chinas/go-live-20260829/` completo al worktree autoritativo que se decida para el go-live.
3. Revisar que no se sobreescriba documentación existente con cambios no previstos.
4. Agregar los snippets de `AGENTS_SNIPPET.md` y `CLAUDE_SNIPPET.md` a los archivos raíz existentes **sin reemplazar sus reglas actuales**.
5. Mostrar `git diff --stat` y `git diff` de los archivos de texto, y listar binarios añadidos.
6. No hacer commit ni push hasta autorización explícita.

## No copiar a Git

El directorio hermano `evidence_external/` contiene screenshots con datos personales visibles y no debe copiarse al repositorio salvo decisión explícita del usuario/equipo.
