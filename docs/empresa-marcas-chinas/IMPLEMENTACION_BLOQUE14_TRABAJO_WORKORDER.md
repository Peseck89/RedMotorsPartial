# Implementación Bloque 14 — Empresa configurable en trabajos de WorkOrder

## Estado

Bloque completado, validado y desplegado en RedMotorsSandbox / Partial.

## Alcance autorizado

El bloque modifica únicamente la resolución de empresa de
`TrabajoController.saveSubtrabajos()` y su prueba directa. No cambia la
determinación del tipo de vehículo, tipos de cargo, impuestos, PricebookEntry,
creación general de WorkOrderLineItem ni otros métodos.

## Comportamiento anterior

`saveSubtrabajos()` utilizaba directamente `WorkOrder.empresaFactura__c` para
consultar `TipoDeCargoConManoDeObra__c`. El lookup
`WorkOrder.empresaFacturaCP__c` no era consultado, por lo que tampoco tenía
precedencia sobre el campo heredado.

Un valor nulo o sin configuración terminaba en el error genérico de mano de
obra y no existía validación explícita de los códigos empresariales admitidos.

## Cambio realizado

- Se agregó `empresaFacturaCP__c` al SOQL del WorkOrder.
- Cuando el lookup está informado, se resuelve con `EmpresaResolver` y se usa
  `Empresa__c.Codigo__c`.
- Cuando está vacío, `empresaFactura__c` permanece como respaldo temporal.
- El lookup tiene prioridad si ambos campos están informados.
- Los únicos códigos admitidos son `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`.
- Empresa nula, inactiva, incompleta o con código no soportado produce un
  error controlado.
- No se usa `Empresa__c.Name` ni existe selección por descarte.

## Pruebas

`TrabajoControllerTest` conserva sus siete pruebas históricas y agrega diez
escenarios dirigidos:

1. lookup RMBAVARIAN;
2. lookup RMOTOBAI;
3. lookup RMPEKING;
4. precedencia de lookup PEKING sobre picklist Bavarian;
5. respaldo RMBAVARIAN;
6. respaldo RMOTOBAI;
7. respaldo RMPEKING;
8. Empresa inactiva;
9. código de lookup no soportado;
10. lookup y respaldo vacíos.

Los escenarios exitosos verifican WorkOrder, producto de mano de obra,
PricebookEntry, Pricebook, cantidad y precio. Los escenarios de error
comprueban la excepción controlada y la ausencia de WorkOrderLineItems.

Los datos son autocontenidos, no usan IDs reales ni `SeeAllData`. Se conserva
el mock histórico requerido por automatizaciones indirectas.

## Riesgos heredados fuera de alcance

- La consulta de PricebookEntry permanece dentro del ciclo.
- El método requiere el impuesto `0108`.
- La configuración de mano de obra depende de empresa, tipo de cargo y tipo
  de vehículo.
- Automatizaciones indirectas de WorkOrderLineItem pueden afectar límites o
  requerir mocks.
- No se modificaron metadata, integraciones ni datos operativos.

## Manifest

El manifest contiene únicamente `TrabajoController` y
`TrabajoControllerTest`.

## Primer dry-run

El dry-run `0AfAK000000vq0H0AQ` compiló correctamente los 2/2 componentes,
aprobó 8/17 pruebas y falló en nueve métodos. La org no fue modificada.

Las siete rutas empresariales exitosas y las dos pruebas históricas que
alcanzan `saveSubtrabajos()` recibieron una excepción técnica envuelta por los
`catch` existentes como `AuraHandledException` en las líneas 144 y 329 de
`TrabajoController`.

Como primera medida se conservó el mock histórico y se agregó un helper para
registrarlo en cada método que alcanza las automatizaciones indirectas:

- `testSaveTrabajo`;
- `testSaveSubtrabajos`;
- las siete rutas empresariales exitosas.

El segundo dry-run `0AfAK000000vq1t0AA` volvió a compilar 2/2 componentes y
obtuvo el mismo resultado de 8/17 pruebas, por lo que se descartó el mock como
causa raíz. La org no fue modificada.

## Dry-run diagnóstico

En el dry-run diagnóstico `0AfAK000000vq570AA` se sustituyeron temporalmente
los dos envoltorios `AuraHandledException` por el relanzamiento de la
excepción original. El controlador fue restaurado inmediatamente después y
conserva sus `catch` originales.

El diagnóstico reveló:

```text
System.QueryException: List has no rows for assignment to SObject
TrabajoController.saveSubtrabajos, línea 298
```

La consulta busca una `PricebookEntry` por el producto de mano de obra y el
`Pricebook2Id` efectivo del WorkOrder. Las pruebas insertaban la entrada en un
Pricebook genérico antes de insertar el WorkOrder. `WorkOrderTrigger`
reemplazaba después ese Pricebook por el nombre empresarial autorizado:

- `Bavarian Local`;
- `Otobai Local`;
- `PEKING Local`.

Cuando el Pricebook autorizado no existía en los datos de prueba, el mapa del
trigger devolvía `null`. En ambos casos la entrada creada no coincidía con el
`Pricebook2Id` finalmente consultado.

Se corrigieron únicamente los datos autocontenidos:

- el escenario histórico crea `Bavarian Local`;
- cada escenario crea o reutiliza el Pricebook local de su empresa;
- WorkOrder y PricebookEntry utilizan explícitamente CRC;
- se consulta el WorkOrder después de los triggers y se comprueba que su
  Pricebook coincide con el de la entrada;
- el mock por método permanece por prevención ante automatizaciones
  indirectas.

Durante el parche diagnóstico las tres pruebas negativas recibieron
directamente `EmpresaConfigurationException` porque se había retirado
temporalmente el envoltorio público. No representan una regresión. Los
`AuraHandledException` originales ya están restaurados.

No se eliminaron pruebas ni se modificó código productivo como parte de esta
corrección.

## Validación final y deploy

| Etapa | Deploy ID | Componentes | Pruebas | Fallas | Resultado |
|---|---|---:|---:|---:|---|
| Primer dry-run | `0AfAK000000vq0H0AQ` | 2/2 | 8/17 | 9 | Fallido |
| Segundo dry-run | `0AfAK000000vq1t0AA` | 2/2 | 8/17 | 9 | Fallido |
| Dry-run diagnóstico | `0AfAK000000vq570AA` | 2/2 | Diagnóstico | No aplica | Causa identificada |
| Dry-run funcional | `0AfAK000000vqBZ0AY` | 2/2 | 17/17 | 0 | Exitoso |
| Dry-run de regresión | `0AfAK000000vqEn0AI` | 2/2 | 26/26 | 0 | Exitoso |
| Deploy real | `0AfAK000000vqGP0AY` | 2/2 | 26/26 | 0 | Exitoso |

El dry-run funcional confirmó 232/266 líneas cubiertas en
`TrabajoController`, equivalentes a 87.22%.

El deploy real terminó correctamente en RedMotorsSandbox / Partial. Quedaron
validados:

- `WorkOrder.empresaFacturaCP__c` como fuente principal;
- `empresaFactura__c` como respaldo temporal;
- soporte explícito para `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`;
- ausencia de selección empresarial por descarte;
- error controlado ante empresa nula, inactiva, incompleta o no soportada;
- conservación de impuestos, PricebookEntry, tipo de vehículo, tipo de cargo
  y creación general de líneas.

Se ejecutaron 17 pruebas funcionales y 26 pruebas de regresión sin fallas. El
controlador conserva el manejo original mediante `AuraHandledException`
después del diagnóstico temporal.

## Avance técnico estimado

El avance técnico estimado queda en 80% completado y 20% pendiente. Esta
estimación representa alcance técnico, no horas oficiales, trabajadas ni
facturables.
