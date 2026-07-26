# Desfase Git ↔ Partial — `RM_VN_CrearOportunidad_Ctrl_Test`

## Resumen

El archivo `force-app/main/default/classes/RM_VN_CrearOportunidad_Ctrl_Test.cls`
tiene dos versiones divergentes que no son evolución una de la otra: la que vive en
`sprint1` (git) y la recuperada desde el sandbox Partial. Este documento registra el
desfase para que quede visible antes de cualquier integración futura del hotfix de
tráfico.

## 1. Versión en sprint1

- Rama: `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724`.
- Archivo: 62 líneas.
- Un único método de prueba: `testGetProducts()`.
- `@TestSetup` mínimo: `RM_VN_DataFactoryHelper.createRecordsVN();`.
- Declaración de clase: `public with sharing class RM_VN_CrearOportunidad_Ctrl_Test`.

## 2. Versión recuperada de Partial

- Archivo: 787 líneas.
- 27 métodos `@IsTest`.
- `@TestSetup` propio y extenso: Trigger controls, Account, Bodega__c, 2 `Product2`
  (vehículo + fantasía), `ProductoXBodega__c`, 2 `Pricebook2`,
  `Configuracion_de_ventas__c`, 3 `PricebookEntry`.
- 8 helpers privados (`getRecordTypeId`, `getTestAccount`, `getContactoId`,
  `getValidPXB`, `getFantasiaPBE`, `getSoftlandPBE`, `buildItems`,
  `getFirstPicklistValue`) + inner class `DummyHttpMock`.
- Declaración de clase: `private class RM_VN_CrearOportunidad_Ctrl_Test`.

No existe un diff línea a línea razonable entre ambas: son dos linajes distintos,
no una evolución incremental.

## 3. Hotfix validado y desplegado

El único cambio funcional que el hotfix aporta sobre la versión previamente
recuperada de Partial (commit `053aa3e`) es una sola línea dentro de
`test_createOpportunity_conTrafico`:

```apex
Convertido_custom__c = true,
```

Este valor es exigido por la Validation Rule `Bloquear_conversion_estandar` del
Lead antes de permitir su conversión estándar (`Database.convertLead`). Sin este
valor en el fixture, la conversión falla y la excepción resultante —envuelta como
`AuraHandledException`— se manifiesta como `Script-thrown exception` en el test.

## 4. Rama y commit de respaldo

- Rama: `fix/pc/redmotors-regression-traffic-test-20260726`.
- Commit: `5ecc127` — `test(traffic): align conversion fixture with validation`.

## 5. Por qué no debe hacerse merge completo

La versión completa recuperada de Partial arrastra, además del fix de tráfico, dos
cambios funcionales no relacionados y **no versionados en sprint1**:

- Campo `Opportunity.BMW_Compania__c`.
- Campo `Opportunity.empresaQueFactura__c`.
- Método `RM_VN_CrearOportunidad_Ctrl.normalizeEmpresaQueFactura(...)`.
- Método `RM_VN_CrearOportunidad_Ctrl.getBMWCompania(...)`.

Ninguno de estos dos campos ni estos dos métodos existe actualmente en
`RM_VN_CrearOportunidad_Ctrl.cls` de sprint1, y el hotfix tampoco los agrega (no
modifica la clase productiva). Se confirmó además que no hay rastro de
`normalizeEmpresaQueFactura` en ningún otro punto del historial de git fuera de
este commit del hotfix — es una funcionalidad que ya existe en Partial/Sandbox pero
nunca fue capturada en este repositorio. Un merge completo de la clase de test
referenciaría campos y métodos inexistentes y **no compilaría** contra el estado
actual de sprint1.

## 6. Decisión

Mantener la rama `fix/pc/redmotors-regression-traffic-test-20260726` preservada,
sin integrar, hasta realizar una sincronización controlada y separada de las
clases/campos que ya están desplegados en Partial (`BMW_Compania__c`,
`empresaQueFactura__c`, `normalizeEmpresaQueFactura`, `getBMWCompania`) pero
ausentes en git. Esa sincronización es un trabajo propio, distinto del fix de
tráfico, y debe abordarse aparte.

## 7. Impacto sobre el cierre del Bloque 19

Este desfase **no bloquea ni invalida el cierre del Bloque 19**. Bloque 19 ya fue
integrado a `sprint1` (commits `fe432cd`, `a993eee`, merge `eede33e`) y no depende
de `RM_VN_CrearOportunidad_Ctrl_Test` ni de los campos `BMW_Compania__c`/
`empresaQueFactura__c` — esa clase y esos campos pertenecen a
`RM_VN_CrearOportunidad_Ctrl`, fuera del alcance de los componentes de Bloque 19
(`RM_VN_CrearOppModeloInteres_Ctrl` y su test). La regresión externa que motivó el
hotfix es, y sigue siendo, deuda externa preexistente, no una dependencia real del
Bloque 19.
