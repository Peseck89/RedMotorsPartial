# Resultado — remediación técnica de `Opp_Flow_V5` ruta Taller

**Fecha:** 12 de agosto de 2026
**Ambiente:** `RedMotorsSandbox` (Partial)
**Componente:** `Opp_Flow_V5`

## Alcance aplicado

El bloque corrigió exclusivamente el defecto por el cual la ruta Taller podía crear una Opportunity sin poblar `Empresa_Operadora__c`. No se modificaron otros Flows, componentes Apex, LWC/Aura, datos, configuración empresarial ni Producción.

La intervención se clasificó como **remediación técnica permitida — cambio limitado**: completa el soporte de Empresa ya implementado, no agrega funcionalidad ni reglas de negocio y no habilita otros cambios en el Flow.

## Causa raíz

La Decision `IfConfigUsuarioTaller` enviaba la rama Taller directamente a `VehiculosEncontradosFalse`, omitiendo `PantallaInicial`. El campo usado por `CreateOpportunity` era `EmpresaSeleccionada.recordId`, disponible únicamente cuando se ejecutaba el selector de la ruta general. En Taller el recurso quedaba vacío y `Empresa_Operadora__c` se creaba como `null`.

`User.Empresa__c` no era una fuente suficiente: es un picklist legacy con valores Bavarian/Otobai, no un lookup a `Empresa__c`, y no puede representar PEKING sin extender el modelo heredado. Por esa razón no se utilizó para resolver el lookup estructural.

## Solución aplicada

- Se agregó `Seleccionar_Empresa_Taller`, una pantalla mínima con un único lookup requerido basado en `Opportunity.Empresa_Operadora__c`.
- La rama Taller de `IfConfigUsuarioTaller` entra a esa pantalla y después retorna al nodo original `VehiculosEncontradosFalse`.
- La fórmula `EmpresaOperadoraSeleccionadaId` usa `EmpresaSeleccionadaTaller.recordId` cuando existe y conserva `EmpresaSeleccionada.recordId` para las demás rutas.
- `CreateOpportunity.Empresa_Operadora__c` usa la fórmula de Id efectivo.
- La compatibilidad `BMW_Compania__c` conserva únicamente Bavarian/Otobai; PEKING y cualquier otra Empresa no caen en una rama legacy.
- No se modificaron nodos legacy muertos ni conectores ajenos a `IfConfigUsuarioTaller`.

## Versiones y deploy

| Evidencia | Resultado |
|---|---|
| Versión inicial en Partial | v30 activa y última |
| Dry-run definitivo | `0AfAK00000146Xh0AI` — exitoso, 1/1 Flow |
| Deploy | `0AfAK00000146ZJ0AY` — exitoso, 1/1 Flow |
| Versión resultante de la selección de Empresa | v31 activa y última en ese bloque |

Las validaciones iniciales `0AfAK00000146Pd0AI`, `0AfAK00000146Sr0AI`, `0AfAK00000146W50AI`, `0AfAK00000145v00AA` y `0AfAK000001461S0AQ` no desplegaron metadata. Permitieron corregir el uso inválido de `isGoTo` hacia una pantalla nueva. La incompatibilidad posterior de `styleProperties` y su resolución mediante serialización MDAPI canónica se documentan en la sección de remediación de Cuenta.

## Validación estructural

- XML bien formado.
- La pantalla Taller contiene exactamente un campo funcional: `EmpresaSeleccionadaTaller`.
- El campo usa el lookup `Empresa_Operadora__c` y es obligatorio.
- Ruta confirmada: `IfConfigUsuarioTaller` → `Seleccionar_Empresa_Taller` → `VehiculosEncontradosFalse` → recorrido Taller vigente → `CreateOpportunity`.
- `CreateOpportunity.Empresa_Operadora__c` referencia `EmpresaOperadoraSeleccionadaId`.
- La selección Taller tiene precedencia; la selección general se conserva para las demás rutas.
- El único conector existente modificado pertenece a `IfConfigUsuarioTaller`.
- No se agregaron literales `PEKING`, `RMPEKING`, Ids de Salesforce ni nombres de Pricebook.
- La metadata remota v31 coincide con el contrato anterior.

Salesforce mantuvo avisos informativos sobre `Encuentra_Price_Book` y sus cuatro Assignments sin uso. Son nodos legacy ya documentados y no se modificaron.

## QA real y remediación de acceso al lookup

El primer interview funcional con un usuario QA del perfil `New Asesor Postventa` confirmó que la ruta Taller entraba correctamente a `Seleccionar Empresa`, pero el lookup mostraba un error de acceso antes de permitir seleccionar PEKING. No se pulsó `Siguiente` y no se creó Opportunity ni Quote.

La configuración del Flow era correcta: tanto el selector general como el selector Taller usan `Opportunity.Empresa_Operadora__c`. La causa estaba fuera del Flow:

- el perfil y los Permission Sets asignados al usuario QA no concedían lectura sobre `Empresa__c`;
- el campo fuente no estaba presente en los layouts aplicables al contexto del usuario.

Se creó el Permission Set `Empresa_Consulta_Flows`, limitado a `Read` sobre `Empresa__c`, sin Create, Edit, Delete, View All, Modify All, FLS administrativa ni clases Apex. Se asignó inicialmente solo al usuario QA controlado `0050P0000074Bf7QAE`.

Para operación normal, la población candidata son los usuarios autorizados que ejecuten los Opportunity Flows con selector estructural de Empresa, comenzando por `New Asesor Postventa` en la ruta Taller. La asignación masiva permanece pendiente de definición funcional; no se modificó ningún otro usuario.

Se modificaron únicamente estos layouts de Opportunity:

- `Autos`: layout del Record Type predeterminado `BMW`, usado como contexto fuente del lookup antes de crear la Opportunity; el campo se agregó en la sección `Fields`, inmediatamente después de `Pricebook2Id`;
- `Taller Autos`: layout de los Record Types `BMW_Taller` y `Mostrador` usados por los Opportunity Flows ya trabajados; el campo se agregó en `Datos de la oportunidad`, inmediatamente después de `BMW_Compania__c`.

No se modificaron `Autos V1.4`, `Opportunity Layout` ni `Opportunity Layout Usados V1.1` porque no corresponden al contexto predeterminado ni a los Record Types usados por las rutas autorizadas con este selector.

| Evidencia de configuración | Resultado |
|---|---|
| Dry-run | `0AfAK000001477B0AQ` — exitoso, 3/3 componentes |
| Deploy | `0AfAK000001478n0AA` — exitoso, 3/3 componentes |
| Permission Set Assignment | `0PaAK000002rbcz0AA` — usuario QA únicamente |
| Acceso efectivo a PEKING | Read: sí; Edit/Delete: no |
| Versión del Flow | v31 activa y última, sin modificación |

La remediación elimina el bloqueo de configuración del lookup. El interview funcional debe repetirse antes de declarar QA OK.

## QA real posterior — datos del Asset y creación de Opportunity

La repetición funcional con PEKING confirmó que el lookup estructural de Empresa funcionaba y permitió continuar con el Asset QA `02iAK000001xtZNYAY` (`VNA00260810051041`). Al avanzar desde `Información del presupuesto`, el Flow falló inicialmente en `UpdateAsset` por la Validation Rule `Asset.Other_Marca`: el registro tenía `Marca_Nvo__c = Otro` y `Marca_Otros__c` vacío.

Este primer fallo era una inconsistencia preexistente del dato QA, no un defecto introducido por PEKING ni por la pantalla de Empresa. Se corrigió exclusivamente `Marca_Nvo__c`, de `Otro` a `BMW Automovil`; no se modificaron los campos de marca/modelo restantes ni metadata funcional.

En la siguiente ejecución manual, el Flow superó `UpdateAsset` y alcanzó `CreateOpportunity`, donde Salesforce devolvió:

`REQUIRED_FIELD_MISSING: Required fields are missing: [Name]`

El análisis del nodo demostró que la causa real era `AccountId` vacío en la ruta Taller. `CreateOpportunity.AccountId` utilizaba directamente `idCuentaBuscadaoCreadaNew`, recurso que esa ruta no garantiza. La generación histórica de `Opportunity.Name` permanece a cargo del trigger existente; el Flow no asignaba `Name` y la remediación no agregó ni modificó ese campo.

El defecto era preexistente en la ruta Taller y se corrigió mediante la fórmula:

```text
CuentaOportunidadEfectivaId =
IF(
  NOT(ISBLANK(idCuentaBuscadaoCreadaNew)),
  idCuentaBuscadaoCreadaNew,
  AssetCreadoOBuscado.AccountId
)
```

`CreateOpportunity.AccountId` referencia ahora `CuentaOportunidadEfectivaId`. Las rutas generales conservan la cuenta previamente resuelta y Taller utiliza como fallback la cuenta del Asset seleccionado.

## Compatibilidad MDAPI y deploy de la remediación de Cuenta

El archivo de trabajo conservaba propiedades visuales `styleProperties` presentes en la representación interna del Flow, pero esa estructura era rechazada al validarse directamente. Para evitar eliminar o reconstruir manualmente metadata visual, se realizaron recuperaciones temporales aisladas mediante Metadata API 54 y 67.

Ambas APIs produjeron la misma serialización canónica:

- conservaron `AssetDataTable` y `FDGPack:GilmoreLabs_FlowDataGrid`;
- conservaron el API interno 54.0 del Flow;
- omitieron `styleProperties` sin transformarlo en otro elemento;
- permitieron round-trip limpio de la v31 con estado `Unchanged`.

Sobre la representación canónica API 67 se aplicaron exclusivamente la fórmula `CuentaOportunidadEfectivaId` y la referencia de `CreateOpportunity.AccountId`. El dry-run `0AfAK00000148850AA` fue exitoso, 1/1 componente, sin dependencias adicionales ni cambios funcionales o visuales no explicados.

| Evidencia final | Resultado |
|---|---|
| Deploy real | `0AfAK00000148EX0AY` — exitoso, 1/1 Flow |
| Versión creada | v32 |
| Versión activa y última | v32 |
| Flow Version Id | `301AK00000PVbLAYA1` |
| API interno | 54.0 |

La inspección de la versión activa confirmó que `EmpresaOperadoraSeleccionadaId` permanece intacta, `CuentaOportunidadEfectivaId` contiene la lógica validada, `CreateOpportunity.AccountId` usa la nueva fórmula y `CreateOpportunity` continúa sin asignar `Name`. No se intentó restaurar manualmente `styleProperties`.

## Resultado por Empresa

| Empresa | Validación técnica | QA funcional |
|---|---|---|
| PEKING | La Empresa está activa y es seleccionable mediante el lookup; su Id alimenta directamente `Empresa_Operadora__c`; no depende de `User.Empresa__c` ni de una rama literal. | Interview manual pendiente. |
| Bavarian | La Empresa está activa y es seleccionable mediante el mismo lookup; se conserva la compatibilidad legacy existente. | Interview manual pendiente. |
| Otobai | La Empresa está activa y es seleccionable mediante el mismo lookup; se conserva la compatibilidad legacy existente. | Interview manual pendiente. |

No se crearon Opportunities durante este bloque, para evitar disparar correos internos de duplicados. Por ello no se declara QA funcional completo.

## Estado final

`Opp_Flow_V5` v32: **Validación técnica OK — QA funcional manual pendiente**.

Los bloqueos previos de acceso al lookup y consistencia del Asset QA quedaron resueltos. La remediación de Cuenta fue desplegada y verificada estructuralmente, pero el estado no cambia a QA OK hasta repetir una sola vez el interview y comprobar la Opportunity resultante.

El inventario autoritativo conserva 20 Flows, distribuidos ahora en:

- 4 revisados sin cambio;
- 2 QA OK / técnicamente cerrados;
- 8 con validación técnica OK y QA funcional manual pendiente;
- 1 con validación técnica OK y comportamiento en datos reales sin confirmar (`Opportunity_Flow_V2`);
- 0 bloqueados técnicamente;
- 3 bloqueados por negocio;
- 2 no aplicables a PEKING.

## QA manual pendiente

Ejecutar una única repetición controlada:

1. ingresar como usuario QA del perfil `New Asesor Postventa` configurado para Taller;
2. abrir `/flow/Opp_Flow_V5`;
3. seleccionar Empresa `PEKING`;
4. seleccionar el Asset `VNA00260810051041`;
5. seleccionar el contacto `QA Prueba`;
6. seleccionar la cuenta de facturación `QA Prueba`;
7. avanzar una sola vez y comprobar que se crea la Opportunity con `Empresa_Operadora__c` y `AccountId` poblados y que el proceso continúa;
8. conservar la evidencia y detenerse si aparece un nuevo error, sin repetir automáticamente.

No continuar con otro componente como parte de esta remediación.
