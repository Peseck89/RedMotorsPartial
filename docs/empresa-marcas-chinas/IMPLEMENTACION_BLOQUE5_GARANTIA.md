# Implementación del Bloque 5 — Garantia en WorkOrder

## Objetivo

Corregir la rama de tipo de cargo de garantía en `WorkOrderTrigger` para que
utilice el valor activo del picklist restringido
`WorkOrder.tipoDeGasto__c`.

## Causa del defecto

La configuración activa utiliza `Garantia`, sin tilde. El trigger comparaba
`Garantía`, con tilde. Salesforce no permite persistir el segundo literal,
por lo que la rama que asigna el código de cargo `4` era inaccesible.

Luis autorizó resolver este pendiente antes del cierre del Sprint 1.

## Cambio productivo

Se cambió un único literal:

```apex
when 'Garantía'
```

por:

```apex
when 'Garantia'
```

No se modificaron otras ramas del switch, metadata, valores del picklist,
lógica de Empresa, Pricebooks, permisos u otros objetos.

## Prueba dirigida

Se restauró `updatesTipoCargoForWarrantyExpense` dentro de
`WorkOrderTriggerTest`.

La prueba:

- crea datos autocontenidos;
- crea una WorkOrder y una sola WorkOrderLineItem;
- reutiliza los cargos generados automáticamente;
- crea un cargo al 100% únicamente cuando no existe ninguno;
- valida una suma de porcentajes menor o igual a 100;
- actualiza `tipoDeGasto__c` a `Garantia`;
- verifica `tipoCargo__c = '4'`;
- verifica `Cliente__c = null`;
- verifica `centroCosto__c = null`.

No usa `SeeAllData`, datos reales, integraciones, callouts ni cambios de
permisos.

## Manifest

`empresa-marcas-chinas-bloque5-garantia.xml` contiene únicamente:

- ApexTrigger `WorkOrderTrigger`;
- ApexClass `WorkOrderTriggerTest`.

## Validación y deploy

Evidencia registrada el 25/07/2026 a la 1:19 p. m., zona horaria UTC−06:00,
en RedMotorsSandbox / Partial:

| Validación | Deploy ID | Estado | Componentes | Pruebas | Fallas |
|---|---|---|---:|---:|---:|
| Dry-run | `0AfAK000000vnqP0AQ` | Succeeded | 2/2 | 51/51 | 0 |
| Deploy real | `0AfAK000000vo4v0AA` | Succeeded | 2/2 | 51/51 | 0 |

Componentes desplegados:

- `WorkOrderTrigger`;
- `WorkOrderTriggerTest`.

La prueba dirigida de garantía fue restaurada y aprobada. La comparación
productiva ahora coincide con el valor activo `Garantia` y la rama asigna
`tipoCargo__c = '4'`.

## Estado y avance

El defecto obligatorio quedó resuelto. El Bloque 5 está completado, validado
y desplegado. No se modificaron campos, permisos, `Empresa__c`, Pricebooks ni
integraciones.

El avance técnico estimado posterior al Bloque 5 es:

- 66% completado;
- 34% pendiente.

El porcentaje es una estimación basada en alcance técnico. No representa
horas oficiales, trabajadas, registradas ni facturables.
