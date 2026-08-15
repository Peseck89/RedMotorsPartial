# Continuidad — Catálogo temporal OMODA y dependencias de picklist en Product2

## Fecha

2026-08-14

## Clasificación

Este trabajo es parte del alcance de Sprint 4: Global Value Sets, configuración de Product2, creación/población de Pricebooks, y soporte necesario para catálogo OMODA/JAECOO. No es trabajo extra ni fuera de alcance.

## Motivo original

QA técnico manual de "Agregar vehículo" (flujo Venta Nueva) sobre la Opportunity OMODA `006AK00000JOCQ5YAP` (Empresa PEKING/RMPEKING, Pricebook "PEKING Dólares"), usando el Product Interest `a4KAK0000001Awb2AE` (Marca OMODA, Año 2026, Modelo `QA OMODA`).

## Cadena de errores funcionales encontrados y resueltos, en orden

1. **"Favor de revisar la configuración de la lista de precio en Configuración de Ventas."** — `RM_VN_Service.getSoftlandPriceBookId()` no encontraba `Configuracion_de_ventas__c` para OMODA. Resuelto creando `Configuracion_de_ventas__c` `a07AK00000IflvXYAR` (Marca__c=OMODA, Listas_de_Precios_Vigente__c='OMODA - 2026', RM_ListaPrecioSoftland__c=Pricebook2 "PEKING Dólares").

2. **"No se encontraron precios de fantasía la Marca y Año ingresados."** — `RM_VN_Service.getPBEFantasiaGroupByModel(brand, year)` requiere un `Product2` + `PricebookEntry` de referencia dentro de un `Pricebook2` cuyo nombre contenga la marca y el año (ej. "OMODA - 2026"). Actualmente no existe ningún `Product2` con `Marca__c = 'OMODA'`, ni el Pricebook2 "OMODA - 2026". **Aún sin resolver — es el objetivo funcional final de esta línea de trabajo.**

## Intento fallido de creación de catálogo temporal

Se autorizó y ejecutó un intento de inserción atómica (sin try/catch, rollback automático garantizado) de 4 registros: `Product2` ("OMODA QA 2026", Marca__c='OMODA', Modelo_De_Inter_s__c='QA OMODA'), `Pricebook2` ("OMODA - 2026"), y 2 `PricebookEntry` (Standard + OMODA - 2026).

**Falló en el primer INSERT** (`Product2`) con:

```
System.DmlException: Insert failed. First exception on row 0; first error: INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, bad value for restricted picklist field: QA OMODA: [Modelo_De_Inter_s__c]
```

Rollback limpio confirmado por SOQL — 0 registros parciales. La causa raíz no era el valor del GVS (ya estaba activo), sino una restricción a nivel de `RecordType`.

## Descubrimiento de la cadena de dependencias de picklist (5 niveles)

`Product2` usa una cadena de picklists dependientes de **5 niveles**, no 4 como se asumió inicialmente:

```
Marca__c
  → Categor_a_veh_culo__c   (controllingField = Marca__c)
    → Grupo__c              (controllingField = Categor_a_veh_culo__c)
      → Familia__c          (controllingField = Grupo__c)
        → Modelo_De_Inter_s__c   (controllingField = Familia__c)
```

`Marca__c` es la raíz — es el único campo de los 5 sin `controllingField` propio, pero controla toda la cadena descendente.

Ejemplo real de referencia (BMW), Product2 `01tPH000002P7pxYAC`:

```
Marca__c = 'BMW'
  → Categor_a_veh_culo__c = 'Eléctrico'
    → Grupo__c = 'BMW i'
      → Familia__c = 'iX1'
        → Modelo_De_Inter_s__c = 'BMW-IX1-20-VR-XLINE'
```

Cada nivel tiene una restricción **adicional e independiente** por `RecordType`: el RecordType `Producto Red Motors` (`0120P000000ENW0QAO`) — el RT usado consistentemente por el 93–100% de los productos de catálogo real (BMW, MINI, Motorrad, Kawasaki, Indian, Polaris) — solo habilita un subconjunto de los valores activos del GVS maestro de cada campo:

| Campo | Valores activos (GVS maestro) | Valores habilitados para RT Producto Red Motors | ¿OMODA/JAECOO/QA OMODA presente? |
|---|---|---|---|
| `Marca__c` | 39 | 18 | No |
| `Categor_a_veh_culo__c` | — | 23 | No |
| `Grupo__c` | 68 | 68 | No |
| `Familia__c` | 162 | 72 | No |
| `Modelo_De_Inter_s__c` | 455 (incluye "QA OMODA" ya activo) | 338 | No |

## Limitación observada del retrieve aislado de RecordType

El retrieve dirigido:

```
sf project retrieve start --metadata "RecordType:Product2.Producto_Red_Motors" --target-org RedMotorsSandbox
```

**no exportó ninguna de las restricciones `<picklistValues>`** para los 5 campos anteriores — el archivo local resultante solo contenía 2 bloques (`Family`, `QuantityUnitOfMeasure`), lo cual generó una falsa contradicción "Metadata API vs UI API" reportada inicialmente como un posible gap de plataforma.

## Solución: retrieve completo de CustomObject:Product2

Se ejecutó, en carpeta externa fuera del repositorio (autorizado explícitamente por el usuario), el retrieve completo:

```
sf project retrieve start --metadata "CustomObject:Product2" --target-org RedMotorsSandbox --target-metadata-dir <ruta externa> --unzip
```

Resultado: `Product2.object` (formato Metadata API), 460,959 bytes, 12,658 líneas, SHA-256 `207c50810da5893d707ad93b19b8d5b3dc91051ddbeebe02fe0ce644acce1237`.

Este archivo **sí contiene** las 18 restricciones `<picklistValues>` completas del RecordType `Producto_Red_Motors` (incluidas las de los 5 campos de la cadena), con conteos que **coinciden exactamente** con lo reportado por UI API (18/23/68/72/338).

**Conclusión confirmada:** no existe ninguna contradicción real entre Metadata API y UI API. La discrepancia observada era exclusivamente un efecto del alcance limitado del retrieve de `RecordType` como componente aislado — el CLI omite las restricciones `<picklistValues>` cross-referenciadas cuando el RecordType se recupera solo, pero sí las incluye cuando se recupera el `CustomObject` completo. **No debe volver a usarse el retrieve aislado de RecordType como fuente completa para restricciones de picklist.**

## Conversión a Source Format y comparación contra el repo

Se convirtió el mdapi recuperado a Source Format, también fuera del repositorio:

```
sf project convert mdapi --root-dir <ruta externa>\unpackaged\unpackaged --output-dir <ruta externa>\source-convertido
```

Resultado relevante: `Producto_Red_Motors.recordType-meta.xml` convertido = **2,309 líneas** (18 campos con picklistValues), frente a las **21 líneas** (2 campos) del archivo actualmente versionado en el repo.

Adicionalmente se confirmó que el archivo `Categor_a_veh_culo__c.field-meta.xml` **no existe en absoluto en el repo local** (ni siquiera como archivo vacío) — existe únicamente en el resultado convertido, con su propia definición de dependencia (`controllingField=Marca__c`, `valueSetName=Categoria_Vehiculo`, restricted=true) y el mapa completo `Marca__c → Categor_a_veh_culo__c` a nivel de campo (global, no restringido por RT). Los otros 4 campos (`Marca__c`, `Grupo__c`, `Familia__c`, `Modelo_De_Inter_s__c`) sí existen localmente y su contenido es idéntico al convertido — la única brecha de contenido está en el archivo `RecordType`, no en los archivos de campo (salvo la ausencia total de `Categor_a_veh_culo__c.field-meta.xml`).

## Metadata temporal propuesta para OMODA (diseño, aún no ejecutado)

Valores temporales exclusivos para OMODA, sin reutilizar semántica de ninguna otra marca (BMW/MINI/Motorrad/Kawasaki/Polaris/Indian):

| Nivel | Valor temporal propuesto | Estado |
|---|---|---|
| Marca__c | `OMODA` | Ya activo en GVS maestro — **no duplicar** |
| Categor_a_veh_culo__c | `OMODA QA` | No existe — requiere alta nueva |
| Grupo__c | `OMODA QA` | No existe — requiere alta nueva |
| Familia__c | `OMODA QA` | No existe — requiere alta nueva |
| Modelo_De_Inter_s__c | `QA OMODA` | Ya activo en GVS maestro (desplegado en bloque previo) — **no duplicar** |

Cambios de metadata que se necesitarían (no ejecutados en este bloque):

1. GVS de `Categor_a_veh_culo__c` (`Categoria_Vehiculo`): agregar valor `OMODA QA`.
2. Campo `Categor_a_veh_culo__c`: agregar `<valueSettings>` mapeando `controllingFieldValue=OMODA` → `valueName=OMODA QA`.
3. GVS de `Grupo__c` (`Categor_a`): agregar valor `OMODA QA`.
4. Campo `Grupo__c`: agregar `<valueSettings>` mapeando `controllingFieldValue=OMODA QA` (de Categoría) → `valueName=OMODA QA`.
5. GVS de `Familia__c` (`Familia`): agregar valor `OMODA QA`.
6. Campo `Familia__c`: agregar `<valueSettings>` mapeando `controllingFieldValue=OMODA QA` (de Grupo) → `valueName=OMODA QA`.
7. Campo `Modelo_De_Inter_s__c`: agregar `<valueSettings>` mapeando `controllingFieldValue=OMODA QA` (de Familia) → `valueName=QA OMODA` (el valor de GVS ya existe, solo falta el mapeo de dependencia).
8. `RecordType Producto_Red_Motors`: habilitar los nuevos valores (`Marca__c=OMODA`, `Categor_a_veh_culo__c=OMODA QA`, `Grupo__c=OMODA QA`, `Familia__c=OMODA QA`, `Modelo_De_Inter_s__c=QA OMODA`) **preservando todos los valores actualmente habilitados** — el deploy de `<picklistValues>` en RecordType es de reemplazo por picklist, no aditivo, por lo que el archivo fuente para el deploy deberá partir del contenido completo reconciliado (fuente: retrieve completo de `CustomObject:Product2`), nunca del archivo local actualmente incompleto.

## Advertencias de riesgo para el siguiente bloque

- El archivo local `Producto_Red_Motors.recordType-meta.xml` (21 líneas) **no es la fuente autoritativa** y no debe usarse como base de un deploy — un deploy basado en él borraría (por reemplazo) las 18 restricciones `<picklistValues>` reales existentes en el RT, incluyendo las de Marca__c/Categor_a_veh_culo__c/Grupo__c/Familia__c/Modelo_De_Inter_s__c para las marcas ya en producción (BMW, MINI, Motorrad, Kawasaki, Indian, Polaris).
- El archivo `Categor_a_veh_culo__c.field-meta.xml` no existe localmente y debe crearse (no editarse) a partir del contenido reconciliado.
- Cualquier reconciliación debe partir del retrieve completo `CustomObject:Product2`, incorporando únicamente los 5 valores nuevos de OMODA sin alterar ningún valor existente.

## Autorización de negocio

Luis autorizó expresamente el uso de datos/valores provisionales de QA (Categoría/Grupo/Familia "OMODA QA", Modelo "QA OMODA") para avanzar el QA técnico mientras llega el catálogo oficial OMODA/JAECOO, bajo las condiciones: exclusivos de Partial, documentados como temporales, sin reutilizar semántica de otra marca, reemplazables por catálogo oficial posteriormente, sin afectar datos actuales.

## Entorno

- Ejecutado exclusivamente en `RedMotorsSandbox` / Partial (`redmotors--partial.sandbox.my.salesforce.com`).
- **Producción no fue tocada** en ningún momento de esta investigación.
- Todo el retrieve/conversión de este bloque se realizó fuera del repositorio, en `C:\Users\dokur\Documents\Auditorias-RedMotors-PEKING\Tmp-Product2-Metadata-20260814`. No se copió metadata de esa carpeta al repositorio.

## Checkpoint — Reconciliación de baseline en Git (2026-08-14)

El commit `f242f55` documentó el diagnóstico completo (cadena de 5 niveles, limitación del retrieve aislado de RecordType, diseño mínimo propuesto). Este checkpoint incorpora a Git, en el commit `09c16e8`, el **baseline real y completo** de `Product2` tal como existe hoy en Partial:

- `force-app/main/default/objects/Product2/recordTypes/Producto_Red_Motors.recordType-meta.xml` reemplazado por la versión completa (2,309 líneas / 18 campos con `picklistValues`, conteos 18/23/68/72/338 verificados por hash contra el source convertido), en lugar de la versión incompleta anterior (21 líneas / 2 campos).
- `force-app/main/default/objects/Product2/fields/Categor_a_veh_culo__c.field-meta.xml` agregado por primera vez al repositorio (no existía en absoluto antes de este checkpoint).

Ambos archivos fueron copiados verbatim (sin edición manual) desde el source convertido externo (`source-convertido/`, generado por `sf project convert mdapi` a partir del retrieve completo `CustomObject:Product2`, SHA-256 `207c50810da5893d707ad93b19b8d5b3dc91051ddbeebe02fe0ce644acce1237`), y verificados con hash idéntico antes de commitear.

**Este checkpoint todavía NO contiene ninguna implementación temporal de OMODA** — cero valores "OMODA QA" agregados, cero valores nuevos en ningún GVS, cero cambios en `<valueSettings>`. Es exclusivamente la incorporación a Git de configuración que ya existía y estaba desplegada en Partial. No hubo deploy (Salesforce ya tiene esta configuración), no hubo DML, Producción no fue tocada.

Con este baseline versionado, el siguiente bloque autorizado es la implementación del metadata temporal OMODA descrita en la sección anterior, partiendo de una base ya completa y recuperable.

## Checkpoint — Implementación del metadata temporal OMODA (2026-08-14)

Sobre el baseline reconciliado (`09c16e8`, documentado en `7bddc28`), se implementó de forma aditiva la cadena temporal completa:

```
OMODA → OMODA QA → OMODA QA → OMODA QA → QA OMODA
Marca__c → Categor_a_veh_culo__c → Grupo__c → Familia__c → Modelo_De_Inter_s__c
```

### Archivos modificados

- `force-app/main/default/globalValueSets/Categoria_Vehiculo.globalValueSet-meta.xml` — recuperado de Partial (no existía localmente) + agregado `OMODA QA` (24 valores totales).
- `force-app/main/default/globalValueSets/Categor_a.globalValueSet-meta.xml` — recuperado de Partial (no existía localmente) + agregado `OMODA QA` (69 valores totales).
- `force-app/main/default/globalValueSets/Familia.globalValueSet-meta.xml` — agregado `OMODA QA` (existente localmente, solo se añadió el valor).
- `force-app/main/default/globalValueSets/Modelo_de_Interes2.globalValueSet-meta.xml` — versionado por primera vez el `QA OMODA` ya desplegado previamente en Partial (dry-run `0AfAK0000015KGr0AM`, deploy `0AfAK0000015KIT0A2`); diff verificado antes de incluirlo — contenía exclusivamente esa adición.
- `force-app/main/default/objects/Product2/fields/Categor_a_veh_culo__c.field-meta.xml` — agregado `valueSettings` (`controllingFieldValue=OMODA` → `valueName=OMODA QA`).
- `force-app/main/default/objects/Product2/fields/Grupo__c.field-meta.xml` — agregado `valueSettings` (`controllingFieldValue=OMODA QA` → `valueName=OMODA QA`).
- `force-app/main/default/objects/Product2/fields/Familia__c.field-meta.xml` — agregado `valueSettings` (`controllingFieldValue=OMODA QA` → `valueName=OMODA QA`).
- `force-app/main/default/objects/Product2/fields/Modelo_De_Inter_s__c.field-meta.xml` — agregado `valueSettings` (`controllingFieldValue=OMODA QA` → `valueName=QA OMODA`, reutilizando el valor de GVS ya existente, sin duplicar).
- `force-app/main/default/objects/Product2/recordTypes/Producto_Red_Motors.recordType-meta.xml` — agregado un `<values>` nuevo (`default=false`) en cada uno de los 5 bloques `picklistValues` correspondientes, preservando el 100% de los valores existentes (+20 líneas, 0 eliminaciones).

### Conteos verificados (UI API, RecordType `0120P000000ENW0QAO`)

| Campo | Predeploy | Postdeploy | Incremento |
|---|---|---|---|
| Marca__c | 18 | 19 | +1 |
| Categor_a_veh_culo__c | 23 | 24 | +1 |
| Grupo__c | 68 | 69 | +1 |
| Familia__c | 72 | 73 | +1 |
| Modelo_De_Inter_s__c | 337 | 338 | +1 |

### Dry-run y deploy

- Dry-run: `0AfAK0000015Lfx0AE` — Succeeded, 9/9 componentes, sin errores.
- Deploy real: `0AfAK0000015LhZ0AU` — Succeeded, exactamente los mismos 9 componentes (sin ampliar el package entre dry-run y deploy real). Componentes: 4 CustomField, 4 GlobalValueSet, 1 RecordType.

### Verificación de la cadena completa (post-deploy, vía `controllerValues`/`validFor`)

`Marca__c('OMODA', índice 1) → Categor_a_veh_culo__c('OMODA QA', validFor=[1]) → Grupo__c('OMODA QA', validFor=[23], índice 23 en el mapa de Familia__c) → Familia__c('OMODA QA', validFor=[68], índice 68 en el mapa de Modelo_De_Inter_s__c) → Modelo_De_Inter_s__c('QA OMODA', validFor=[72])`. Cadena confirmada extremo a extremo.

### Verificación de que BMW permanece intacto

Se re-verificó la cadena de referencia BMW tras el deploy: `BMW → Eléctrico (validFor incluye 0) → BMW i (validFor incluye 0) → iX1 (validFor=[0]) → BMW-IX1-20-VR-XLINE (validFor=[18])` — sin cambios respecto al estado anterior al deploy.

### Commit funcional y documental

- Commit funcional: `e72747f` — `feat(peking): add temporary omoda product catalog metadata`, 9 archivos, 521 inserciones, 0 eliminaciones.
- Push realizado, rama sincronizada 0/0 con origin.

### Aclaraciones

- Los valores `OMODA QA` (Categoría/Grupo/Familia) y la relación hacia `QA OMODA` (Modelo) son **temporales de QA**, autorizados expresamente por Luis, y deberán reemplazarse por el catálogo oficial OMODA/JAECOO cuando esté disponible.
- Clasificación: dentro del alcance oficial de Sprint 4 (Global Value Sets, configuración de Product2). No es trabajo extra.
- **No se creó todavía** ningún `Product2`, `Pricebook2` ni `PricebookEntry` — eso corresponde al siguiente bloque.
- No hubo DML en ningún momento de este checkpoint.
- Producción no fue tocada — todo ejecutado exclusivamente en `RedMotorsSandbox` / Partial.

## Estado

Investigación, diseño, reconciliación de baseline e implementación del metadata temporal OMODA: **completos.** Creación del catálogo de fantasía OMODA 2026 (`Product2`, `Pricebook2`, `PricebookEntry`) y reanudación del QA del modal "Agregar vehículo": **pendiente, siguiente bloque.**
