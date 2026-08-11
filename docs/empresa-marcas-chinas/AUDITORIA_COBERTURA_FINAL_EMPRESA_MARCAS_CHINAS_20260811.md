# Auditoría final de cobertura — Empresa / Marcas Chinas (Omoda / Jaecoo / PEKING)

**Fecha:** 11 de agosto de 2026.
**Naturaleza:** auditoría de análisis, conciliación y documentación — solo lectura. No se modificó Salesforce, no
se hizo deploy, no se crearon ni borraron datos, no se cambió metadata, no se repitieron pruebas ya realizadas, no
se borró ningún archivo local ni se limpió ningún repositorio.
**Matriz autoritativa resultante:** `MATRIZ_MAESTRA_COBERTURA_EMPRESA_MARCAS_CHINAS_20260811.csv` (16 filas: los 14
ítems del alcance original, el ítem 10 NA, y 2 filas de trabajo adicional sin horas propias en el alcance
original — `Opportunity_Record_Page_VN` y la jerarquía Omoda/Jaecoo).

---

## 1. Qué pidió originalmente la asignación

El documento de alcance actualizado (`DEV_Evaluacion_Alcance_Actualizada_20260805.docx`, fuente principal vigente
según `README_CONTEXTO_ACTIVO.md` y `auditoria/INDICE_MAESTRO_AUDITORIA.md`) define **14 requerimientos con horas**
(un 15º ítem, Profiles/Permission Sets, está marcado NA por el propio documento y se excluye del total de 150h):
objeto configurable de empresa, picklists/campos, Record Types nuevos, Apex (incluye Softland/Pricebook), Flows,
LWC/Aura, Layouts/FlexiPages/Quick Actions, List Views, Validation Rules/Approval Processes, Custom
Metadata/Softland, Global Value Sets, creación y población de 2 Pricebooks, y pruebas de integración end-to-end.

El documento original del cliente (el PDF, recibido de PortalNet) es evidencia técnica de respaldo pero **no**
contiene la tabla consolidada de horas — esa tabla vive únicamente en la versión actualizada del `.docx`, que es la
que se usó como base para esta auditoría, consistente con la jerarquía de fuentes ya establecida en
`auditoria/INDICE_MAESTRO_AUDITORIA.md`.

---

## 2. Qué está realmente cubierto

Con evidencia concreta y verificable (`COMPLETO_CON_EVIDENCIA`):

- El objeto configurable de empresa (ítem 1) — desplegado, en uso activo en todo el trabajo posterior.
- Las 4 reglas de validación de Sprint 3 (parte del ítem 9) — 15 escenarios de prueba aprobados.

Implementado y desplegado, con la validación final por completar (`IMPLEMENTADO_VALIDACION_PENDIENTE`):

- La reutilización de la pantalla principal de Oportunidad para Omoda/Jaecoo (trabajo adicional, no parte de las
  horas originales) — la decisión ya está tomada y el contenido técnico ya la incorpora.
- La estructura de asignación de responsables de aprobación para Omoda/Jaecoo (trabajo adicional, no parte de las
  horas originales) — desplegada, sin regresión confirmada contra las marcas existentes, con la prueba funcional
  final por completar.

---

## 3. Qué está parcialmente cubierto

8 de los 14 ítems originales están en estado `PARCIAL`: Record Types en otros objetos (ítem 3), Apex (ítem 4),
Flows (ítem 5), LWC/Aura (ítem 6), UI (ítem 7), Validation Rules/Approval Processes (ítem 9, mixto —VR completo,
AP con lógica resuelta pero QA en vivo pendiente), Custom Metadata/Softland (ítem 11), y Pricebooks-dato (ítem
13). El detalle componente por componente de cada uno está en la matriz maestra y no se repite aquí.

---

## 4. Qué no está cubierto

4 ítems están en estado `PENDIENTE`, sin evidencia de ejecución en ninguna fuente revisada: picklists/campos
(ítem 2, 4h), List Views (ítem 8, 8h), Global Value Sets (ítem 12, 1h), y pruebas de integración end-to-end (ítem
14, 10h). No se afirma que estén incompletos por mala ejecución — simplemente no existe evidencia documentada de
que se hayan trabajado, y no se asume que sí solo porque pudieron haberse tocado incidentalmente en otro bloque.

---

## 5. Qué depende de configuración

- La asignación final de la pantalla de Oportunidad por marca y rol de usuario (entrelazada con el trabajo de
  renombre de perfiles en curso).
- La configuración de bodegas y clave de integración externa, una vez definida la convención oficial.
- La actualización de los responsables de aprobación de prueba por los responsables reales, una vez confirmados.

---

## 6. Qué depende de datos o de una definición funcional de negocio

Es el grupo más grande. Requiere una decisión o un dato que solo el negocio puede dar, no desarrollo:

- Confirmar si los ítems sin evidencia de ejecución (2, 8, 12, 14) realmente se trabajaron o no.
- Confirmar el alcance real de Record Types en Order/Case (Order ya está confirmado fuera de alcance de Sprint 1;
  Case nunca se abordó en ninguna fuente revisada).
- Confirmar cuál era la "clase 33" pendiente del bloque de Apex de Sprint 1.
- Decidir, para los 32 elementos de pantalla sin uso activo demostrado, si siguen siendo necesarios.
- Definir contenido de plantilla para los 3 elementos de pantalla que sí aplican pero necesitan una plantilla
  propia de Omoda/Jaecoo.
- Responsables reales de aprobación (Director/Gerente/Jefe) para Omoda/Jaecoo.
- Regla de Pricebook por defecto, centro de costo y aprobador oficiales, bodegas oficiales y convención de clave,
  contenido real de catálogos, regla y aprobador de garantías.
- Datos oficiales de precio para completar la población de los 2 Pricebooks ya creados.

---

## 7. Qué requiere desarrollo

- Los 12 Flows de Sprint 2 marcados "modificar" (sujeto a la misma verificación de alcance autorizado que ya rige
  el resto del proyecto).
- Los componentes de interfaz reutilizables (LWC/Aura) que ya cuentan con autorización nominal explícita y siguen
  con desarrollo pendiente — hoy solo `rm_vu_inventario` tiene esa autorización confirmada por nombre.
- Cualquier ajuste puntual que surja después de resolver las definiciones de la sección 6 (por ejemplo, una vez
  definido el contenido de plantilla para los 3 elementos de pantalla del ítem 7, o una vez confirmada la "clase
  33").

**No hay desarrollo automatizable pendiente que no dependa de alguna definición previa** — no se identificó
ningún bloque de trabajo técnico "listo para ejecutar sin ninguna dependencia" más allá de los puntos anteriores.

---

## 8. Qué requiere validación

- La prueba funcional final de la jerarquía de responsables y de los procesos de aprobación de descuento para
  Omoda/Jaecoo — bloqueada temporalmente por una demora técnica de la plataforma (no atribuible a este proyecto),
  con el paso ya preparado para ejecutarse en cuanto se libere.
- Un ciclo de prueba de integración de punta a punta (ítem 14), que solo tiene sentido ejecutar una vez existan
  los datos oficiales de negocio (centro de costo, bodegas, catálogos, Pricebook por defecto).

---

## 9. Qué pasa a Sprint 4

Ver `SPRINT4_BACKLOG_REAL` (sección 13). Solo se incluye ahí trabajo que pertenece al alcance, sigue realmente
pendiente, y no es simplemente una definición externa disfrazada de tarea de desarrollo.

---

## 10. Qué bloquearía un cierre definitivo

- Las 4 definiciones/datos de negocio pendientes que afectan directamente una funcionalidad ya construida y
  esperando esos datos: responsables de aprobación, Pricebook por defecto, bodegas/clave de Softland, y contenido
  real de catálogos.
- La confirmación de Sprint 1 que sigue sin marcarse formalmente (el checkpoint de aceptación de Luis en el cierre
  de las 44h).
- La validación final de la jerarquía de responsables (bloqueada temporalmente por la plataforma, no una decisión
  pendiente).
- Los 4 ítems `PENDIENTE` sin ninguna evidencia (2, 8, 12, 14) — antes de un cierre definitivo, alguien debe
  confirmar si se ejecutaron o no; no se pueden dejar en ambigüedad indefinidamente.

**No se declara "todo cubierto", "Sprint cerrado" ni "proyecto terminado"** — persisten los puntos anteriores.

---

## 11. Qué NO debemos volver a auditar

- El estado técnico de Sprint 1 (objeto Empresa, Apex 32/33+3 triggers, Record Types Opportunity/Lead) — ya
  verificado con evidencia de despliegue y pruebas, documentado en `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`
  y `CIERRE_SPRINT1_44H.md`.
- El estado técnico de Sprint 2 (20 Flows, 25 LWC/Aura) — ya verificado en `AUDITORIA_CIERRE_SPRINT2.md` /
  `MATRIZ_CIERRE_SPRINT2.csv` (2026-08-04), que reemplazó los inventarios preliminares anteriores
  (`INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md`, `MATRIZ_TRAZABILIDAD_SPRINT2.md`) usados como candidatos iniciales
  más amplios antes de la conciliación de cierre.
- Las 78 pantallas de Sprint 3 — ya auditadas y clasificadas (`RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md`).
- Las 4 Validation Rules — ya probadas 15/15.
- El mecanismo técnico de los procesos de aprobación de descuento — ya confirmado que no requieren desarrollo
  específico de marca.
- Las 36 pruebas simuladas de los catálogos de Softland — ya ejecutadas y aprobadas.
- Las 4 evidencias visuales — ya grabadas, revisadas y aprobadas.

---

## 12. Qué información debe conservarse

Ver sección 14 de este documento para el detalle completo por categoría.

---

## 13. `SPRINT4_BACKLOG_REAL`

Solo trabajo que pertenece al alcance, sigue realmente pendiente, no es una definición externa disfrazada, y no
fue ya implementado.

### A. DESARROLLO
- Los 12 Flows de Sprint 2 marcados "modificar" (sujeto a verificación de alcance autorizado antes de tocarlos).
- Desarrollo pendiente de componentes de interfaz reutilizables (LWC/Aura) ya autorizados por nombre — hoy solo
  `rm_vu_inventario`.
- Ajustes puntuales que puedan surgir una vez resueltas las definiciones de la categoría D (por ejemplo, contenido
  de plantilla para 3 elementos de pantalla, o la "clase 33" de Apex si la definición confirma que falta trabajo).

### B. CONFIGURACION
- Asignación final de la pantalla de Oportunidad por marca y rol de usuario.
- Configuración de bodegas y clave de integración externa, una vez exista la convención oficial.
- Actualización de los responsables de aprobación de prueba por los responsables reales, una vez confirmados.

### C. VALIDACION
- Prueba funcional final de la jerarquía de responsables y de los procesos de aprobación de descuento — el paso
  técnico ya está preparado, bloqueado temporalmente por una demora de la plataforma ajena al proyecto.
- Ciclo de prueba de integración de punta a punta (ítem 14), una vez existan los datos oficiales necesarios.

### D. DEFINICION_FUNCIONAL
- Confirmar si los ítems 2 (picklists), 8 (List Views), 12 (Global Value Sets) y 14 (pruebas E2E) se ejecutaron o
  no.
- Confirmar el alcance real de Record Types en Order/Case.
- Confirmar cuál era la "clase 33" pendiente del bloque de Apex de Sprint 1.
- Decidir, para los 32 elementos de pantalla sin uso activo demostrado, si siguen siendo necesarios.
- Confirmar si la lógica binaria anterior (que distinguía únicamente entre las dos empresas históricas) debe
  migrarse por completo a la lógica configurable actual, o si eso queda fuera del alcance de este proyecto — hoy
  persiste sin migrar en un grupo de clases que no forma parte del compromiso original de 44h de Sprint 1 (ver
  nota de auditoría en la sección 15).

### E. DATOS_NEGOCIO
- Responsables reales de aprobación (Director/Gerente/Jefe) para Omoda/Jaecoo.
- Regla de Pricebook por defecto.
- Centro de costo y aprobador oficiales.
- Bodegas oficiales de PEKING y convención de clave externa.
- Contenido real y definitivo de los 6 catálogos.
- Regla y aprobador de garantías.
- Contenido de plantillas de correo/presupuesto propias de Omoda/Jaecoo.
- Datos oficiales de precio para completar la población de los 2 Pricebooks ya creados.

**No se mezclan decisiones de negocio con horas de desarrollo** — las categorías D y E no tienen una estimación de
horas de programación asociada; son insumos que el equipo de desarrollo necesita recibir antes de poder generar
una estimación real para las categorías A y C que dependen de ellas.

---

## 14. Qué conservar localmente

Clasificación pensada como apoyo para una futura limpieza de la laptop — **no se borró ni movió nada** en esta
auditoría.

**CONSERVAR_PARA_SPRINT4:**
- El repositorio/worktree activo completo: `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint2-Flows-Components`.
- `docs/empresa-marcas-chinas/REGLAS_ALCANCE_AUTORIZADO.md`, `README_CONTEXTO_ACTIVO.md`,
  `auditoria/INDICE_MAESTRO_AUDITORIA.md`, `auditoria/MATRIZ_DOCUMENTOS_CLAVE_VIGENCIA.csv`.
- `MATRIZ_MAESTRA_COBERTURA_EMPRESA_MARCAS_CHINAS_20260811.csv` (esta auditoría) y
  `AUDITORIA_COBERTURA_FINAL_EMPRESA_MARCAS_CHINAS_20260811.md` (este documento) — punto de partida para Sprint 4.
- `CONCILIACION_HORAS_AVANCE_REAL_EMPRESA_MARCAS_CHINAS_20260811.md` y su matriz de horas.
- `CONTENIDO_FINAL_REPORTE_EMPRESA_MARCAS_CHINAS_20260811.md` (contenido consolidado para el reporte de negocio).
- `EVIDENCIAS_NEGOCIO_SPRINT3_20260810.md` y `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md` (detalle
  técnico vigente de Sprint 3).

**CONSERVAR_HASTA_CIERRE:**
- `AUDITORIA_CIERRE_SPRINT2.md` / `MATRIZ_CIERRE_SPRINT2.csv` (evidencia de cierre de Sprint 2, sigue pausado no
  cerrado).
- `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` y `CIERRE_SPRINT1_44H.md` (evidencia de cierre de Sprint
  1, checkpoint de Luis sin marcar todavía).
- El resto de resultados técnicos de Sprint 3 citados como evidencia en las matrices vigentes (Validation Rules,
  Approval Processes, Softland, UI).

**RECONSTRUIBLE_DESDE_GIT (no urgente conservar fuera del repositorio):**
- Todo el código y metadata ya versionados en la rama activa — recuperable en cualquier momento con el
  historial de commits, ya confirmado sincronizado (sección 15).

**DOCUMENTACION_HISTORICA_NO_NECESARIA_PARA_CONTINUAR:**
- Los documentos ya autodeclarados "SUSTITUIDO PARA EJECUCIÓN" (`LOTES_PROPUESTOS_SPRINT3_20260805.md`,
  `PLAN_INICIO_SPRINT3_20260805.md`, `RESUMEN_PREPARACION_SPRINT3_20260805.md`,
  `MATRIZ_ALCANCE_SPRINT3_PRELIMINAR_20260805.csv`).
- Los bloques de implementación de Sprint 1 (`IMPLEMENTACION_BLOQUE*.md`) y la reconciliación 33x3 — evidencia
  histórica ya resumida en los documentos de cierre.
- Las versiones intermedias de las matrices de Sprint 3 (`MATRIZ_NOMINAL_S3_0_20260806.csv` hasta `_V3`,
  `MATRIZ_ASIGNACIONES_UI_S3_0_20260806.csv` sin versión) — superadas por sus versiones `V4`/`V2` finales o por
  `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md`.

**Evidencia que vive fuera de Git (no versionada, solo se registra su existencia):** las 4 evidencias visuales
(`Evidencia Sprint 3 - Opportunity Omoda/Jaecoo/BMW/Presupuesto Omoda - Agregar Extras.mp4`) — archivos externos,
no copiados ni movidos en esta auditoría.

---

## 15. Estado del respaldo Git del proyecto activo

Verificado en el momento de esta auditoría, sin hacer ningún cambio:

```
git status -sb   → limpio, sin archivos modificados ni sin rastrear
git rev-parse HEAD → 428a6ced9b40c4e5235932d36129e5696770895c
git rev-list --left-right --count HEAD...@{upstream} → 0  0
```

**`RESPALDO_GIT_PROYECTO_ACTIVO_CONFIRMADO`.**

Se revisaron además, únicamente para identificar trabajo no respaldado, todas las ramas y worktrees relacionados
con el proyecto (sin ejecutar ningún comando que modifique nada): todas muestran su rama local sincronizada con su
propio remoto, salvo la excepción ya conocida y documentada en `auditoria/INDICE_MAESTRO_AUDITORIA.md` sección 12
punto 3 (`RedMotors-Sprint1-Next8-Reconcile`), donde el único commit local no compartido tiene un contenido idéntico
a uno ya incorporado en la rama autoritativa — no representa trabajo perdido. No se encontró ningún otro caso de
trabajo relevante sin respaldar.

---

## 16. Inconsistencias de alcance encontradas

1. **Rango de horas del documento original ("144-150h"):** la suma exacta de las cifras visibles en la tabla es
   150h; no existe en las fuentes revisadas una explicación documentada del extremo inferior (144h). Ya reportado
   como `INCONSISTENCIA_REQUIERE_REVISION` en la conciliación de horas — no se repite el análisis aquí.
2. **Lógica binaria heredada (Bavarian/Otobai) sin migrar por completo:** documentación de Sprint 1
   (`INVENTARIO_APEX_SPRINT1.md`) confirma que, fuera del grupo específico de 33 clases + 3 triggers acordado como
   compromiso de las 44h, persisten aproximadamente 14 clases adicionales con la lógica binaria anterior sin
   reemplazar por la lógica configurable de empresa. **Esto no formó parte del compromiso original de 44h ni de
   ningún ítem con horas propias del documento de alcance actualizado** — se registra aquí como hallazgo de
   auditoría y candidato a definición funcional (sección 13.D), no como un pendiente con horas que se le esté
   agregando al proyecto por inferencia.
3. **Case nunca abordado:** ninguna fuente revisada en esta auditoría ni en la anterior menciona si el objeto
   Case necesita Record Type propio para Omoda/Jaecoo — el ítem original solo habla de "4-6 en otros objetos" sin
   nombrarlos. Order sí está confirmado explícitamente fuera de alcance de Sprint 1.
4. **Conteos preliminares de Sprint 2 superados:** los inventarios iniciales de Sprint 2
   (`INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md`: 47 Flows candidatos; `MATRIZ_TRAZABILIDAD_SPRINT2.md`: 36
   LWC/Aura candidatos) reportan números distintos a los de la auditoría de cierre (`AUDITORIA_CIERRE_SPRINT2.md`:
   20 Flows exactos, 25 LWC/Aura reales). No es una contradicción sin resolver — la auditoría de cierre es
   posterior (2026-08-04) y explícitamente reemplaza a los inventarios preliminares como candidatos iniciales más
   amplios antes de la conciliación final. Se deja registrado para que quede trazable por qué los números
   cambiaron entre un documento y otro.

---

## 17. Confirmación final

**No se modificó Salesforce, no se hizo deploy, no se crearon ni borraron datos, no se cambió metadata, no se
repitió ninguna prueba ya realizada, y no se borró ningún archivo local ni se limpió ningún repositorio o
worktree durante esta auditoría.**

**No se declara "todo cubierto", "Sprint cerrado" ni "proyecto terminado".**
