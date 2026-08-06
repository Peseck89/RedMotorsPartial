# Plan de inicio — Sprint 3

> ESTADO: SUSTITUIDO PARA EJECUCIÓN. Este documento fue preparado con una versión incompleta de la línea base. Se conserva únicamente para trazabilidad y no autoriza implementación.

Fecha de corte: 5 de agosto de 2026.

## 1. Objetivo

Sprint 3 puede iniciar por autorización de Luis para avanzar con lo que está respaldado por el alcance original de PortalNet. Este plan separa el trabajo ya cubierto, lo que puede revisarse de inmediato, lo que necesita una decisión externa y lo que corresponde a una ampliación posterior.

El documento inicial no rotula expresamente cada elemento como “Sprint 3”. Para esta preparación se consideran los frentes declarativos, de configuración e integración que permanecen después del trabajo documentado de Sprint 1 y Sprint 2. Esta reconstrucción no convierte automáticamente cada mención del documento en una modificación.

## 2. Límites

- Sprint 2 sigue pausado y no está cerrado.
- No se incorpora la implementación de 'Work_Order_from_Quote', 'Work_Order_from_Quote_Selective', 'SegregateWOLIs', 'aperturaCaseWorOrderEvent' ni 'ct_newCaseWorkOrderEvent'.
- Las ampliaciones identificadas en TD-RQ308 no forman parte automática de Sprint 3.
- No se inventarán bodegas, sucursales, territorios, talleres, servicios, garantías, productos, precios, monedas, permisos, responsables, identidad legal ni configuración Softland.
- PEKING no aplica a procesos exclusivos de vehículos usados.
- No se trabajarán Flows inactivos.
- El lookup vigente de Empresa, principalmente 'Empresa_Operadora__c', es la fuente principal; el campo legacy solo puede mantenerse como compatibilidad controlada.
- No se resolverán registros configurables mediante nombres o identificadores fijos.

## 3. Alcance original reconstruido

| Frente | Fuente original | Estado actual |
|---|---|---|
| Layouts | Página 7, sección 6 | Product2 requiere validación; Opportunity y Account necesitan inventario dirigido antes de decidir duplicaciones. |
| FlexiPages | Páginas 7–8, sección 6 | Opportunity VN fue atendida en Sprint 1; Quote requiere definición; páginas exclusivas de usados no aplican a PEKING. |
| Quick Actions | Página 8, sección 6 | Cinco acciones fueron mencionadas. Su existencia se confirmó parcial o totalmente en Partial, pero no todas requieren una variante funcional. |
| List Views | Página 8, sección 7 | Ocho vistas de Opportunity Omoda/Jaecoo ya están desplegadas. Lead y postventa requieren inventario y, en varios casos, definición funcional. |
| Perfiles, Permission Sets y accesos | Página 8, sección 8 | Los permisos base de Empresa ya tuvieron trabajo; falta la matriz exacta de perfiles, Record Types, layouts y separación de acceso. |
| Custom Metadata | Página 9, sección 9 | Los mappings Lead→Opportunity ya están cubiertos; la lista predeterminada VN depende de decisión comercial; VU no aplica. |
| Softland | Página 9, secciones 9–10 | Los batches existen y tuvieron refactor previo, pero la validación de tercera Empresa depende de bodegas y catálogo oficiales. |
| Global Value Sets y picklists | Página 9, sección 10 | Los valores base de producto fueron trabajados; queda comprobar dependencias reales sin ampliar picklists legacy. |
| Pricebooks y PricebookEntry | Páginas 9–10 | Resolver y estructura PEKING fueron atendidos; la carga de entradas de precio está bloqueada por datos oficiales. |
| Validation Rules | Separación por Empresa en páginas 9–10 | El PDF no enumera reglas concretas. Se permite inventariar; las reglas detalladas del v0.13 requieren autorización. |
| Approval Processes | Postventa y separación en páginas 9–10 | Se permite inventariar procesos existentes; aprobadores, garantía y reglas comerciales siguen sin definición. |
| Pruebas E2E y regresión | Páginas 9–10 | La regresión técnica puede comenzar; los recorridos positivos de ventas y postventa dependen de datos y decisiones oficiales. |

La estimación original se expresó de forma global —al menos un mes de desarrollo y dos o tres semanas de QA—. No se reparte entre filas ni se usa como sustituto de evidencia.

## 4. Trabajo ya cubierto

- 'Opportunity.Omoda' y 'Opportunity.Jaecoo', junto con los Record Types equivalentes de Lead y producto.
- 'Opportunity_Record_Page_VN', ampliada para Omoda y Jaecoo.
- Ocho List Views de Opportunity para abiertas, ganadas y perdidas de Omoda y Jaecoo.
- 'RM_RecordTypeMapping.Lead_Omoda_to_Opp' y 'RM_RecordTypeMapping.Lead_Jaecoo_to_Opp'.
- Campos, permisos y dependencias base de Empresa atendidos en Sprint 1.
- Resolución dinámica Empresa–Pricebook y configuración técnica asociada atendida en Sprint 2.
- Incorporación y conciliación de los bundles auditados de Sprint 2.

Estos elementos solo vuelven a aparecer cuando necesitan una validación de asignación, acceso o regresión. No se cuentan como desarrollo nuevo.

## 5. Trabajo ejecutable

Puede comenzar sin decisiones funcionales adicionales:

1. Inventario nominal y conciliación Git–Partial de layouts, FlexiPages, Quick Actions, List Views, Validation Rules, Approval Processes y accesos incluidos en el documento original.
2. Validación de asignaciones de 'Opportunity_Record_Page_VN' y de las ocho List Views ya desplegadas.
3. Validación de layouts Product2 y de los valores de marca/familia realmente consumidos.
4. Revisión no funcional de las Quick Actions para determinar si son reutilizables o si contienen dependencias BMW.
5. Suite de regresión técnica y escenarios negativos de Empresa/Pricebook que no requieran inventar datos.

Todo cambio funcional que aparezca durante el inventario debe pasar a un lote posterior con evidencia y autorización.

## 6. Trabajo bloqueado

| Decisión faltante | Componente afectado | Consecuencia de avanzar sin definición |
|---|---|---|
| Modelo de Account y necesidad real de Record Types/layouts por marca | 'Account-BMW Cuenta Empresarial V2' | Se crearían layouts o Record Types sin una experiencia aprobada. |
| Segmentación y activación de Quote por Empresa/Record Type | 'Quote_Record_Page_VN' y variantes | Se podrían duplicar páginas innecesarias o asignarlas a usuarios incorrectos. |
| Plantillas, remitente, logos y datos legales | Envío de correo y documentos | Se publicaría identidad no oficial. |
| Moneda, catálogos, servicios y plantillas de taller | Quick Actions de Work Order | Se alterarían procesos comerciales sin configuración válida. |
| Filtros y modelo de acceso por sucursal, territorio y taller | List Views, perfiles, roles y sharing | Un filtro visual podría confundirse con seguridad efectiva. |
| Pricebook VN predeterminado para PEKING | 'RM_Config.Default_Price_List_VN' | La resolución podría elegir una lista arbitraria. |
| Productos, precios, monedas y catálogos oficiales | PricebookEntry y QA positivo de ventas | No existe un conjunto válido para cargar o probar. |
| Bodegas y configuración Softland | Batches e inventario | La integración no puede validarse sin inventar configuración. |
| Aprobadores, garantía y reglas comerciales | Approval Processes y postventa | No se puede determinar el recorrido correcto. |

Los cinco Flows pausados pertenecen a Sprint 2. Sprint 3 solo registra sus dependencias; no los absorbe.

## 7. Ampliaciones no autorizadas

Los siguientes elementos provienen del detalle adicional de RQ308 y deben tratarse mediante control de cambios:

- obligatoriedad e inmutabilidad detallada de Empresa y Marca;
- derivación por VIN, placa o vehículo y auditoría ampliada;
- seguridad efectiva más allá de los frentes generales del documento inicial;
- aislamiento y reproceso formal de errores;
- notificaciones específicas;
- carga inicial y conciliación formal;
- UAT, Go/No-Go y soporte posterior con entregables detallados;
- mejora transversal del módulo de productos y catálogos;
- diferenciación de “trabajos a realizar” por Empresa, que el alcance inicial identifica expresamente como adicional.

Esto no elimina las validaciones básicas de separación, integración, E2E y regresión que sí aparecen en el alcance original.

## 8. Evidencia requerida

| Bloque | Evidencia mínima |
|---|---|
| Inventario | Nombre exacto, tipo, estado, asignación, referencia, existencia en Git/Partial y diff o justificación de por qué no aplica. |
| Configuración declarativa | Metadata recuperada temporalmente, matriz de asignaciones, capturas en Partial y resultado antes/después. |
| Permisos y accesos | Matriz por perfil QA, Record Type y campo; pruebas positivas y negativas; sin nombres de usuarios de apoyo. |
| Integraciones | Pruebas Apex, logs sin datos sensibles, Empresa procesada, error controlado y trazabilidad de configuración. |
| Pricebooks | Pruebas 'EXITO', 'NO_CONFIGURADO', 'SELECCION_REQUERIDA' y 'ERROR'; ninguna continuación con IDs nulos. |
| QA positivo | Datos oficiales proporcionados por el equipo y recorrido funcional real. Las Opportunities de evidencia deben provenir de Ver inventario o ser entregadas con VIN/datos completos. |
| QA negativo | Empresa ausente/desconocida, configuración inexistente o ambigua y confirmación de que no cae en Bavarian/Otobai. |
| Regresión | Comparación Bavarian, Otobai y PEKING; capturas, resultados y defectos registrados. |
| Videos | Un video por recorrido funcional aprobado; errores controlados visibles y sin información sensible. |

## 9. Orden propuesto de ejecución

1. **S3-0 — Inventario y conciliación declarativa.** Recuperación temporal y matriz de asignaciones, sin cambios funcionales.
2. **S3-1 — Validaciones de bajo riesgo.** Opportunity VN, List Views existentes, Product2, mappings y Permission Sets.
3. **S3-2 — Configuración declarativa independiente.** Solo elementos que el inventario confirme como necesarios y no bloqueados.
4. **S3-3 — Pricebooks y Custom Metadata.** Después de decisión comercial y datos oficiales.
5. **S3-4 — Integración Softland e inventario VN.** Después de bodegas y catálogo oficiales.
6. **S3-5 — Postventa, accesos y aprobaciones.** Después de resolver bloqueos funcionales; sin absorber los cinco Flows de Sprint 2.
7. **S3-6 — E2E, regresión, videos y cierre documental.**

Los detalles de cada lote están en 'LOTES_PROPUESTOS_SPRINT3_20260805.md'.

## 10. Criterio de cierre

Sprint 3 no se considerará completo hasta que el 100 % del alcance original reconstruido esté revisado con evidencia. “Revisado” puede terminar en cambio implementado, validación sin cambio, completado previamente, no aplica o bloqueado formalmente; compilar o desplegar por sí solo no demuestra cierre funcional.

El cierre exige trazabilidad entre requerimiento, metadata, prueba y evidencia; ausencia de cruces silenciosos entre Empresas; regresión de Bavarian y Otobai; pendientes asignados; ampliaciones separadas; y confirmación de que Sprint 2 permanece pausado.
