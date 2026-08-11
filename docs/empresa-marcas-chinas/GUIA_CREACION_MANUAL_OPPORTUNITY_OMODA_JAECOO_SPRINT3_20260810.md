# Guía práctica — Crear manualmente una Oportunidad Omoda / Jaecoo en Partial

**Fecha:** 10 de agosto de 2026
**Org:** Partial (`RedMotorsSandbox`) — **nunca Producción**.
**Para:** Claudia (usuario administrador, ya tiene habilitado el acceso a Omoda/Jaecoo).
**Objetivo:** crear a mano, desde la pantalla de Salesforce, una Oportunidad Omoda y una Jaecoo completas, siguiendo
el mismo proceso que ya usa un asesor para una Venta Nueva BMW/MINI, para poder grabarlas como evidencia y explicar
a negocio cómo funciona.

Esta guía es para usar Salesforce, no para programar. No hace falta saber nada técnico para seguirla.

---

## 0. Qué NO hacer durante esta prueba

- No usar Producción — solo Partial (`RedMotorsSandbox`).
- No usar datos de clientes reales — usar siempre los nombres y correos ficticios de esta guía.
- No enviar correos reales (no ejecutar botones de "Enviar Correo de Presupuesto" ni similares).
- No completar una reserva, un anticipo, una aprobación real ni una facturación real.
- No conectar con Softland ni ejecutar ninguna sincronización real.
- Si algo pide una acción que no está en esta guía, detente y pregunta antes de continuar.

---

## 1. Dónde entrar y qué botón pulsar

1. Entrar a Partial (`RedMotorsSandbox`) con el usuario administrador.
2. Ir al módulo **Oportunidades** (Opportunities).
3. Pulsar **Nuevo** (**New**).
4. Aparece una ventana para elegir el **Record Type**. Elegir **Omoda** (para la primera) o **Jaecoo** (para la
   segunda). Pulsar **Siguiente** (**Next**).

**Importante:** una vez elegido el Record Type y pulsado "Siguiente", ya no se puede cambiar desde este formulario
— queda fijo. Si te equivocas de marca, es más fácil cancelar y empezar de nuevo que corregirlo después.

---

## 2. Qué llenar, campo por campo

El formulario que aparece es el mismo que ya usa BMW/MINI para vender autos nuevos (Layout `Opportunity-Autos
V1.4`) — no es una pantalla especial ni distinta para Omoda/Jaecoo.

### A. Obligatorios para poder guardar

Si falta cualquiera de estos, Salesforce no deja guardar y muestra el campo en rojo.

| Campo (como se ve en pantalla) | Nombre técnico | Valor a usar | De dónde sale |
|---|---|---|---|
| Nombre de la Oportunidad | `Name` | Lo que escribas se **reemplaza automáticamente** al guardar — ver nota abajo | El sistema lo reescribe siempre |
| Campaña | `Campana__c` | Ver nota abajo — no existe todavía una campaña de PEKING | Se elige de una lista existente |
| Sucursal | `Sucursal__c` | Cualquiera de las sucursales existentes (ej. "Escazú") — no hay una sucursal específica de PEKING todavía | Se elige de una lista |
| Nombre del Producto | `NombreProducto__c` | Texto libre, ej. "Omoda C5 (prueba QA)" o "Jaecoo J7 (prueba QA)" | Lo escribe Claudia |
| Moneda | `CurrencyIsoCode` | `CRC` (colones) — ver nota de Pricebook en sección 3 | Se elige de una lista |
| Departamento | `Departamento__c` | "Ventas" | Se elige de una lista |
| Cuenta | `AccountId` | La cuenta de cliente ficticia ya creada (ver sección 6) | Se elige de una lista |
| Cuenta de Facturación | `Cuenta_de_Facturaci_n__c` | La misma cuenta ficticia | Se elige de una lista |
| Fecha de Cierre | `CloseDate` | Cualquier fecha futura, ej. 30 días adelante | Lo escribe Claudia |
| Etapa | `StageName` | **"Interesado"** | Se elige de una lista — ver nota importante abajo |
| Origen del Lead | `LeadSource` | "Página Web" (o cualquier valor genérico existente) | Se elige de una lista |
| Correo del Cliente | `CorreoElectronicoCliente__c` | Lo que escribas aquí **no se guarda** — ver nota abajo | El sistema lo reescribe siempre |
| Forma de Pago | `Forma_de_Pago__c` | "Contado" | Se elige de una lista |
| Entidad | `Entidad__c` | "No aplica" (ya que la forma de pago es Contado) | Se elige de una lista |
| Tipo de Cliente | `Tipo_de_Cliente__c` | "Conquista" | Se elige de una lista |

**Nota importante sobre la Etapa:** el valor que se usó en pruebas técnicas anteriores ("Prospecto") **no existe**
en la lista real que ve un asesor — esa lista solo tiene: Interesado, Oportunidad Calificada, Test Drive, Oferta,
Cerrada Ganada, Cerrada Perdida, Usado, Finalizado. La etapa correcta para una Oportunidad recién creada es
**"Interesado"**.

**Nota sobre Campaña:** hoy no existe ninguna campaña de marketing específica de PEKING/Omoda/Jaecoo en el sistema.
Tampoco fue posible crear una campaña QA nueva — el usuario administrador no tiene permiso de creación (Create)
sobre el objeto Campaña en absoluto (hallazgo confirmado, no es un límite de este formulario en particular). Se
revisaron las campañas activas existentes buscando una neutral, y se usó **"Prueba"** — nombre genérico, sin
asociación a ninguna marca — en lugar de reutilizar una campaña de otra marca (como "Motorrad Expo 2 Ruedas 2019",
usada al inicio y luego corregida). **No representa una campaña real de PEKING**, es solo un requisito técnico de
la pantalla.

**Corrección importante (confirmada al preparar la primera evidencia real, 2026-08-10):**

- **El Nombre de la Oportunidad no se queda con lo que se escribe.** Al guardar, el sistema lo reemplaza siempre
  (para cualquier marca, no solo PEKING) con el patrón `{Nombre de la Cuenta}-{Marca}-{Fecha}`, por ejemplo:
  `QA_PEKING_S3_EVIDENCIA - Cliente Omoda-Omoda-10/08/2026`. No es necesario escribir un nombre elaborado en este
  campo — el nombre final depende del nombre de la Cuenta elegida.
- **El Correo del Cliente tampoco se queda con lo que se escribe directamente en ese campo al crear el registro.**
  El sistema lo completa automáticamente copiándolo del campo "Correo electrónico empresarial" de la **Cuenta**
  seleccionada (no del texto que el asesor escriba en el formulario de la Oportunidad). **Para que este campo quede
  con un valor real: la Cuenta debe tener su propio correo cargado antes de crear la Oportunidad**, o hay que
  editar el campo manualmente en la Oportunidad ya guardada (sí se puede corregir después, editando el registro).
  Esto aplica igual para BMW/MINI — no es una diferencia de PEKING.
- **"Vendedor" (`Vendedor__c`) no es un nombre ni una persona — es una casilla de Sí/No** (verdadero/falso). Marca
  simplemente si la Oportunidad corresponde a un vendedor, no a quién.

### B. Recomendados para que la evidencia se vea realista

Salesforce permite guardar sin estos, pero un asesor normalmente los llena:

| Campo | Nombre técnico | Por qué llenarlo |
|---|---|---|
| Lista de Precios (Pricebook) | `Pricebook2Id` | Sin esto, después no se pueden agregar líneas de producto al presupuesto. Ver decisión en sección 3 |
| Observaciones | `Observaciones__c` | Contexto de la conversación con el cliente |
| Fecha posible de compra | `Fecha_Posible_Compra__c` | Fecha estimada de decisión del cliente |
| Contacto | `contacto__c` | Si ya existe un contacto asociado a la cuenta |
| Monto | `Amount` | Precio estimado del vehículo, aunque sea aproximado |
| Vendedor | `Vendedor__c` | Es una casilla de Sí/No (no un nombre) — marcarla si corresponde a un vendedor |

### C. Se completan solos (no los llena Claudia)

| Campo | Qué hace |
|---|---|
| Consecutivo de Oportunidad | Se genera automáticamente al guardar, con el patrón `Omoda-######` o `Jaecoo-######` |
| Dueño (Owner) | Queda asignado automáticamente al usuario que crea el registro |
| Probabilidad | Se calcula sola según la Etapa elegida (0% para "Interesado") |
| Tipo de Registro | Queda fijo con lo elegido en el paso 1, ya no editable desde este formulario |
| Fecha de creación / modificación | Las pone el sistema |

**Importante — esto NO se completa solo para Omoda/Jaecoo (a diferencia de BMW):** los campos **Director de
Ventas**, **Gerente de Sucursal** y **Jefe de Sucursal** (`DirectorVentas__c`, `GerenteSucursal__c`,
`JefeSucursal__c`) se autocompletan para BMW, MINI, Motorrad, Polaris, Kawasaki y Harley-Davidson según la
sucursal elegida — pero **el sistema todavía no tiene esa misma configuración para Omoda ni Jaecoo**. Al crear la
Oportunidad, estos tres campos van a quedar vacíos. No es un error de la prueba — es un pendiente real (ver
sección E). No hay nada que Claudia deba hacer al respecto; simplemente van a aparecer en blanco.

### D. Vacíos normales — corresponden a etapas posteriores

Estos campos se llenan más adelante en el proceso de venta, no al crear la Oportunidad:

| Campo/grupo | Para qué sirve | Cuándo se llena |
|---|---|---|
| VIN / Placa del vehículo | Identificar el vehículo físico exacto | Cuando se reserva un vehículo específico del inventario |
| Vehículos Reservados | Indicar que ya hay un vehículo apartado | Al reservar |
| Aprobador / Descuento Aprobado | Registrar quién aprobó un descuento | Cuando se solicita un descuento |
| Envío de formalización legal | Trámite legal de la venta | Cuando el negocio avanza a formalización |
| Entregado / Fecha de entrega | Confirmar que el vehículo se entregó | Al finalizar la venta |
| Facturado / Fecha de factura | Confirmar que se facturó | Al facturar |
| Sección Financiamiento (Plazo, Prima, Enganche, etc.) | Datos del crédito | Solo si la Forma de Pago es "Financiado" — no aplica a esta prueba (se usó "Contado") |
| Sección Pedido Especial | Para vehículos que se piden a fábrica fuera del inventario normal | Solo si aplica ese caso |
| Detalle de Extras / Regalías | Accesorios o beneficios negociados | Durante la negociación del presupuesto |

### E. Pendiente de datos oficiales de PEKING

| Campo/dato | Qué falta | Por qué está pendiente | De quién depende | ¿Hay autorización de placeholder? |
|---|---|---|---|---|
| Director de Ventas / Gerente de Sucursal / Jefe de Sucursal | No se autocompletan para Omoda/Jaecoo | El código que los llena (y los campos de la Sucursal donde se guardan los nombres) todavía no tiene una versión para Omoda/Jaecoo — solo existe para las marcas ya establecidas | Diego (perfiles/jerarquía) | No — no se debe inventar una jerarquía falsa; se documenta el campo vacío, tal como ya se decidió para los procesos de aprobación de descuento |
| Empresa (`Empresa_Operadora__c`) | Este campo, que conecta la Oportunidad con la empresa PEKING, **no aparece en esta pantalla de creación** | La pantalla (Layout) que ya usa Ventas Nuevas nunca incluyó este campo — no es algo que falte solo para PEKING, ninguna marca lo llena desde este formulario | Decisión de negocio/Diego: ¿se agrega al formulario o se llena por otro medio? | No aplica — no es un dato, es una pregunta de diseño de pantalla |
| Lista de Precios por defecto (PEKING Local vs. PEKING Dólares) | No hay una regla que diga cuál usar cuando el asesor no elige ninguna | Pendiente definición comercial (ya documentado en rondas anteriores) | Ventas / negocio | Sí — para esta prueba se puede elegir cualquiera de los dos y aclarar que es una selección de prueba, no la regla oficial |
| Campaña de marketing PEKING | No existe ninguna campaña específica de Omoda/Jaecoo | Todavía no se ha creado una campaña oficial para el lanzamiento | Marketing/negocio | Sí — se usa cualquier campaña activa existente solo como requisito técnico de pantalla, aclarando que no es la real |
| Sucursal específica de venta PEKING | No existe una sucursal marcada como punto de venta Omoda/Jaecoo | Pendiente de decisión comercial (¿en qué sucursales se venderá?) | Ventas / negocio | Sí — se usa una sucursal existente como prueba |

---

## 3. Empresa / Marca / Pricebook / Cuenta / Moneda / Sucursal / Asesor

| Dato | ¿Se elige manualmente o se calcula solo? | Qué hacer para Omoda/Jaecoo |
|---|---|---|
| **Record Type (Marca)** | Manual, en el paso "Nuevo → Siguiente" | Elegir Omoda o Jaecoo según corresponda |
| **Empresa** (`Empresa_Operadora__c`) | Ninguno de los dos — no aparece en este formulario | No se llena en esta prueba; queda pendiente de decisión de negocio (ver sección 2.E) |
| **Cuenta** | Manual | Usar la cuenta ficticia ya preparada (sección 6) |
| **Pricebook** | Manual (el campo existe y se puede editar, pero nada lo llena solo) | **No existe todavía una decisión oficial entre "PEKING Local" y "PEKING Dólares".** Para esta prueba concreta, se puede elegir uno de los dos — se recomienda "PEKING Local" (colones) por ser el más simple de explicar — mientras se aclara en la evidencia que es una **selección de prueba, no un valor por defecto oficial** |
| **Moneda** | Manual | Debe coincidir con el Pricebook elegido: `CRC` si se usa "PEKING Local", `USD` si se usa "PEKING Dólares" |
| **Sucursal** | Manual | No existe una sucursal específica de PEKING; se usa una existente (ej. "Escazú") como prueba |
| **Asesor / Dueño (Owner)** | Automático — el sistema asigna al usuario que crea el registro | No requiere acción; se puede reasignar manualmente después si se necesita |

---

## 4. Validaciones que pueden aparecer al crear/guardar

Se hizo una prueba técnica controlada (sin dejar datos persistentes) creando una Oportunidad Omoda y una Jaecoo con
exactamente los campos obligatorios de la tabla A, en la Etapa "Interesado": **ninguna regla de validación bloqueó
el guardado, en ninguna de las dos marcas.**

Las reglas de validación relevantes para Oportunidad que sí existen en el sistema se activan más adelante en el
proceso, no al crear el registro:

| Regla | Cuándo se activa | Qué exige | ¿Ya contempla a Omoda/Jaecoo? | Qué debe hacer Claudia para no toparse con un error artificial |
|---|---|---|---|---|
| Debe registrarse una actividad (`MusthaveActivity`) | Al pasar a Test Drive, Oferta, Usado, Cerrada Ganada o Cerrada Perdida | Que exista al menos una actividad relacionada | Sí, desde el cambio hecho hoy mismo (ver `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md`) | No avanzar la Oportunidad más allá de "Interesado"/"Oportunidad Calificada" durante esta prueba, o registrar una actividad antes de avanzar |
| Gustos y aficiones obligatorio | Al pasar a "Oferta" | Que la Cuenta tenga el campo "Gustos y aficiones" lleno | Sí (ya corregido y probado, B9-1) | No aplica si la prueba se queda en "Interesado" |
| Cambiar a Finalizado — Descuento / Formalización / Vehículo | Al pasar a "Finalizado" | Descuento aprobado / formalización completa / vehículo reservado | Sí | No aplica si la prueba se queda en "Interesado" |

**Recomendación:** para esta ronda de evidencia, dejar la Oportunidad en la etapa **"Interesado"** (la etapa con la
que se crea) — así no se activa ninguna de estas reglas y no hace falta preparar datos adicionales de actividad,
descuento o reserva.

---

## 5. Comparación Omoda/Jaecoo vs. BMW/MINI

| Campo/proceso | BMW/MINI | Omoda/Jaecoo | ¿Mismo comportamiento? | Observación |
|---|---|---|---|---|
| Pantalla de creación (Layout) | `Opportunity-Autos V1.4` | La misma | Sí | Es exactamente la misma pantalla, sin ninguna adaptación especial |
| Campos obligatorios | Los de la tabla A | Los mismos | Sí | Ninguno cambia por marca |
| Etapa inicial | "Interesado" | "Interesado" | Sí | Sin diferencia |
| Validaciones al crear | Ninguna bloquea | Ninguna bloquea | Sí | Confirmado con prueba técnica |
| Director/Gerente/Jefe de Sucursal | Se completan solos según la sucursal | **Quedan vacíos** | **No** | El sistema no tiene la configuración de jerarquía para Omoda/Jaecoo todavía (pendiente de Diego) |
| Campo Empresa en el formulario | No aparece para nadie | No aparece para nadie | Sí | No es una diferencia de PEKING — ninguna marca lo llena desde este formulario |
| Lista de Precios (Pricebook) | Tiene Pricebooks Bavarian/Otobai ya en uso normal | Tiene "PEKING Local"/"PEKING Dólares" creados, pero sin regla de cuál usar por defecto | No completamente | Para BMW la elección ya es habitual en el día a día; para PEKING todavía no hay una convención definida |
| "Vehículo Nuevo" (indicador interno) | Ya reconocía a BMW/MINI | Ahora también reconoce a Omoda/Jaecoo (cambio de hoy) | Sí, ya emparejado | Ver `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md` sección 6 |

**Conclusión para negocio:** *"Omoda y Jaecoo se crean siguiendo exactamente el mismo proceso de una Venta Nueva
BMW/MINI — misma pantalla, mismos campos obligatorios, mismas validaciones. La única diferencia real es que la
asignación automática de Director/Gerente/Jefe de Sucursal todavía no está configurada para estas dos marcas, y
que la Lista de Precios no tiene todavía una regla de cuál usar por defecto — ambos son pendientes de negocio/Diego,
no defectos de la pantalla ni del proceso."*

---

## 6. Datos preparados para la evidencia

Se crearon únicamente los siguientes **registros auxiliares** (necesarios para que el formulario tenga qué
mostrar en los campos de Cuenta) — **no se crearon las Oportunidades**, esas las crea Claudia manualmente
siguiendo esta guía:

| Registro | Objeto | Id | Propósito |
|---|---|---|---|
| `QA_PEKING_S3_EVIDENCIA - Cliente Omoda` | Account | `001AK00000PQ172YAD` | Cuenta para la Oportunidad Omoda |
| `QA_PEKING_S3_EVIDENCIA - Cliente Jaecoo` | Account | `001AK00000PQ173YAD` | Cuenta para la Oportunidad Jaecoo |
| `QA_PEKING_S3_EVIDENCIA - Cliente BMW` | Account | `001AK00000PQ174YAD` | Cuenta para la Oportunidad BMW de comparación |

Todas ficticias, sin datos de clientes reales.

### Tabla de valores — Oportunidad 1: `QA_PEKING_S3_EVIDENCIA - Omoda`

| Campo | Valor a ingresar | Por qué |
|---|---|---|
| Record Type | Omoda | Marca a probar |
| Nombre | `QA_PEKING_S3_EVIDENCIA - Omoda` | Prefijo estándar para identificarla como QA |
| Cuenta | `QA_PEKING_S3_EVIDENCIA - Cliente Omoda` | Ya preparada |
| Cuenta de Facturación | `QA_PEKING_S3_EVIDENCIA - Cliente Omoda` | Misma cuenta |
| Campaña | Cualquier campaña activa existente | Ver nota de la sección 2 |
| Sucursal | Escazú | Placeholder, sin sucursal oficial PEKING |
| Nombre del Producto | Omoda C5 (prueba QA) | Ejemplo de modelo, ficticio |
| Moneda | CRC | Acompaña al Pricebook "PEKING Local" |
| Departamento | Ventas | — |
| Fecha de Cierre | 30 días a partir de hoy | Cualquier fecha futura razonable |
| Etapa | Interesado | Etapa inicial correcta (no "Prospecto") |
| Origen del Lead | Página Web | Valor genérico |
| Correo del Cliente | qa.peking.evidencia.omoda@example.com | Ficticio, dominio de prueba |
| Forma de Pago | Contado | Evita la sección de Financiamiento |
| Entidad | No aplica | Coherente con "Contado" |
| Tipo de Cliente | Conquista | — |
| Lista de Precios (Pricebook) | PEKING Local | Selección QA, aclarar que no es el default oficial |

### Tabla de valores — Oportunidad 2: `QA_PEKING_S3_EVIDENCIA - Jaecoo`

Igual que la anterior, cambiando:

| Campo | Valor a ingresar |
|---|---|
| Record Type | Jaecoo |
| Nombre | `QA_PEKING_S3_EVIDENCIA - Jaecoo` |
| Cuenta / Cuenta de Facturación | `QA_PEKING_S3_EVIDENCIA - Cliente Jaecoo` |
| Nombre del Producto | Jaecoo J7 (prueba QA) |
| Correo del Cliente | qa.peking.evidencia.jaecoo@example.com |

El resto de campos, igual que la tabla de Omoda.

### Tabla de valores — Oportunidad 3: `QA_PEKING_S3_EVIDENCIA - BMW` (comparación/regresión)

Igual que la de Omoda, cambiando:

| Campo | Valor a ingresar |
|---|---|
| Record Type | BMW |
| Nombre | `QA_PEKING_S3_EVIDENCIA - BMW` |
| Cuenta / Cuenta de Facturación | `QA_PEKING_S3_EVIDENCIA - Cliente BMW` |
| Nombre del Producto | BMW Serie 3 (prueba QA) |
| Correo del Cliente | qa.peking.evidencia.bmw@example.com |
| Lista de Precios (Pricebook) | La que BMW usa normalmente en Partial (Bavarian Local o equivalente) |

---

## 7. Qué comprobar después de guardar

Para cada una de las 3 Oportunidades, después de guardar:

1. **Confirmar que se guardó sin errores** — no debe aparecer ningún mensaje rojo.
2. **Revisar el número consecutivo**: debe verse algo como "Omoda-XXXXXX" o "Jaecoo-XXXXXX" en el campo
   correspondiente — confirma que el sistema ya identifica correctamente la marca.
3. **Revisar Director de Ventas / Gerente de Sucursal / Jefe de Sucursal**: en Omoda/Jaecoo deben verse **vacíos**
   (esto es lo esperado, no un error — ver sección 2.E). En BMW deben verse **llenos**.
4. **Revisar la Lista de Precios**: debe mostrar la que se eligió (PEKING Local/Dólares para Omoda/Jaecoo, la de
   BMW para la de comparación).
5. **Revisar que las tres pantallas se vean sin errores de componente** (sin recuadros rojos ni mensajes de "algo
   salió mal") al abrir el registro.

---

## 8. Qué NO ejecutar durante esta prueba

- No cambiar la Etapa más allá de "Interesado" u "Oportunidad Calificada".
- No usar el botón de enviar correo de presupuesto.
- No crear un Presupuesto (Quote) todavía, salvo que se pida explícitamente en una evidencia posterior.
- No reservar vehículo ni asignar VIN.
- No solicitar ni aprobar descuento.
- No marcar como entregado ni facturado.

---

## Resumen para negocio

Omoda y Jaecoo se crean con el mismo formulario, los mismos campos obligatorios y las mismas validaciones que ya
usa cualquier Venta Nueva BMW/MINI — no hay una pantalla especial ni un proceso distinto. Las únicas diferencias
reales hoy son: (1) la asignación automática de responsables de aprobación por sucursal todavía no existe para
estas dos marcas, y (2) no hay una Lista de Precios por defecto definida entre "PEKING Local" y "PEKING Dólares".
Ninguna de las dos es un defecto de la pantalla — son decisiones/trabajo pendientes de Diego y de negocio.
