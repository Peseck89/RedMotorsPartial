# Implementación Bloque 8 — Permisos de Empresa Operadora en Opportunity

## Objetivo

Replicar en `Opportunity.Empresa_Operadora__c` el acceso concedido a
`Opportunity.BMW_Compania__c`, manteniendo el modelo vigente basado en
perfiles y sin ampliar permisos a usuarios que no contaban con acceso al
campo anterior.

## Autorización y alcance

Se autorizó:

- conservar el modelo de seguridad basado en perfiles;
- conceder lectura y edición a los 146 perfiles que tienen lectura y edición
  sobre `Opportunity.BMW_Compania__c`;
- conceder solo lectura mediante `Vehiculos_Nuevos_PS`;
- no crear un Permission Set adicional;
- no modificar layouts, páginas, aplicaciones, permisos de objeto,
  asignaciones, usuarios ni automatizaciones.

`procesos_walking` y `sfdc_a360_sfcrm_data_extract` ya coinciden con el acceso
requerido y se excluyeron del cambio.

## Verificación de nombres completos

La consulta de solo lectura confirmó 146 perfiles únicos. Los nombres
completos utilizados por Salesforce están incluidos individualmente en el
manifest del bloque.

Cinco perfiles estándar presentan etiquetas traducidas distintas de sus
nombres completos de metadata:

| Etiqueta mostrada | Nombre completo |
|---|---|
| Administrador del contrato | `ContractManager` |
| Administrador del sistema | `Admin` |
| Administrador de soluciones | `SolutionManager` |
| Usuario estándar | `Standard` |
| Usuario de marketing | `MarketingProfile` |

No quedaron perfiles faltantes ni bloqueados.

## Metadata recuperada

Se recuperó exclusivamente:

- 146 perfiles;
- `Vehiculos_Nuevos_PS`;
- `Opportunity.BMW_Compania__c`;
- `Opportunity.Empresa_Operadora__c`.

La recuperación se utilizó para inspeccionar el formato real y preparar los
permisos locales. No se ejecutó dry-run ni deploy.

## Cambio preparado

### Perfiles

Los 146 perfiles quedan con:

```xml
<fieldPermissions>
    <editable>true</editable>
    <field>Opportunity.Empresa_Operadora__c</field>
    <readable>true</readable>
</fieldPermissions>
```

Distribución comprobada:

- 144 perfiles no tenían acceso efectivo y reciben lectura y edición;
- `Asesor de Taller V2` tenía lectura y se eleva a edición;
- `Jefe de Ventas Usados Motos A1` tenía lectura y se eleva a edición.

### Permission Set

`Vehiculos_Nuevos_PS` recibe:

```xml
<fieldPermissions>
    <editable>false</editable>
    <field>Opportunity.Empresa_Operadora__c</field>
    <readable>true</readable>
</fieldPermissions>
```

No se modificaron los permisos de `Opportunity.BMW_Compania__c`.

## Validaciones locales

| Control | Resultado |
|---|---:|
| Perfiles recuperados y procesados | 146 |
| Perfiles con lectura y edición finales | 146 |
| Accesos habilitados desde estado sin acceso | 144 |
| Accesos elevados de lectura a edición | 2 |
| Permission Sets actualizados | 1 |
| Perfiles faltantes o bloqueados | 0 |
| XML de perfiles inválidos | 0 |
| Cambios ajenos al bloque objetivo dentro de los perfiles | 0 |

La comparación automatizada eliminó temporalmente del análisis únicamente el
bloque `fieldPermissions` de `Opportunity.Empresa_Operadora__c` y confirmó
que el contenido restante de cada Profile XML permaneció idéntico.

## Primer dry-run

| Dato | Resultado |
|---|---|
| Deploy ID | `0AfAK000000vouX0AQ` |
| Componentes válidos | 146/147 |
| Perfiles aceptados | 146/146 |
| Componente fallido | `Vehiculos_Nuevos_PS` |
| Estado de la org | Sin modificaciones |

La única falla fue de parsing:
`Element fieldPermissions is duplicated at this location in type
PermissionSet`.

El permiso de `Opportunity.Empresa_Operadora__c` aparecía una sola vez, pero
había quedado después de `tabSettings`, fuera del grupo continuo de
`fieldPermissions` permitido por el esquema. Se reubicó junto con los demás
permisos de campo, entre `Opportunity.Distribuidor__c` y
`Opportunity.EnOferta__c`, conservando lectura habilitada y edición
deshabilitada.

`Opportunity.BMW_Compania__c` permaneció intacto y no se modificaron otros
permisos del Permission Set.

## Riesgos y pendientes

- La asignación efectiva continúa dependiendo del perfil y de los Permission
  Sets que tenga cada usuario.
- Este bloque no agrega el campo a layouts o páginas y no resuelve la
  migración de datos históricos.
- No se modificaron `Empresa_Admin`, `procesos_walking` ni
  `sfdc_a360_sfcrm_data_extract`.

## Validación final y deploy real

Registro realizado el 25/07/2026 a las 3:44 p. m., zona horaria UTC−06:00,
en RedMotorsSandbox / Partial.

| Validación | Deploy ID | Estado | Componentes | Fallas | Pruebas Apex |
|---|---|---|---:|---:|---|
| Dry-run final | `0AfAK000000vow90AA` | Succeeded | 147/147 | 0 | No aplican |
| Deploy real | `0AfAK000000voUk0AI` | Succeeded | 147/147 | 0 | No aplican |

Quedaron actualizados 146 perfiles y el Permission Set
`Vehiculos_Nuevos_PS`.

Resultado funcional:

- los 146 perfiles replican en `Opportunity.Empresa_Operadora__c` la lectura
  y edición existentes en `Opportunity.BMW_Compania__c`;
- 144 perfiles recibieron acceso que no tenían previamente;
- `Asesor de Taller V2` y `Jefe de Ventas Usados Motos A1` pasaron de solo
  lectura a lectura y edición;
- `Vehiculos_Nuevos_PS` recibió lectura sin edición;
- `procesos_walking` y `sfdc_a360_sfcrm_data_extract` no fueron modificados
  porque ya coincidían con el acceso requerido;
- no se modificaron layouts, FlexiPages, usuarios, asignaciones, Apex ni
  flows.

## Estado

Bloque 8 completado, validado y desplegado.

Avance técnico estimado del Sprint 1:

- completado: 71%;
- pendiente: 29%.

El incremento respecto del 69% anterior corresponde al cierre transversal de
permisos para el lookup de Empresa en Opportunity. Es una estimación basada
en alcance técnico y no representa horas oficiales, trabajadas o facturables.
