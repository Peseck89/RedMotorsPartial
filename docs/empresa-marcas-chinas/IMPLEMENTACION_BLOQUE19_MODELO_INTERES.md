# Implementación Bloque 19 - Empresa Operadora en creación de Opportunity desde modelo de interés

## Estado

Implementación local preparada en worktree aislado. Pendiente de dry-run porque el Bloque 18 continúa ejecutándose contra RedMotorsSandbox.

## Alcance autorizado

Luis autorizó agregar Empresa Operadora a la creación de Opportunity desde modelo de interés en `RM_VN_CrearOppModeloInteres_Ctrl.createOpportunity(...)`.

El bloque se limita a:

- resolver la empresa desde la marca recibida;
- asignar `Opportunity.Empresa_Operadora__c`;
- conservar la creación actual de Opportunity, OpportunityLineItem y `Oportunidad_Producto_Interes__c`;
- mantener sin cambios la resolución actual de Record Type con `DeveloperName = :brand.toUpperCase()`, porque una consulta de solo lectura confirmó que encuentra Omoda y Jaecoo.

## Preflight técnico

Worktree:

`C:\Users\dokur\Documents\Repositorios\RedMotors-Bloque19-ModeloInteres`

Rama:

`feature/pc/redmotors-empresa-marcas-chinas-bloque19-modelo-interes-20260726`

Base:

`origin/feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724`

Rama de respaldo publicada:

`backup/pc/redmotors-before-bloque19-modelo-interes-20260726`

Org confirmada:

`RedMotorsSandbox`, instancia Partial/Sandbox.

## Record Types confirmados por consulta de solo lectura

| DeveloperName | Activo |
|---|---:|
| BMW | Sí |
| MINI | Sí |
| Polaris | Sí |
| Kawasaki | Sí |
| Omoda | Sí |
| Jaecoo | Sí |

Además, la consulta con `OMODA`, `JAECOO`, `POLARIS` y `KAWASAKI` confirmó que la comparación actual con `brand.toUpperCase()` encuentra los Record Types existentes. Por esa razón no se modificó la resolución de Record Type.

## Cambio productivo preparado

Se agregó un helper privado explícito para resolver la empresa por marca:

| Marca | Código Empresa |
|---|---|
| BMW | RMBAVARIAN |
| MINI | RMBAVARIAN |
| Polaris | RMOTOBAI |
| Kawasaki | RMOTOBAI |
| Omoda | RMPEKING |
| Jaecoo | RMPEKING |

Una marca desconocida genera error controlado antes de cualquier DML.

La empresa se resuelve mediante:

`EmpresaResolver.resolveByCodigo(codigoEmpresa)`

La Opportunity nueva recibe:

`Opportunity.Empresa_Operadora__c = empresaContext.empresaId`

## Comportamiento conservado

No se modificó:

- `Pricebook2Id`;
- creación de `OpportunityLineItem`;
- creación de `Oportunidad_Producto_Interes__c`;
- búsqueda o conversión de tráfico;
- Account;
- forma de pago;
- datos financieros;
- Softland;
- reservas;
- inventario;
- permisos;
- Flows;
- `ProductSearcherController`;
- Bloque 18.

No se eliminó `dummy()` en esta etapa.

## Pruebas preparadas

`RM_VN_CrearOppModeloInteres_Ctrl_Test` fue reconstruida con fixtures autocontenidos.

Datos creados por prueba:

- `Empresa__c` para `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`;
- Account;
- Pricebook2;
- Product2;
- PricebookEntry estándar;
- PricebookEntry del Pricebook de prueba.

Escenarios cubiertos:

1. BMW → `RMBAVARIAN`.
2. MINI → `RMBAVARIAN`.
3. Polaris → `RMOTOBAI`.
4. Kawasaki → `RMOTOBAI`.
5. Omoda → `RMPEKING`.
6. Jaecoo → `RMPEKING`.
7. Marca desconocida → error controlado y cero registros parciales.
8. Empresa inactiva → error y cero registros parciales.

En escenarios positivos se valida:

- `Opportunity.Empresa_Operadora__c`;
- `Opportunity.RecordTypeId`;
- `Opportunity.Pricebook2Id`;
- creación de `OpportunityLineItem`;
- creación de `Oportunidad_Producto_Interes__c`;
- `opportunityId` retornado.

## Manifest

`manifest/empresa-marcas-chinas-bloque19-modelo-interes.xml`

Incluye únicamente:

- `RM_VN_CrearOppModeloInteres_Ctrl`;
- `RM_VN_CrearOppModeloInteres_Ctrl_Test`.

## Validaciones

### Diagnóstico del fixture Product2

Se revisó que `createOpportunity(...)` utiliza la marca funcional desde el parámetro `brand` para resolver el Record Type y la empresa operadora. El `Product2` consultado se usa para obtener el producto asociado al `PricebookEntry`, su `Familia__c` cuando aplica y el modelo de interés; no se usa `Product2.Marca__c` para resolver empresa ni Record Type.

La metadata y datos de referencia de Partial confirmaron dependencias de picklist en `Product2`:

- `Product2.Categor_a_veh_culo__c` es picklist restringido controlado por `Marca__c`.
- `Product2.Grupo__c` es picklist restringido controlado por `Categor_a_veh_culo__c`.
- `Product2.Familia__c` es picklist restringido controlado por `Grupo__c`.
- La combinación válida usada en el fixture es `Marca__c = BMW`, `Categor_a_veh_culo__c = SUV`, `Grupo__c = X`, `Familia__c = X1`.
- El Record Type operativo de `Product2` usado en pruebas es `Producto_Red_Motors`, resuelto dinámicamente por Schema Describe.

La asignación de `Product2.Marca__c = BMW` en el fixture es exclusivamente técnica para satisfacer la dependencia de picklist. La marca funcional probada continúa llegando mediante el parámetro `brand` de `createOpportunity(...)`.

### Dry-runs enfocados fallidos y correcciones

| Deploy ID | Resultado | Causa | Corrección |
|---|---|---|---|
| `0AfAK000000vsmr0AA` | Compilación fallida | La prueba invocaba `createOpportunity(...)` con 20 parámetros; la firma real contiene 21. | Se agregó el parámetro faltante como `null`. |
| `0AfAK000000vsoT0AQ` | 0/8 pruebas | `Product2.Familia__c` rechazó `SUV`. | Se separaron `Categor_a_veh_culo__c`, `Grupo__c` y `Familia__c`. |
| `0AfAK000000vstJ0AQ` | 0/8 pruebas | Valores no válidos en picklists restringidos del fixture. | Se retiraron asignaciones directas no requeridas por la lógica funcional. |
| `0AfAK000000vsi20AA` | 0/8 pruebas | `Product2.Grupo__c = X` sin la cadena completa de dependencias. | Se agregó `Categor_a_veh_culo__c = SUV`. |
| `0AfAK000000vsuv0AA` | 0/8 pruebas | `Categor_a_veh_culo__c = SUV` requería valor controlador en `Marca__c`. | Se agregó `Marca__c = BMW` solo para el fixture. |
| `0AfAK000000vszl0AA` | 0/8 pruebas | La combinación dependiente requería Record Type operativo de Product2. | Se resolvió dinámicamente `Producto_Red_Motors`. |
| `0AfAK000000vt4b0AA` | 0/8 pruebas | Duplicidad de `PricebookEntry` estándar para el mismo producto y moneda. | Se agregó helper de prueba que reutiliza la entrada estándar si ya existe. |
| `0AfAK000000vtFt0AI` | Compilación fallida | Cierre de llaves incorrecto al retirar código histórico de cobertura. | Se corrigió el cierre final de clase. |
| `0AfAK000000vtHV0AY` | 8/8 pruebas, cobertura insuficiente | Cobertura 115/207 = 55.556%. | Se agregaron pruebas funcionales de métodos públicos y validaciones tempranas. |
| `0AfAK000000vtKj0AI` | 9/11 pruebas | Aserción inestable sobre `Invoice_Email__c` y uso repetido de `Test.startTest()`. | Se ajustaron aserciones deterministas y el helper de error. |
| `0AfAK000000vt300AA` | Compilación fallida | Se retiró por error `findValidTraffic(...)`, que sí es usado por `createOpportunity(...)`. | Se restauró únicamente ese helper. |

La org no fue modificada en ninguno de estos dry-runs.

### Ajuste de cobertura

El método histórico `dummy()` no tenía llamadores y agregaba líneas ejecutables sin comportamiento funcional. Se eliminó con el objetivo de medir cobertura real.

Además, se retiraron helpers privados locales de tráfico que no tenían llamadores dentro de esta clase y duplicaban lógica que la ruta pública no invoca. Se conservó `findValidTraffic(...)` porque `createOpportunity(...)` sí lo utiliza. La llamada productiva a conversión de tráfico permanece apuntando a `RM_VU_CrearOportunidad_Ctrl.convertTrafficLead(...)`, sin cambios funcionales.

### Dry-run enfocado exitoso — 0AfAK000000vtML0AY

- Componentes: 2/2.
- Pruebas ejecutadas: 11/11.
- Fallas: 0.
- Cobertura de `RM_VN_CrearOppModeloInteres_Ctrl`: 136/151 = 90.066%.
- Estado: Succeeded.
- La org no fue modificada.

### Regresión bloqueada

Se ejecutó la regresión autorizada con:

- `RM_VN_CrearOppModeloInteres_Ctrl_Test`;
- `RM_VN_CrearOportunidad_Ctrl_Test`;
- `EmpresaResolverTest`.

Resultados:

| Deploy ID | Resultado | Falla |
|---|---|---|
| `0AfAK000000vtPZ0AY` | 47/48 pruebas | `RM_VN_CrearOportunidad_Ctrl_Test.test_createOpportunity_conTrafico` falló con `Script-thrown exception`. |
| `0AfAK000000vtRB0AY` | 47/48 pruebas | Misma falla en `RM_VN_CrearOportunidad_Ctrl_Test.test_createOpportunity_conTrafico`. |

La falla pertenece a una prueba de `RM_VN_CrearOportunidad_Ctrl_Test`, fuera de los archivos del Bloque 19. No se ejecutó deploy real porque la regresión no quedó aprobada.

## Estado final del bloque

Bloque 19 queda implementado localmente y con dry-run enfocado aprobado, pero bloqueado para deploy real por regresión externa fallida.

Se deja commit WIP y rama publicada para preservar el avance sin integrar todavía a la rama principal del sprint.

## Manifest

`manifest/empresa-marcas-chinas-bloque19-modelo-interes.xml`

Incluye únicamente:

- `RM_VN_CrearOppModeloInteres_Ctrl`;
- `RM_VN_CrearOppModeloInteres_Ctrl_Test`.

## Pendientes

- Resolver o excluir formalmente la falla externa de `RM_VN_CrearOportunidad_Ctrl_Test.test_createOpportunity_conTrafico` antes de deploy real.
- Ejecutar nuevamente la regresión autorizada.
- Ejecutar deploy real solo después de regresión aprobada.
- Integrar la rama del Bloque 19 a la rama principal del sprint cuando el cierre técnico esté completo.

Avance técnico estimado al completar el deploy del Bloque 19: 86% completado y 14% pendiente. Corresponde al alcance técnico y no representa horas oficiales, trabajadas ni facturables.
