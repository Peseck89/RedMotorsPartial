# Reglas de Producción — go-live 29-08-2026

## Hasta autorización explícita del pase

Permitido:

- inspección read-only de Producción;
- comparación Partial vs Producción;
- preparación de inventario/manifests/paquetes;
- preparación de Copado;
- Validate Only / checkOnly contra Producción;
- análisis de tests y cobertura;
- generación de scripts **sin ejecutarlos en Producción**;
- QA y correcciones en Partial dentro del alcance autorizado;
- documentación, backups y planes de rollback.

Prohibido sin autorización explícita adicional:

- Deploy real a Producción;
- Quick Deploy;
- DML o ejecución de scripts en Producción;
- creación/modificación/eliminación de datos en Producción;
- callouts de prueba que puedan impactar sistemas externos no certificados;
- cambios destructivos de metadata;
- des-fusionar manualmente componentes compartidos para crear versiones no probadas.

## Git

Commit, push, merge, reset, clean, stash drop/clear, borrado o movimiento de evidencia son approval-gated. Antes de una acción aprobada verificar repo/worktree, rama, HEAD, status, diff, remote y divergencia. Después verificar HEAD local/remoto y status final.

## Datos

No reutilizar IDs de Partial en Producción. Toda data productiva/provisional autorizada debe estar documentada en una matriz con valor, fuente, método idempotente de creación y rollback.

La reunión del 26/08 autoriza trabajar con supuestos para el go-live y contempla crear bodega china y Service Territory de ejemplo si los definitivos aún no existen. Esto **no equivale a copiar ciegamente cualquier registro QA**: los valores exactos y el script deben reconciliarse antes de ejecutar DML.
