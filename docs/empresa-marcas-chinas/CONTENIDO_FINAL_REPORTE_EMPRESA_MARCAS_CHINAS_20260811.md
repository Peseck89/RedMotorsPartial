# Empresa / Marcas Chinas (Omoda y Jaecoo) — Reporte general de avance

**Fecha de esta actualización:** 13 de agosto de 2026 (sustituye la versión del 11 de agosto de 2026; el contenido anterior queda incorporado y ampliado, no descartado).
**Estado general:** en curso. Sprint 1 cerrado técnicamente. Sprint 2 **no cerrable** (dos de cuatro bloqueos resueltos). Sprint 3 **no cerrado**.
**Naturaleza de este documento:** reporte consolidado para Luis, Diego y María — balance entre lectura de negocio y detalle técnico verificable. El detalle nominal exhaustivo vive en la sección 7 (inventario) y en los documentos técnicos referenciados; el cuerpo principal no describe componente por componente.
**Preparado por:** solo documentación. No se modificó Salesforce, no hubo deploy ni DML para producir este reporte.

---

## 1. Resumen ejecutivo

El proyecto adapta RedMotors para operar con una nueva empresa/marca china (PEKING, con las submarcas Omoda y Jaecoo), migrando la lógica que históricamente solo reconocía BMW, MINI y las demás marcas existentes hacia un modelo configurable basado en el objeto `Empresa__c` — en vez deif/else fijos por nombre de compañía.

**Qué significa esto para negocio:** hoy es posible crear un Prospecto, una Oportunidad de venta, un Presupuesto y, en los flujos ya autorizados, una Orden de Trabajo de postventa para PEKING, reutilizando la misma pantalla y el mismo proceso que ya usa el resto del negocio — sin construir un sistema paralelo. Varias partes de ese recorrido ya están probadas con evidencia funcional real; otras están técnicamente listas pero esperan una prueba dirigida o una definición que solo negocio puede dar (bodega oficial, garantía, territorios, responsables de aprobación, precio de lista por defecto).

**Estado general por Sprint:**

| Sprint | Foco | Estado al 13 de agosto de 2026 |
|---|---|---|
| Sprint 1 | Objeto `Empresa__c`, lógica de programación central (32 clases + 3 triggers) | Cerrado técnicamente. Un punto puntual (la llamada "clase 33") nunca se seleccionó y sigue sin resolver, sin efecto práctico conocido. |
| Sprint 2 | 20 Flows y 25 componentes de interfaz (LWC/Aura) ya existentes | **No cerrable.** De los cuatro bloqueos identificados, dos ya se resolvieron con evidencia funcional (F07 de mantenimiento, y la creación de Orden de Trabajo desde Presupuesto); los otros dos siguen abiertos: uno tuvo su primer intento de prueba dirigida, que falló por un problema técnico de inicialización pendiente de diagnóstico; el otro espera una definición de Diego sobre garantía. |
| Sprint 3 | Pantallas, reglas de negocio, aprobaciones e integración con el sistema externo para Omoda/Jaecoo | Avance sustancial y validado en varios frentes; otros esperan definiciones de negocio. Continúa trabajo en paralelo (rama de continuidad abierta el 13 de agosto). |

**Bloques ya trabajados desde el reporte anterior (11 de agosto):**

- Se corrigieron 2 regresiones técnicas confirmadas en clases Apex (`precioProductoJSON`, `BatchGetCatalogoSoftland`) sin afectar Bavarian ni Otobai.
- Se corrigió la propagación de la Empresa al crear una Orden de Trabajo desde un Presupuesto (bloqueo N2) y quedó **QA funcional aprobado con PEKING**.
- Se configuró la resolución de Empresa por Sucursal de Servicio para los Casos de postventa (bloqueo N4) — desplegado técnicamente y con los permisos mínimos de lectura verificados; el primer intento de QA dirigido falló durante la inicialización del Flow (antes de crear ningún registro), por lo que requiere diagnóstico técnico adicional, no solo repetir la prueba.
- Se reconcilió una auditoría técnica externa completa (de Luis, vía Codex) contra el estado real del código: se confirmó un defecto nuevo de severidad alta (recálculo de Precio de Lista que nunca encuentra el registro correcto, afecta también a Bavarian y Otobai) y se descartaron varios hallazgos que ya no aplican.
- Se estableció una regla formal de prioridad de trabajo y de separación entre autorización técnica y cobertura económica (ver sección 9).

**Pendientes funcionales/técnicos reales (detalle en secciones 10 y 12):**

- Un defecto técnico de alto impacto (recálculo de Precio de Lista) confirmado y **sin corregir**, a la espera de autorización.
- Una definición de negocio sobre garantía de fábrica para PEKING (bloqueo N3).
- Un fallo técnico de inicialización sin diagnosticar todavía en el Flow que abre Caso/Orden de Trabajo de servicio (bloqueo N4) — los permisos ya se corrigieron, pero el Flow falla antes de crear cualquier registro por una causa distinta todavía no identificada.
- Definiciones de negocio pendientes: bodega y territorio oficiales, centro de costo, responsables de aprobación definitivos, Precio de Lista por defecto, catálogos oficiales del sistema externo, razón social/branding de PEKING.

**Datos todavía provisionales:** bodega, Sucursal de Servicio, tipo de plan, término de garantía de mantenimiento, y varios registros de Precio de Lista están configurados con valores de prueba basados en Bavarian, rotulados explícitamente y sin usarse en Producción (detalle completo en sección 6).

Este reporte no usa porcentajes de avance inventados. Donde una cifra de horas es medible con precisión se muestra como tal (sección 5.3 del documento de conciliación de horas, referenciado); donde no lo es, se muestra el resultado concreto (cuántos componentes, en qué estado) en vez de forzar un porcentaje.

**Ni Sprint 2 ni Sprint 3 se declaran cerrados.**

---

## 2. Explicación por bloques funcionales

### Empresa y configuración

**Problema:** el sistema reconocía compañías por texto fijo (`BMW_Compania__c`, nombres de Pricebook) en decenas de puntos del código, sin un catálogo central. Agregar una empresa nueva significaba tocar código en cada punto.

**Qué se hizo:** se creó el objeto `Empresa__c` (campos `Codigo__c`, `Codigo_ERP__c`, `Nombre_Legal__c`, `Activa__c`) como catálogo central, y un lookup `Empresa_Operadora__c` que se propaga desde la Oportunidad hacia Presupuesto, Orden de Trabajo y Sucursal de Servicio. Esto reemplaza — donde ya se aplicó — la comparación de texto por una relación real entre registros.

**Qué reutiliza:** toda la lógica de resolución dinámica ya construida en Sprint 1 (`EmpresaResolver`, `EmpresaPricebookResolver`) sirve igual para Bavarian, Otobai y PEKING sin duplicar código.

**Qué queda pendiente:** `Nombre_Legal__c` sigue vacío para las 3 empresas en el ambiente de pruebas, lo que bloquea una de las dos rutas de resolución (`EmpresaResolver.resolveByCodigo`); la ruta usada en producción no depende de ese campo, así que no es un bloqueo funcional hoy, pero es una inconsistencia de datos pendiente de completar.

**Ejemplo concreto:** antes, saber si una Orden de Trabajo era de Bavarian u Otobai dependía de leer un texto libre en `empresaFactura__c`. Hoy, `WorkOrder.empresaFacturaCP__c` es un lookup real a `Empresa__c`; para PEKING, esa propagación se completó el 13 de agosto (ver sección 10).

### Opportunity / Quote

**Problema:** la creación de Oportunidad y Presupuesto decidía la empresa y el Precio de Lista con listas cerradas (Bavarian/Otobai) y, en algunos Flows, buscaba el Pricebook por su nombre exacto en vez de por relación.

**Qué se hizo:** los 4 Flows principales de Oportunidad (`Opp_flow_V3`, `Opp_Flow_V5`, `Opp_Flow_v6`, `Opportunity_Flow_V2`) ya crean Oportunidad y Presupuesto de PEKING correctamente, con Empresa, moneda (CRC) y Pricebook (`PEKING Local`) correctos — confirmado con evidencia funcional real, no solo revisión de código.

**Qué reutiliza:** el mismo Record Type de Venta Nueva y la misma pantalla (`Opportunity_Record_Page_VN`) que ya usa el resto del negocio — no se construyó una pantalla separada para PEKING/Omoda/Jaecoo.

**Qué queda pendiente:** se confirmó un defecto real (no solo para PEKING — también para Bavarian y Otobai) en la ruta que **recalcula** el Pricebook de un Presupuesto ya existente: compara el nombre del Pricebook contra un identificador único (Id), una comparación que nunca puede coincidir, y deja el Pricebook en blanco si esa ruta se ejecuta. Ver el detalle completo en la sección 10. No se ha corregido — está pendiente de autorización.

**Ejemplo concreto:** al crear un Presupuesto de PEKING desde cero, el sistema ya asigna correctamente `PEKING Local` en colones. Si ese mismo Presupuesto se vuelve a abrir más adelante y el sistema intenta recalcular su Pricebook, hoy lo dejaría vacío — ese es el defecto pendiente.

### Work Order / Postventa

**Problema:** al crear una Orden de Trabajo desde un Presupuesto, el sistema solo llenaba un campo de texto legacy con el código de empresa, sin llenar el lookup real que usan los Flows de postventa más nuevos.

**Qué se hizo:** se agregó la asignación del lookup `empresaFacturaCP__c` al crear la Orden de Trabajo, sin tocar el campo legacy ni los conectores existentes. Se probó con una ejecución normal y una selectiva: ambas terminaron correctamente, cada una creó exactamente una Orden de Trabajo y una línea de trabajo (WOLI) de PEKING, sin error ni duplicado.

**Qué reutiliza:** el resto del Flow de creación de Orden de Trabajo, sin cambios estructurales.

**Qué queda pendiente:** la bodega y el territorio usados en esta prueba son datos de prueba basados en la estructura de Bavarian (ver sección 6) — no son la configuración oficial de PEKING todavía.

**Ejemplo concreto:** antes, una Orden de Trabajo de PEKING creada desde un Presupuesto no tenía forma de que los Flows de gastos y mano de obra (que ya dependen del lookup) supieran que era PEKING. Hoy, esa Orden de Trabajo trae el lookup correcto desde el momento en que se crea.

### Softland / integración

**Problema:** los 6 catálogos que trae la integración con el sistema externo de inventario/facturación (Softland) usaban listas cerradas de empresa, y el prefijo de identificación de bodega dependía de un caso especial solo para Otobai.

**Qué se hizo:** se corrigió el prefijo de bodega para que se derive del código de cualquier empresa, no de un caso especial. Se incorporaron a control de versiones (sin cambiar su comportamiento) las 6 clases programadas que sincronizan esos catálogos, junto con la clase que hace la llamada real y sus 13 pruebas — quedaron reconciliadas y probadas (36 de 36 pruebas aprobadas).

**Qué reutiliza:** la misma instancia e integración que ya usa el negocio — no se creó una integración paralela, y ninguna prueba generó una llamada real al sistema externo.

**Qué queda pendiente:** el contenido real de esos catálogos para PEKING (no la mecánica, que ya está probada) y la bodega oficial siguen sin definirse. `QuoteSoftlandPedidoService`, la clase que arma el pedido hacia el sistema externo, ya resuelve la empresa correctamente en su ruta principal; conserva un mecanismo de respaldo (fallback) con las 3 empresas escritas literalmente, que solo se activa si el lookup de Empresa viene vacío — ver detalle en la sección 11.

**Ejemplo concreto:** antes, el prefijo de bodega para identificar un producto en el sistema externo solo cambiaba para Otobai; cualquier otra empresa (incluida PEKING) hubiera compartido el mismo prefijo que Bavarian, con riesgo de que dos bodegas de empresas distintas colisionaran en la misma clave. Hoy cada empresa deriva su propio prefijo.

### Pantallas y experiencia de usuario

**Problema:** determinar cuáles de las pantallas, pestañas y botones existentes necesitaban algún ajuste para funcionar igual con Omoda/Jaecoo que con las marcas actuales.

**Qué se hizo:** ver el desglose completo y los conteos exactos en la sección 3 — no se repite aquí para evitar una cifra sin contexto.

**Qué reutiliza:** la decisión ya tomada de que Omoda y Jaecoo comparten la misma pantalla de Venta Nueva del resto del negocio.

**Qué queda pendiente:** ver sección 3.

### Validaciones y aprobaciones

**Problema:** las reglas de validación que protegen la calidad de una venta (Validation Rules) y la asignación de responsables de aprobación (Director de Ventas, Gerente de Sucursal, Jefe de Sucursal) no reconocían Omoda ni Jaecoo.

**Qué se hizo:** ver el desglose completo en la sección 4 (reglas) y la sección 5 (jerarquía).

**Qué reutiliza:** el mismo mecanismo de aprobación por descuento que ya usan las demás marcas — no se crearon procesos de aprobación nuevos.

**Qué queda pendiente:** ver secciones 4 y 5.

### Mano de obra / mantenimiento

**Problema:** dos Flows de postventa (creación de línea de trabajo desde un gasto, y agregar mano de obra a una Orden de Trabajo) tenían rutas que no resolvían PEKING, y uno de ellos superaba el límite de consultas permitido al recorrer un catálogo grande de productos.

**Qué se hizo:** ambos Flows quedaron con **QA funcional aprobado con PEKING** — cada uno creó exactamente el registro esperado, sin duplicado ni error, usando datos representativos de una venta real. El límite de consultas se eliminó reestructurando el recorrido del catálogo, sin cambiar el resultado para Bavarian ni Otobai.

**Qué reutiliza:** el resto de la lógica de ambos Flows, sin cambios estructurales.

**Qué queda pendiente:** un tercer Flow del mismo dominio (`PlanDeMantenimientoV2`, planes de mantenimiento/regalías) también quedó QA funcional aprobado, tras corregir un problema de permisos de acceso a dos campos que impedía guardar el resultado — ver sección 10.

**Ejemplo concreto:** el Flow de mano de obra recorría un catálogo de 610 productos con una consulta por cada uno, superando el límite de 100 consultas por transacción que impone la plataforma; se corrigió resolviendo el producto correcto de una sola vez.

### Servicios / agenda / territorios

**Problema:** los dos Flows que abren un Caso de servicio y su Orden de Trabajo asociada decidían la empresa por texto dentro del nombre de la Sucursal de Servicio (una coincidencia de texto, no una relación real), y no existía forma de vincular una Sucursal de Servicio a una Empresa de catálogo.

**Qué se hizo:** se agregó un lookup real `Empresa__c` en el objeto Sucursal de Servicio, y ambos Flows ya resuelven el código de empresa desde ese lookup en vez de leer el texto del nombre. Se conservó el mecanismo anterior únicamente como respaldo, para sucursales antiguas que todavía no tienen el lookup poblado.

**Qué reutiliza:** las reglas de agenda, Caso, Activo, contacto y las pantallas existentes — ninguna de ellas se modificó.

**Qué queda pendiente:** se verificaron los permisos mínimos de lectura y se ejecutó el primer intento de prueba funcional dirigida (crear un Caso y su Orden de Trabajo con PEKING); ese intento **falló durante la inicialización del Flow**, antes de generar cualquier entrevista o registro — no fue un problema de permisos (esos ya se confirmaron correctos), sino un fallo técnico distinto que todavía no se ha diagnosticado. El segundo Flow del mismo bloque (`ct_newCaseWorkOrderEvent`) no se ejecutó, siguiendo el criterio de detenerse ante el primer fallo. Los servicios, la agenda y las sucursales oficiales de PEKING tampoco están definidos todavía; se usa una Sucursal de Servicio de prueba, rotulada como tal (sección 6).

**Ejemplo concreto:** antes, el sistema reconocía Otobai únicamente si el nombre de la Sucursal de Servicio contenía la palabra "Otobai"; cualquier otra empresa, incluida PEKING, hubiera recibido por defecto la configuración de Bavarian sin darse cuenta. Hoy, la empresa se determina por una relación real de datos, no por texto.

---

## 3. Pantallas / Layouts / Lightning Pages

Diego pidió expresamente que las cantidades se entiendan, no solo se enuncien. Este conteo corresponde al inventario dedicado de Sprint 3 (78 elementos de pantalla: formularios, pestañas y botones de acción que ya existen para las marcas actuales).

| Grupo | Cantidad | Qué significa concretamente |
|---|---:|---|
| Ya tienen resolución concreta dentro del alcance evaluado | 19 | Funcionan igual para Omoda/Jaecoo que para las marcas existentes, o ya se ajustaron en esta ronda. No requieren trabajo adicional. |
| Página principal de detalle de la Oportunidad (`Opportunity_Record_Page_VN`) | 1 | Caso puntual: en vez de una pantalla nueva, Omoda y Jaecoo reutilizan la misma experiencia de Venta Nueva que ya usa el resto del negocio (Record Type compartido, `FlexiPage` desplegada desde el 26 de julio). |
| No aplican a marcas nuevas | 4 | Funcionalidad exclusiva de otro proceso (por ejemplo, taller de una marca específica); confirmado que no tiene relación con Omoda/Jaecoo. |
| Quedan pendientes de definición o aplicación posterior | 54 | Ver desglose por categoría abajo. |
| **Total revisado** | **78** | |

**Por qué los 54 restantes no se ajustaron de forma indiscriminada:** cada uno depende de una definición distinta (a qué proceso pertenece, si sigue vigente, o qué contenido debe mostrar). Aplicar el mismo ajuste genérico a los 54 habría sido irresponsable sin esa definición. Se agrupan así:

| Categoría | Cantidad | Por qué está pendiente |
|---|---:|---|
| Sin uso activo demostrado actualmente | 32 | No hay evidencia de que se usen hoy en el proceso comercial vigente — corresponde confirmar si siguen siendo necesarios antes de invertir esfuerzo en adaptarlos. |
| Taller / Postventa | 14 | Pertenecen a mantenimiento y servicio posventa, un frente donde N3 (garantía) y N4 (servicios/agenda) siguen abiertos — depende de esas mismas definiciones. |
| Segmentos legacy | 5 | Corresponden a configuraciones de venta anteriores que ya no representan el proceso comercial actual. |
| Acciones que requieren contenido o plantilla propia de PEKING | 3 | Botones o acciones que sí aplican, pero necesitan una plantilla de correo o presupuesto redactada específicamente para PEKING antes de activarse (relacionado con `cT_QuotePDFEmail`, sección 8). |
| **Total** | **54** | |

**Objetos y Record Types donde vive esto:** el caso concreto de la página principal de la Oportunidad se resuelve en el objeto `Opportunity`, sobre el mismo Record Type de Venta Nueva que ya usan BMW, MINI y las demás marcas — no existe un Record Type separado "Omoda" u "Jaecoo" para la pantalla en sí; la diferenciación ocurre en el dato (`Empresa_Operadora__c`, marca), no en la pantalla.

**Ejemplo adicional (fuera de las pantallas de venta, dentro de postventa):** en el bloque de preparación de QA de mano de obra (12 de agosto) se habilitó el acceso al campo de empresa en dos layouts de Orden de Trabajo ya existentes (`Opportunity-Autos`, `Opportunity-Taller Autos`) — un ajuste de acceso a campo, no una pantalla nueva, necesario para que el perfil de prueba pudiera ver el dato ya propagado.

**Lo que Diego debe leer de este número:** de 78 elementos revisados, 20 ya están resueltos (19 + 1 de la página principal), 4 confirmados fuera de alcance, y 54 dependen de decisiones que no son de desarrollo — no de que falte trabajo técnico por hacer sin rumbo.

---

## 4. Validation Rules / Reglas

Universo revisado: **94 Validation Rules** de Opportunity, Quote y WorkOrder, identificadas y contrastadas nominalmente una por una contra su fórmula y estado activo real en el ambiente de pruebas.

| Clasificación (versión corregida, B9-0.1) | Cantidad | Qué significa |
|---|---:|---|
| `SIN_CAMBIO_REQUIERE_REGRESIÓN` | 66 | Ya son neutrales a empresa/marca, o incluyen PEKING mediante una condición general. No necesitan modificación técnica; sí necesitan una prueba de regresión con Bavarian y Otobai. |
| `CANDIDATO_AJUSTE_TÉCNICO` → **ya implementado** | 4 | Ver el detalle inmediatamente abajo — es el único grupo que sí recibió un cambio de fórmula. |
| `BLOQUEADO_DATOS_OPERATIVOS` | 9 | Depende de bodegas, sucursales, asesores o centros de costo oficiales que todavía no existen. |
| `BLOQUEADO_NEGOCIO` | 4 | Depende de un aprobador, responsable o criterio de aseguradora que el negocio no ha definido para PEKING. |
| `DEPENDENCIA_DIEGO` | 8 | Referencia directa a un Perfil o `ProfileId`; depende de los perfiles que Diego confirmó que creará. |
| `NO_APLICA` | 3 | Reglas exclusivas de vehículos usados o de una cuenta Bavarian específica; Luis confirmó que PEKING no aplica a usados. |
| **Total** | **94** | |

**Las 4 reglas con ajuste técnico ya implementado (ejemplo pedido por Diego):**

| Regla | Antes | Ahora | Beneficio | ¿Conserva Bavarian/Otobai? |
|---|---|---|---|---|
| `Cambiar_a_Finalizado_Descuento` | Contemplaba BMW/MINI (y otras marcas ya existentes) por `RecordType.DeveloperName` | Se agregaron Omoda y Jaecoo dentro de la misma condición | La Oportunidad puede finalizar con descuento aprobado también para PEKING, con el mismo control que ya existía | Sí, sin cambio |
| `Cambiar_a_Finalizado_Formalización` | Igual patrón | Igual ampliación | Igual beneficio, para el paso de formalización | Sí |
| `Cambiar_Oportunidad_a_Finalizado_VH` | Igual patrón | Igual ampliación | La Oportunidad exige vehículo reservado antes de finalizar, también para PEKING | Sí |
| `Campo_Gustos_y_aficiones_Obligatorio` | Contemplaba las marcas existentes por `RecordType.Name` | Se agregaron Omoda y Jaecoo | El dato de la cuenta se exige también para PEKING antes de avanzar | Sí |

Estas 4 reglas ya están desplegadas en el ambiente de pruebas (deploy `0AfAK0000011gCj0AI`, 4 de 4 componentes, sin errores). El QA técnico (XML válido, diff limitado a la condición de Record Type, retrieve posterior equivalente) está **completo**. El QA funcional quedó **parcial**: 3 de las 4 reglas (descuento, formalización, vehículo reservado) se probaron en positivo, negativo y regresión BMW con resultado correcto; la cuarta (`Campo_Gustos_y_aficiones_Obligatorio`) **falló** en su primera prueba funcional — Omoda pudo avanzar con el dato de la cuenta realmente vacío — y no se ha vuelto a probar. No se declara este bloque cerrado.

**Por qué las otras 90 no se tocaron:** ninguna combina "contempla marca por texto" con "sin ninguna otra dependencia abierta". Las 66 sin cambio ya funcionan igual para cualquier marca; las 21 restantes (9+4+8) dependen de un dato, un perfil o una decisión que no corresponde inventar. No se pegan aquí las fórmulas completas porque no aportan valor de negocio adicional al ejemplo ya mostrado; están disponibles en `MATRIZ_VALIDATION_RULES_B9_0_V2_20260806.csv` para quien necesite el detalle técnico exacto.

---

## 5. Jerarquía / Perfiles / Ejemplo end-to-end

**Cómo se ve el proceso hoy, con lo que cada tramo demuestra realmente — no se afirma que exista todavía una sola ejecución continua de punta a punta con evidencia:**

```
Admin / usuario autorizado
   → Lead (Prospecto)                     [Empresa/marca: mapeo Omoda/Jaecoo ya activo]
   → Opportunity (Venta Nueva)            [Record Type compartido; Empresa_Operadora__c;
                                            jerarquía Director/Gerente/Jefe; Validation Rules ampliadas]
   → Quote (Presupuesto)                  [Pricebook PEKING Local/Dólares vía EmpresaPricebookResolver]
   → Work Order (Orden de Trabajo)        [empresaFacturaCP__c propagado; bodega/territorio provisionales]
   → Servicio / postventa                 [mano de obra y gastos QA OK; garantía y agenda pendientes]
```

**Dónde interviene cada concepto:**

- **Empresa:** el lookup `Empresa_Operadora__c` (Oportunidad) y sus equivalentes (`empresaFacturaCP__c` en Orden de Trabajo, `Empresa__c` en Sucursal de Servicio) son la fuente de verdad en los tramos ya remediados. Los tramos todavía no remediados (algunas clases fuera de alcance, sección 8) siguen decidiendo por texto.
- **Marca:** Omoda y Jaecoo se distinguen a nivel de dato (cuenta, mapeo de Lead) y de jerarquía de aprobación (Sucursal), no de pantalla — ambas comparten la misma experiencia de Venta Nueva.
- **Record Type:** un único Record Type de Venta Nueva sirve para las marcas existentes y para Omoda/Jaecoo; el mapeo de Lead usa Metadata Personalizada (`RM_RecordTypeMapping`) dedicada a Omoda y a Jaecoo.
- **Perfil/rol:** la asignación de responsables de aprobación (Director de Ventas, Gerente de Sucursal, Jefe de Sucursal) para Omoda/Jaecoo se implementó como 6 campos nuevos en el objeto Sucursal (`DirectordeVentasOmoda__c`, `GerentedeSucursalOmoda__c`, `JefesdeSucursalOmoda__c` y sus equivalentes Jaecoo), consumidos por la misma lógica de asignación que ya usan las demás marcas.
- **Jerarquía:** el consumidor de esos campos (`OpportunityTriggerHandler`) hoy tiene Omoda y Jaecoo como 2 de 9 ramas explícitas de Record Type; un Record Type no reconocido simplemente no asigna responsables (no bloquea el guardado, pero tampoco asigna a nadie) — deuda técnica documentada, no un bloqueo.
- **Pricebook:** resuelto dinámicamente por Empresa y moneda en la ruta de creación (ya QA OK); la ruta de recálculo tiene el defecto pendiente de la sección 10.
- **Territorio:** resuelto por el lookup `Empresa__c` en Sucursal de Servicio (N4), con datos de prueba mientras no exista territorio oficial.

**Qué SÍ tiene evidencia funcional real, tramo por tramo:**

| Tramo | Evidencia | Estado |
|---|---|---|
| Lead → Oportunidad | Creación de Oportunidad Omoda y Jaecoo con datos representativos, comparada contra BMW | QA OK (Sprint 3) |
| Oportunidad → Presupuesto (creación) | 4 Flows, creación de Opportunity+Quote PEKING persistida correctamente | QA FUNCIONAL OK |
| Presupuesto → recálculo de Pricebook | Defecto confirmado por lectura de código, no por ejecución fallida en QA (esa ruta no se había ejercido antes) | **Pendiente de corrección** |
| Presupuesto → Orden de Trabajo | Ejecución normal y selectiva, cada una con 1 Work Order y 1 WOLI PEKING | QA FUNCIONAL OK |
| Orden de Trabajo → mano de obra / gasto | 2 Flows, cada uno con 1 WOLI correcto y único | QA FUNCIONAL OK |
| Orden de Trabajo → mantenimiento/regalía | 1 Plan y 1 línea de Presupuesto persistidos correctamente | QA FUNCIONAL OK |
| Caso de servicio → Orden de Trabajo (agenda) | Permisos verificados; el único intento de prueba dirigida falló en la inicialización del Flow, antes de crear registros | **QA parcial — fallo técnico sin diagnosticar** |
| Orden de Trabajo → garantía/segregación | Sin cambio técnico necesario con garantía en cero; **regla definitiva sin confirmar** | **Pendiente de negocio (Diego)** |

No se afirma que la ruta completa Lead→postventa esté "QA OK" como una sola ejecución — cada tramo fue probado por separado, con los resultados exactos de la tabla de arriba.

---

## 6. Datos provisionales usados para QA

Todos los valores de esta tabla son de prueba, no son la configuración oficial de PEKING, y no deben tratarse como tal. Se usaron para no bloquear el trabajo técnico mientras negocio confirma los valores finales.

| Dato | Valor usado | Baseline | Estado | Qué lo reemplazará |
|---|---|---|---|---|
| Bodega (Work Order/QA general) | `a2bAK0000000vvxYAA` | Estructura de bodega de Bavarian | **PROVISIONAL / QA / BASADO EN BAVARIAN — NO PRODUCCIÓN** | Bodega oficial de PEKING (N2) |
| Sucursal de Servicio (Service Territory) | `0HhAK0000000sbV0AQ`, "PEKING TEMPORAL - NO PRODUCCION", moneda CRC | Estructura de Bavarian | **PROVISIONAL / QA / BASADO EN BAVARIAN — NO PRODUCCIÓN** | Territorio, taller y servicios oficiales de PEKING (N4) |
| Vehículo/Product2 usado en QA de mantenimiento | `01tPH00000K5VMDYA3` (BMW X1) | Vehículo real de Bavarian | **PROVISIONAL / QA / BASADO EN BAVARIAN — NO PRODUCCIÓN** | Vehículo/catálogo PEKING oficial |
| Precio de Lista (PBE) del vehículo de mantenimiento | `01uAK000000YWrtYAG`, PEKING Local, CRC, precio nominal `1` | PBE de Bavarian del mismo producto | **PROVISIONAL / QA / BASADO EN BAVARIAN — NO PRODUCCIÓN** | Catálogo y precio oficiales de PEKING |
| Término de garantía usado en el plan de mantenimiento | `4V3PH00000000eL0AQ` | Plan de Bavarian `A-0575` | **PROVISIONAL / QA / BASADO EN BAVARIAN — NO PRODUCCIÓN** | Término oficial de PEKING |
| Tipo de plan de mantenimiento | `Regalías Autos` | Plan de Bavarian `A-0575` | **PROVISIONAL / QA / BASADO EN BAVARIAN — NO PRODUCCIÓN** | Tipo de plan oficial de PEKING |
| Precio de Lista SAD001 (mano de obra) | `01uAK000000YRDtYAO` / `01uAK000000YRFVYA4`, Local/Dólares | Estructura Bavarian | **PROVISIONAL / QA / BASADO EN BAVARIAN — NO PRODUCCIÓN** | Catálogo comercial definitivo |
| Precio de Lista SUB — variante histórica de mano de obra | `01uAK000000YRH7YAO` / `01uAK000000YRFWYA4` | Estructura Bavarian | **PROVISIONAL / QA / BASADO EN BAVARIAN — NO PRODUCCIÓN**; requiere decisión de catálogo antes de promoción | Decisión de catálogo de mano de obra PEKING |
| Precio de Lista Subcontrato autoritativo | `01uAK000000YUy9YAG`, PEKING Local, precio `1` | Configuración funcional del ambiente de pruebas | **PROVISIONAL / QA — NO ES PRECIO OFICIAL** | Precio comercial oficial |
| Reserva / despacho / taller | Valores por defecto de los Flows y del territorio provisional | Bavarian | **PROVISIONAL / QA / BASADO EN BAVARIAN — NO PRODUCCIÓN** | Reglas operativas oficiales de PEKING |
| Garantía (WOLI, `SegregateWOLIs`) | Se asume 0% de garantía (sin regla especial) | Ausencia de equivalencia Bavarian demostrada | **PENDIENTE CONFIRMACIÓN DIEGO — GARANTÍA PEKING** | Regla y campo oficial de garantía PEKING |
| Catálogo `TipoDeCargoConManoDeObra__c` | 0 filas configuradas para PEKING (`RMBAVARIAN`=12, `RMOTOBAI`=3, `RMPEKING`=0) | N/A | **SIN DATOS — PENDIENTE DE CATÁLOGO OFICIAL** | Combinaciones oficiales de tipo de cargo/vehículo/producto para PEKING |
| Responsables de aprobación (Director/Gerente/Jefe Omoda/Jaecoo) | Usuario administrador temporal | N/A | **PROVISIONAL / QA — NO ES ASIGNACIÓN DE NEGOCIO DEFINITIVA** | Responsables reales que confirme el negocio |
| Precio de Lista por defecto (Sprint 3) | No definido | N/A | **SIN DEFINIR** | Regla de negocio de Precio de Lista por defecto |
| Bodegas y códigos oficiales del sistema externo (Softland) | No definidos; solo mecánica probada | N/A | **SIN DEFINIR** | Bodegas y convención de código oficiales |

Ningún dato de esta tabla se usa en Producción. Cada Permission Set y cada registro temporal asociado a estos datos está explícitamente rotulado como QA temporal en los documentos técnicos de cierre (`CIERRE_FUNCIONAL_SPRINT2_POST_RESPUESTA_LUIS_20260813.md`).

---

## 7. Inventario completo de elementos trabajados

Este inventario distingue explícitamente **revisado** (se leyó/analizó, sin cambio de código), **modificado** (cambio de código o metadata real), **desplegado** (llevado a Partial), **QA** (probado funcionalmente) y **descartado/no aplica**. No se suma "revisado" con "modificado" en un único total.

### Clases Apex

**Total revisado/reconciliado (Sprint 1, alcance nominal oficial):** 32 clases.
**De esas 32, con cambio de código real confirmado en esta línea de trabajo:** 9 (`precioProductoJSON`, `QuoteSoftlandPedidoService`, `ServicioConsDispBodegaQuoli`, `ServicioCrearSCQuote`, `ServicioEliminarReservaArticuloQuote`, `ServicioReservaApartadoArticulosQuote`, y las 7 `BatchGet*Softland` menos una ya contada — ver nota).
**Adicional (Sprint 2, no cuenta dentro de las 32):** 1 clase modificada (`BatchGetCatalogoSoftland`, dependencia de soporte).
**Adicional (Sprint 3, bloque B11-1, reconciliación sin cambio de comportamiento):** 12 clases productivas incorporadas a Git desde Partial (6 wrappers `BatchGet*Softland` ya contados arriba + 6 schedulers `ScheduleGet*Softland` nuevos en esta cuenta) + 13 clases de prueba asociadas.

| Elemento | Tipo | Acción realizada | Sprint/bloque | Estado | Evidencia |
|---|---|---|---|---|---|
| `precioProductoJSON` | Clase | Modificada — rama RMPEKING agregada, resolución dinámica de Pricebook | Sprint 2, precheck 12-ago | QA técnico OK (test agregado) | `RESULTADO_PRECHECK_REGRESIONES_20260812.md` |
| `BatchGetCatalogoSoftland` | Clase (soporte, no cuenta en las 32) | Modificada — prefijo de bodega generalizado por empresa | Sprint 2, precheck 12-ago | QA técnico OK | Igual |
| `QuoteSoftlandPedidoService` | Clase | Modificada — ruta principal resuelta vía `EmpresaResolver` | Sprint 1 | Reconciliado | commit `c320138` |
| `ServicioConsDispBodegaQuoli` | Clase | Modificada — resolución vía `Empresa_Operadora__c` | Sprint 1 | Reconciliado | commit `a0dbcf8` |
| `ServicioCrearSCQuote` | Clase | Modificada | Sprint 1 | Reconciliado | commit `5999793` |
| `ServicioEliminarReservaArticuloQuote` | Clase | Modificada | Sprint 1 | Reconciliado | commit `1e73956` |
| `ServicioReservaApartadoArticulosQuote` | Clase | Modificada, con prueba dedicada nueva | Sprint 1 | Reconciliado | commit `73b5d57` |
| `BatchGetCategoriaClienteSoftland`, `BatchGetCentroCostoSoftland`, `BatchGetCondicionPagoSoftland`, `BatchGetCuentaContableSoftland`, `BatchGetImpuestoSoftland`, `BatchGetSubtipoDocumentoSoftland`, `BatchGetBodegaSoftland` | 7 clases | Reconciliadas desde Partial (Git difería) | Sprint 1 | Validadas — 33/33 pruebas, 100% cobertura enfocada | `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` |
| `ScheduleGetCategoriaClienteSoftland`, `ScheduleGetCentroCostoSoftland`, `ScheduleGetCondicionPagoSoftland`, `ScheduleGetCuentaContableSoftland`, `ScheduleGetImpuestoSoftland`, `ScheduleGetSubtipoDocumentoSoftland` | 6 clases | Incorporadas a Git desde Partial, sin cambio de comportamiento | Sprint 3, bloque B11-1 | Reconciliadas — 36/36 pruebas del lote, 100% cobertura enfocada | `RESULTADO_B11_1_CATALOGOS_SOFTLAND_20260806.md` |
| Otras 22 de las 32 clases confirmadas (`BMW_LineaPlantillaEmpresa`, `ProductControllerTwo`, `servicioReservas`, `servicioEliminarReserva`, `QuoteController`, `cT_QuoteCrcPDFController`, `cT_QuoteUsdPDFController`, `UpdateCurrencyScheduler`, `BMW_ChangeCurrencyWOWOLI`, `OpportunityServiceInvoker`, `Registrar_Anticipo_Controller`, `savePDFfile`, `BMWServiceQuoteApprovalEmailInvocable`, `productJSON`, `HttpCalloutCreateKit`, `ProductSearcherController`, `QuoteService`, `QuoteSoftlandQueryService`, `RM_VN_CambiarUbicacion_Ctrl`) | 19 clases (más `productJSON` con diferencia cosmética, sin impacto funcional) | Revisadas — código ya correcto para las 3 empresas o sin diferencia funcional Git/Partial | Sprint 1 | Revisado, sin cambio necesario | `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` |

**Clase 33:** nunca seleccionada. Candidata más fuerte documentada: `TrabajoQuoteController` (pendiente de confirmación de Luis).

**Adicionalmente, ~64 clases citadas en una auditoría técnica externa (de Luis) fueron revisadas una por una en modo estrictamente de solo lectura** — ninguna de ellas se modificó; el detalle completo está en la sección 8.

### Triggers

**Total:** 3 (alcance oficial de Sprint 1).

| Elemento | Acción realizada | Sprint/bloque | Estado | Evidencia |
|---|---|---|---|---|
| `ChanceAccountBavarian` | Revisado | Sprint 1 | Revisado, sin cambio necesario | `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` |
| `ChanceAccountContado` | Revisado | Sprint 1 | Revisado, sin cambio necesario | Igual |
| `WorkOrderTrigger` | Reconciliado desde Partial | Sprint 1 | Validado — `WorkOrderTriggerTest`, 94% cobertura enfocada | Igual |

### Flows

**Total:** 20 (alcance autoritativo de Sprint 2, sin doble conteo).

| Elemento | Acción realizada | Sprint/bloque | Estado | Evidencia |
|---|---|---|---|---|
| `PlanDeMantenimientoV2` | Modificado (permisos de campo) y QA ejecutado | Sprint 2, F07 | **QA FUNCIONAL OK** | `CIERRE_FUNCIONAL_SPRINT2_POST_RESPUESTA_LUIS_20260813.md` |
| `Work_Order_from_Quote` | Modificado (propagación de lookup) y QA ejecutado | Sprint 2, F09 / N2 | **QA FUNCIONAL OK** | Igual |
| `Work_Order_from_Quote_Selective` | Modificado (mismo patrón) y QA ejecutado | Sprint 2, F08 / N2 | **QA FUNCIONAL OK** | Igual |
| `Opp_Flow_V5` | Modificado (rama Taller) y QA ejecutado | Sprint 2, F12 | **QA FUNCIONAL OK** (creación y navegación) | `RESULTADO_REMEDIACION_OPP_FLOW_V5_TALLER_20260812.md` |
| `CreateWoliFromExpense` | Modificado (producto SUB) y QA ejecutado | Sprint 2, F16 | **QA FUNCIONAL OK** | `CIERRE_FUNCIONAL_SPRINT2_POST_RESPUESTA_LUIS_20260813.md` |
| `AgregarManoObra` | Modificado (límite SOQL) y QA ejecutado | Sprint 2, F19 | **QA FUNCIONAL OK** | Igual |
| `Opp_flow_V3` | Modificado (navegación) y QA parcial | Sprint 2, F13 | Validación técnica OK / QA de enlace diferido | Igual |
| `Opp_Flow_v6` | Modificado (navegación) y QA parcial | Sprint 2, F14 | Validación técnica OK / QA de enlace diferido | Igual |
| `Opportunity_Flow_V2` | Modificado (navegación) y QA parcial | Sprint 2, F15 | Validación técnica OK / QA de enlace diferido | Igual |
| `aperturaCaseWorOrderEvent` | Modificado (lookup Empresa en territorio); primer intento de QA ejecutado | Sprint 2, F17 / N4 | QA parcial — falló en inicialización antes de crear registros; pendiente diagnóstico | `CIERRE_TECNICO_SPRINT2_20260813.md` |
| `ct_newCaseWorkOrderEvent` | Modificado (mismo patrón); no ejecutado todavía (se detuvo tras el fallo del anterior) | Sprint 2, F18 / N4 | Desplegado técnicamente, QA funcional pendiente | Igual |
| `SegregateWOLIs` | Revisado, sin modificar | Sprint 2, F10 / N3 | Bloqueo de negocio — pendiente Diego | Igual |
| `Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla`, `BMW_Gestiona_Listas_de_Precios`, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto`, `Opportunity_Flow_From_Work_Order` | Revisados, sin cambio técnico | Sprint 2, F01-F06 | Revisado sin cambio; QA depende de datos oficiales | `RESUMEN_EJECUTIVO_AUDITORIA_SPRINT2.md` |
| `ReciboUsadosFlow` | Revisado | Sprint 2, F11 | No aplica (proceso exclusivo de usados, confirmado por Luis) | Igual |
| `Carga_MO_26_Lavado_a_Caso` | Revisado | Sprint 2, F20 | No aplica (sin versión activa) | Igual |

**Resumen exacto:** 6 QA FUNCIONAL OK, 3 validación técnica OK/QA diferido, 3 bloqueo de negocio, 6 revisado sin cambio, 2 no aplica. Total 20.

### LWC (Lightning Web Components)

**Total:** 20 bundles (alcance autoritativo de Sprint 2).

| Grupo | Cantidad | Acción realizada | Estado |
|---|---:|---|---|
| Identificados para modificar | 3 (`busquedaDetallada`, `productSearcher`, `rm_vn_crear_opp_inventario`) | Revisados y priorizados; **ninguno modificado todavía** | Pendiente de reconciliación Git/Partial y de autorización |
| Sin cambio técnico | 3 (`rm_vn_crear_opp_general`, `rm_vn_crear_opp_home`, `rm_vn_crear_opp_home_movil`) | Revisados | Sin cambio necesario; QA de composición pendiente |
| No aplica | 2 (`rm_vu_inventario`, `rm_vu_crear_opp`) | Revisados | Exclusivos de vehículos usados, confirmado por Luis |
| Bloqueado | 12 (`quoliGridDespacho`, `woliGridDespacho`, `kpiSucursales`, `cT_Estadisticas_Inventario_lwc`, `rm_vn_inventario`, `rm_vn_inventario_movil`, `assetGarantiaLookupLwc`, `rm_vn_get_record_opp_record_types`, `qoSearchDetailProduct`, `woSearchDetailProduct`, `localizacionDetails`, `pricebookReferenceDetails`) | Revisados | Bloqueo técnico (diff Git/Partial) o funcional (alcance PEKING no confirmado) |

**Ningún componente LWC previamente bloqueado cruzó el umbral de desbloqueo en la reconciliación de Sprint 2** (confirmado 12 de agosto).

### Aura Components

**Total:** 5 bundles.

| Grupo | Cantidad | Acción realizada | Estado |
|---|---:|---|---|
| Sin cambio técnico | 1 (`CommunityCalendar`) | Revisado | Sin cambio necesario |
| Bloqueado | 4 (`CommunityMenu`, `CommunityControl`, `customerCommunity_lwc`, `callcenterCommunity_lwc`) | Revisados | Diff Git/Partial y, en `CommunityMenu`, contenido legal que requiere aprobación oficial antes de tocarse |

### Layouts

**Total con cambio confirmado en control de versiones:** 3.

| Elemento | Acción realizada | Sprint/bloque | Estado |
|---|---|---|---|
| `Opportunity-Autos` | Habilitado acceso al campo de empresa | Sprint 2, preparación QA (12-ago) | Desplegado |
| `Opportunity-Taller Autos` | Igual | Sprint 2, preparación QA (12-ago) | Desplegado |
| `Pricebook2-Price Book Layout` | Ajuste de layout como parte de la remediación de la auditoría de Sprint 2 | Sprint 2 (31-jul) | Desplegado |

### Lightning Pages / FlexiPages

**Total con cambio confirmado en control de versiones:** 1.

| Elemento | Acción realizada | Sprint/bloque | Estado |
|---|---|---|---|
| `Opportunity_Record_Page_VN` | Configurada para reconocer Omoda/Jaecoo, reutilizando la experiencia de Venta Nueva existente | Sprint 1/3 (26-jul) | Desplegado; pendiente puesta a punto final de asignación por marca/rol |

### Validation Rules

Ver desglose completo en la sección 4. **Total revisado:** 94. **Total modificado y desplegado:** 4.

### Approval Processes

**Total modificado:** 0. No se crearon ni modificaron procesos de aprobación — los existentes se reutilizan directamente para Omoda/Jaecoo una vez que la jerarquía de responsables (sección 5) esté configurada con datos reales; no requieren cambio propio (confirmado, sección 2 "Validaciones y aprobaciones").

### Permission Sets

**Total con cambio confirmado en control de versiones:** 7 (algunos con más de una modificación).

| Elemento | Acción realizada | Sprint/bloque | Estado |
|---|---|---|---|
| `Vehiculos_Nuevos_PS` | Replicado acceso de lookup de empresa | Sprint 1 (25-jul) | Desplegado |
| `Empresa_Admin` | Creado y modificado | Sprint 1/2 | Desplegado |
| `Empresa_Consulta_Flows` | Creado y modificado — Read mínimo sobre `Empresa__c` | Sprint 2 | Desplegado — **QA TEMPORAL**, posible uso funcional real pendiente de confirmar población |
| `QA_PEKING_S3_RecordType_Access` | Creado | Sprint 3 (10-ago) | Desplegado — QA |
| `Plan_Mantenimiento_QLI_QA` | Creado — Read/Edit sobre 2 campos de `QuoteLineItem` | Sprint 2, F07 | Desplegado — **QA TEMPORAL, NO PROMOVER A PRODUCCIÓN** |
| `Empresa_Codigo_ERP_QA` | Creado — Read sobre `Empresa__c.Codigo_ERP__c` | Sprint 2, N2 | Desplegado — **QA TEMPORAL, NO PROMOVER A PRODUCCIÓN** |
| `WorkOrder_Empresa_Factura_QA` | Creado | Sprint 2 | Desplegado — **QA TEMPORAL, NO PROMOVER A PRODUCCIÓN** |

### Custom Metadata

**Total:** 2 registros.

| Elemento | Acción realizada | Sprint/bloque | Estado |
|---|---|---|---|
| `RM_RecordTypeMapping.Lead_Omoda_to_Opp` | Creado | Sprint 1 (26-jul) | Desplegado |
| `RM_RecordTypeMapping.Lead_Jaecoo_to_Opp` | Creado | Sprint 1 (26-jul) | Desplegado |

### Campos / objetos configurados

**Total de campos nuevos confirmados:** 19, sobre 8 objetos. **Objeto nuevo:** 1 (`Empresa__c`).

| Objeto | Campos | Sprint/bloque |
|---|---|---|
| `Empresa__c` (objeto nuevo) | `Codigo__c`, `Codigo_ERP__c`, `Nombre_Legal__c`, `Activa__c` | Sprint 1 |
| `Opportunity` | `Empresa_Operadora__c`, `Flag_Vehiculo_Nuevo_FM__c` | Sprint 1 |
| `Plantilla_de_Presupuesto__c` | `Empresa_Operadora__c` | Sprint 1 |
| `Pricebook2` | `Empresa__c` | Sprint 2 (bloque Pricebook, autorizado 30-jul) |
| `Product2` | `Empresa__c` | Sprint 1/2 |
| `ServiceTerritory` | `Empresa__c` | Sprint 2, N4 |
| `TipoDeCargoConManoDeObra__c` | `Empresa__c` | Sprint 1 |
| `WorkOrder` | `empresaFacturaCP__c`, `empresaFactura__c` | Sprint 1/2 |
| `Sucursal__c` | `DirectordeVentasOmoda__c`, `DirectordeVentasJaecoo__c`, `GerentedeSucursalOmoda__c`, `GerentedeSucursalJaecoo__c`, `JefesdeSucursalOmoda__c`, `JefesdeSucursalJaecoo__c` | Sprint 3 (11-ago) |

### Pricebooks / Pricebook Entries

**Total de Pricebook Entries de PEKING creados como dato de QA:** 7 (todos rotulados como provisionales, ver sección 6). **Pricebook `PEKING Local` y `PEKING Dólares`:** ya existían desde el cierre de Sprint 1, reutilizados sin cambio.

### Service Territories / configuración QA

**Total de Service Territory de PEKING creado como dato de QA:** 1 (`0HhAK0000000sbV0AQ`, provisional, ver sección 6). **Campo de configuración nuevo:** `ServiceTerritory.Empresa__c` (contado en "Campos/objetos" arriba).

### Otro metadata realmente modificado

Ningún Approval Process, ningún Report/Dashboard y ninguna Email Template se modificaron dentro del alcance de este reporte. La plantilla de correo/presupuesto propia de PEKING mencionada en la sección 3 (3 acciones pendientes) todavía no se creó.

---

## 8. Clases Apex — alcance vs. hallazgos

Se usa la reconciliación ya realizada de la auditoría técnica de Luis (~64 clases citadas) contra el alcance oficial confirmado de Sprint 1 (32 clases + 3 triggers). Ninguna de estas ~64 clases se modificó en esta tarea — es una revisión de solo lectura.

| Clasificación (específica de esta sección) | Cantidad | Qué significa |
|---|---:|---|
| **A — incluidas en alcance original** | 24 | Ya forman parte de las 32 clases confirmadas de Sprint 1; 22 ya están correctas para las 3 empresas, 2 conservan un defecto activo pendiente de corrección dentro de su propio alcance (`HttpCalloutCreateKit`, contradice lo que afirma la auditoría). |
| **B — autorizadas posteriormente** | 9 | No estaban en las 32 originales, pero recibieron autorización explícita después (bloque Pricebook de Sprint 2, jerarquía de Sprint 3, o reconciliación B11-1 de catálogos Softland). No se tratan como trabajo extra. |
| **C — pendientes de confirmación económica** | 21 | Fueron analizadas y documentadas durante la investigación de Sprint 1 (aparecen en el inventario técnico de 69 clases), pero nunca se seleccionaron dentro del cupo de 33 clases pagado. **PENDIENTE DE DEFINICIÓN DE ALCANCE/HORAS CON LUIS** — no se afirma todavía que sean ni alcance cubierto ni trabajo extra. |
| **D — no confirmables** | 6 | No existen en este repositorio Git, o no se localizaron en ningún lado accesible. |
| **E — trabajo adicional real** | 2 | Cumplen el estándar de evidencia para marcarse como trabajo fuera del alcance original — ver sección 9. |
| **Total** | **62 + 2 clases sin nombre de clase Apex propio** (`ScheduleGetCatalogoSoftland`, que no existe, se cuenta dentro de D) | 64 hallazgos de la auditoría, sin omitir ninguno |

**Qué significa para negocio:** de todo lo que la auditoría externa señaló, 24 clases ya están dentro de lo que se pagó y se trabajó en Sprint 1; 9 más están cubiertas porque un bloque posterior las autorizó explícitamente; solo 2 tienen evidencia suficiente para plantearse como trabajo genuinamente adicional (sección 9); el resto (21+6) no se puede clasificar todavía sin una decisión o una confirmación adicional de Luis.

El detalle clase por clase, con hallazgo exacto y evidencia, está en `RECONCILIACION_AUDITORIA_LUIS_20260813.md` (sección 6) — no se repite aquí para no duplicar casi 500 líneas de detalle técnico dentro de un reporte de negocio.

---

## 9. Regla obligatoria de trabajo extra

Vigente desde el 13 de agosto de 2026, documentada formalmente en `REGLA_PRIORIDAD_Y_TRABAJO_ADICIONAL_20260813.md`.

**La autorización técnica de Luis o Diego para corregir una urgencia NO significa automáticamente que ese trabajo esté cubierto económicamente por el alcance/horas originales.** Son dos decisiones distintas: la autorización técnica decide si se puede tocar un componente; la cobertura económica decide si ya estaba pagado, y es una decisión exclusiva de Luis.

Toda actividad que realmente quede fuera del alcance/horas original se marca así, en el componente exacto que corresponde:

**TRABAJO EXTRA — NO CONTEMPLADO EN EL ALCANCE/HORAS ORIGINALES**

- `ServicioCitas`
- `ServicioCitasFieldService`

Ambas fueron analizadas durante Sprint 1 (aparecen en el inventario técnico de 69 clases) pero quedaron **excluidas explícitamente** del conteo de la clase 33, pendientes de una decisión de negocio sobre el modelo operativo de citas de PEKING que nunca llegó. No tienen lógica de empresa real que corregir hoy — solo una traducción de etiqueta "Otobai" en sucursal — así que no representan horas ya gastadas, sino una posible ampliación de alcance si se pide resolver su decisión de negocio pendiente.

Las **21 clases ambiguas** de la sección 8 (categoría C) **no se marcan como trabajo extra**. Se marcan como:

**PENDIENTE DE DEFINICIÓN DE ALCANCE/HORAS CON LUIS**

hasta que se acuerde si entran dentro del ítem 4 original (30h, Apex) ya excedido en alcance real frente a lo presupuestado, o si constituyen una ampliación a negociar aparte.

---

## 10. Correcciones prioritarias / urgentes

| Urgencia | Estado real al 13 de agosto de 2026 |
|---|---|
| Quote → Work Order: propagación de Empresa (N2) | **Ya corregido y QA funcional OK.** Ambas variantes (normal y selectiva) crearon Work Order y WOLI de PEKING correctos, sin fault ni duplicado. |
| Bug `Pricebook2.Name = Id` en `Opp_flow_V3`, `Opp_Flow_V5`, `Opp_Flow_v6`, `Opportunity_Flow_V2` | **Pendiente de autorización — no corregido.** Confirmado por lectura directa de los 4 Flows; afecta también a Bavarian y Otobai en la ruta de recálculo de Pricebook de un Presupuesto ya existente (no en la ruta de creación, que sí está QA OK). Riesgo alto porque toca datos de producción de las 3 empresas. |
| N4 — servicios/agenda/territorios (`aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent`) | **QA parcial.** Permisos mínimos aplicados y verificados; el único intento de `aperturaCaseWorOrderEvent` v21 falló durante la inicialización del Flow, antes de crear cualquier registro — requiere diagnóstico técnico dirigido de esa causa, no una nueva definición de negocio ni repetir la misma prueba. `ct_newCaseWorkOrderEvent` v55 no se ejecutó. |
| N3 — garantía (`SegregateWOLIs`) | **Pendiente confirmación de Diego.** Con garantía en 0%, PEKING no requiere cambio técnico, pero la regla definitiva de garantía de fábrica sigue sin confirmar. |
| Clases con lógica Bavarian/Otobai binaria realmente pendientes y sin bloqueo de negocio de por medio | `HttpCalloutGetProductRefPrices`, `ProductoLocalizacionHelper` (ignoran el parámetro de empresa que ya reciben), `HttpCalloutCreateKit` (sin manejo de Omoda/Jaecoo, contradice lo que afirmaba la auditoría externa), `BatchOppActivityUploader`, `cT_QuotePDFEmail` (ambas con razón social "Bavarian Motors CR S.A." fija en documentos emitidos). Ninguna está autorizada todavía. |

---

## 11. QuoteSoftlandPedidoService

Luis pidió atención específica a esta clase por su rol central en el pedido hacia el sistema externo (Softland).

- **Qué ya usa Empresa:** la ruta principal ya resuelve la empresa dinámicamente vía `EmpresaResolver.resolve(Empresa_Operadora__c)` — no depende de una lista cerrada cuando el lookup viene poblado.
- **Qué fallback/validación legacy queda:** el mecanismo de respaldo (`resolveLegacyCompanyCode`, solo se activa si el lookup viene vacío) y el validador (`validateSupportedCompany`) todavía escriben las 3 empresas de forma literal, incluida PEKING — es una lista cerrada, no una consulta dinámica al catálogo `Empresa__c`.
- **Impacto:** bajo. Solo se manifiesta si un registro llega a este punto sin el lookup de Empresa poblado — un escenario de datos incompletos, no el camino normal ya QA OK.
- **¿Está dentro del alcance original?** Sí — es una de las 32 clases confirmadas de Sprint 1 (categoría A de la sección 8).
- **Estado actual:** no autorizado para tocar el fallback; no bloquea a PEKING hoy.
- **Siguiente acción:** ninguna urgente. Si se decide invertir en robustecer este fallback, sería para hacerlo configurable (leer del catálogo `Empresa__c` en vez de la lista fija), no para "agregar PEKING" — ya está incluido.

---

## 12. Qué queda pendiente de negocio

Separado explícitamente de los defectos técnicos (sección 10) — nada de esta lista se resuelve escribiendo código sin antes tener la definición correspondiente.

- **Garantía PEKING:** ¿usa garantía de fábrica? ¿Con qué campo o mecanismo se identifica? (bloqueo N3, Diego).
- **Bodega y territorio oficiales:** para las rutas Quote→Work Order y para Sucursales de Servicio (N2/N4).
- **Centro de costo oficial:** para el ciclo real de aprobación de descuentos y de Órdenes de Trabajo.
- **Servicios, agenda y sucursales oficiales de postventa** (N4).
- **Citas / modelo operativo:** si PEKING comparte la operación de citas de Bavarian/Otobai o requiere una propia (`ServicioCitas`, sección 9).
- **Branding / razón social oficial de PEKING:** para documentos emitidos (`BatchOppActivityUploader`, `cT_QuotePDFEmail`) y para el fallback de `QuoteSoftlandPedidoService`.
- **Catálogos oficiales del sistema externo (Softland):** contenido real de los 6 catálogos — la mecánica ya está probada, los datos no.
- **Responsables definitivos de aprobación** (Director de Ventas, Gerente de Sucursal, Jefe de Sucursal) para Omoda y Jaecoo — hoy configurado con un usuario de prueba.
- **Precio de Lista (Pricebook) por defecto** para Omoda/Jaecoo.
- **Catálogo `TipoDeCargoConManoDeObra__c` para PEKING:** hoy tiene 0 filas configuradas.
- **Plantillas y remitentes de correo propios de PEKING**, para las 3 acciones de pantalla que los requieren (sección 3).

---

# Puntos para sesión con María

**Qué ya quedó:**
- Sprint 1 cerrado técnicamente (32 clases + 3 triggers).
- Dentro de Sprint 2: mantenimiento/regalías (F07) y creación de Orden de Trabajo desde Presupuesto (N2) — ambos con QA funcional real, no solo revisión de código.
- 3 Flows de Oportunidad más con creación funcional aprobada (navegación diferida, no bloqueante).
- 2 Flows de mano de obra/gastos con QA funcional real.
- Sprint 3: creación de Oportunidad Omoda/Jaecoo, 4 Validation Rules ampliadas (3 de 4 con QA funcional positivo/negativo/regresión), integración Softland probada con datos simulados (36/36 pruebas), jerarquía de aprobación implementada técnicamente.

**Qué está en curso:**
- N4 (servicios/agenda/postventa): permisos corregidos y verificados; el primer intento de prueba dirigida falló por un problema técnico de inicialización todavía sin diagnosticar (no es un tema de definición de negocio).
- Corrección del bug de recálculo de Pricebook (afecta las 3 empresas) — identificado, sin corregir, a la espera de autorización.
- Sprint 3 continúa en paralelo (rama de continuidad abierta el 13 de agosto).

**Qué datos son provisionales:** bodega, territorio de servicio, vehículo/catálogo de mantenimiento, término de garantía, y varios Precios de Lista — todos basados en la estructura de Bavarian, ninguno en Producción (detalle en sección 6).

**Qué hallazgos adicionales existen:** una auditoría técnica externa revisó ~64 clases Apex fuera del alcance ya pagado; 24 ya estaban cubiertas, 9 tienen autorización posterior, 21 quedan pendientes de que Luis decida si entran o no en el alcance ya cubierto, y solo 2 (`ServicioCitas`, `ServicioCitasFieldService`) tienen evidencia suficiente para considerarse trabajo genuinamente adicional.

**Qué podría implicar horas adicionales:**
- Las 21 clases pendientes de definición de alcance/horas (sección 8, categoría C).
- `ServicioCitas`/`ServicioCitasFieldService`, si se pide resolver su decisión de negocio pendiente.
- La corrección del bug de recálculo de Pricebook, si se decide tratar como remediación técnica prioritaria fuera del ítem 4 original.

**Qué decisiones se necesitan:** todas las de la sección 12 (pendientes de negocio), más la decisión de Luis sobre las 21 clases ambiguas y sobre si el bug de Pricebook se autoriza como remediación técnica inmediata.

---

## Anexo técnico breve

Este anexo existe únicamente como referencia de respaldo documental.

- El detalle clase por clase de la auditoría Apex está en `RECONCILIACION_AUDITORIA_LUIS_20260813.md`.
- La regla de prioridad y trabajo extra completa está en `REGLA_PRIORIDAD_Y_TRABAJO_ADICIONAL_20260813.md`.
- El cierre técnico y funcional detallado de Sprint 2 está en `CIERRE_TECNICO_SPRINT2_20260813.md` y `CIERRE_FUNCIONAL_SPRINT2_POST_RESPUESTA_LUIS_20260813.md`.
- El detalle de horas por bloque está en `CONCILIACION_HORAS_AVANCE_REAL_EMPRESA_MARCAS_CHINAS_20260811.md`.
- El detalle de Validation Rules está en `MATRIZ_VALIDATION_RULES_B9_0_V2_20260806.csv`.
- Las evidencias visuales de Sprint 3 corresponden a archivos de video externos, no versionados junto con el código.

**Fin del contenido consolidado. No sustituye al reporte Word final — está preparado para revisión y discusión con Luis, Diego y María.**
