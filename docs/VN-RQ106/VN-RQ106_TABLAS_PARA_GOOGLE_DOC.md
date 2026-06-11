# VN-RQ106 - Tablas para Google Docs

Contenido preparado para copiar y pegar manualmente en la plantilla oficial.
Producción: sin cambios. QA: pendiente de validación formal / no aprobado.

## Componentes Modificados

| Tipo de Componente | Nombre API / Técnico | Acción | Descripción del Cambio | Observaciones |
| --- | --- | --- | --- | --- |
| Lightning Web Component | vnRq106SolicitudesAnticipos | Creado | Componente de acción rápida para abrir el modal de consulta de solicitudes y anticipos desde Opportunity. | Implementado en RedMotors Sandbox Partial. |
| Lightning Web Component | vnRq106OpportunityOverview | Reutilizado / ajustado | Se reutiliza dentro del modal de Solicitudes anticipos y se retiró su presencia embebida en la vista principal de Opportunity. | Relacionado también con lectura del resumen operativo. |
| Quick Action | Opportunity.VN_RQ106_Solicitudes_Anticipos | Creada | Acción de Opportunity para abrir el botón Solicitudes anticipos. | Agregada a páginas VN y VU. |
| Lightning Record Page | Opportunity_Record_Page_VN | Modificada | Se agregó la acción Solicitudes anticipos y se retiró el overview embebido de la vista principal. | Aplicable a oportunidades VN. |
| Lightning Record Page | Opportunity_Record_Page_VU | Modificada | Se agregó la acción Solicitudes anticipos y se retiró el overview embebido de la vista principal. | Aplicable a oportunidades VU. |
| Permission Set | VN_RQ106_Anticipo | Configurado / validado | Permisos y accesos requeridos para los perfiles QA definidos. | 28 asignaciones activas validadas en Sandbox. |
| Apex Class | VN_RQ106_OpportunityOverviewController | Relacionado | Controlador utilizado por el overview operativo de solicitudes y anticipos. | Relacionado con la funcionalidad; consolidación y validación final pendientes según alcance de QA. |
| Apex Class | VN_RQ106_AnticipoController | Relacionado | Controlador relacionado con el registro de solicitud de ingreso / anticipo. | Relacionado con el módulo VN-RQ106; validación final pendiente según QA. |
| Apex Test Class | VN_RQ106_OppOverviewCtrlTest | Relacionado | Prueba técnica relacionada con el controlador del overview. | Pendiente de consolidación de resultados finales. |
| Apex Test Class | VN_RQ106_AnticipoControllerTest | Relacionado | Prueba técnica relacionada con el controlador de anticipo. | Pendiente de consolidación de resultados finales. |
| Flow | VN_RQ106_Notificaciones_Anticipo | Relacionado | Flow existente relacionado con notificaciones de VN-RQ106. | Sin cambios funcionales nuevos en Bloque A. |
| Objeto | Anticipo__c | Relacionado | Objeto principal para solicitudes de ingresos, anticipos y reservas. | Campo de estado de aprobación producto queda pendiente de definición/creación. |
| Objeto | Opportunity | Relacionado | Objeto desde el cual se accede al botón Solicitudes anticipos. | Sin cambios de objeto confirmados para Bloque A. |
| Objeto | Product2 | Relacionado | Objeto de producto o vehículo relacionado con reservas. | Sin cambios de objeto confirmados para Bloque A. |

## Instrucciones de Deployment

| Campo | Detalle |
| --- | --- |
| Sandbox Origen | RedMotors Sandbox Partial. |
| Ambiente destino validado | RedMotors Sandbox Partial. Producción sin cambios. |
| Responsable | Equipo Salesforce RedMotors. |
| Fecha programada | Pendiente de confirmación para cualquier pase posterior. Bloque A ya fue desplegado en Sandbox. |
| Ventana de deployment | Pendiente de confirmación para Producción; no aplica como ventana productiva en esta entrega. |
| Método de deployment | Despliegue técnico de componentes del Bloque A hacia Sandbox. No se documenta despliegue a Producción. |
| Dependencias | Permisos del Permission Set VN_RQ106_Anticipo; páginas Opportunity VN/VU; componentes LWC relacionados; disponibilidad de datos completos para QA formal. |
| Componentes incluidos | LWC vnRq106SolicitudesAnticipos; LWC vnRq106OpportunityOverview; Quick Action Opportunity.VN_RQ106_Solicitudes_Anticipos; páginas Opportunity_Record_Page_VN y Opportunity_Record_Page_VU. |
| Validación de deployment | Deploy a Sandbox exitoso. Validación técnica de componentes completada. |
| Observaciones | Producción permanece sin cambios y queda pendiente de autorización, QA formal, evidencia visual y validación final. |
| Rollback | Pendiente de validación para Producción. En Sandbox, el rollback sería retirar la acción de las páginas VN/VU y restaurar el overview embebido si negocio lo requiere. |

## Orden Correcto de Deployment

| Paso | Descripción |
| --- | --- |
| 1 | Confirmar aprobación del alcance y ambiente destino. |
| 2 | Validar disponibilidad de datos de prueba completos para QA. |
| 3 | Desplegar primero los Lightning Web Components relacionados. |
| 4 | Desplegar la Quick Action de Opportunity. |
| 5 | Desplegar ajustes de Lightning Record Pages VN y VU. |
| 6 | Validar permisos del Permission Set VN_RQ106_Anticipo para los perfiles QA definidos. |
| 7 | Ejecutar QA manual, registrar evidencia y confirmar resultados antes de cualquier pase productivo. |

## Permisos y Accesos

| Tipo | Nombre | Uso / Descripción | Acción Realizada |
| --- | --- | --- | --- |
| Permission Set | VN_RQ106_Anticipo | Permisos funcionales para VN-RQ106 sobre componentes y datos relacionados. | Configurado y validado en Sandbox. |
| Asignaciones activas | 28 asignaciones activas | Usuarios con el permission set asignado para validación en Sandbox. | Validadas. |
| Perfil QA | Asesor de Ventas BMW y Nuevos V2 | Perfil cubierto para validación funcional. | Cubierto por permisos/perfiles configurados. |
| Perfil QA | Asesor de Ventas Kawa - Polaris y Nuevos V2 | Perfil cubierto para validación funcional. | Cubierto por permisos/perfiles configurados. |
| Perfil QA | Asesor de Ventas Motorrad-Kawa-Polaris y Nuevos V2 | Perfil cubierto para validación funcional. | Cubierto por permisos/perfiles configurados. |
| Perfil QA | Asesor Ventas Autos Usados | Perfil cubierto para validación funcional. | Cubierto por permisos/perfiles configurados. |
| Perfil QA | Asesor Ventas Motos Usados v2 | Perfil cubierto para validación funcional. | Cubierto por permisos/perfiles configurados. |
| Checklist Dev | Permisos / perfiles configurados | Checklist de permisos y perfiles con evidencia. | Llenado con evidencia disponible. |

## Cobertura de Código

| Clase de Test | Coverage % | Resultado |
| --- | --- | --- |
| VN_RQ106_OppOverviewCtrlTest | Pendiente de consolidación | Clase relacionada identificada en el repositorio. Resultado final pendiente de consolidación. |
| VN_RQ106_AnticipoControllerTest | Pendiente de consolidación | Clase relacionada identificada en el repositorio. Resultado final pendiente de consolidación. |
| Validación técnica de deployment | No aplica | Exitosa en RedMotors Sandbox Partial. |
| Cobertura general | Pendiente de validación | Pendiente de validación final antes de Producción. |

## Casos Probados

| Caso de Prueba | Resultado Esperado | Resultado Real | Estado | Evidencia |
| --- | --- | --- | --- | --- |
| Botón Solicitudes anticipos en Opportunity VN | El botón aparece en la página Opportunity VN. | Implementado; pendiente QA formal con Opportunity BMW completa. | Pendiente de validación | Pendiente de evidencia visual. |
| Botón Solicitudes anticipos en Opportunity VU | El botón aparece en la página Opportunity VU. | Implementado; pendiente QA formal. | Pendiente de validación | Pendiente de evidencia visual. |
| Apertura de modal | El botón abre un modal nativo de Salesforce. | Implementado en Bloque A. | Pendiente de validación | Pendiente de video/evidencia. |
| Carga del overview dentro del modal | El modal muestra la funcionalidad del overview reutilizado. | Implementado mediante vnRq106OpportunityOverview. | Pendiente de validación | Pendiente de evidencia formal. |
| Retiro de overview embebido | El overview ya no aparece embebido en la vista principal. | Implementado en páginas VN/VU. | Pendiente de validación | Pendiente de evidencia visual. |
| Botón Registrar ingreso / anticipo | El botón original continúa funcionando desde su acción correspondiente. | Pendiente de validación formal en QA. | Pendiente de validación | Pendiente de evidencia. |
| Permission Set VN_RQ106_Anticipo | Perfiles QA pueden acceder según permisos definidos. | Configurado y validado en Sandbox; 28 asignaciones activas. | Validado parcialmente | Checklist Dev con evidencia. |
| Opportunity BMW completa | Opportunity BMW con VIN, familia y datos completos para QA formal. | Pendiente de disponibilidad. | Pendiente de validación | Pendiente. |
| Aprobación de reserva | Flujo funcional de aprobación de reserva validado. | No incluido como completado en Bloque A. | Pendiente de validación | Pendiente. |
| Rechazo de reserva | Rechazo registra decisión sin cambiar Anticipo__c.Estatus__c. | Pendiente funcional. | Pendiente de confirmación | Pendiente. |
| Reenvío de solicitud de reserva | Reenvío funcional validado y limpieza de estado de aprobación producto si aplica. | Pendiente funcional. | Pendiente de confirmación | Pendiente. |
| Integraciones / logs | Integraciones y logs finales validados. | Pendiente de validación final. | Pendiente de validación | Pendiente. |

## Integraciones

| Sistema / API | Servicio | Método | Autenticación | Configuración | Observaciones |
| --- | --- | --- | --- | --- | --- |
| Helios | Integración relacionada | No modificado en Bloque A | Pendiente de validación funcional | Pendiente de confirmación | No modificado en Bloque A. Ticket Helios corresponde al Id Helios. Enlace Helios pendiente de confirmación. |
| Softland | Integración relacionada | No modificado en Bloque A | Pendiente de validación funcional | Pendiente de confirmación | No modificado en Bloque A. PDF real y errores de integración quedan pendientes de validación funcional. |
| Salesforce | Componentes internos del módulo | No aplica | No aplica | No aplica | Bloque A corresponde a interfaz, acción rápida, páginas y permisos en Salesforce. |
| Logs de integración | Trazabilidad operativa | Pendiente de validación | Pendiente de validación | Pendiente de confirmación | Validación final de integraciones/logs pendiente. |

## Variables / JSON Examples

| Elemento | Detalle |
| --- | --- |
| Id Helios | Confirmado como referencia funcional para ticket Helios. |
| Enlace Helios | Pendiente de confirmación. |
| PDF Softland | Pendiente de validación funcional; fuera de los cambios de Bloque A. |
| Errores de integración | Pendiente de validación final. |
| Información sensible de integración | No se incluye información sensible de integración en este documento. |

## Riesgos o Limitaciones

| Riesgo / Limitación | Impacto | Mitigación / Comentario |
| --- | --- | --- |
| QA formal no completado | No se puede cerrar QA ni recomendar Producción sin evidencia completa. | Ejecutar QA formal con Opportunity BMW con VIN, familia y datos completos. |
| Videos de evidencia pendientes | Falta soporte visual para cierre funcional. | Completar videos de evidencia antes de cierre final. |
| Aprobación de reserva pendiente | Funcionalidad de reserva no queda cerrada en Bloque A. | Mantener como pendiente funcional y validar reglas de notificación. |
| Rechazo de reserva pendiente | Debe registrar decisión sin cambiar Anticipo__c.Estatus__c. | Definir y validar campo Estado de aprobación producto en Anticipo__c. |
| Notificaciones de reserva pendientes | Riesgo de notificar destinatarios incorrectos. | Confirmar notificación a Owner y GerenteSucursal__c; no notificar al usuario que aprueba/rechaza. |
| Reenvío de solicitud de reserva pendiente | Puede requerir alcance adicional y validación separada. | Pendiente de confirmación; debe limpiar estado de aprobación producto al reenviar si se confirma. |
| Textos finales de correos pendientes | Los correos de rechazo/reenvío pueden requerir ajustes posteriores. | Confirmar textos finales antes de entrega productiva. |
| Integraciones y logs pendientes | Riesgo de comportamiento no validado con sistemas externos. | Validación final de integraciones/logs antes de Producción. |

## Versionado

| Versión | Fecha | Responsable | Cambios Realizados |
| --- | --- | --- | --- |
| 0.1 | 2026-06-10 | Equipo Salesforce RedMotors | Documento técnico de entrega preparado para Bloque A en RedMotors Sandbox Partial. |
| 0.2 | 2026-06-10 | Equipo Salesforce RedMotors | Revisión v2: se amplía deployment, integraciones, Apex relacionado, entregables, evidencias y pendientes funcionales. |
| 1.0 | Pendiente de validación | Equipo Salesforce RedMotors | Versión final para cierre funcional, sujeta a aprobación QA y autorización de Producción. |

## Evidencia Visual

| Tipo de Evidencia | Descripción | Ubicación / Link |
| --- | --- | --- |
| Checklist Dev | Permisos/perfiles configurados con evidencia. | Disponible en checklist de permisos/perfiles. |
| Metadata / deployment Sandbox | Deploy exitoso a RedMotors Sandbox Partial. | Evidencia técnica disponible o pendiente de link final. |
| Asignaciones permission set | 28 asignaciones activas validadas. | Evidencia disponible en checklist de permisos/perfiles. |
| Opportunity BMW completa | Evidencia requerida con VIN, familia y datos completos. | Pendiente de validación. |
| Videos QA | Videos de botón, modal, carga de información y flujo relacionado. | Pendiente de validación. |
| Casos formales de QA | Casos manuales iniciales para VN BMW asesor. | Pendiente de ejecución formal y evidencia final. |
| Aprobación/rechazo reserva | Evidencia del flujo de aprobación o rechazo de reserva. | Pendiente de validación. |
| Reenvío de reserva | Evidencia del reenvío si se confirma alcance. | Pendiente de confirmación. |
| Integraciones/logs | Evidencia de validación final de integraciones y logs. | Pendiente de validación. |
| Evidencias Drive | Links finales de videos/capturas. | Pendiente de validación. |

## Entregables Finales

| Archivo / Carpeta | Incluido | Observaciones |
| --- | --- | --- |
| /docs | Sí | Documentación técnica y evidencia local del proyecto. |
| /force-app | Sí | Componentes Salesforce relacionados con el Bloque A y módulos VN-RQ106. |
| package.xml | Pendiente / si aplica | Confirmar si se entrega manifiesto específico para pase final. |
| README.md o sección README técnico | Sí | Resumen técnico incluido en este documento. Archivo independiente pendiente si negocio lo requiere. |
| deployment-guide.md o instrucciones de deployment | Sí | Instrucciones de deployment incluidas en este documento. Archivo independiente pendiente si se solicita. |
| test-cases.xlsx / Template QA | Pendiente | Template QA y links de evidencia pendientes de cierre formal. |
| Evidencias Drive | Pendiente | Videos/capturas y links finales pendientes. |
| Documento técnico de entrega | Parcial / Borrador en revisión | Este documento consolida el estado del Bloque A para revisión. |
| Componentes de interfaz y acción rápida | Sí | LWC, Quick Action y páginas VN/VU desplegados en Sandbox. |
| Permission Set VN_RQ106_Anticipo | Sí | Configurado y validado en Sandbox. |
| Producción | No | Producción sin cambios. |

## README Técnico

| Elemento | Detalle |
| --- | --- |
| Descripción funcional | Bloque A de VN-RQ106 implementa el acceso desde Opportunity al botón Solicitudes anticipos, abriendo un modal que reutiliza el overview operativo de solicitudes y anticipos. |
| Arquitectura | Solución basada en Lightning Web Components, Quick Action de Opportunity, Lightning Record Pages VN/VU, controladores Apex relacionados y Permission Set de acceso. |
| Dependencias | Depende de Opportunity, Anticipo__c, Product2, permisos de usuario y configuración de páginas Lightning. Integraciones Helios/Softland quedan pendientes de validación funcional. |
| Pendientes funcionales principales | Campo Estado de aprobación producto en Anticipo__c; aprobación y rechazo de reserva; reenvío de solicitud; limpieza de estado al reenviar; textos finales de correos rechazo/reenvío; enlace Helios. |
| Regla de rechazo de reserva | Pendiente de confirmación: al rechazar reserva no debe modificarse Anticipo__c.Estatus__c; la decisión debe registrarse en campo de aprobación producto. |
| Regla de notificación reserva | Pendiente de confirmación: notificar a Owner y GerenteSucursal__c, sin notificar al usuario que aprueba/rechaza. |
| Pasos de instalación | Desplegar componentes del Bloque A en orden: LWC, Quick Action, páginas Lightning y validación de permisos. Producción requiere aprobación y QA formal previo. |
| Troubleshooting | Si el botón no aparece, revisar asignación de página Lightning y permisos del usuario. Si el modal no carga, validar acceso al LWC reutilizado y permisos sobre datos relacionados. |
| Operación técnica | No se incluyen instrucciones internas ni información sensible en este documento oficial. |

## Checklist Final

| Validación | Completado | Observaciones |
| --- | --- | --- |
| Tests ejecutados | Parcial | Validación técnica de deploy completada. QA formal pendiente. |
| Flow activado | No aplica / relacionado | Flow VN_RQ106_Notificaciones_Anticipo relacionado, sin cambios funcionales nuevos en Bloque A. |
| Permission Sets asignados | Sí | VN_RQ106_Anticipo configurado; 28 asignaciones activas validadas. |
| Deployment validado | Sí | Deploy exitoso a RedMotors Sandbox Partial. |
| Documentación entregada | Parcial / Borrador en revisión | Faltan QA formal, videos de evidencia y validación final. |
| QA aprobado | No | Pendiente QA formal, videos de evidencia y casos formales. |
| Cobertura validada | Pendiente | Pendiente de consolidación de resultados finales. |
| Rollback documentado | Parcial | Estrategia conceptual documentada; rollback productivo pendiente de confirmación si aplica. |
| Producción modificada | No | Producción sin cambios. |
