# VN-RQ106 - Estado QA y evidencias 2026-06-11

Documento interno de control. No usar como documento oficial sin revisión.

## 1. Estado técnico actual

- Proyecto: RedMotors VN-RQ106.
- Sandbox: `RedMotorsSandbox`.
- Producción: sin cambios.
- Opportunity QA usada:
  - Id: Opportunity QA Sandbox.
  - Nombre: `Opportunity QA Sandbox`.
- Anticipo QA:
  - Id: Anticipo QA Sandbox.
  - Nombre: `Anticipo QA Sandbox`.
- Estado actual del anticipo:
  - `Estatus__c = En validación de Tesorería`.
  - `Estado_Aprobacion_Producto__c = Pendiente`.
  - `Identificador_Helios__c` generado por Helios/Softland.
- Datos confirmados en Opportunity/cuentas:
  - `empresaQueFactura__c = Bavarian`.
  - `Account.codigoSoftland__c` contiene el código Softland del cliente.
  - `Cuenta_de_Facturaci_n__r.codigoSoftland__c` contiene el código Softland del cliente.

## 2. Avances validados

- Borrador creado correctamente desde UI.
- Borrador existente se puede retomar desde el formulario.
- Botón cambia a `Actualizar borrador`.
- Evidencia se puede adjuntar.
- Validaciones visibles en formulario:
  - Campos obligatorios completos: Listo.
  - Evidencia presente: Listo.
  - Oportunidad activa: Listo.
  - Cliente relacionado: Listo.
  - Monto mayor a cero: Listo.
  - Preparado para Tesorería: Listo.
- Se corrigió el payload Salesforce para incluir:
  - `codigoSoftland = código Softland del cliente`.
  - `cliente = código Softland del cliente`.
- Envío inicial a Helios/Softland validado:
  - La solicitud ya no presenta error por parámetro `cliente`.
  - Helios genera identificador externo.
  - El anticipo queda en estado `En validación de Tesorería`.
  - La aprobación o rechazo posterior queda pendiente del proceso externo en Helios.
  - PDF Softland continúa pendiente hasta que el proceso externo avance.
- Deploy Sandbox del fix `cliente`:
  - Deploy Id: `0AfNq00000XqkyDKAR`.
  - Tests: `VN_RQ106_AnticipoControllerTest`.
  - Resultado: `35/35` exitosos.
  - Componentes: `SolicitudAprobacionTesoreria`, `VN_RQ106_AnticipoController`, `VN_RQ106_AnticipoControllerTest`.

## 3. Estado de integración Helios/Softland

- El envío inicial desde Salesforce hacia Helios/Softland ya fue validado correctamente.
- Salesforce envía `cliente` con el código Softland del cliente.
- Helios/Softland genera identificador externo.
- El anticipo queda en `En validación de Tesorería`.
- La aprobación o rechazo posterior queda pendiente del proceso externo en Helios.
- PDF Softland continúa pendiente hasta que el proceso externo avance.

## 3.1 Bloque B.2 — Notificaciones de reserva

- Se creó el documento `docs/VN-RQ106/BLOQUE_B2_NOTIFICACIONES_RESERVA.md`.
- Contenido documentado:
  - Correo de reenvío de solicitud de reserva.
  - Correo de producto/reserva rechazada.
  - Variables Salesforce sugeridas.
  - Pendientes funcionales.
  - Pendientes técnicos.
  - Criterios de aceptación.
- Estado: implementado y validado funcionalmente en Sandbox; pendiente confirmar configuración productiva final de destinatarios.

## 3.1.1 Cierre de correos VN-RQ106 — Sandbox 2026-06-12

Se desplegó y activó una nueva versión del Flow `VN_RQ106_Notificaciones_Anticipo` con textos corregidos según plantillas de negocio.

Deploy:

- Flow: `VN_RQ106_Notificaciones_Anticipo`.
- Deploy ID: `0AfNq00000Xt7U5KAJ`.

Correos validados funcionalmente:

1. `Solicitud enviada a Tesorería`
   - Incluye resumen de solicitud.
   - Incluye cliente, asesor, tipo de ingreso, monto, medio de pago, fecha de ingreso, referencia/comprobante, depositante, vehículo/VIN, Ticket Helios y enlace Helios.
2. `Vehículo reservado`
   - Incluye vendedor, oportunidad, cliente, vehículo, VIN, reservado por, fecha/hora de reserva y estado `Vehículo reservado`.
3. `Reserva rechazada`
   - Mantiene texto aprobado.
   - Se ajustaron negritas y formato.
4. Reenvío de solicitud de reserva
   - No tuvo plantilla adicional nueva.
   - Se mantiene sin cambio de texto.

Estado:

- Flow actualizado y validado en Sandbox.
- Correos corregidos según plantillas de negocio.
- Pendiente para Producción: confirmar destinatarios/configuración productiva final antes del pase.

## 3.1.2 Hotfixes post-checkpoint 2026-06-12

### Hotfix Tesorería — `sObject type 'Organization' is not supported`

- Problema: Error al enviar anticipo a Tesorería por perfiles sin acceso al objeto Organization.
- Clases: `SoftlandEndpointService`, `SolicitudAprobacionTesoreria`.
- Deploy `SoftlandEndpointService`: `0AfNq00000XtJmzKAF`.
- Deploy `SolicitudAprobacionTesoreria`: `0AfNq00000XtBr5KAF`.
- Validación: Paola/Jorge reintentaron con ANT-01228 — sin error.
- Estado: **validado en Sandbox**.

### Fix DotsContacto — `rellenarDatosContacto` Jefe de Sucursal

- Problema: Perfil Jefe de Sucursal veía error de Flow no gestionado en Opportunity.
- Flow: `rellenarDatosContacto`. Páginas: `Opportunity_Record_Page_VN`, `Opportunity_Record_Page_VU`.
- Perfiles excluidos: `Jefe de Sucursal BMW Escazú`, `Jefe de Sucursal BMW Uruca`.
- Deploy Sandbox: `0AfNq00000XtKntKAF`.
- Estado: **desplegado en Sandbox — pendiente validación con Pedro**.

### Pendiente Luis — correos temporales

- Flow: `VN_RQ106_Notificaciones_Anticipo`.
- Correos: `oaparicio@redmotorscr.com`, `cmora@redmotorscr.com`.
- Estado: **pendiente — NO aplicado todavía**.
- Nota: temporal Sandbox, remover antes de Producción.

## 3.2 Validación funcional posterior a deploy 2026-06-12

Se validó en video el flujo funcional completo en Sandbox sobre la Opportunity usada para evidencia funcional.

Datos observados:

- Opportunity: `Opportunity QA Sandbox`.
- Anticipo principal: `Anticipo QA Sandbox`.
- Tipo: `Reserva de vehículo`.
- Estado inicial validado: `Anticipo creado`.
- Identificador Helios: `176316`.
- Aprobación producto inicial: `Pendiente`.
- Monto: `USD 500,00`.

Validaciones confirmadas:

- La tabla muestra la columna `Código de anticipo`.
- La tabla ya no muestra la columna `Evidencia`.
- El texto visible quedó corregido a `PDF Softland pendiente de generación`.
- Los botones `Aprobar reserva` y `Rechazar reserva` aparecen para el anticipo principal.
- El rechazo de reserva se ejecutó correctamente y cambió la aprobación producto a `Rechazada`.
- El reenvío se ejecutó correctamente y devolvió la aprobación producto a `Pendiente`.
- La aprobación de reserva se ejecutó correctamente y dejó la aprobación producto en `Aprobada`.
- El anticipo quedó aplicado como `Vehículo reservado`.
- El historial de aprobaciones quedó actualizado.
- El resumen financiero quedó actualizado:
  - Total anticipos aprobados: `USD 500,00`.
  - Saldo pendiente: `USD 124 500,00`.

Conclusión:

- Se confirmó que el flujo funcional opera correctamente en Sandbox.
- La evidencia final formal queda pendiente de consolidación.
- No se debe subir documentación oficial todavía.

Pendientes:

- Confirmar destinatarios/configuración productiva final de correos.
- Queda registrada una incidencia separada de integración Helios/Softland para un anticipo que no devuelve `Identificador_Helios__c`.
- No subir documentación oficial todavía.

## 3.3 Cierre funcional Sandbox 2026-06-12

Validación funcional completa realizada el 2026-06-12 con usuarios reales en Sandbox.

### Registros usados

- Opportunity: `Opportunity QA Sandbox`.
- Asesor / Owner: `Usuario QA Asesor`.
- `JefeSucursal__c`: `Usuario QA JefeSucursal`.
- Cliente: `Cliente QA Sandbox`.
- Anticipo QA principal — código Helios generado — aprobado — `Vehículo reservado`.
- Anticipo QA secundario — código Helios generado — `Confirmada por Tesorería`, aprobación pendiente.

### Validaciones confirmadas

UI y tabla:

- Columna `Código de anticipo` muestra valor de `Identificador_Helios__c`.
- Columna `Id Helios` eliminada (era duplicado).
- Columna `Evidencia` ya no aparece.
- Texto PDF muestra `PDF Softland pendiente de generación`.

Flujo completo:

- El equipo de integración corrigió el parámetro `@adjunto`.
- Creación desde cero con usuario asesor: exitosa.
- Envío a Tesorería: exitoso, Helios generó identificador externo.
- Modal se cerró automáticamente tras envío exitoso.

Autorización:

- El usuario asesor, al no ser `JefeSucursal__c`, NO puede aprobar, rechazar ni reenviar.
- El usuario configurado como `JefeSucursal__c` SÍ puede aprobar, rechazar y reenviar.

Ciclo completo del anticipo QA principal:

- Rechazo ejecutado correctamente → aprobación producto = `Rechazada`.
- Reenvío ejecutado correctamente → aprobación producto = `Pendiente`.
- Aprobación ejecutada correctamente → aprobación producto = `Aprobada`, estado = `Vehículo reservado`.
- Historial de aprobaciones actualizado.
- Resumen financiero actualizado correctamente.

### Deploys que respaldan esta validación

| Descripción | Deploy Id |
|---|---|
| UI + Flow B.2 | 0AfNq00000Xscq5KAB |
| Apex: permitir `Anticipo creado` + Id Helios | 0AfNq00000Xsg5hKAB |
| Texto PDF Softland | 0AfNq00000XshD3KAJ |
| Corrección autorización JefeSucursal__c | 0AfNq00000XswX3KAJ |
| Código de anticipo usando Identificador_Helios__c | 0AfNq00000XsxePKAR |

### Evidencia

La evidencia final del flujo completo queda pendiente de consolidación formal.
No subir documentación oficial ni marcar QA como aprobado hasta completar revisión final.

### Pendientes registrados

1. Confirmar destinatarios/configuración productiva final de correos.
2. Confirmar alcance final de PDF Softland, si aplica.
3. No subir documentación oficial hasta completar revisión final.

---

## 4. Usuario QA puede comenzar solo evidencia básica/no destructiva

Casos permitidos:

1. Abrir Opportunity de prueba indicada por el equipo funcional.
2. Mostrar botón `Solicitudes anticipos`.
3. Abrir modal.
4. Validar que carga overview.
5. Validar que la tabla de solicitudes se muestra.
6. Validar que no hay error visual en el modal.

Condiciones:

- Usar solo Sandbox.
- No modificar registros.
- No crear nuevos anticipos.
- No ejecutar acciones de avance externo de Tesorería fuera del procedimiento autorizado.
- Registrar evidencia visual y observaciones.

## 5. Usuario QA no debe hacer todavía

Casos bloqueados:

1. Crear nuevo anticipo real.
2. Forzar avance del proceso externo de Tesorería.
3. Cambiar destinatarios/configuración final de correos sin aprobación del equipo funcional.
4. Publicar evidencia final oficial sin revisión previa.
7. Pruebas destructivas sobre Opportunity reservada para evidencia funcional.

Motivo del bloqueo:

- El envío inicial a Helios/Softland ya genera identificador externo.
- El flujo funcional de reserva fue validado localmente en Sandbox.
- Las notificaciones y correos de Bloque B.2 quedaron validados en Sandbox.
- La evidencia final formal queda pendiente de consolidación.

## 6. Pendientes para liberar QA completa a Usuario QA

1. Confirmar destinatarios/configuración productiva final de correos.
2. Consolidar evidencia final de QA.
3. Confirmar generación de PDF Softland cuando el proceso externo avance.
4. Documentar incidencia separada de integración Helios/Softland para anticipo que no devuelve `Identificador_Helios__c`.
5. Ordenar evidencia final aprobada.
6. Preparar instrucciones finales para Usuario QA.
7. Actualizar Excel QA y documentación oficial Drive cuando corresponda.

## 7. Estado de cierre

- Producción permanece sin cambios.
- No se debe marcar QA oficial como aprobado hasta contar con evidencia final y validación de correos si aplica.
- El flujo funcional de reserva quedó validado en Sandbox.
- No subir documentación oficial todavía.

---

## 8. Estado oficial del proyecto VN-RQ106 al 2026-06-12

### Avances completados en Sandbox

1. Registro de solicitudes de ingreso/anticipo desde la oportunidad.
2. Adjuntar evidencia en la solicitud.
3. Envío exitoso de solicitud a Tesorería.
4. Generación y recepción del identificador externo de Helios/Softland.
5. Visualización de `Código de anticipo` usando `Identificador_Helios__c`.
6. Eliminación de columnas duplicadas/no requeridas en la tabla.
7. Mensaje correcto para PDF Softland pendiente de generación.
8. Cierre automático del modal posterior al envío exitoso.
9. Control funcional de aprobación/rechazo/reenvío por usuario autorizado.
10. Validación de que el asesor no ejecuta aprobación/rechazo/reenvío.
11. Validación de que el usuario autorizado por producto sí ejecuta aprobación/rechazo/reenvío.
12. Flujo de rechazo de reserva.
13. Flujo de reenvío de solicitud de reserva.
14. Flujo de aprobación de reserva.
15. Actualización del estado a `Vehículo reservado`.
16. Actualización del historial de aprobaciones.
17. Actualización del resumen financiero.
18. Validación de correos/notificaciones del proceso:
    - Validación de ingreso requerida.
    - Solicitud de aprobación de reserva.
    - Reserva rechazada.
    - Vehículo reservado.
19. Flow `VN_RQ106_Notificaciones_Anticipo` actualizado y validado en Sandbox con plantillas de negocio.

### Pendientes oficiales

1. Consolidar evidencia final de QA.
2. Confirmar aprobación funcional de negocio.
3. Definir configuración final de destinatarios para Producción.
4. Sustituir configuración de destinatarios de Sandbox por configuración final productiva antes del pase.
5. Confirmar comportamiento final del PDF Softland generado, si aplica dentro del alcance.
6. Preparar paquete final de documentación de entrega.
7. Preparar plan de pase a Producción.
8. Ejecutar validación post-deploy en Producción cuando se autorice el pase.

### Estado de ambientes

- Sandbox: funcionalidad completa validada.
- Producción: sin cambios. Requiere aprobación funcional, evidencia y plan de pase antes de cualquier despliegue.
