# Evidencias para negocio — Sprint 3 PEKING (Omoda / Jaecoo)

**Fecha:** 10 de agosto de 2026 (actualizado la misma fecha, tras la autorización de Luis para habilitar acceso)
**Proyecto:** RedMotors — Empresa / Marcas Chinas / PEKING
**Org de pruebas:** ambiente de pruebas interno de Salesforce (Partial), nunca el sistema de producción real.

Este documento resume, en lenguaje de negocio, qué se probó en esta ronda de trabajo (10 de agosto), aprovechando
que se autorizó crear datos de ejemplo para pruebas (QA) y, más tarde el mismo día, que Luis autorizó habilitar el
acceso técnico necesario para crear registros Omoda/Jaecoo reales. No repite auditorías generales ya hechas en
rondas anteriores; se apoya en ellas.

---

## 0. Desbloqueo de acceso — qué cambió hoy

Hasta la mañana del 10 de agosto, **ningún usuario del sistema, ni siquiera el administrador, podía crear un
registro marcado como Omoda o Jaecoo** (ni Oportunidad ni Lead). Luis autorizó expresamente habilitar ese acceso
para el usuario administrador actual.

**Qué se hizo, en términos simples:** se creó un permiso adicional, pequeño y específico, que solo agrega "puede
ver y usar los tipos de registro Omoda y Jaecoo" para Lead y Oportunidad. Ese permiso se le asignó únicamente al
usuario administrador actual (Claudia Pérez). **No se tocó nada más:** no se modificaron pantallas, no se tocó la
jerarquía de aprobadores, no se tocó ningún otro permiso de ningún otro usuario. Se evaluó agregar un segundo
usuario de prueba, pero no existe hoy ningún usuario activo apto para eso (los únicos candidatos son cuentas de
sitio web sin acceso a Oportunidades/Leads, o una cuenta con una licencia limitada que tampoco lo permite) — se
continuó solo con el administrador, tal como Luis autorizó como alternativa válida.

**Resultado confirmado:** con ese permiso activo, sí se pudieron crear registros reales Omoda y Jaecoo (Lead y
Oportunidad), algo que era imposible hasta hoy.

---

## 1. Pantallas / Interfaz de usuario (UI)

**Qué se revisó:** las pantallas y layouts (formularios) que usa la Oportunidad de venta y el Presupuesto (Quote)
en Salesforce.

**Los 10 elementos que ya funcionan sin cambio — estado real tras el desbloqueo:**

| # | Elemento | Objeto | Dónde aplica | ¿Se probó hoy con un registro real Omoda/Jaecoo? |
|---|---|---|---|---|
| 1 | `Opportunity-Autos V1.3` | Oportunidad | Asignado a Omoda y Jaecoo (36 perfiles cada uno) | No probado con este layout específico — el administrador no está entre esos 36 perfiles; requiere el perfil correspondiente |
| 2 | `Opportunity-Autos V1.3 - Inventario` | Oportunidad | Asignado a Omoda y Jaecoo (1 perfil cada uno) | No probado — mismo motivo, perfil distinto al administrador |
| 3 | `Opportunity-Autos V1.4` | Oportunidad | Asignado a Omoda y Jaecoo (5 perfiles cada uno, incluye al administrador) | **Sí — probado técnicamente.** Se creó una Oportunidad Omoda y una Jaecoo reales; el sistema confirmó que cargan sus datos y secciones sin ningún error, con las mismas 7 secciones que ya usa BMW (Datos generales, Test Drive, Financiamiento, Detalles del Negocio, Vehículo Actual, Información de vehículos nuevos, Pedido Especial). **Falta la captura visual en el navegador** — ver lista de capturas pendientes |
| 4 | `Opportunity-Autos V1.4 Sin Botones` | Oportunidad | Asignado a Omoda y Jaecoo (1 perfil cada uno) | No probado — perfil distinto al administrador |
| 5 | `Opportunity-Opportunity Layout` | Oportunidad | Asignado a Omoda y Jaecoo (117 perfiles cada uno) | No probado directamente con este layout — el administrador puede no estar entre esos perfiles; pendiente de confirmar cuál layout ve exactamente cada perfil |
| 6 | `Opportunity-Vehiculos Nuevos V1.1` | Oportunidad | Asignado a Omoda y Jaecoo (1 perfil cada uno) | No probado — perfil distinto al administrador |
| 7 | Página `Opportunity_Record_Page1` | Oportunidad | Activación general (todas las marcas, sin distinción) | Ya no depende del bloqueo de Record Type (se resolvió); falta la confirmación visual de carga sin errores — ver lista de capturas |
| 8 | Página `Quote_Record_Page` | Presupuesto | Activación general | Se creó un Presupuesto Omoda y uno Jaecoo reales, ligados a sus Oportunidades; el sistema confirmó que el registro carga sus datos sin error (6 secciones: Datos del presupuesto, Información de cliente, Totales, Preparado para, Dirección, Información del sistema). Falta la confirmación visual — ver lista de capturas |
| 9 | Página `Quote_Record_Page2` | Presupuesto | Activación general | Igual que el anterior — falta confirmación visual |
| 10 | Botón "Duplicar Partidas de Presupuesto" | Presupuesto | Disponible para todas las marcas, según el análisis de la pantalla | **Diagnóstico cerrado.** Se confirmó que este botón está agregado solo a una pantalla que ningún asesor de ventas activo usa hoy — la pantalla real que usa cualquier venta de auto nuevo (BMW incluido) tampoco lo tiene. No es una diferencia de PEKING: BMW y Omoda/Jaecoo se comportan exactamente igual. No requiere corrección ni decisión de negocio |

**Lo que el desbloqueo permitió probar, y lo que todavía falta:** ya no existe el bloqueo de fondo (crear el
registro). Lo que queda pendiente para los elementos marcados "No probado" es exclusivamente una cuestión de
**perfil**: varios de estos 10 elementos están asignados a perfiles de negocio específicos (asesores de ventas,
por ejemplo) que no son el administrador, y no existe hoy un segundo usuario de prueba seguro con esos perfiles
para verificarlos con ese perfil exacto. Esto responde directamente a la pregunta de Diego ("los 10 que dice que ya
están, ¿dónde son, qué objetos y para qué Record Types?"): los 10 son 6 formularios y 3 páginas de Oportunidad y
Presupuesto más 1 botón, ya asignados a Omoda y Jaecoo desde antes de este proyecto; 2 de ellos (el formulario
`Opportunity-Autos V1.4` y las páginas de Presupuesto) sí se pudieron confirmar técnicamente hoy porque el
administrador tiene acceso; los demás requieren un perfil de negocio distinto al administrador para confirmarse con
el mismo nivel de certeza.

**Actualización (10 de agosto, tarde) — nueva definición de Luis: "Omoda y Jaecoo deben reutilizar la configuración
equivalente de Ventas Nuevas".** Se aplicó ese criterio a los 63 pendientes, verificando técnicamente qué pantallas
usa hoy un asesor de "Ventas Nuevas" (los perfiles que ya venden BMW/MINI/etc. nuevos) para cada objeto. Resultado:
**9 de los 63 quedan resueltos**; **54 siguen pendientes**, con el motivo real identificado (no genérico). Detalle
técnico completo en `RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md`.

| Grupo | Cantidad | Qué significa | Ejemplo concreto |
|---|---:|---|---|
| **Resuelto por la nueva definición — sin desarrollo pendiente** | **8** (2 pantallas de Cuenta, 4 de Producto, 1 de Presupuesto, 1 de Orden de Trabajo) | Estas pantallas no distinguen por marca — se asignan solo por el perfil del asesor. En cuanto exista el perfil de Omoda/Jaecoo (que Diego ya está preparando), verán automáticamente las mismas pantallas que ya usa BMW, sin que nuestro equipo tenga que tocar nada más | La pantalla de Cuenta Empresarial que ya usa un asesor BMW es la misma que verá un asesor Omoda en cuanto tenga su perfil asignado |
| **`Quote_Record_Page_VN` — resuelta con un ajuste ejecutado hoy** | **1** página de Presupuesto | Ver explicación completa abajo | La pestaña "Agregar extras" del Presupuesto ya se ve igual para Omoda/Jaecoo que para BMW |
| Requiere decisión de asignación (Taller/Postventa) | 14 pantallas | Son para el flujo de taller/mecánicos, no de venta — un proceso distinto, sin definir todavía si Omoda/Jaecoo tendrán taller propio | Pantalla de Orden de Trabajo para mecánicos |
| Requiere decisión de asignación (otros segmentos) | 5 pantallas | Son de motos, mostrador u otros segmentos que no corresponden al patrón de venta de autos nuevos que Omoda/Jaecoo replican | Pantalla de Oportunidad de motocicletas |
| Sin ningún uso demostrado hoy (probablemente no se necesitan, sin descartar) | 32 elementos | Ningún asesor activo las usa actualmente, ni para Ventas Nuevas ni para ningún otro proceso — son variantes antiguas sin actividad | Páginas numeradas de respaldo sin asignar a nadie |
| Requiere definición de negocio (plantilla/proceso propio) | 3 botones de acción rápida | Necesitan una plantilla de correo o presupuesto propia de PEKING que negocio debe aprobar — no se resuelve solo con el perfil | "Enviar Correo de Presupuesto" necesita remitente y plantilla propios de PEKING |
| No aplicable (categoría aparte, no cuenta dentro de los 63) | 4 páginas | Exclusivas del proceso de vehículos usados; Luis ya confirmó que PEKING no vende usados en esta etapa | Páginas de "Inventario de Usados" |

**Nota de conteo:** los 63 se reparten así: 8 resueltos + 1 `Quote_Record_Page_VN` (resuelta) + 14 Taller/Postventa
+ 5 otros segmentos + 32 sin uso demostrado + 3 botones = 63. Las 4 páginas "No aplicable" y la página
`Opportunity_Record_Page_VN` de abajo **no forman parte de los 63** — son categorías separadas desde la auditoría
original (`NO_APLICA` y `DRIFT_REQUIERE_CONCILIACION`, cada una su propio grupo dentro de los 78 totales).

**`Quote_Record_Page_VN` — qué se hizo y qué cambió:**

- **Antes:** la pantalla de Presupuesto ya reconocía correctamente como "vehículo nuevo" a las marcas existentes
  (BMW, MINI, Motorrad, Polaris, Kawasaki, Indian), pero no a Omoda ni Jaecoo — aunque ambas también venden
  vehículos nuevos. Por eso dos partes de esa pantalla (la pestaña "Agregar extras" y la sincronización interna de
  vehículo nuevo) no se mostraban para Omoda/Jaecoo.
- **Cambio:** se incorporaron Omoda y Jaecoo a esa misma identificación de "vehículo nuevo", agregándolas al
  listado de marcas que ya tenían las demás. No se tocó la pantalla en sí, ni ninguna otra configuración — solo se
  amplió el listado de marcas de ese único indicador.
- **Resultado:** las funciones de Ventas Nuevas que dependen de ese indicador ya quedan disponibles también para
  Omoda y Jaecoo, igual que para BMW/MINI. Se confirmó con datos de prueba reales: el indicador ya marca "sí" para
  Omoda y Jaecoo, sin cambiar el resultado para las marcas existentes (regresión verificada). También se confirmó,
  con una prueba dirigida y sin persistir datos, que un control de calidad relacionado (exigir una actividad
  registrada antes de avanzar la venta) ahora también aplica correctamente a Omoda/Jaecoo, igual que a BMW.
- **Efecto adicional a tener en cuenta:** ese mismo indicador también decide si un Presupuesto lleva un impuesto
  adicional del 13% o no. Con este cambio, los Presupuestos de Omoda/Jaecoo dejan de llevar ese impuesto adicional,
  igual que ya ocurre con BMW/MINI — es el mismo trato, no un descuento especial inventado para PEKING.

**Caso especial — `Opportunity_Record_Page_VN` (no es uno de los 63; es su propia categoría desde la auditoría
original):** se analizó con el nuevo criterio. Para agregar Omoda/Jaecoo con la misma configuración que ya usa BMW
en esta página, hace falta escribir el nombre exacto del perfil de destino — y ese es justo el nombre que está en
proceso de cambio (mismo hallazgo de renombre). Luis confirmó que él tampoco sabe si ese cambio corresponde al
trabajo paralelo de Diego. **Queda `PENDIENTE_CONFIRMACION_DIEGO_RENOMBRE_PERFILES`** — no se modificó ni se
revirtió nada por suposición, y este punto no detuvo el resto del trabajo (los 8 elementos resueltos arriba no
dependen de esto).

---

## 2. Reglas de validación (Validation Rules)

Se modificaron 4 reglas de la Oportunidad para que reconozcan Omoda y Jaecoo, no solo BMW/MINI y otras marcas
existentes. Las 4 ya se probaron a fondo en una ronda anterior (15 escenarios en la regla más compleja, con
resultado 15 de 15 correctos). No se repitieron esas pruebas en esta ronda porque no hay ningún dato nuevo que
cambie el resultado.

| Regla | Qué hacía antes | Qué se agregó para Omoda/Jaecoo | Ejemplo | Resultado |
|---|---|---|---|---|
| Cambiar a Finalizado — Descuento | Exigía que un descuento estuviera aprobado antes de cerrar la venta, solo para las marcas existentes | Ahora también exige la aprobación del descuento para Omoda y Jaecoo | Un asesor de Omoda no puede marcar la venta como "Finalizado" si el descuento sigue pendiente de aprobar | Probado y correcto |
| Cambiar a Finalizado — Formalización | Exigía que el trámite de formalización estuviera completo, solo para marcas existentes | Ahora también aplica a Omoda y Jaecoo | Una venta Jaecoo no se puede cerrar si falta completar la formalización | Probado y correcto |
| Cambiar Oportunidad a Finalizado (Vehículo) | Exigía que el vehículo estuviera reservado antes de cerrar, solo para marcas existentes | Ahora también aplica a Omoda y Jaecoo | Una venta Omoda no se puede cerrar sin el vehículo reservado | Probado a nivel de regla (sin conectar con el proceso real de reservas, que necesita datos oficiales de inventario) |
| Campo "Gustos y aficiones" obligatorio | Exigía llenar el campo antes de pasar la Oportunidad a "Oferta", solo para marcas existentes | Se amplió a Omoda y Jaecoo — **y en el camino se encontró y corrigió un defecto** | Ver detalle abajo | Probado y correcto, 15/15 |

**Caso especial — Campo "Gustos y aficiones" obligatorio:**
- **Defecto encontrado:** la regla, tal como estaba escrita, dejaba pasar una venta a la etapa "Oferta" aunque el
  campo estuviera realmente vacío, siempre que el sistema detectara un valor especial interno ("nulo técnico") en
  lugar de un vacío normal. En la práctica esto significaba que el control de calidad de datos no siempre se
  aplicaba.
- **Impacto también en legacy:** el defecto no era exclusivo de Omoda/Jaecoo — afectaba de la misma forma a BMW,
  MINI y todas las demás marcas ya existentes. Es decir, se corrigió un problema que ya existía antes de este
  proyecto, no uno introducido por él.
- **Corrección:** se ajustó la fórmula para que reconozca correctamente cualquier forma de "vacío", sin tocar nada
  más de la regla (ni las marcas que aplica, ni el mensaje, ni las demás excepciones).
- **Resultado final:** 15 de 15 pruebas aprobadas, cubriendo las 7 marcas relevantes (Omoda, Jaecoo, BMW, MINI,
  Kawasaki, Motorrad, Polaris) tanto con el campo vacío (debe bloquear) como con el campo lleno (debe permitir).
- **"Por actualizar" sigue permitido:** el valor especial "Por actualizar" (que el equipo de ventas usa cuando aún
  no tiene el dato pero necesita avanzar) sigue funcionando exactamente igual que antes — no se retiró ni se
  restringió.

---

## 3. Procesos de aprobación (Approval Processes)

**Qué funciona igual para todas las marcas (común):** 8 procesos de aprobación de descuento y 2 procesos de
aprobación de centro de costo (uno para Presupuesto, uno para Orden de Trabajo) están escritos de forma neutral —
no distinguen por marca ni tipo de vehículo, así que Omoda y Jaecoo ya quedan cubiertos sin cambios.

**Actualización (10 de agosto, tarde) — definición confirmada de Luis:** los 8 procesos de descuento de Omoda y
Jaecoo deben usar exactamente la misma jerarquía de aprobadores (jefe, gerente, director) que Diego ya está
armando para toda la empresa — no una jerarquía especial para PEKING. Esto cierra la duda funcional: ya no falta
decidir "qué jerarquía usar", solo falta que Diego termine de construirla en el ambiente de pruebas.

| Aspecto | Estado |
|---|---|
| Qué jerarquía deben usar los 8 procesos de descuento | **Ya definido** — la misma de Diego, sin desarrollo especial para PEKING |
| Trabajo técnico adicional necesario para PEKING | **Ninguno** — los 8 procesos ya son neutrales a la marca |
| Prueba final de envío/aprobación real | Pendiente únicamente de que Diego termine de construir esa jerarquía en el ambiente de pruebas |

**Qué se probó con datos de prueba (placeholder), en una ronda anterior el mismo día:**
- **Centro de costo:** se creó un centro de costo de prueba (identificado claramente como "Test"), modelado igual
  que los reales, y un presupuesto y una orden de trabajo de prueba enlazados a él. El sistema aceptó correctamente
  la información y quedó listo para entrar al proceso de aprobación (el proceso llega correctamente al estado
  "Pendiente de aprobación").
- **Descuentos:** se intentó simular el envío a aprobación con los mismos datos que usaría un caso real. Se
  descubrió que el sistema **recalcula automáticamente** quién debe aprobar (jefe, gerente, director) según la
  estructura de mando del vendedor dueño de la venta — sin importar qué se intente forzar manualmente. Se
  comprobó que este comportamiento es igual para Omoda que para BMW, así que **no es un problema específico de
  PEKING**: es exactamente la estructura de mando que Diego está armando. No se fabricó una jerarquía falsa para
  evitar este hallazgo.
- **Garantía:** no se tocó — está fuera de este lote a propósito, porque todavía falta que negocio defina la regla
  y quién aprueba las garantías de Omoda/Jaecoo. No se decidió eso por nuestra cuenta. No llegó ninguna respuesta
  nueva sobre Garantía en esta ronda.

No se repitió esta prueba en la ronda de hoy después del desbloqueo porque no hay ningún dato nuevo (Omoda ya
había sido probado con el mecanismo anterior de PEKING vía BMW) que cambie el resultado.

**Qué requiere negocio:**
- La aprobación *real* (no solo la entrada al proceso) de centro de costo necesita un aprobador y un centro de
  costo oficiales, no de prueba.
- Los 8 procesos de descuento necesitan que exista la estructura de mando real de aprobadores.
- Garantía necesita que negocio defina la regla y el aprobador.

---

## 4. Softland (integración de catálogos e inventario)

- **Qué reconoce el sistema hoy para PEKING:** el código de empresa `RMPEKING` ya está reconocido en las 13 clases
  técnicas que traen los 6 catálogos desde Softland (el sistema externo de inventario/facturación) y en los
  procesos automáticos (schedulers) asociados — verificado documentalmente, sin cambios nuevos en esta ronda.
- **Qué catálogos se probaron:** los 6 catálogos ya cuentan con pruebas técnicas automatizadas (36 de 36 exitosas)
  usando datos simulados (mocks), no una conexión real a Softland — nunca se ejecutó un batch real ni se llamó al
  sistema externo real.
- **Qué placeholder se usó (bodega):** en una ronda anterior el mismo día se creó una bodega de prueba llamada
  "Bodega1Peking" con un código propio (`PK01`) que no coincide con ningún código ya usado por Bavarian u Otobai,
  modelada con los mismos campos que las bodegas reales de BMW. Ya fue eliminada tras confirmar el resultado (ver
  sección 5).
- **Resultado:** la funcionalidad local (que el sistema acepte y muestre una bodega PEKING) se validó sin problema
  con el placeholder. Sigue aparte, sin resolver, la pregunta de negocio: ¿cuál será la convención oficial de
  código para que una bodega de PEKING nunca choque por accidente con una de Bavarian?

---

## 5. Datos QA — listado de registros y su destino

### Ronda 1 (10 de agosto, antes del desbloqueo) — todos ya cerrados

Todos con prefijo `QA_PEKING_S3_20260810`. Ver `RESULTADO_QA_PLACEHOLDERS_SPRINT3_20260810.md` para el detalle
técnico completo.

| Placeholder | Propósito | Estado |
|---|---|---|
| Cuenta de prueba "BMW Regresión" | Contenedor aislado para la Oportunidad de prueba | Eliminado |
| Oportunidad de prueba BMW con referencia a PEKING | Probar la conexión Oportunidad↔Empresa PEKING sin el permiso bloqueado | Eliminado |
| Centro de costo de prueba | Probar la regla de centro de costo obligatorio y la entrada al proceso de aprobación | Eliminado |
| Presupuesto (Quote) de prueba | Probar la regla de centro de costo obligatorio, casos positivo y negativo | Eliminado |
| Orden de Trabajo de prueba `0WOAK000005j4Kj4AI` | Probar la misma regla en una Orden de Trabajo | **Eliminado (10 de agosto, con autorización explícita de Luis).** Se activó temporalmente el permiso específico que lo bloqueaba, se eliminó el registro, se confirmó por consulta que ya no existe, y el permiso se devolvió exactamente a su valor original |
| Bodega de prueba "Bodega1Peking" | Confirmar que una bodega PEKING con código propio no choca con las de Bavarian/Otobai | Eliminado |

**Diagnóstico y cierre del Work Order:** no era un permiso de objeto estándar de Salesforce — era un campo de
configuración propio de la aplicación (`CanDeleteWO__c`, en el registro del usuario) que el sistema revisa antes de
permitir borrar cualquier Orden de Trabajo. Se activó temporalmente solo para el usuario administrador, se eliminó
el registro, se confirmó por consulta directa que ya no existe, y el campo se restauró exactamente a su valor
original (`false`). No se modificó ningún otro campo, usuario ni configuración. Detalle completo en
`RESULTADO_QA_PLACEHOLDERS_SPRINT3_20260810.md` sección 7.6.

### Ronda 2 (10 de agosto, después del desbloqueo) — quedan temporalmente para que Claudia grabe evidencia

Todos con prefijo `QA_PEKING_S3_RT_20260810`. Datos ficticios, ninguno con información real de cliente.

| Registro | Objeto | Motivo por el que permanece |
|---|---|---|
| Lead Omoda | Lead | Para grabar la evidencia visual de que un Lead Omoda ahora se puede crear y abrir |
| Lead Jaecoo | Lead | Igual que el anterior, para Jaecoo |
| Cuenta + Oportunidad Omoda | Account + Opportunity | Para grabar el Video 1 (Layout `Opportunity-Autos V1.4`) y el Video 2 (página `Opportunity_Record_Page1`) con un registro Omoda real |
| Cuenta + Oportunidad Jaecoo | Account + Opportunity | Igual que el anterior, para Jaecoo |
| Cuenta + Oportunidad BMW de regresión | Account + Opportunity | Para comparar contra Omoda/Jaecoo y confirmar que no hay regresión en marcas existentes |
| Presupuesto (Quote) Omoda, Jaecoo y BMW | Quote | Para grabar el Video 2 (páginas de Presupuesto) y el Video 3 (botón de duplicar partidas), una vez confirmado en el navegador si el botón aparece o no |

Ninguno de estos registros tiene emails enviados, conexiones a otros sistemas, reservas, pedidos, facturas ni
aprobaciones reales — confirmado en cada inserción (0 correos, 0 conexiones externas, 0 tareas pendientes). Se
eliminarán todos apenas Claudia confirme que ya grabó lo que necesitaba, o si Diego/Luis indican que ya no se
necesitan.

---

## Nota final

Este documento no declara Sprint 3 terminado. Su propósito es dejar evidencia clara, en lenguaje de negocio, de lo
que ya se probó y de lo que todavía depende de una decisión, un permiso o una grabación manual pendiente.
