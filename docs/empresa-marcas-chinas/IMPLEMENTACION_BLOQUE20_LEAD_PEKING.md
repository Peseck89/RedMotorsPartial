# Implementación Bloque 20 — Lead/Tráfico PEKING

## Estado inicial

Bloque 20 retomado bajo el criterio de autonomía autorizado por Luis:
“dale tú sin miedo a los ajustes, documenta y en todo caso si hay cosas que
cambiar, lo vemos el lunes”.

Ambiente autorizado: RedMotorsSandbox / Partial. Producción queda fuera de
alcance.

## Evidencia técnica

Lead/Tráfico está incluido en el flujo existente del proyecto porque
`TraficoTriggerHandler.afterUpdate()` ejecuta, al convertir Leads:

- `TraficoService.TransferirIntereses(...)`
- `RM_Lead_Trigger_Helper.setOpportunityRecordType(...)`
- `RM_Lead_Trigger_Helper.identifyVehicleUsed(...)`

`RM_Lead_Trigger_Helper.setOpportunityRecordType(...)` no contiene lógica fija
por marca. Resuelve el Record Type destino mediante `RM_RecordTypeMapping__mdt`
activo para `Lead` → `Opportunity`.

Consulta de configuración real en RedMotorsSandbox:

- `Lead.MINI` → `Opportunity.MINI`
- `Lead.Polaris` → `Opportunity.Polaris`
- `Lead.Kawasaki` → `Opportunity.Kawasaki`
- `Lead.BMW` → `Opportunity.Polaris`

La configuración `BMW` → `Polaris` se documenta como anomalía existente. No se
corrige en este bloque porque podría representar una configuración operativa
intencional y no existe evidencia concluyente para cambiarla.

Estado de Record Types antes del bloque:

- Lead: existen `BMW`, `MINI`, `Polaris`, `Kawasaki`; no existen `Omoda` ni
  `Jaecoo`.
- Opportunity: existen `BMW`, `MINI`, `Polaris`, `Kawasaki`, `Omoda` y `Jaecoo`.

## Decisión autónoma aplicada

La evidencia demuestra que Omoda y Jaecoo pueden replicar el patrón técnico
existente sin arquitectura nueva, integraciones, seguridad adicional ni reglas
financieras. Se implementa:

- `Lead.Omoda`
- `Lead.Jaecoo`
- `RM_RecordTypeMapping.Lead_Omoda_to_Opp`
- `RM_RecordTypeMapping.Lead_Jaecoo_to_Opp`

No se modifica la anomalía `Lead.BMW` → `Opportunity.Polaris`.

## Metadata implementada

### Record Types de Lead

`Lead.Omoda` y `Lead.Jaecoo` se crean usando `Lead.BMW` como plantilla técnica,
por consistencia con el Bloque 17, donde Opportunity Omoda y Jaecoo se crearon
desde BMW por tratarse de marcas de automóviles.

Configuración conservada desde BMW:

- `active=true`
- `businessProcess=Autos`
- mismos `picklistValues`

Cambios por marca:

- `fullName`
- `description`
- `label`

### Custom Metadata

Se crean dos mappings activos:

- `Lead.Omoda` → `Opportunity.Omoda`
- `Lead.Jaecoo` → `Opportunity.Jaecoo`

## Pruebas

`RM_Lead_Trigger_Helper_Test` se reconstruye con aserciones reales:

- valida que `getRecordTypeIdsByRTName()` incluye Omoda → Omoda;
- valida que incluye Jaecoo → Jaecoo;
- valida que mappings heredados MINI y Kawasaki se conservan;
- valida que `setOpportunityRecordType()` actualiza oportunidades convertidas
  desde Lead Omoda y Lead Jaecoo;
- valida que un Lead sin Record Type mapeado no modifica la Opportunity.

No se elimina `RM_Lead_Trigger_Helper.name()` porque `TraficoServiceTest` aún lo
invoca. Retirarlo en este bloque ampliaría el alcance a pruebas ajenas.

## Fuera de alcance

No se modifican:

- Softland;
- reservas;
- anticipos;
- finanzas;
- branding legal;
- sucursales o territorios;
- `Lead.BMW` → `Opportunity.Polaris`;
- `RM_Config__mdt`;
- lógica productiva de `RM_Lead_Trigger_Helper`;
- Flows, LWC, layouts o permisos.

## Manifest

`manifest/empresa-marcas-chinas-bloque20-lead-peking.xml` incluye únicamente:

- `RecordType`: `Lead.Omoda`, `Lead.Jaecoo`
- `CustomMetadata`: `RM_RecordTypeMapping.Lead_Omoda_to_Opp`,
  `RM_RecordTypeMapping.Lead_Jaecoo_to_Opp`
- `ApexClass`: `RM_Lead_Trigger_Helper_Test`

## Validación y despliegue

Primer dry-run enfocado:

- Deploy ID: `0AfAK000000vuK10AI`
- Componentes: 5/5
- Pruebas: 0/3
- Resultado: falló por compilación de prueba.
- Causa: `Lead.ConvertedOpportunityId` no es escribible mediante asignación
  directa.

Segundo dry-run enfocado:

- Deploy ID: `0AfAK000000vuLd0AI`
- Componentes: 5/5
- Pruebas: 0/3
- Resultado: falló en ejecución de pruebas.
- Causas:
  - los Record Types nuevos no estaban disponibles para el perfil ejecutor
    durante el check-only;
  - `ConvertedOpportunityId` tampoco era editable mediante `SObject.put()`.

Corrección de prueba:

- Se dejó de exigir `RecordTypeInfo.isAvailable()` para Record Types que se
  crean en la misma transacción de despliegue.
- Se construyeron Leads convertidos en memoria mediante deserialización JSON,
  sin DML, sin datos reales y sin modificar lógica productiva.

Dry-run enfocado aprobado:

- Deploy ID: `0AfAK000000vuNF0AY`
- Componentes: 5/5
- Pruebas: 3/3
- Fallas: 0

Regresión seleccionada aprobada:

- Deploy ID: `0AfAK000000vuOr0AI`
- Componentes: 5/5
- Pruebas: 53/53
- Fallas: 0
- Pruebas ejecutadas:
  - `RM_Lead_Trigger_Helper_Test`
  - `TraficoServiceTest`
  - `RM_VN_CrearOportunidad_Ctrl_Test`
  - `RM_VN_CrearOppModeloInteres_Ctrl_Test`
  - `EmpresaResolverTest`

Deploy real:

- Deploy ID: `0AfAK000000vuQT0AY`
- Ambiente: RedMotorsSandbox / Partial
- Componentes: 5/5
- Pruebas: 53/53
- Fallas: 0
- Estado: Succeeded

Verificación post-deploy:

- `Lead.Omoda` existe y está activo.
- `Lead.Jaecoo` existe y está activo.
- `Opportunity.Omoda` existe y está activo.
- `Opportunity.Jaecoo` existe y está activo.
- `RM_RecordTypeMapping.Lead_Omoda_to_Opp` está activo y mapea
  `Lead.Omoda` → `Opportunity.Omoda`.
- `RM_RecordTypeMapping.Lead_Jaecoo_to_Opp` está activo y mapea
  `Lead.Jaecoo` → `Opportunity.Jaecoo`.
- Test Run ID post-deploy: `707AK00000GxONW`
- Pruebas post-deploy: 3/3
- Fallas: 0

Avance técnico estimado posterior al cierre: 86% completado / 14% pendiente.
No representa horas oficiales, trabajadas ni facturables.
