# Lotes propuestos — Sprint 3

Fecha de corte: 5 de agosto de 2026. Ningún lote de este documento está autorizado para implementación automática.

## Lote S3-0 — Inventario y conciliación declarativa

- **Requerimientos incluidos:** S3-LYT-01/03, S3-FLX-02/03, S3-QA-01/05, S3-LV-01/03, S3-SEC-01/03, S3-VAL-01 y S3-APR-01, únicamente en modo inventario.
- **Componentes:** layouts de Opportunity, Account y Product2; páginas Opportunity/Quote; cinco Quick Actions; List Views; perfiles, Permission Sets, roles/sharing; Validation Rules y Approval Processes.
- **Motivo del agrupamiento:** crear una fuente nominal antes de decidir qué metadata necesita cambio.
- **Dependencias:** acceso de lectura a Partial y documentación existente.
- **Riesgo:** bajo; el principal riesgo es clasificar como pendiente algo ya cubierto.
- **Validación técnica:** retrieve temporal, comparación semántica, activaciones, asignaciones y referencias.
- **Validación funcional:** no aplica en este lote salvo revisión visual sin cambios.
- **Evidencia:** inventario nominal, diff, matriz Git–Partial y capturas de asignación.
- **Condición para comenzar:** repositorio limpio y manifest de lectura limitado.
- **Condición para cerrar:** cada componente queda como coincidente, diferencia justificada, bloqueado o no aplica.
- **Posibilidad de reversión:** total; no modifica metadata.

## Lote S3-1 — Validaciones de bajo riesgo ya cubiertas

- **Requerimientos incluidos:** S3-LYT-03, S3-FLX-02, S3-LV-01, S3-SEC-02, S3-CMD-03, S3-GVS-01 y S3-E2E-03.
- **Componentes:** Product2 layouts; 'Opportunity_Record_Page_VN'; ocho List Views Omoda/Jaecoo; 'Empresa_Admin'; 'Vehiculos_Nuevos_PS'; mappings Lead→Opportunity; valores de marca/familia.
- **Motivo del agrupamiento:** confirmar trabajo preexistente sin volver a implementarlo.
- **Dependencias:** perfiles QA y datos existentes que no requieran creación artificial.
- **Riesgo:** bajo; asignaciones o visibilidad podrían diferir aunque la metadata exista.
- **Validación técnica:** consistencia Git–Partial, referencias y pruebas negativas.
- **Validación funcional:** visibilidad por Record Type, conversión Lead y regresión Bavarian/Otobai.
- **Evidencia:** capturas, resultados por perfil QA y trazabilidad de metadata.
- **Condición para comenzar:** cierre de S3-0 para estos componentes.
- **Condición para cerrar:** evidencia de asignación y comportamiento; cualquier diferencia pasa a S3-2.
- **Posibilidad de reversión:** total si se limita a validación.

## Lote S3-2 — Configuración declarativa independiente

- **Requerimientos incluidos:** únicamente filas que S3-0 reclasifique como 'EJECUTABLE' con evidencia.
- **Componentes:** posibles layouts, FlexiPages, Quick Actions o List Views sin dependencia comercial.
- **Motivo del agrupamiento:** aplicar cambios pequeños, declarativos y verificables.
- **Dependencias:** decisión técnica documentada por componente; ninguna definición de negocio pendiente.
- **Riesgo:** medio por activaciones y asignaciones.
- **Validación técnica:** validación estructural, dry-run limitado y comparación posterior.
- **Validación funcional:** prueba por Record Type y perfil QA.
- **Evidencia:** diff, ID de validación/deploy cuando se autorice, capturas y reversión.
- **Condición para comenzar:** aprobación explícita de la lista exacta después de S3-0.
- **Condición para cerrar:** metadata coincidente, prueba exitosa y sin regresiones.
- **Posibilidad de reversión:** alta mediante versión anterior recuperada y manifest limitado.

## Lote S3-3 — Pricebooks y Custom Metadata comercial

- **Requerimientos incluidos:** S3-CMD-01, S3-PRC-01 y S3-PRC-02.
- **Componentes:** 'RM_Config.Default_Price_List_VN', asociaciones Empresa–Pricebook y PricebookEntry oficiales.
- **Motivo del agrupamiento:** comparten configuración comercial y escenarios del resolver.
- **Dependencias:** decisión de lista predeterminada; productos, precios y monedas oficiales; autorización de datos separada.
- **Riesgo:** alto por impacto en cotización y selección de precios.
- **Validación técnica:** tests de 'EmpresaPricebookResolver' y estados 'EXITO', 'NO_CONFIGURADO', 'SELECCION_REQUERIDA', 'ERROR'.
- **Validación funcional:** Quote real por Empresa, varias opciones válidas y ausencia de Pricebook.
- **Evidencia:** conteos, muestreo, resultados del resolver y video.
- **Condición para comenzar:** configuración comercial aprobada y archivo de carga oficial.
- **Condición para cerrar:** ninguna ruta continúa con ID nulo o selección ambigua.
- **Posibilidad de reversión:** media; requiere respaldo y plan de reversión de registros.

## Lote S3-4 — Integración Softland e inventario VN

- **Requerimientos incluidos:** S3-SFT-01, S3-SFT-02 y S3-INV-01.
- **Componentes:** 'BatchGetBodegaSoftland', 'BatchGetCatalogoSoftland', Product2 y configuración oficial de bodegas.
- **Motivo del agrupamiento:** catálogo y bodegas son dependencias compartidas de inventario.
- **Dependencias:** configuración Softland, bodegas y catálogo oficiales; responsables técnicos de Red Motors.
- **Riesgo:** alto por integración y datos maestros.
- **Validación técnica:** tests Apex, manejo de error, logs sin secretos y procesamiento explícito de PEKING.
- **Validación funcional:** inventario VN por Empresa, sin cruces con Bavarian/Otobai.
- **Evidencia:** logs controlados, muestreo, capturas y video E2E.
- **Condición para comenzar:** datos y configuración oficiales disponibles.
- **Condición para cerrar:** tercera Empresa procesada o error entendible sin selección arbitraria.
- **Posibilidad de reversión:** media; separar metadata, configuración y datos en pasos independientes.

## Lote S3-5 — Postventa, accesos y aprobaciones

- **Requerimientos incluidos:** S3-LYT-02, S3-FLX-03, S3-QA-01/05 bloqueadas, S3-LV-03, S3-SEC-01/03 y S3-APR-01.
- **Componentes:** Account/Quote/WorkOrder declarativo, List Views, accesos y procesos de aprobación.
- **Motivo del agrupamiento:** dependen de decisiones comunes de sucursal, territorio, taller, servicio, garantía y responsables.
- **Dependencias:** respuestas de negocio y estado de los cinco Flows pausados.
- **Riesgo:** alto por seguridad, agenda, garantía y operación de taller.
- **Validación técnica:** asignaciones, referencias, acceso efectivo y estados activo/inactivo.
- **Validación funcional:** recorridos por perfil, Empresa y taller; aprobaciones positivas y negativas.
- **Evidencia:** matriz de acceso, diagramas aprobados, capturas y videos.
- **Condición para comenzar:** decisiones oficiales completas; no basta con supuestos técnicos.
- **Condición para cerrar:** procesos aislados por Empresa y sin ampliar el alcance de Sprint 2.
- **Posibilidad de reversión:** media; cambios pequeños por tipo de metadata y respaldo previo.

## Lote S3-6 — E2E, regresión, videos y cierre

- **Requerimientos incluidos:** S3-E2E-01, S3-E2E-02 y S3-E2E-03.
- **Componentes:** ventas, inventario, documentos, postventa, integración, permisos y errores controlados.
- **Motivo del agrupamiento:** producir evidencia transversal después de estabilizar los lotes anteriores.
- **Dependencias:** datos oficiales, perfiles QA y bloques funcionales aprobados.
- **Riesgo:** medio; los defectos pueden revelar dependencias no inventariadas.
- **Validación técnica:** suite repetible y trazabilidad de cada resultado.
- **Validación funcional:** Bavarian, Otobai y PEKING; positivos y negativos.
- **Evidencia:** videos, capturas, resultados, defectos y matriz final.
- **Condición para comenzar:** cada recorrido tiene datos válidos y configuración conocida.
- **Condición para cerrar:** todo el alcance original está revisado con evidencia y los bloqueos restantes están asignados.
- **Posibilidad de reversión:** no aplica a evidencia; cualquier corrección debe ejecutarse en un lote propio.

## Lote separado — Ampliaciones RQ308

S3-EXT-01, S3-EXT-02 y S3-EXT-03 no forman parte de los lotes ejecutables. Solo pueden planificarse después de una autorización de alcance o control de cambios.

## Recomendación de inicio

El primer lote recomendado es **S3-0 — Inventario y conciliación declarativa**. Es reversible, no requiere decisiones funcionales y evita duplicar trabajo ya realizado.
