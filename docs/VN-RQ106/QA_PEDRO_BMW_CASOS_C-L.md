# Guía QA Usuario QA - VN-RQ106 BMW Asesor

## 1. Objetivo

Usuario QA apoyará ejecutando pruebas, grabando videos, tomando capturas y subiendo evidencias para la pestaña "Casos de prueba: Nuevos-BMW-Asesor (C-L)".

## 2. Alcance de Usuario QA

Estado al 2026-06-11: Usuario QA puede iniciar solo evidencia básica/no destructiva. La QA completa sigue bloqueada hasta resolver el envío a Tesorería con Helios/Softland y validar el flujo completo en Sandbox.

Usuario QA puede:

- ejecutar pruebas manuales;
- grabar videos;
- tomar capturas;
- subir evidencias a Drive;
- pegar links en el Excel;
- marcar OK, Falló o Pendiente;
- registrar observaciones.

Usuario QA no debe:

- modificar configuración Salesforce;
- modificar metadata;
- crear datos por Apex;
- crear datos por CLI;
- cambiar permisos;
- tocar Producción;
- cambiar Flow/correos;
- corregir errores por cuenta propia.
- crear un nuevo anticipo real para evidencia final;
- enviar solicitudes a Tesorería;
- aprobar reserva;
- rechazar reserva;
- reenviar solicitud;
- ejecutar pruebas destructivas sobre la Opportunity reservada para evidencia funcional.

Motivo del bloqueo:

- El envío a Tesorería depende de confirmación Helios/Softland.
- Salesforce ya envía `cliente` con el código Softland del cliente, pero Helios/Softland continúa respondiendo que el parámetro `@cliente` no fue suministrado.
- El anticipo QA permanece en `Borrador` porque la integración no confirma el envío.

## 3. Ambiente

- Ambiente: RedMotors Sandbox Partial.
- App: Ventas.
- Objeto principal: Opportunity.
- Flujo de creación de oportunidad: Ventas -> Ver inventario -> seleccionar vehículo BMW disponible -> crear Opportunity.

## 4. Usuario sugerido

- Usuario: Usuario QA asesor BMW.
- Estado de validación: listo con observaciones; usuario encontrado y activo en RedMotors Sandbox Partial, con perfil y rol alineados a BMW/Nuevos.
- Username: usuario QA asesor en Sandbox.
- Perfil: Asesor de Ventas BMW y Nuevos V2.
- Rol: Asesor de Ventas Online BMW.
- Cargo: ASESOR DE VENTAS - AUTOS NUEVOS BMW.
- Sucursal: Uruca.
- Indicador BMW visible: Last Assigned BMW activo.
- Permisos relevantes identificados:
  - Perfil: Asesor de Ventas BMW y Nuevos V2.
  - Acceso por perfil a Opportunity, Anticipo, Account, Contact y Product2.
  - Acceso Apex confirmado a VN_RQ106_AnticipoController.
  - Lightning experience user.
  - CalendarAnything LWC Default Permission Set.
  - DocuSign User.
  - Field Service Agent License.
  - Field Service Agent Permissions.
  - RM - Líder de Taller.
  - Usuario Service.
- Permisos VN-RQ106/Anticipo pendientes:
  - No se confirmó asignación del permission set VN RQ106 Anticipo a Usuario QA Asesor.
  - No se confirmó acceso Apex de Usuario QA Asesor a VN_RQ106_OpportunityOverviewController, requerido por el modal Solicitudes anticipos.
  - No se confirmó por metadata la visibilidad real de Ver inventario para Usuario QA Asesor.
- Instrucción: Usuario QA no debe iniciar evidencia formal hasta que el equipo funcional/técnico valide en UI que Usuario QA Asesor puede abrir Ver inventario, crear la Opportunity desde inventario, ver el botón Solicitudes anticipos y abrir el modal sin error.

## 5. Creación correcta de Opportunity

Usuario QA debe preparar la Opportunity desde el flujo real antes de iniciar la grabación principal:

1. Entrar a RedMotors Sandbox Partial.
2. Abrir app Ventas.
3. Entrar a Ver inventario.
4. Buscar un vehículo BMW disponible.
5. Seleccionar el vehículo.
6. Crear Opportunity con cuenta válida.
7. Confirmar que la Opportunity quede con datos completos.
8. No iniciar video de evidencia hasta tener la Opportunity creada y validada.

Checklist de Opportunity válida:

- Cuenta completa.
- Producto/vehículo relacionado.
- VIN/BIN visible.
- Sucursal completa.
- Gerente de sucursal completo.
- Jefe de sucursal / jefe de producto completo.
- Owner correcto.
- Correo del cliente presente.
- Botones de VN-RQ106 visibles.

## 6. Carpeta de evidencias

Usar:

Carpeta de evidencias -> Vh nuevos

Subcarpeta sugerida:

BMW - Equipo funcional/técnico

Formato de nombres:

TC-ID_Modulo_Descripcion_BMW.mp4

Ejemplos:

- TC-BMW-A01_Opportunity_Boton_Solicitudes_Anticipos_BMW.mp4
- TC-BMW-A02_Opportunity_Modal_Solicitudes_Anticipos_BMW.mp4
- TC-BMW-A03_Opportunity_Registrar_Ingreso_Anticipo_BMW.mp4

## 7. Casos iniciales para Usuario QA - Bloque A

| ID | Escenario | Precondición | Pasos | Resultado esperado | Evidencia requerida | Nombre sugerido de video | Qué registrar en Excel |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TC-BMW-A01 | Validar botón Solicitudes anticipos visible en Opportunity VN BMW. | Opportunity BMW creada desde Ver inventario y abierta con Usuario QA Asesor. | Abrir la Opportunity y revisar las acciones disponibles en la parte superior. | El botón "Solicitudes anticipos" está visible. | Video o captura de la cabecera de la Opportunity. | TC-BMW-A01_Opportunity_Boton_Solicitudes_Anticipos_BMW.mp4 | Estado, link de evidencia y observación si el botón no aparece. |
| TC-BMW-A02 | Validar que el overview incrustado ya no aparezca en la parte superior de Opportunity. | Opportunity BMW creada desde Ver inventario. | Abrir la Opportunity y revisar la parte superior de la página. | La sección de anticipos no aparece incrustada como bloque fijo en la parte superior. | Video corto o captura de la parte superior. | TC-BMW-A02_Opportunity_Overview_No_Incrustado_BMW.mp4 | Confirmar OK si no aparece incrustado; Falló si sigue visible. |
| TC-BMW-A03 | Validar que el botón Solicitudes anticipos abre modal. | Botón "Solicitudes anticipos" visible. | Hacer clic en "Solicitudes anticipos". | Se abre un modal con la información de solicitudes/anticipos. | Video del clic y apertura del modal. | TC-BMW-A03_Opportunity_Modal_Solicitudes_Anticipos_BMW.mp4 | Indicar si el modal abrió correctamente o registrar mensaje de error. |
| TC-BMW-A04 | Validar que el modal carga información de ingresos y anticipos. | Modal abierto. | Revisar que el modal muestre la información disponible de ingresos/anticipos para la Opportunity. | El modal carga sin error y presenta la información del módulo VN-RQ106. | Video o captura del modal cargado. | TC-BMW-A04_Modal_Carga_Ingresos_Anticipos_BMW.mp4 | Registrar si carga completo, vacío correctamente o con error. |
| TC-BMW-A05 | Validar que dentro del modal no aparece el botón interno Registrar ingreso / anticipo. | Modal abierto desde "Solicitudes anticipos". | Revisar visualmente las acciones internas del modal. | Dentro del modal no se muestra el botón interno "Registrar ingreso / anticipo". | Captura o video del modal. | TC-BMW-A05_Modal_Sin_Boton_Interno_Registrar_Ingreso_BMW.mp4 | Confirmar OK si no aparece; Falló si aparece dentro del modal. |
| TC-BMW-A06 | Validar que el modal se puede cerrar sin congelar la Opportunity. | Modal abierto. | Cerrar el modal con la X o botón de cierre disponible. Luego navegar o refrescar visualmente la Opportunity. | El modal cierra correctamente y la Opportunity queda usable. | Video cerrando el modal y mostrando la Opportunity activa. | TC-BMW-A06_Modal_Cierre_Sin_Bloqueo_BMW.mp4 | Registrar OK si la página sigue respondiendo. |
| TC-BMW-A07 | Validar que el botón original Registrar ingreso / anticipo sigue funcionando. | Opportunity BMW abierta y botón original visible. | Hacer clic en "Registrar ingreso / anticipo". | Se abre el flujo/modal original para registrar ingreso/anticipo. | Video del botón original funcionando. | TC-BMW-A07_Opportunity_Registrar_Ingreso_Anticipo_BMW.mp4 | Registrar OK o el mensaje exacto si falla. |

## 8. Evidencia básica permitida ahora

Usuario QA puede grabar únicamente estos escenarios no destructivos:

1. Abrir la Opportunity de prueba indicada por el equipo funcional.
2. Mostrar el botón `Solicitudes anticipos`.
3. Abrir el modal.
4. Validar que carga el overview.
5. Validar que la tabla de solicitudes se muestra.
6. Validar que no hay error visual en el modal.

Reglas para esta evidencia:

- No crear nuevos anticipos.
- No enviar a Tesorería.
- No aprobar, rechazar ni reenviar reservas.
- No modificar registros manualmente.
- No usar Producción.
- Si aparece un error, grabar/capturar y reportar el mensaje exacto.

## 9. Casos que Usuario QA NO debe ejecutar todavía

- Aprobar reserva.
- Rechazar reserva.
- Reenvío de reserva.
- Crear nuevo anticipo real.
- Enviar a Tesorería.
- Evidencia final de flujo completo.
- Pruebas destructivas sobre Opportunity reservada para evidencia funcional.
- Correos finales.
- Cambios de Flow.
- Cambios de permisos.
- Pruebas en Producción.
- Pruebas sin Opportunity creada desde Ver inventario.

## 10. Pendientes para liberar QA completa

Antes de pedir a Usuario QA la evidencia final:

1. Recibir respuesta del equipo de integración sobre el error Helios/Softland.
2. Confirmar si backend corrige el mapeo de `cliente`.
3. Reintentar envío del anticipo QA `Anticipo QA Sandbox`.
4. Confirmar cambio de estatus e `Identificador_Helios__c`.
5. Llevar anticipo a estado `Confirmada por Tesorería`.
6. Probar aprobar/rechazar/reenvío con usuario `JefeSucursal__c`.
7. Preparar instrucciones finales para Usuario QA.
8. Actualizar Excel QA y documentación oficial Drive.

## 11. Qué hacer si falla algo

Usuario QA debe:

1. No corregir configuración.
2. Tomar captura.
3. Grabar video si es posible.
4. Copiar mensaje exacto de error.
5. Registrar observación en Excel.
6. Avisar al equipo funcional/técnico.

## 12. Checklist antes de iniciar

- [ ] Usuario confirmado.
- [ ] Opportunity creada desde Ver inventario.
- [ ] VIN/BIN presente.
- [ ] Producto relacionado presente.
- [ ] Jefe de sucursal presente.
- [ ] Gerente de sucursal presente.
- [ ] Carpeta de evidencias abierta.
- [ ] Excel abierto en pestaña correcta.
- [ ] Grabador de pantalla listo.
- [ ] No estar en Producción.
- [ ] Confirmado que solo se ejecutará evidencia básica/no destructiva.

## 13. Resultado esperado del apoyo de Usuario QA

- Videos en Drive.
- Links pegados en Excel.
- Estados actualizados.
- Observaciones claras.
- Fallos reportados sin modificar configuración.
