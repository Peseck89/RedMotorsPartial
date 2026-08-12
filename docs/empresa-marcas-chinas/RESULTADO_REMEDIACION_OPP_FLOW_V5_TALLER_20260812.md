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
| Versión resultante | v31 activa y última |

Las validaciones iniciales `0AfAK00000146Pd0AI`, `0AfAK00000146Sr0AI`, `0AfAK00000146W50AI`, `0AfAK00000145v00AA` y `0AfAK000001461S0AQ` no desplegaron metadata. Permitieron corregir el uso inválido de `isGoTo` hacia una pantalla nueva y confirmar que la definición completa requiere Metadata API 67.0 por elementos `styleProperties` preexistentes. No apareció ninguna dependencia adicional.

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

## Resultado por Empresa

| Empresa | Validación técnica | QA funcional |
|---|---|---|
| PEKING | La Empresa está activa y es seleccionable mediante el lookup; su Id alimenta directamente `Empresa_Operadora__c`; no depende de `User.Empresa__c` ni de una rama literal. | Interview manual pendiente. |
| Bavarian | La Empresa está activa y es seleccionable mediante el mismo lookup; se conserva la compatibilidad legacy existente. | Interview manual pendiente. |
| Otobai | La Empresa está activa y es seleccionable mediante el mismo lookup; se conserva la compatibilidad legacy existente. | Interview manual pendiente. |

No se crearon Opportunities durante este bloque, para evitar disparar correos internos de duplicados. Por ello no se declara QA funcional completo.

## Estado final

`Opp_Flow_V5`: **Validación técnica OK — QA funcional manual pendiente**.

El inventario autoritativo conserva 20 Flows, distribuidos ahora en:

- 4 revisados sin cambio;
- 2 QA OK / técnicamente cerrados;
- 8 con validación técnica OK y QA funcional manual pendiente;
- 1 con validación técnica OK y comportamiento en datos reales sin confirmar (`Opportunity_Flow_V2`);
- 0 bloqueados técnicamente;
- 3 bloqueados por negocio;
- 2 no aplicables a PEKING.

## QA manual pendiente

Ejecutar la entrada real de `Opp_Flow_V5` con perfiles QA autorizados, minimizando registros:

1. entrar con configuración de oportunidad Taller;
2. seleccionar PEKING, crear una Opportunity y comprobar `Empresa_Operadora__c`, `Pricebook2Id` y continuidad del proceso;
3. repetir una vez para Bavarian;
4. repetir una vez para Otobai cuando la ruta sea aplicable;
5. conservar video y consultas de los registros resultantes;
6. registrar cualquier correo interno disparado por automatización de duplicados.

No continuar con otro componente como parte de esta remediación.
