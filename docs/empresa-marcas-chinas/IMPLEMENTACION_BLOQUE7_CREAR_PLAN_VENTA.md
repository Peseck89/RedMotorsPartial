# Implementación del Bloque 7 — Empresa en Crear Plan de Venta

## Objetivo

Propagar directamente `Opportunity.Empresa_Operadora__c` desde la
Opportunity original hacia la nueva Opportunity creada por
`CrearPlandeVenta`.

## Checkpoint

- commit protegido: `ae6e0e6`;
- backup: `backup/pc/redmotors-before-plan-venta-20260725`.

## Análisis previo

`CrearPlandeVenta` no clona la Opportunity completa. Consulta un subconjunto
de campos, calcula datos según el Record Type, inserta una nueva Opportunity,
crea un Quote y copia determinadas líneas.

Antes de este bloque:

- `BMW_Compania__c` se consultaba en la Opportunity original;
- su valor normalmente se recalculaba como Bavarian u Otobai según el Record
  Type;
- el resultado se asignaba a la nueva Opportunity y a `Quote.Compania__c`;
- `Empresa_Operadora__c` no se consultaba ni se copiaba.

## Cambio productivo

La propagación del lookup preparada originalmente se conserva:

1. Se agregó `Empresa_Operadora__c` al SOQL de la Opportunity original.
2. Se copió directamente el Id del lookup:

```apex
newOpp.Empresa_Operadora__c = oppOriginal.Empresa_Operadora__c;
```

Después del dry-run bloqueado, Luis autorizó la siguiente precedencia para la
cuenta de facturación:

1. utilizar `Opportunity.Cuenta_de_Facturaci_n__c` de la Opportunity
   original cuando tenga valor;
2. utilizar la cuenta fija correspondiente al Record Type únicamente cuando
   el campo original esté vacío.

Para implementarla:

- se agregó `Cuenta_de_Facturaci_n__c` al SOQL de la Opportunity original;
- `accountIdFacturacion` se inicializa con ese campo;
- cada asignación hardcodeada existente se ejecuta solamente si el valor
  continúa vacío;
- el mismo valor se asigna a la nueva Opportunity y al nuevo Quote.

No se utilizó `EmpresaResolver` y no se transformó el lookup.

Se mantuvieron sin cambios:

- cálculo de `BMW_Compania__c`;
- cálculo por Record Type;
- `Quote.Compania__c`;
- Pricebooks;
- talleres;
- cuentas fijas, como respaldo;
- centros de costo;
- VIN;
- detección de duplicados;
- creación de líneas;
- IDs hardcodeados;
- comportamiento ante valores nulos.

Una contradicción entre lookup y picklist se conserva. Este bloque no
sincroniza ni corrige ambos campos.

## Pruebas

Se creó `CrearPlandeVentaTest` sin `SeeAllData`, con tres escenarios:

1. Opportunity con una Empresa autocontenida cuyo código es `RMPEKING`:
   - ejecuta el método invocable;
   - obtiene el Quote retornado;
   - verifica que la nueva Opportunity conserva el mismo Id del lookup;
   - verifica que la Opportunity original no fue modificada.
2. Opportunity sin lookup:
   - verifica que la nueva Opportunity mantiene el lookup nulo;
   - verifica que `BMW_Compania__c` conserva el cálculo actual;
   - verifica que `Quote.Compania__c` permanece sincronizado con ese valor;
   - verifica que el Quote pertenece a una Opportunity nueva.
3. Opportunity sin cuenta de facturación:
   - confirma que el campo fuente está vacío;
   - determina la cuenta fija correspondiente al Record Type;
   - confirma que se conserva el ID legado mediante el error de acceso de
     referencia cruzada ya observado en el sandbox.

Los dos escenarios funcionales crean su propia Account y verifican que
`Cuenta_de_Facturaci_n__c` tiene prioridad tanto en la nueva Opportunity
como en `Quote.Cuenta_de_facturaci_n2__c`. También confirman que la
Opportunity original no cambia.

Los datos fuente de Empresa, Account, Pricebook, Opportunity y Quote son
autocontenidos.

## Dry-run anterior y motivo del cambio

El dry-run `0AfAK000000vomT0AQ` compiló 2/2 componentes, pero sus 2 pruebas
fallaron antes de completar el flujo. La inserción de la nueva Opportunity
intentó utilizar la cuenta fija `001PH00000X9ZEcYAN` y Salesforce devolvió
`INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY` en
`CrearPlandeVenta.generarEstructuraPlanVenta`, línea 163 de esa versión.

La org no fue modificada. La nueva precedencia evita esa dependencia cuando
la Opportunity original ya tiene una cuenta de facturación válida, sin
eliminar el comportamiento heredado para registros vacíos.

## Dry-run de cobertura

| Dato | Resultado |
|---|---|
| Deploy ID | `0AfAK000000vp7R0AQ` |
| Componentes | 2/2 |
| Pruebas | 3/3 |
| Fallas | 0 |
| Líneas ejecutables | 127 |
| Líneas cubiertas | 75 |
| Líneas no cubiertas | 52 |
| Cobertura | 59.055% |
| Estado de la org | Sin modificaciones |

### Matriz de líneas y ramas no cubiertas

| Líneas | Rama funcional | Tratamiento |
|---|---|---|
| 59-61 | Taller de motos para Motorrad, Indian, Kawasaki, Polaris o motos usadas | Prueba dirigida con Record Type Indian |
| 72-75 | Compañía, Pricebook y cuenta de respaldo Otobai | Se cubre compañía y Pricebook con Indian; la cuenta fija solo se ejecuta si la cuenta fuente está vacía |
| 82-85 | Centros de costo de Motorrad, MINI, Indian/Kawasaki/Polaris y Autos usados | Indian cubre la rama agrupada; las demás requieren Record Types adicionales |
| 86-100 | Centro de costo de motos usadas según marca del OpportunityLineItem | Pendiente por dependencia de líneas, productos y IDs fijos de centro de costo |
| 117-119 | Extracción del VIN desde una regalía tipo Vehiculo | Prueba de retorno anticipado por VIN |
| 154-163 | Búsqueda y retorno de un plan y Quote ya existentes para el VIN | Prueba de retorno anticipado por VIN |
| 196-197 | Recolección de productos de regalía distintos de Vehiculo y Mano de Obra | Pruebas con regalía tipo Varios |
| 204, 206-211 | Búsqueda del PricebookEntry USD compatible | Pruebas con entrada activa e inactiva |
| 217, 219 | Resolución del PricebookEntry destino | Pruebas con entrada activa e inactiva |
| 222-235, 241 | Construcción e inserción de la línea copiada | Prueba con PricebookEntry compatible |

### Pruebas agregadas

1. `returnsExistingPlanWhenGiftVehicleHasSameVin`
   - crea una regalía tipo Vehiculo con VIN;
   - crea previamente el plan y Quote con los Record Types utilizados por la
     clase;
   - confirma el retorno del Quote existente y que no se duplica el plan.
2. `copiesGiftLineWhenCompatiblePricebookEntryExists`
   - crea producto, precios estándar y del Pricebook, Quote y regalía;
   - confirma la copia de producto, Pricebook, cantidad, precio, descuento,
     descripción y fecha de servicio.
3. `skipsGiftLineWhenCompatiblePricebookEntryIsInactive`
   - conserva la línea fuente pero desactiva su entrada;
   - confirma que el nuevo Quote no recibe una línea sin entrada activa
     compatible.
4. `appliesOtobaiBranchForIndianRecordType`
   - usa el Record Type Indian y una cuenta de facturación autocontenida;
   - confirma Otobai en Opportunity y Quote;
   - confirma que la cuenta original se propaga sin usar la cuenta fija.

No se agregó una prueba con múltiples `FlowInput`: cada iteración realiza
consultas y DML completos, por lo que aporta pocas ramas nuevas y eleva el
riesgo de límites sin mejorar la cobertura funcional prioritaria.

Las pruebas nuevas cubren de forma estimada al menos 32 líneas previamente no
cubiertas. Esto proyecta un mínimo de 107/127, equivalente a 84.252%. Si la
rama Indian aporta todas sus líneas previstas, la proyección alcanza
aproximadamente 113/127, equivalente a 88.976%. La cifra definitiva requiere
un nuevo dry-run.

## Corrección de compilación de datos de regalía

El dry-run `0AfAK000000vp930AA` falló durante la compilación de
`CrearPlandeVentaTest`, antes de ejecutar pruebas. Salesforce reportó en la
línea 394:

`Field is not writeable: QuoteLineItem.BMW_TipoDeArticulo__c`.

La org no fue modificada.

El describe de solo lectura confirmó:

- `QuoteLineItem.BMW_TipoDeArticulo__c` es un campo fórmula de texto;
- su fórmula es `TEXT(Product2.tipoProducto__c)`;
- no admite creación ni actualización directa;
- `Product2.tipoProducto__c` es un picklist editable, no restringido;
- `QuoteLineItem.esRegalia__c` es el indicador editable utilizado por la
  consulta de `CrearPlandeVenta` para incluir la línea como regalía.

La prueba ahora asigna el tipo en `Product2.tipoProducto__c` y conserva
`QuoteLineItem.esRegalia__c = true`. Se eliminó la asignación directa al campo
fórmula. Product2, PricebookEntry y QuoteLineItem siguen siendo creados con
datos autocontenidos.

## Corrección de Record Types en las pruebas

El dry-run `0AfAK000000vpAf0AI` compiló 2/2 componentes, pero aprobó 1/7
pruebas. Las otras seis fallaron en `createSourceQuote`, línea 360, al
insertar una Opportunity:

`INVALID_CROSS_REFERENCE_KEY: Id. de tipo de registro: this ID value isn't
valid for the user`.

La cobertura temporal fue 61.417% y la org no fue modificada.

El helper incluía `RecordTypeId` en el constructor de todas las Opportunities,
incluso cuando el parámetro recibido era nulo. Solo la prueba Indian
proporcionaba un Record Type resuelto y disponible expresamente; las demás
quedaban sujetas a una asignación de Record Type no válida para el contexto
de ejecución.

La corrección:

- omite por completo `RecordTypeId` cuando la rama no necesita un tipo
  específico, permitiendo el predeterminado disponible;
- resuelve Opportunity Indian mediante `DeveloperName = Indian`;
- resuelve Opportunity Planes de Venta mediante
  `DeveloperName = Planes_de_Venta`;
- resuelve Quote Taller mediante `DeveloperName = Taller`;
- utiliza `getRecordTypeInfosByDeveloperName()`;
- exige que el Record Type exista y que `isAvailable()` sea verdadero antes
  de usar su Id;
- elimina de la prueba todos los IDs fijos de Record Type.

Indian se conserva únicamente para recorrer la rama Otobai. Planes de Venta y
Taller se conservan porque la lógica de retorno anticipado filtra
explícitamente esos tipos de registro.

## Riesgos y validación pendiente

La clase productiva conserva IDs hardcodeados para Record Types, Pricebooks,
cuentas de respaldo, talleres y centros de costo. También dispara
automatizaciones al insertar Opportunity y Quote.

El escenario de respaldo no puede completar el DML con datos totalmente
autocontenidos porque el ID fijo pertenece al sandbox y no es accesible en el
contexto de la prueba. La prueba confirma que el respaldo se mantiene, pero
no valida una creación exitosa mediante esa ruta.

Las ramas de centros de costo conservan IDs externos. Se cubre Indian sin
depender de la cuenta fija, pero no se fuerza el uso exitoso de esos centros
de costo ni las ramas de motos usadas.

No se introdujeron bypasses con `Test.isRunningTest`, IDs alternativos,
refactors, `SeeAllData` ni desactivación de automatizaciones. Las dependencias
hardcodeadas permanecen como riesgo heredado, pero no bloquearon la
validación final ni el deploy.

## Componentes no modificados

- flows;
- metadata;
- Permission Sets;
- integraciones;
- reservas;
- Product2;
- plantillas;
- lógica de Empresa o Pricebook.

## Validación final y deploy

| Validación | Deploy ID | Componentes | Pruebas | Fallas |
|---|---|---:|---:|---:|
| Dry-run funcional | `0AfAK000000vpFV0AY` | 2/2 | 7/7 | 0 |
| Dry-run de regresión | `0AfAK000000vpH70AI` | 2/2 | 17/17 | 0 |
| Deploy real | `0AfAK000000vpIj0AI` | 2/2 | 17/17 | 0 |

El deploy real terminó correctamente en RedMotorsSandbox / Partial.

La cobertura final de `CrearPlandeVenta` fue 115/127 líneas, equivalente a
90.55%.

## Cierre técnico

El Bloque 7 queda completado, validado y desplegado con el siguiente
comportamiento:

- `CrearPlandeVenta` copia `Opportunity.Empresa_Operadora__c` sin
  transformación;
- `Opportunity.Cuenta_de_Facturaci_n__c` de la Opportunity original tiene
  prioridad;
- las cuentas hardcodeadas existentes se conservan únicamente como fallback
  cuando el campo original está vacío;
- el resultado de la selección de cuenta se utiliza tanto en la nueva
  Opportunity como en el nuevo Quote;
- no se modificaron Record Types, compañías, Pricebooks, talleres, centros de
  costo, VIN, líneas ni automatizaciones.

`CrearPlandeVentaTest` contiene siete métodos que validan:

- copia del lookup de Empresa;
- precedencia de la cuenta de facturación;
- fallback heredado;
- comportamiento de compañía con lookup nulo;
- retorno anticipado por VIN;
- regalía con PricebookEntry compatible;
- regalía sin PricebookEntry activo compatible;
- rama Otobai mediante el Record Type Indian.

Avance técnico estimado del Sprint 1:

- completado: 72%;
- pendiente: 28%.

Este porcentaje corresponde al alcance técnico y no representa horas
oficiales, trabajadas, registradas ni facturables.
