# Resumen sanitizado de errores de logs VN-RQ106

## Alcance y sanitización

Se revisaron exclusivamente los cinco logs solicitados. No se preservaron los logs crudos. Este resumen omite identificadores completos, correos, URLs internas, tokens, nombres de usuarios y datos de registros de prueba.

## Hallazgos

### 1. Error de procedimiento externo no disponible

- Fuentes conceptuales: log de error de anticipo y uno de los logs de depuración del flujo de envío.
- Tipo: respuesta funcional de error recibida con transporte HTTP exitoso, seguida por una excepción controlada de interfaz.
- Componente relacionado: `SolicitudAprobacionTesoreria` y `VN_RQ106_AnticipoController`.
- Causa: el esquema/compañía seleccionado no tenía disponible el procedimiento requerido por el servicio de integración.
- Resolución conocida: no se encontró un cambio local específico asociado a esos dos eventos; validaciones posteriores documentan envíos exitosos y generación del identificador externo, por lo que la incidencia quedó superada operativamente por la corrección externa o de configuración.
- Estado: `RESUELTO_EN_VALIDACION_POSTERIOR`; la corrección exacta del lado externo no quedó trazada en estos logs.
- Evidencia conceptual: el backend devolvió un código funcional de error y el controlador evitó marcar la operación como exitosa.

### 2. Parámetro adjunto ausente en la integración

- Fuente conceptual: log de depuración del envío a Tesorería.
- Tipo: error funcional del procedimiento externo, encapsulado posteriormente como excepción controlada.
- Componentes relacionados: `SolicitudAprobacionTesoreria` y `VN_RQ106_AnticipoController`.
- Causa: el contrato de integración no enviaba un parámetro requerido para el adjunto.
- Resolución conocida: el equipo de integración corrigió el contrato; la documentación posterior confirma creación desde cero, envío exitoso y generación del identificador externo.
- Estado: `RESUELTO`.
- Evidencia conceptual: respuesta funcional de error anterior y validación funcional exitosa posterior.

### 3. Acceso insuficiente a una referencia relacionada

- Fuente conceptual: log de creación del borrador de solicitud.
- Tipo: `DmlException` por acceso insuficiente a una referencia durante la inserción del anticipo.
- Componente relacionado: `VN_RQ106_AnticipoController.createDraftSolicitud`.
- Causa identificable: el usuario de ejecución no tenía acceso a uno de los registros relacionados utilizados al insertar el borrador. El log no permite atribuir de forma segura cuál referencia concreta originó el bloqueo.
- Resolución conocida: las validaciones posteriores documentan creación desde cero con perfil asesor y continuación exitosa del flujo.
- Estado: `RESUELTO_EN_VALIDACION_POSTERIOR`; el ajuste puntual de permisos o acceso no quedó explícito en el log.
- Evidencia conceptual: fallo DML anterior y prueba funcional posterior con creación exitosa.

### 4. Consulta a Organization no soportada para el perfil

- Fuente conceptual: log del flujo de envío a Tesorería.
- Tipo: `QueryException`, seguida por una excepción controlada en el controlador.
- Componentes relacionados: `SolicitudAprobacionTesoreria`, `SoftlandEndpointService` y `VN_RQ106_AnticipoController`.
- Causa: consulta directa al objeto `Organization` desde un perfil sin acceso compatible.
- Resolución conocida: manejo de excepción y detección alternativa por dominio; el hotfix fue validado posteriormente en Sandbox.
- Estado: `RESUELTO`.
- Evidencia conceptual: error de consulta anterior, hotfix documentado y reintento posterior sin reproducción.

## Conclusión

Los cinco logs se reducen a cuatro familias de error. Tres cuentan con resolución documentada o validación posterior concluyente; la incidencia de procedimiento externo también aparece superada en pruebas posteriores, aunque su corrección exacta fuera de Salesforce no quedó registrada. No es necesario conservar los logs crudos para el cierre técnico después de preservar este resumen.
