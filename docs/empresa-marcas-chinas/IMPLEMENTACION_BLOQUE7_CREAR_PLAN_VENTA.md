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

Se aplicaron únicamente dos cambios:

1. Se agregó `Empresa_Operadora__c` al SOQL de la Opportunity original.
2. Se copió directamente el Id del lookup:

```apex
newOpp.Empresa_Operadora__c = oppOriginal.Empresa_Operadora__c;
```

No se utilizó `EmpresaResolver` y no se transformó el lookup.

Se mantuvieron sin cambios:

- cálculo de `BMW_Compania__c`;
- cálculo por Record Type;
- `Quote.Compania__c`;
- Pricebooks;
- talleres;
- cuentas;
- centros de costo;
- VIN;
- detección de duplicados;
- creación de líneas;
- IDs hardcodeados;
- comportamiento ante valores nulos.

Una contradicción entre lookup y picklist se conserva. Este bloque no
sincroniza ni corrige ambos campos.

## Pruebas

Se creó `CrearPlandeVentaTest` sin `SeeAllData`, con dos escenarios:

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

Los datos fuente de Empresa, Account, Pricebook, Opportunity y Quote son
creados por cada prueba.

## Riesgos y validación pendiente

La clase productiva conserva IDs hardcodeados para Record Types, Pricebooks,
cuentas, talleres y centros de costo. También dispara automatizaciones al
insertar Opportunity y Quote.

No se introdujeron bypasses con `Test.isRunningTest`, IDs alternativos,
refactors, `SeeAllData` ni desactivación de automatizaciones. La ejecución
real de las pruebas queda pendiente de dry-run. Si alguna dependencia
hardcodeada impide el DML, debe registrarse la línea, el ID y el componente
exactos antes de considerar una alternativa.

## Componentes no modificados

- flows;
- metadata;
- Permission Sets;
- integraciones;
- reservas;
- Product2;
- plantillas;
- lógica de Empresa o Pricebook.

## Estado

Implementación local preparada. No se encontraron bloqueos de sintaxis o
estructura mediante revisión local; las dependencias de datos y
automatizaciones quedan pendientes de validación.

El avance técnico estimado posterior permanece pendiente del dry-run. No
representa horas oficiales, trabajadas o facturables.
