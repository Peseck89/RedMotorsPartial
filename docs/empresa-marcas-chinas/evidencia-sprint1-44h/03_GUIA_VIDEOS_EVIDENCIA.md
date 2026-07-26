# Guía de videos de evidencia — RedMotorsSandbox / Partial

## Reglas generales para Claudia

- Grabar en RedMotorsSandbox / Partial.
- No modificar datos.
- No crear productos, PricebookEntry, reservas, anticipos ni registros Softland.
- No mostrar datos personales sensibles, tokens, endpoints ni credenciales.
- Mantener videos cortos, claros y enfocados en evidencia visual.
- Si un dato operativo no existe, indicar “pendiente de carga operativa” y no simularlo.

## Video 1 — Objeto Empresa y RMPEKING

| Punto | Detalle |
|---|---|
| Objetivo | Mostrar que existe la base de empresa configurable y el código RMPEKING. |
| Duración recomendada | 2 a 3 minutos |
| Ruta | App Launcher → Object Manager → `Empresa` / `Empresa__c` |
| Qué abrir | Objeto Empresa, campos principales y registros si están disponibles. |
| Campos a mostrar | Código, nombre legal o nombre, estado/configuración disponible. |
| Narración sugerida | “En el Sprint 1 se creó la base de Empresa configurable. La lógica nueva trabaja con códigos estables como RMBAVARIAN, RMOTOBAI y RMPEKING, evitando depender del nombre visual de la empresa.” |
| Qué no mostrar | Información sensible de usuarios, integraciones o credenciales. |
| Qué no modificar | No crear ni editar registros de Empresa. |

## Video 2 — Opportunity Omoda/Jaecoo

| Punto | Detalle |
|---|---|
| Objetivo | Mostrar que Omoda y Jaecoo existen como Record Types de Opportunity y tienen experiencia declarativa disponible. |
| Duración recomendada | 4 a 5 minutos |
| Ruta | Setup → Object Manager → Opportunity → Record Types |
| Qué abrir | Record Types `Omoda` y `Jaecoo`. |
| Campos / elementos a mostrar | Activo, Sales Process Autos, Compact Layout Vehiculos_Nuevos, campo `Empresa Operadora`, List Views y Lightning Page. |
| Ruta List Views | App de ventas correspondiente → pestaña Opportunities → selector de vistas. |
| List Views esperadas | Abiertas, ganadas, perdidas y todas perdidas para Omoda y Jaecoo. |
| Ruta Lightning Page | Setup → Object Manager → Opportunity → Lightning Record Pages → `Opportunity_Record_Page_VN`. |
| Narración sugerida | “Omoda y Jaecoo quedaron habilitados como marcas de vehículos nuevos siguiendo el patrón de BMW. La página de Opportunity y las vistas ya contemplan ambas marcas.” |
| Qué no mostrar | No abrir oportunidades con información comercial sensible si no fueron autorizadas como evidencia. |
| Qué no modificar | No cambiar Record Types, páginas, vistas ni registros. |

## Video 3 — Lead / Tráfico Omoda y Jaecoo

| Punto | Detalle |
|---|---|
| Objetivo | Evidenciar que Lead Omoda/Jaecoo y los mappings Lead → Opportunity están disponibles. |
| Duración recomendada | 3 a 4 minutos |
| Ruta Record Types | Setup → Object Manager → Lead → Record Types |
| Qué abrir | Record Types `Omoda` y `Jaecoo`. |
| Ruta mappings | Setup → Custom Metadata Types → `RM_RecordTypeMapping` → Manage Records |
| Qué abrir | `Lead_Omoda_to_Opp` y `Lead_Jaecoo_to_Opp`. |
| Campos a mostrar | Source Object Lead, Source Record Type Omoda/Jaecoo, Target Object Opportunity, Target Record Type Omoda/Jaecoo, Active. |
| Narración sugerida | “El flujo de tráfico quedó preparado para convertir leads de Omoda y Jaecoo hacia oportunidades de la misma marca, usando metadata de mapping y sin tocar el mapeo histórico BMW→Polaris.” |
| Qué no mostrar | Leads reales con datos personales sin autorización. |
| Qué no modificar | No crear leads ni convertir tráfico durante el video. |

## Video 4 opcional — Quote, Work Order o Pricebook representativo

| Punto | Detalle |
|---|---|
| Objetivo | Mostrar un proceso técnico representativo que ya tenga datos estables, sin forzar escenarios PEKING sin datos operativos. |
| Duración recomendada | 3 a 5 minutos |
| Ruta sugerida Pricebook | Setup → Price Books / App de Pricebooks → buscar Bavarian, Otobai y PEKING. |
| Qué abrir | Pricebooks `PEKING Local` y `PEKING Dólares`, solo para mostrar que existen activos. |
| Narración sugerida | “Los Pricebooks PEKING existen y fueron incorporados a la lógica técnica. La operación real con productos depende de carga futura de productos y entradas de precio.” |
| Alternativa | Mostrar una Quote u Orden de Trabajo existente con `Empresa Operadora` si el equipo proporciona un registro QA estable. |
| Qué no demostrar | Productos PEKING, PricebookEntry PEKING, Softland real, reservas, anticipos ni inventario PEKING. |
| Qué no modificar | No crear líneas, no guardar cambios, no ejecutar procesos externos. |

## Revisión antes de enviar

- Confirmar que cada video se vea nítido.
- Confirmar que no aparezcan credenciales, tokens o información sensible.
- Confirmar que el audio mencione “Partial” o “Sandbox”, no Producción.
- Confirmar que no se afirme que productos PEKING o Softland PEKING ya están operativos.
