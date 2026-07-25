# Implementación Bloque 9 — Empresa configurable en líneas de plantilla

## Objetivo

Incorporar `Empresa__c` como fuente principal para determinar la empresa de
una `Plantilla_de_Presupuesto__c`, conservando temporalmente
`BMW_Compania__c` como respaldo explícito para registros existentes.

## Metadata

Se creó el campo `Plantilla_de_Presupuesto__c.Empresa_Operadora__c`:

| Propiedad | Valor |
|---|---|
| Label | Empresa Operadora |
| Tipo | Lookup |
| Referencia | `Empresa__c` |
| Requerido | No |
| Comportamiento al eliminar | SetNull |
| Relationship Name | `Plantillas_Presupuesto_Empresa` |
| Relationship Label | Plantillas de presupuesto |

No se modificaron layouts, Lightning Pages ni datos existentes.

## Comportamiento anterior

`BMW_LineaPlantillaEmpresa.getEmpresa()` consultaba únicamente
`BMW_Compania__c`.

- Bavarian retornaba `RMBAVARIAN`.
- Cualquier otro valor retornaba `RMOTOBAI`.

Esto producía un fallback implícito a Otobai para valores nulos,
desconocidos o una tercera empresa.

## Comportamiento implementado

La precedencia es:

1. Si `Empresa_Operadora__c` está informado, se resuelve mediante
   `EmpresaResolver` y se retorna `Empresa__c.Codigo__c`.
2. Si el lookup está vacío, se utiliza temporalmente el campo heredado:
   - Bavarian → `RMBAVARIAN`;
   - Otobai → `RMOTOBAI`.

No se utiliza `Empresa__c.Name`, no existen IDs de Empresa hardcodeados y no
se selecciona una empresa por descarte.

El método produce `EmpresaConfigurationException` cuando:

- el Id de plantilla es nulo;
- la plantilla no existe;
- ambos campos están vacíos;
- el valor heredado no está reconocido;
- la Empresa está inactiva;
- la Empresa tiene configuración incompleta.

`EmpresaResolver` no fue modificado.

## Pruebas

`BMW_LineaPlantillaEmpresa_Test` contiene nueve métodos de prueba:

- lookup RMBAVARIAN;
- lookup RMOTOBAI;
- lookup RMPEKING;
- precedencia del lookup sobre un picklist contradictorio;
- respaldo Bavarian;
- respaldo Otobai;
- Empresa inactiva y configuración incompleta;
- Id nulo;
- plantilla inexistente.

Todos los datos de Empresa y plantilla son autocontenidos. Las pruebas no
usan datos existentes.

### Primer dry-run

| Dato | Resultado |
|---|---|
| Deploy ID | `0AfAK000000vpLx0AI` |
| Componentes | 3/3 |
| Pruebas aprobadas | 2/9 |
| Pruebas fallidas | 7/9 |
| Estado de la org | Sin modificaciones |

Las siete fallas ocurrieron al crear las plantillas de prueba:

`REQUIRED_FIELD_MISSING: BMW_TipoDeVehiculo__c`.

`BMW_TipoDeVehiculo__c` es un picklist restringido, obligatorio y editable.
Los valores activos confirmados son Automóvil, Motocicleta, Mula y
Cuadraciclo. No existe otra prueba local que cree
`Plantilla_de_Presupuesto__c` asignando ese campo.

El helper `createPlantilla` ahora utiliza `Automóvil`, valor activo confirmado
por el describe del objeto y compatible con los escenarios de plantilla
probados. No se utilizaron IDs ni datos existentes.

### Casos no persistibles

`BMW_Compania__c` es un picklist restringido, obligatorio y solo admite
Bavarian y Otobai. Salesforce impide insertar una plantilla con el campo
nulo o con un valor desconocido.

El código productivo conserva las validaciones fail-closed para ambos casos,
pero no se crearon pruebas que evadan la restricción mediante
deserialización, cambios de metadata o bypasses.

## Inventario de permisos

La consulta de solo lectura de `FieldPermissions` no encontró entradas
explícitas para `Plantilla_de_Presupuesto__c.BMW_Compania__c`:

| Tipo | Cantidad |
|---|---:|
| Perfiles con entrada explícita | 0 |
| Permission Sets con entrada explícita | 0 |

Para replicar exactamente el estado del campo heredado no se agregaron
entradas de `fieldPermissions` al nuevo lookup y no se modificaron perfiles
ni Permission Sets.

## Archivos del bloque

- metadata del lookup `Empresa_Operadora__c`;
- `BMW_LineaPlantillaEmpresa`;
- `BMW_LineaPlantillaEmpresa_Test`;
- manifest específico del Bloque 9.

## Riesgos y pendientes

- Las plantillas existentes continúan usando el picklist hasta que se defina
  una migración.
- El lookup no se agregó a layouts o Lightning Pages.
- No se asignaron permisos adicionales porque el campo heredado tampoco
  tiene entradas explícitas.
- La resolución por lookup exige Empresa activa, código, código ERP y nombre
  legal, conforme al contrato vigente de `EmpresaResolver`.

## Validación final y deploy

| Validación | Deploy ID | Componentes | Pruebas | Fallas |
|---|---|---:|---:|---:|
| Dry-run funcional | `0AfAK000000vpPB0AY` | 3/3 | 9/9 | 0 |
| Dry-run de regresión | `0AfAK000000vpSP0AY` | 3/3 | 18/18 | 0 |
| Deploy real | `0AfAK000000vpU10AI` | 3/3 | 18/18 | 0 |

El deploy real terminó correctamente en RedMotorsSandbox / Partial.

La cobertura confirmada de `BMW_LineaPlantillaEmpresa` fue 16/21 líneas,
equivalente a 76.19%.

## Cierre técnico

El Bloque 9 queda completado, validado y desplegado:

- se creó `Plantilla_de_Presupuesto__c.Empresa_Operadora__c`;
- el lookup tiene prioridad sobre `BMW_Compania__c`;
- Bavarian y Otobai permanecen como respaldos explícitos;
- PEKING se resuelve mediante `EmpresaResolver` y `Empresa__c.Codigo__c`;
- se eliminó el fallback automático a Otobai;
- se validaron nueve escenarios funcionales;
- no se modificaron layouts, migraciones ni permisos.

Avance técnico estimado del Sprint 1:

- completado: 74%;
- pendiente: 26%.

Este porcentaje corresponde al alcance técnico y no representa horas
oficiales, trabajadas, registradas ni facturables.
