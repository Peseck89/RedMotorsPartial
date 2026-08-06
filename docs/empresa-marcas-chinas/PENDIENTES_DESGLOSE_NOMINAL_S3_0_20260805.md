# Pendientes de desglose nominal — S3-0

Fecha de corte: 5 de agosto de 2026.

Las 44 filas actuales de la matriz son filas de alcance. No representan 44 componentes nominalmente conciliados. S3-0 debe producir el inventario individual y no podrá cerrar un grupo porque solo uno de sus elementos tenga evidencia.

| Fila matriz | Grupo actual | Motivo del desglose | Resultado requerido en S3-0 |
|---|---|---|---|
| S3C-B02-01 | 13 campos del inventario original | Agrupa campos de distintos objetos e incluye un elemento exclusivo de usados. | Identificar cada campo, su objeto, estado, aplicabilidad PEKING y exclusión de usados. |
| S3C-B03-01 | Opportunity.Omoda y Opportunity.Jaecoo | La evidencia de un Record Type no demuestra el otro ni sus asignaciones. | Una fila por Record Type con asignaciones, valores de picklist, estado y evidencia. |
| S3C-B03-02 | Lead Omoda/Jaecoo; Order/Case por confirmar | Mezcla Record Types existentes con variantes cuya necesidad no está confirmada. | Inventario nominal de Lead y listado separado de cualquier candidato Order/Case, sin inventar nombres. |
| S3C-B04-01 | Lista visible de 32 clases | El conteo general no demuestra estado individual ni resuelve la clase 33. | Relación nominal de cada clase con evidencia y discrepancia de conteo separada. |
| S3C-B04-02 | Tres triggers | Los estados y pruebas pueden diferir entre triggers. | Una entrada por trigger con evidencia técnica y funcional. |
| S3C-B05-01 | 20 Flows de Sprint 2 | Contiene versiones y estados activos/inactivos distintos. | Mantener el inventario nominal de Sprint 2 como referencia, sin absorberlo en Sprint 3. |
| S3C-B06-01 | 25 bundles LWC/Aura de Sprint 2 | Mezcla componentes aplicables con bundles exclusivos de usados. | Mantener la lista nominal y distinguir aplicabilidad PEKING y exclusiones VU. |
| S3C-B07-03 | Layouts Product2 | Cada layout puede tener secciones, campos y asignaciones diferentes. | Una fila por layout con contenido, asignaciones y evidencia. |
| S3C-B07-05 | Quote Record Pages VN y VU | Mezcla una página potencialmente aplicable con otra exclusiva de usados. | Separar VN y VU; validar activación y dependencias sin adaptar VU. |
| S3C-B07-06 | FlexiPages de inventario usado | Agrupa páginas y bundles exclusivos de usados. | Confirmar nominalmente la exclusión PEKING y las dependencias de regresión. |
| S3C-B08-01 | List Views de seis objetos | La cifra es aproximada y no existe lista final ni Sprint asignado. | Inventario por nombre exacto, objeto, filtro, uso y aplicabilidad, condicionado a asignación de Sprint. |
| S3C-B09-01 | Cinco Validation Rules de Opportunity | Una regla puede estar activa y otra inactiva o no aplicar. | Una fila por regla con fórmula, estado, dependencia y aplicabilidad. |
| S3C-B09-02 | Dos Validation Rules de Quote | Las reglas tienen propósitos y estados independientes. | Una fila por regla con evidencia y prueba requerida. |
| S3C-B09-03 | Dos Validation Rules de WorkOrder | La definición de centros de costo no puede generalizarse entre reglas. | Una fila por regla con estado y decisión funcional asociada. |
| S3C-B09-05 | Ocho Approval Processes de Opportunity | El estado o evidencia de uno no cierra los demás. | Una fila por proceso con estado, criterios, aprobadores y aplicabilidad. |
| S3C-B09-07 | Tres Approval Processes de WorkOrder | Mezcla procesos de centros de costo y garantía. | Una fila por proceso con estado, dependencia funcional y riesgo. |
| S3C-B09-08 | Quince roles | La jerarquía y el acceso deben evaluarse individualmente. | Una fila por rol con parent, usuarios/perfiles relacionados y decisión sobre PEKING. |
| S3C-B10-01 | Perfiles y Permission Sets estimados | Mezcla componentes amplios, perfiles VU y permisos mínimos potenciales. | Inventario nominal solo si se autoriza; distinguir dependencias mínimas de ajustes masivos. |
| S3C-B11-02 | Defaults VU y moneda VU | Son dos registros distintos y exclusivos de usados. | Confirmar individualmente su exclusión y necesidad de regresión. |
| S3C-B11-03 | Dos mappings Lead→Opportunity | La existencia de ambos no prueba la conversión funcional de cada marca. | Una fila por mapping con prueba funcional Omoda y Jaecoo. |
| S3C-B11-06 | Batches y servicios Softland relacionados | Agrupa consumidores con comportamientos distintos y pertenecientes a Sprint 1. | Mapa nominal de dependencias; devolver defectos Apex al frente autorizado correspondiente. |
| S3C-B12-01 | Tres Global Value Sets por identificar | No existen nombres exactos ni Sprint asignado. | Identificar cada GVS y su where-used, sujeto a confirmación de Sprint. |
| S3C-B13-02 | PricebookEntry oficiales PEKING | Agrupa una carga masiva dependiente de datos comerciales. | Inventario y conteos por Pricebook solo después de asignación y entrega de datos oficiales. |
| S3C-B14-01 | E2E y regresión integral | Agrupa recorridos funcionales de varios Sprints. | Casos nominales por proceso, Empresa y resultado, sujetos a asignación de Sprint. |

El desglose debe conservar por componente la fuente, el estado en metadata versionada y Partial, el estado activo cuando aplique, la relación con PEKING, las dependencias, la evidencia y la decisión. La ausencia de un nombre confirmado debe registrarse como pendiente, no completarse por inferencia.
