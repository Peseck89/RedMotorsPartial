# Plan corregido de Sprint 3

## 1. Motivo de la corrección

El plan anterior se preparó con una versión incompleta del documento de alcance. Esa versión no contenía la tabla consolidada que asigna explícitamente bloques a Sprint 1, Sprint 2, Sprint 3, bloques sin Sprint y elementos NA.

El plan anterior se conserva para trazabilidad, pero quedó sustituido para ejecución. Ninguna clasificación anterior se reutilizó sin volver a contrastarla con la fuente actualizada, la metadata versionada y Partial.

## 2. Fuente principal

La línea base es [DEV_Evaluacion_Alcance_Actualizada_20260805.docx](DEV_Evaluacion_Alcance_Actualizada_20260805.docx), recibida el 5 de agosto de 2026. Contiene 14 páginas según Word y coincide con la versión descrita como “aproximadamente 13 páginas” por su tabla consolidada y sus bloques 1–14.

La jerarquía de fuentes está documentada en [FUENTES_AUTORITATIVAS_EMPRESA_MARCAS_CHINAS.md](FUENTES_AUTORITATIVAS_EMPRESA_MARCAS_CHINAS.md).

## 3. Sprint 3 explícito

Sprint 3 contiene únicamente estos tres bloques:

| Bloque | Frente | Estimación original | Estado de preparación |
|---|---|---:|---|
| 7 | Layouts, FlexiPages y Quick Actions | 5h; ~10 + 10 + 5 | Inventario parcial; sin lote de implementación listo. |
| 9 | Validation Rules, Approval Processes y roles nuevos | 10h; ~7 VR y ~6 AP | Inventario parcial; decisiones de negocio pendientes. |
| 11 | Custom Metadata e integración Softland configurable | 8h | Mappings preexistentes; default VN y mecanismo de endpoint pendientes. |

Las cantidades son estimadas. No deben transformarse en metas de creación sin lista nominal y evidencia.

## 4. Pendiente de confirmar asignación

La tabla consolidada no asigna Sprint a:

- bloque 8: List Views;
- bloque 12: Global Value Sets;
- bloque 13: creación y carga de Pricebooks y PricebookEntry;
- bloque 14: pruebas E2E y regresión.

Estos frentes no se incorporan automáticamente a Sprint 3. Pueden conservar trabajo preexistente o ser necesarios para el cierre general, pero requieren confirmación de asignación.

## 5. Trabajo que permanece en Sprint 1

- bloque 1: objeto configurable Empresa;
- bloque 4: Apex y triggers;
- bloque 2: campos, picklists y corrección de valores, pendiente de validar contra Sprint 1;
- bloque 3: Record Types, pendiente de validar contra Sprint 1.

La lista Apex visible contiene 32 clases y 3 triggers; la clase 33 sigue siendo inconsistente en la fuente. El bloque 11 de Sprint 3 puede validar configuración Softland, pero no absorbe refactor Apex ni batches.

## 6. Trabajo que permanece en Sprint 2

- bloque 5: Flows;
- bloque 6: LWC/Aura;
- Work_Order_from_Quote;
- Work_Order_from_Quote_Selective;
- SegregateWOLIs;
- aperturaCaseWorOrderEvent;
- ct_newCaseWorkOrderEvent.

Sprint 2 continúa pausado y no cerrado. Los componentes exclusivos de usados no se adaptan a PEKING.

## 7. Elementos NA

El bloque 10 marca como NA el ajuste amplio de Profiles y Permission Sets. No es un bloque normal de Sprint 3.

Esto no impide documentar una dependencia mínima de acceso para un componente concreto, pero cualquier ajuste masivo o creación de perfiles/permisos necesita autorización separada.

## 8. Resultados funcionales generales

La separación de Ventas y Postventa es un resultado global del proyecto. Incluye sucursales, inventario, oportunidades, PDFs, talleres, calendarios, comunidad, órdenes, pedidos, bodegas, listas y catálogos.

Estos resultados no son una asignación automática a Sprint 3. Deben trazarse al bloque y Sprint que corresponda.

## 9. Trabajo ejecutable

Durante esta corrección no se identificó ningún lote funcional listo para implementación.

Sí puede ejecutarse, como análisis previo y sin cambios de Salesforce, el lote S3-0:

- inventario exacto de los bloques 7, 9 y 11;
- comparación de metadata versionada contra Partial;
- estado activo/inactivo;
- asignaciones y Record Types;
- aplicabilidad PEKING;
- exclusión de usados;
- identificación de dependencias y evidencia.

Los mappings Lead Omoda/Jaecoo ya cuentan con evidencia técnica y solo requieren validación funcional. Opportunity_Record_Page_VN contiene condiciones Omoda/Jaecoo, pero su asignación activa debe demostrarse.

## 10. Trabajo bloqueado

| Definición faltante | Componentes afectados | Responsable | Riesgo de asumir |
|---|---|---|---|
| Modelo Account/Quote por Empresa y asignaciones | Layout Account; Quote Record Pages | Negocio | Crear variantes o asignaciones incorrectas. |
| Identidad de correo/PDF | BMW_EnviarCorreoPresupuesto | Negocio | Publicar datos o identidad no oficiales. |
| Moneda, plantillas y catálogos de taller | Quick Actions WorkOrder | Negocio | Alterar operación y precios sin configuración válida. |
| Reglas de descuento y centros de costo | Validation Rules y Approval Processes | Negocio | Bloquear o aprobar transacciones incorrectamente. |
| Garantía y aprobadores | Approval Processes WorkOrder | Negocio | Copiar aprobadores fijos o reglas de otra Empresa. |
| Jerarquía de acceso | 15 roles actuales y posibles roles nuevos | Negocio | Confundir filtros visuales con seguridad. |
| Default Pricebook VN | RM_Config.Default_Price_List_VN | Negocio | Mantener o seleccionar Bavarian para PEKING. |
| Mecanismo autoritativo de endpoints | Configuración Softland | Diego | Duplicar configuración o exponer valores sensibles. |

## 11. Evidencia requerida

La evidencia debe separar:

1. **Existencia:** nombre exacto y tipo en metadata versionada y Partial.
2. **Modificación:** diff semántico y justificación.
3. **Deploy:** ID, componentes exactos y resultado, cuando se autorice.
4. **Validación técnica:** referencias, asignaciones, estado activo y pruebas automáticas.
5. **QA funcional:** recorrido con datos oficiales y perfil QA.
6. **Regresión:** Bavarian, Otobai y PEKING sin cruces silenciosos.
7. **Aceptación:** evidencia aprobada por el responsable funcional.

Existir o estar desplegado no demuestra aceptación.

## 12. Criterio de cierre

Sprint 3 no podrá declararse completo hasta:

- revisar todos los componentes reales de los bloques 7, 9 y 11;
- resolver o asignar formalmente los bloques 8, 12, 13 y 14;
- separar dependencias de Sprint 1 y Sprint 2;
- excluir usados donde corresponda;
- validar configuración Softland existente con RMPEKING;
- producir evidencia técnica, funcional y de regresión;
- mantener las ampliaciones TD-RQ308 fuera del alcance automático.
