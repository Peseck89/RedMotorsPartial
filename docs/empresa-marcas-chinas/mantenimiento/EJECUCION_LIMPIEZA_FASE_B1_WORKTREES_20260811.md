# Ejecución de limpieza — Fase B1 (18 worktrees históricos RedMotors)

**Fecha:** 11 de agosto de 2026.
**Alcance:** retiro controlado, con `git worktree remove`, de los 18 worktrees históricos ya identificados como
seguros en `AUDITORIA_ALMACENAMIENTO_LAPTOP_20260811.md` y `MATRIZ_LIMPIEZA_LAPTOP_20260811.csv` (clasificación
`BORRAR_SEGURO_DESPUES_DE_CONFIRMACION`), y re-verificados de forma independiente en el precheck de la sesión
anterior. Esta ejecución corresponde únicamente al lote B1 del `PLAN_LIMPIEZA_LAPTOP_20260811.md` — ningún otro
lote (A, B2, C, D) se ejecutó.

**No se borraron ramas locales ni remotas, tags ni referencias históricas.** Solo se retiraron carpetas de
worktree y su metadata asociada en `.git/worktrees/`.

---

## 1. Precheck final (inmediatamente antes del retiro)

Se reverificaron los 18 worktrees, cada uno de forma independiente: existencia, estado limpio, rama correcta,
upstream configurado, sincronización `0/0`, sin archivos sin rastrear. **Los 18 pasaron el precheck** — ninguno
quedó marcado `REQUIERE_REVISION`.

## 2. Worktrees retirados (18/18)

Todos retirados con `git worktree remove <ruta>`, sin necesitar `--force` en ningún caso (todos estaban limpios y
sincronizados, por lo que el mecanismo estándar de Git los retiró sin objeciones):

1. `RedMotors-Bloque10-BusquedaDetallada`
2. `RedMotors-Hotfix-TestTrafico`
3. `RedMotors-Sprint1-Cierre-Luis-Definiciones`
4. `RedMotors-Sprint1-Cierre44H`
5. `RedMotors-Sprint1-Diego-Definiciones`
6. `RedMotors-Sprint1-Integracion`
7. `RedMotors-Sprint1-Next8`
8. `RedMotors-Sprint1-Pendientes`
9. `RedMotors-Sprint1-PrecioProducto-Peking`
10. `RedMotors-Sprint1-ProductJSON-RecordType-Peking`
11. `RedMotors-Sprint1-Reconciliacion33`
12. `RedMotors-Sprint1-Remediacion-Luis-Codex`
13. `RedMotors-Sprint1-Trazabilidad`
14. `RedMotors-Sprint1-Validacion33`
15. `RedMotors-Sprint2-Cierre-Empresa-Pricebook`
16. `RedMotors-Sprint2-Pricebook-Flows-Peking`
17. `RedMotors-Sprint2-Remediacion-Luis-Codex`
18. `RedMotors-Sprint2-RmVuInventario-Param-Fix`

## 3. Worktrees explícitamente NO tocados

- `RedMotors-Sprint2-Flows-Components` — worktree activo, Sprint 4.
- `RedMotorsPartial-Sandbox` — repositorio/base común, contiene la modificación local de `jsconfig.json` y el
  stash único de VN-RQ106, ambos intactos y sin revisar en esta fase.
- `RedMotors-Sprint1-Next8-Reconcile` — contiene el documento no rastreado
  `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`, sin decisión tomada todavía.
- `RedMotors-Empresa-Marcas-Chinas` — enlace `.git` roto (apunta a una ruta de otra sesión/entorno); confirmado
  intacto en el sistema de archivos, no forma parte de la lista de `git worktree list` de este repositorio porque
  su enlace nunca fue válido en esta máquina.

## 4. Validación posterior

```
git worktree list
```
→ Solo 3 entradas: `RedMotorsPartial-Sandbox`, `RedMotors-Sprint1-Next8-Reconcile`,
`RedMotors-Sprint2-Flows-Components`. Los 18 retirados ya no aparecen.

**Ramas:** las 18 ramas locales y sus 18 referencias remotas (`origin/...`) siguen existiendo — confirmado por
conteo directo. Ningún tag ni referencia histórica fue tocado.

**Worktree activo (`RedMotors-Sprint2-Flows-Components`):**
- `git status -sb` → limpio.
- HEAD → `7c964185e092b7e944af55cf036e5fd5b6ee1ede`.
- `git rev-list --left-right --count HEAD...@{upstream}` → `0 0`.

**`RedMotorsPartial-Sandbox`:** operativo; conserva exactamente la misma modificación local de `jsconfig.json`
(pérdida de salto de línea final, no funcional) y el mismo `stash@{0}` de antes de esta fase — ninguno de los dos
fue tocado.

**`RedMotors-Sprint1-Next8-Reconcile`:** intacto; conserva el mismo documento no rastreado de antes de esta fase.

**`RedMotors-Empresa-Marcas-Chinas` (roto):** confirmado que la carpeta sigue existiendo en el sistema de
archivos, sin ningún cambio.

## 5. Espacio recuperado (medido, no estimado)

| Momento | Tamaño de `Documents\Repositorios` |
|---|---:|
| Antes del retiro | 1,185,118 KiB ≈ 1,157.34 MiB ≈ 1.130 GiB |
| Después del retiro | 275,765 KiB ≈ 269.30 MiB ≈ 0.263 GiB |
| **Recuperado (real, medido)** | **909,353 KiB ≈ 888.04 MiB ≈ 0.867 GiB** |

El estimado previo de la auditoría de almacenamiento era ≈738.1 MiB. **El resultado real medido (≈888.04 MiB) es
mayor al estimado** — no se forzó el número original; se reporta la cifra real. La diferencia es consistente con
que el estimado previo sumó tamaños de archivo por worktree sin necesariamente incluir toda la sobrecarga de
metadata Git por worktree (`.git/worktrees/<nombre>/index`, `HEAD`, `logs`, etc.), que también se libera al
retirar cada worktree con el mecanismo estándar.

## 6. Confirmación

- No se borraron ramas remotas, ramas locales, tags ni referencias históricas.
- No se usó `--force` en ningún retiro.
- No se modificó Salesforce, no se hizo deploy.
- No se tocó `RedMotorsPartial-Sandbox`, `RedMotors-Sprint1-Next8-Reconcile` ni `RedMotors-Empresa-Marcas-Chinas`.
- El worktree activo de Sprint 4 permanece limpio y sincronizado.

**Pendiente de una fase posterior, no de esta:** Fase A (duplicados/ZIP pequeños, con aprobación explícita del
lote de rutas), Fase B2 (VN-RQ106 — inventariar y respaldar el stash antes de cualquier acción), y las revisiones
humanas de la Fase C (recuperación de archivos, worktree roto, documento no rastreado).
