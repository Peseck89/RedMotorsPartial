# Implementación Bloque 17 - Metadata base de PEKING, Omoda y Jaecoo

## Estado

Bloque 17 completado, validado y desplegado en RedMotorsSandbox / Partial.

## Autorización

Luis autorizó agregar `RMPEKING` a `Product2.Empresa__c`, crear los Record Types de Opportunity `Omoda` y `Jaecoo`, avanzar con ajustes técnicos razonables y documentar las decisiones aplicadas.

## Alcance implementado

### Product2.Empresa__c

Se agregó `RMPEKING` como valor activo y no predeterminado en el picklist restringido `Product2.Empresa__c`.

Se conservaron sin cambios:

- `restricted=true`;
- `sorted=false`;
- `RMBAVARIAN`;
- `RMOTOBAI`;
- ausencia de valor predeterminado.

### Opportunity.Omoda y Opportunity.Jaecoo

Se crearon los Record Types `Omoda` y `Jaecoo` usando `Opportunity.BMW` como plantilla técnica.

BMW fue utilizado como referencia porque la metadata recuperada confirma que BMW y MINI son Record Types de automóviles:

- `businessProcess=Autos`;
- `compactLayoutAssignment=Vehiculos_Nuevos`;
- mismos `picklistValues` de `ForecastCategoryName`, `LeadSource` y `Type`.

Omoda y Jaecoo conservan:

- `active=true`;
- `businessProcess=Autos`;
- `compactLayoutAssignment=Vehiculos_Nuevos`;
- todos los valores de picklist de BMW.

### Vehiculos_Nuevos_PS

Se conservó la visibilidad existente para `Opportunity.BMW`.

Se agregaron visibilidades para:

- `Opportunity.Jaecoo`;
- `Opportunity.Omoda`.

No se modificaron otros permisos del Permission Set.

## Componentes

| Tipo | Componente |
|---|---|
| CustomField | `Product2.Empresa__c` |
| RecordType | `Opportunity.Jaecoo` |
| RecordType | `Opportunity.Omoda` |
| PermissionSet | `Vehiculos_Nuevos_PS` |

## Fuera de alcance

No se modificaron:

- Apex;
- Flows;
- perfiles;
- layouts;
- Lightning Record Pages;
- ProductSearcherController;
- componentes de inventario, reservas, Softland, anticipos o aprobaciones.

`ProductSearcherController` queda separado para un Bloque 18 posterior.

## Archivos auxiliares eliminados

Se eliminaron los archivos recuperados únicamente como referencia y sin cambio funcional:

- `force-app/main/default/objects/Opportunity/Opportunity.object-meta.xml`;
- `force-app/main/default/objects/Product2/Product2.object-meta.xml`;
- `force-app/main/default/objects/Opportunity/recordTypes/BMW.recordType-meta.xml`;
- `force-app/main/default/objects/Opportunity/recordTypes/MINI.recordType-meta.xml`;
- `force-app/main/default/objects/Opportunity/recordTypes/Polaris.recordType-meta.xml`;
- `force-app/main/default/objects/Opportunity/recordTypes/Kawasaki.recordType-meta.xml`.

## Validación y despliegue

El primer dry-run falló:

- Deploy ID: `0AfAK000000vrE50AI`;
- Componentes: 3/4;
- Causa: `Vehiculos_Nuevos_PS` contenía `viewAllFields`, elemento no compatible con Metadata API 61.0.

El segundo dry-run falló:

- Deploy ID: `0AfAK000000vrHJ0AY`;
- Componentes: 3/4;
- Causa: el parámetro `--api-version 67.0` no sustituyó la versión `61.0` declarada dentro del manifest.

El ajuste aplicado fue actualizar
`manifest/empresa-marcas-chinas-bloque17-product2-recordtypes.xml` de 61.0 a
67.0. No se modificó ni eliminó `viewAllFields` del Permission Set.

El dry-run final fue exitoso:

| Deploy ID | Componentes | Test level | Fallas |
|---|---:|---|---:|
| `0AfAK000000vquk0AA` | 4/4 | NoTestRun | 0 |

El deploy real fue exitoso:

| Deploy ID | Ambiente | Componentes | Fallas |
|---|---|---:|---:|
| `0AfAK000000vrNl0AI` | RedMotorsSandbox / Partial | 4/4 | 0 |

Validación post-deploy confirmada:

- `Opportunity.Jaecoo` existe y está activo;
- `Opportunity.Omoda` existe y está activo;
- ambos usan Sales Process `Autos`;
- ambos usan compact layout `Vehiculos_Nuevos`;
- `Product2.Empresa__c` es picklist restringido;
- `Product2.Empresa__c` contiene los valores activos `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`;
- los tres valores tienen `default=false`;
- `Vehiculos_Nuevos_PS` incluye visibilidad para `Opportunity.BMW`, `Opportunity.Omoda` y `Opportunity.Jaecoo`.

## Riesgos

La metadata local no contiene layouts, Lightning Record Pages ni visibilidades completas por perfil. Si la validación funcional requiere selección por usuarios no cubiertos por `Vehiculos_Nuevos_PS`, será necesario un retrieve dirigido adicional de perfiles/layouts o una decisión de permisos complementaria.

## Avance técnico estimado

Avance técnico estimado posterior al cierre del Bloque 17: 84% completado y 16% pendiente. Este porcentaje corresponde al alcance técnico y no representa horas oficiales, trabajadas ni facturables.
