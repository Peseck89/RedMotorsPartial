# Implementación Bloque 13 — Empresa configurable en trabajos de Quote

## Estado

Bloque completado, validado y desplegado en RedMotorsSandbox / Partial.

El Bloque 10 continúa pausado. Este bloque no depende del mapeo de sucursales
ni de visibilidad de Pricebooks.

## Autorización y alcance

Luis autorizó avanzar con cambios claros de bajo riesgo, documentando lo
realizado. El alcance se limita a la resolución de empresa dentro de
`TrabajoQuoteController.saveTrabajo()`.

No se modificaron otros métodos, integraciones, cálculos, tipos de vehículo,
tipos de cargo, selección de PricebookEntry ni la creación general de
QuoteLineItem. La única metadata incorporada fue el valor `RMPEKING` en la
picklist necesaria para la configuración de mano de obra.

## Comportamiento anterior

El método utilizaba `Opportunity.BMW_Compania__c`:

- Bavarian o RMBavarian → `RMBAVARIAN`;
- cualquier otro valor, incluido nulo o desconocido → `RMOTOBAI`.

PEKING no podía representarse y caía implícitamente en Otobai. El código se
utilizaba para consultar `TipoDeCargoConManoDeObra__c`.

## Cambio realizado

`Opportunity.Empresa_Operadora__c` es ahora la fuente principal:

1. Si el lookup está informado, se resuelve mediante `EmpresaResolver`.
2. Se utiliza `EmpresaContext.codigo`, normalizado como clave técnica.
3. Se admiten `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`.
4. El lookup tiene prioridad sobre un picklist contradictorio.

Cuando el lookup está vacío se conserva únicamente la compatibilidad
heredada explícita:

- Bavarian o RMBavarian → `RMBAVARIAN`;
- Otobai → `RMOTOBAI`.

Una empresa nula, desconocida, inactiva o no soportada produce un error
controlado basado en `EmpresaConfigurationException`. Se eliminó el fallback
implícito a Otobai y no se utiliza `Empresa__c.Name`.

## Pruebas

`TrabajoQuoteControllerTest` conserva la prueba histórica y agrega ocho
métodos dirigidos:

1. Lookup RMBAVARIAN.
2. Lookup RMOTOBAI.
3. Lookup RMPEKING.
4. Precedencia del lookup sobre el picklist.
5. Compatibilidad heredada Bavarian.
6. Compatibilidad heredada Otobai.
7. Empresa inactiva.
8. Empresa nula sin fallback.

Los escenarios crean su propia Empresa, configuración
`TipoDeCargoConManoDeObra__c`, producto, Pricebook, PricebookEntry,
Opportunity y Quote. Se valida producto, PricebookEntry, Pricebook, cantidad
y precio de la línea creada.

No se utiliza `SeeAllData`, IDs reales, `Test.isRunningTest`, callouts ni datos
operativos.

## Primer dry-run

El dry-run `0AfAK000000vpqb0AA` falló durante la compilación de
`TrabajoQuoteControllerTest` en la línea 252:

```text
Field is not writeable: tiposDeTrabajo__c.Cantidad__c
```

No se ejecutaron pruebas y la org no fue modificada.

`Cantidad__c` es un campo de fórmula numérica de solo lectura derivado de
`UTS__c`. La fórmula representa la cantidad a partir de las unidades de
tiempo, con 12 UTS por unidad de cantidad (`UTS__c / 12`).

`TrabajoQuoteController.saveTrabajo()` utiliza `Cantidad__c` únicamente
cuando `TrabajoWrapper.uts == -1`. En los escenarios dirigidos el wrapper
establece explícitamente `uts = 2`; ese valor editable determina
`QuoteLineItem.Quantity`, mientras que el tipo de trabajo conserva
`UTS__c = 12`.

Se eliminó la asignación directa a `Cantidad__c` y no se modificó el código
productivo ni la metadata. Se mantienen los nueve métodos y todas sus
aserciones funcionales.

## Segundo dry-run

El dry-run `0AfAK000000vpsD0AQ` compiló 2/2 componentes y aprobó 5/9
pruebas. Cuatro pruebas fallaron y la org no fue modificada.

### Picklist de empresa

Los dos escenarios PEKING fallaron porque
`TipoDeCargoConManoDeObra__c.Empresa__c` es una picklist local restringida.
Los valores activos previos eran:

- `RMBAVARIAN`, etiqueta Bavarian;
- `RMOTOBAI`, etiqueta Otobai.

El campo no utiliza un Global Value Set y `RMPEKING` estaba ausente. Se creó
localmente la metadata
`TipoDeCargoConManoDeObra__c.Empresa__c` conservando ambos valores y
agregando únicamente `RMPEKING`, activo, no predeterminado y con etiqueta
PEKING. El manifest incluye ahora este CustomField.

### Contrato de errores

`saveTrabajo()` captura `EmpresaConfigurationException` y las demás
excepciones dentro de su manejo existente, y expone una
`AuraHandledException`. El mensaje interno no constituye un contrato estable
para una prueba Apex y no se conserva de forma fiable como texto observable.

Las pruebas de Empresa inactiva y Empresa nula ahora validan:

- que se lance `AuraHandledException`;
- que no se cree ninguna QuoteLineItem para la Quote del escenario.

No se modificó `TrabajoQuoteController` para acomodar estas aserciones. Se
mantienen los nueve métodos, la precedencia del lookup, los respaldos
explícitos Bavarian/Otobai y la ausencia de fallback.

## Validación y deploy

| Validación | Deploy ID | Componentes | Pruebas | Fallas |
|---|---|---:|---:|---:|
| Dry-run funcional | `0AfAK000000vptp0AA` | 3/3 | 9/9 | 0 |
| Dry-run de regresión | `0AfAK000000vpvR0AQ` | 3/3 | 18/18 | 0 |
| Deploy real | `0AfAK000000vpx30AA` | 3/3 | 18/18 | 0 |

El dry-run funcional confirmó una cobertura de 282/302 líneas para
`TrabajoQuoteController`, equivalente a 93.38%.

El deploy real terminó correctamente en RedMotorsSandbox / Partial. Quedaron
desplegados:

- `TrabajoQuoteController`;
- `TrabajoQuoteControllerTest`;
- `TipoDeCargoConManoDeObra__c.Empresa__c`, con soporte para `RMPEKING`.

Se validaron nueve escenarios funcionales y 18 pruebas de regresión. El
lookup `Opportunity.Empresa_Operadora__c` quedó como fuente principal;
`BMW_Compania__c` permanece como respaldo explícito para Bavarian y Otobai.
No existe fallback automático hacia `RMOTOBAI`.

## Riesgos y pendientes

- La operación real de PEKING requiere registros
  `TipoDeCargoConManoDeObra__c` con código `RMPEKING`.
- La mano de obra debe tener una entrada activa en el Pricebook de la Quote.
- El manejo público existente convierte la causa de configuración en
  `AuraHandledException`; se conserva la firma y el contrato de interfaz.

No se modificaron cálculos, tipos de cargo, Pricebooks ni la creación general
de líneas.

## Avance técnico estimado

- completado: 78%;
- pendiente: 22%.

Es una estimación del alcance técnico y no representa horas oficiales,
trabajadas, registradas ni facturables.
