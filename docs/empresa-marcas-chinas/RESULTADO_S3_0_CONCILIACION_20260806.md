# Resultado S3-0 — Conciliación del Sprint 3 explícito

## 1. Objetivo y autorización

El responsable del proyecto comunicó el 6 de agosto de 2026 la autorización para continuar con Sprint 3 exclusivamente mediante S3-0. La ejecución se limitó a consultas y retrieves de lectura en Partial. Esta autorización no comprende implementación, deploy ni el inicio de S3-1, S3-2, S3-3 o S3-4.

## 2. Alcance revisado

Se inventariaron únicamente los bloques expresamente asignados a Sprint 3:

- bloque 7: Layouts, FlexiPages y Quick Actions;
- bloque 9: Validation Rules, Approval Processes y roles;
- bloque 11: Custom Metadata y configuración Softland configurable.

Los bloques 8, 12, 13 y 14 permanecen pendientes de asignación. Los componentes exclusivos de usados se identificaron por separado y no se adaptan a PEKING.

## 3. Inventario nominal

La matriz nominal contiene 72 componentes individuales:

| Bloque | Tipo | Componentes |
|---|---|---:|
| 7 | Layout | 4 |
| 7 | FlexiPage | 5 |
| 7 | QuickAction | 5 |
| 9 | ValidationRule | 10 |
| 9 | ApprovalProcess | 12 |
| 9 | Role | 15 |
| 11 | CustomMetadata | 17 |
| 11 | Registros de configuración Empresa | 3 |
| 11 | Mecanismo de configuración Softland | 1 |

Estos conteos describen el inventario encontrado; no representan porcentaje de avance ni aceptación.

## 4. Coincidencia Git–Partial

### Coincidentes

- `RM_RecordTypeMapping.Lead_Omoda_to_Opp`.
- `RM_RecordTypeMapping.Lead_Jaecoo_to_Opp`.

Ambos mappings coinciden semánticamente y están activos en Partial. La conversión funcional continúa pendiente de QA.

### Solo Git

No se identificaron componentes del inventario nominal que existan únicamente en Git.

### Solo Partial

Se identificaron 65 componentes presentes en Partial y no versionados en Git. Corresponden principalmente a Layouts, FlexiPages, Quick Actions, Validation Rules, Approval Processes, roles y Custom Metadata legacy. Su presencia exclusiva en Partial no autoriza recuperarlos al repositorio ni modificarlos en bloque.

### Diferencias

`Opportunity_Record_Page_VN` existe en Git y Partial, pero Partial contiene además la acción `Opportunity.Plan_del_cliente_save_PDF`. El resto del diff recuperado para esta comparación no mostró otra diferencia. Debe conciliarse de forma controlada antes de utilizar Git como base de una modificación futura.

### Evidencia insuficiente

- El mecanismo autoritativo que resuelve la configuración de endpoints Softland no quedó identificado sin consultar contenido sensible.
- La asignación activa por aplicación, Record Type o perfil no está contenida en los archivos de Layout/FlexiPage recuperados y requiere evidencia adicional.
- La exposición efectiva de Quick Actions en cada experiencia no quedó demostrada únicamente por su existencia.

## 5. Componentes que requieren cambio

No existe todavía un componente clasificado como `REQUIERE_CAMBIO` que esté libre de decisiones y evidencia pendientes.

Sí existen cambios potenciales, pero permanecen condicionados:

- `RM_Config.Default_Price_List_VN` conserva un nombre Bavarian y requiere una decisión comercial escalable;
- `Opportunity.Cambiar_a_Finalizado_Descuento` solo contempla BMW y MINI, pero la política de descuentos PEKING no está confirmada;
- páginas, acciones y layouts pueden requerir ajustes una vez demostradas sus asignaciones y reglas funcionales;
- la conciliación del drift de `Opportunity_Record_Page_VN` es técnica y no equivale por sí misma a un cambio funcional PEKING.

## 6. Componentes que solo requieren validación

Quince componentes quedaron como `SOLO_VALIDACION`. Incluyen reglas sin referencia Empresa explícita, los mappings Omoda/Jaecoo y los tres registros activos de Empresa. Ninguno se considera aceptado sin prueba funcional.

Las validaciones mínimas incluyen:

- conversión Lead Omoda y Jaecoo hacia su Opportunity correcta;
- resolución separada de RMBAVARIAN, RMOTOBAI y RMPEKING;
- casos positivos y negativos de reglas activas e inactivas;
- ausencia de fallback silencioso hacia otra Empresa.

## 7. Bloqueos funcionales

Treinta y cinco componentes permanecen `BLOQUEADO_NEGOCIO`. Los grupos principales son:

| Decisión | Componentes afectados | Responsable | Riesgo de asumir |
|---|---|---|---|
| Modelo Account/Quote y asignaciones | Layout Account; Quote Record Page VN | Negocio | Exponer una variante incorrecta. |
| Identidad de correo y PDF | BMW_EnviarCorreoPresupuesto | Negocio | Usar identidad o datos no oficiales. |
| Moneda, plantillas y catálogos | Quick Actions Quote/WorkOrder | Negocio | Seleccionar configuración comercial incorrecta. |
| Política de descuentos PEKING | Validation Rules y ocho Approval Processes Opportunity | Negocio | Bloquear o aprobar transacciones incorrectamente. |
| Centros de costo y garantía | Reglas y aprobaciones Quote/WorkOrder | Negocio | Enrutar aprobaciones a responsables incorrectos. |
| Jerarquía PEKING | 15 roles | Negocio / Luis | Confundir filtros de interfaz con seguridad. |
| Default VN | RM_Config.Default_Price_List_VN | Negocio | Mantener Bavarian como default para PEKING. |

## 8. Dependencias de Sprint 1 y Sprint 2

- Los Quick Actions que invocan Flows dependen de componentes de Sprint 2; S3-0 no los modificó ni absorbió.
- `RM_RecordTypeMapping` es consumido por Apex de Sprint 1; cualquier defecto del consumidor debe volver a ese frente.
- Los servicios de VN/VU que consumen `RM_Config` pertenecen a frentes previos y requieren regresión separada.
- Los batches y servicios Softland siguen siendo dependencias Apex, no implementación del bloque 11.

Sprint 2 continúa pausado por sus cinco Flows pendientes.

## 9. Exclusiones

- `Quote_Record_Page_VU`, `Estadisticas_Inventario_Usados` y `Ver_Inventario_Vehiculos_Usados`.
- Defaults VU y mappings de Autos/Motos usados.
- Bloques 8, 12, 13 y 14.
- Ajustes amplios de Profiles y Permission Sets.
- Ampliaciones del documento posterior que no estén expresamente autorizadas.

## 10. Evidencia

Se utilizaron:

- fuente actualizada y documentos autoritativos del proyecto;
- matriz de alcance corregida y desglose requerido para S3-0;
- metadata versionada;
- List Metadata y Tooling API sobre Partial;
- retrieves temporales de los tipos autorizados, fuera del worktree;
- consultas agregadas sin nombres personales para revisar uso de roles;
- consulta de códigos y estado de Empresa sin acceder a datos legales;
- comparación semántica Git–Partial de los componentes presentes en ambos lados.

No se consultaron valores de credenciales, secretos, tokens ni endpoints sensibles.

## 11. Conclusión

S3-0 produjo un inventario nominal completo de los componentes identificados, pero conserva limitaciones de evidencia sobre asignaciones activas y el mecanismo configurable de Softland. Por ello se registra como análisis ejecutado con limitaciones y no como cierre funcional.

No existe todavía un primer lote funcional listo. La única acción técnica aislable es conciliar el drift de `Opportunity_Record_Page_VN`, pero debe presentarse para aprobación y no debe confundirse con implementación PEKING.

## 12. Corrección posterior S3-0.1 — 2026-08-06

El resultado anterior se conserva como evidencia histórica del commit `5316bea`, pero la auditoría posterior determinó que no demostraba el universo completo. El estado vigente se corrige a `S3-0 — EN_PROGRESO_CON_BRECHAS_DE_COBERTURA`.

Se documentaron 61 Layouts, 25 FlexiPages, 50 acciones custom referenciadas, 383 Validation Rules, 18 Approval Processes y los 15 Roles existentes. La matriz V2 separa 225 filas nominales de un placeholder de investigación.

Persisten brechas de asignación efectiva de Layouts/FlexiPages, baseline Git y mecanismo Softland. Los 65 componentes de la cohorte original que solo existen en Partial siguen sin modificación. No existe lote funcional listo ni autorización para `Opportunity_Record_Page_VN`.

Detalle: `AUDITORIA_COBERTURA_S3_0_20260806.md`, `UNIVERSO_Y_CRITERIOS_SELECCION_S3_0_20260806.csv`, `MATRIZ_NOMINAL_S3_0_V2_20260806.csv` y `PLAN_BASELINE_GIT_PARTIAL_SPRINT3_20260806.md`.

## 13. Corrección posterior S3-0.2 — 2026-08-06

Se preservan los resultados anteriores como historia. La integridad vigente está en las versiones V2/V3 y en `CORRECCION_INTEGRIDAD_S3_0_20260806.md`. La matriz nominal corregida contiene 224 componentes únicos y un placeholder; no cuenta dos veces `Product2-Product Layout V1.1`.

La evidencia de asignación está en `MATRIZ_ASIGNACIONES_UI_S3_0_20260806.csv`. Demuestra asignaciones declaradas, no acceso ni uso efectivo. Seis Layouts tienen relación nominal con Record Types Omoda/Jaecoo/PEKING; no se encontró activación FlexiPage explícita para esos Record Types. S3-0 continúa abierto y no autoriza ningún lote funcional.

## 14. Cierre de integridad S3-0.3 — 2026-08-06

S3-0 queda `COMPLETADO_COMO_ANALISIS_CON_LIMITACIONES`. La V4 contiene 225 componentes nominales y un placeholder; la matriz UI V2 distingue las seis referencias de perfil no resueltas sin registrar identificadores. Los 4,735 ProfileLayouts se conservaron porque son asignaciones distintas; no había duplicados reales.

Persisten Softland, decisiones de negocio y QA funcional. No hay funcionalidad implementada, baseline autorizado ni lote funcional listo.
