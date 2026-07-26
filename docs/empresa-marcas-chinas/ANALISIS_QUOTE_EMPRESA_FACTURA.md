# Análisis — `Quote.empresaFactura__c`

## Estado

No se implementó cambio funcional.

La revisión confirmó que `Quote.empresaFactura__c` no es un campo editable ni una fuente primaria de empresa. Es una fórmula de texto basada en:

`TEXT(Opportunity.empresaQueFactura__c)`

## Hallazgos

### Campos relacionados en Quote

`Quote.Compania__c`:

- tipo: picklist restringido;
- valores activos: `Bavarian`, `Otobai`.

`Quote.empresaFactura__c`:

- tipo: fórmula de texto;
- fórmula: `TEXT(Opportunity.empresaQueFactura__c)`;
- no es editable directamente.

### Campo fuente en Opportunity

`Opportunity.empresaQueFactura__c`:

- tipo: picklist restringido;
- valores activos:
  - `Bavarian`;
  - `Otobay`.

También existe `Opportunity.Empresa_Operadora__c`, lookup hacia `Empresa__c`, que ya fue implementado como fuente principal en bloques anteriores.

## Consumidores encontrados

El campo y su fuente aparecen en:

- componentes de búsqueda de productos en WorkOrder y Quote;
- Flows de Opportunity, WorkOrder y reenvío de encuesta;
- clases relacionadas con generación o cancelación de pedidos;
- clases relacionadas con datos hacia procesos externos.

Varios consumidores pertenecen a dominios explícitamente fuera de alcance para cambios autónomos en esta etapa:

- integraciones;
- Softland;
- órdenes;
- procesos operativos dependientes de Flows.

## Conclusión

No existe una corrección técnica única y segura para agregar PEKING en `Quote.empresaFactura__c` de forma aislada.

Agregar `PEKING` a `Opportunity.empresaQueFactura__c` o modificar la fórmula de Quote requeriría una decisión funcional sobre:

1. si `empresaQueFactura__c` debe seguir existiendo como picklist heredado;
2. si debe reflejar `Empresa_Operadora__c`;
3. cómo deben comportarse los Flows y procesos externos que ya consumen ese valor;
4. cómo resolver la discrepancia existente `Otobay` / `Otobai`.

## Decisión

No se modifica `Quote`, `Opportunity`, Flows ni Apex.

El soporte de empresa configurable en Quote debe continuar usando los componentes ya migrados a `Opportunity.Empresa_Operadora__c`. Cualquier cambio sobre `empresaQueFactura__c` debe tratarse como bloque separado con definición funcional explícita.

## Validación

No se ejecutó dry-run ni deploy porque no se preparó cambio funcional.

No se modificaron:

- Apex;
- metadata;
- Flows;
- permisos;
- datos;
- integraciones.

## Pendientes

- Definir si `Opportunity.empresaQueFactura__c` debe migrarse, mantenerse o retirarse.
- Definir si el valor `Otobay` debe corregirse o conservarse por compatibilidad.
- Definir si `Quote.empresaFactura__c` debe seguir siendo fórmula del picklist heredado o derivarse del lookup `Empresa_Operadora__c`.
