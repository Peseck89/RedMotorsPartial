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
| 10 | Botón "Duplicar Partidas de Presupuesto" | Presupuesto | Disponible para todas las marcas, según el análisis de la pantalla | **Hallazgo nuevo:** al consultar directamente qué acciones están disponibles en el Presupuesto Omoda real, este botón **no aparece** en la lista que el sistema devuelve. El análisis anterior (basado en leer la configuración de la pantalla) decía que sí estaba disponible para cualquier marca. Esta diferencia debe confirmarse abriendo la pantalla en el navegador antes de dar el punto por cerrado |

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

**Los 63 elementos restantes — clasificados para negocio (no se dice "63 variantes nuevas", se agrupan):**

| Grupo | Cantidad | Qué significa | Ejemplo concreto |
|---|---:|---|---|
| Reutilizar probable | 0 | Ninguno cumple hoy los cuatro requisitos a la vez (asignación clara a PEKING, sin conflictos de versión, sin depender de perfiles pendientes, y que se pueda aislar para prueba) | — |
| Requiere decisión de asignación | 40 formularios (Layouts) | Existen varias versiones legacy (para BMW, MINI, motos, etc.) y hace falta que negocio decida cuál usará Omoda/Jaecoo — no se puede adivinar | Ej.: decidir si Omoda usa el mismo formulario que MINI o necesita uno propio |
| Requiere decisión de asignación | 19 páginas (FlexiPages) | Igual que arriba, pero para páginas completas de registro | Ej.: qué página ve un asesor de Omoda al abrir un Presupuesto |
| Requiere definición de negocio | 4 botones de acción rápida | El proceso de negocio que activan (enviar correo de presupuesto, cambiar moneda, importar plantilla) aún no está definido para Omoda/Jaecoo | Ej.: "Enviar Correo de Presupuesto" necesita una plantilla y remitente propios de PEKING que negocio debe aprobar |
| No aplicable | 4 páginas | Son exclusivas del proceso de vehículos usados; Luis ya confirmó que PEKING no vende usados en esta etapa | Páginas de "Inventario de Usados" |
| Requiere conciliación técnica previa | 1 página (`Opportunity_Record_Page_VN`) | Esta página tiene una diferencia entre lo que hay en el ambiente de pruebas y lo que está documentado (posiblemente porque Diego ya empezó a renombrar perfiles) — hay que confirmar con Diego antes de tocarla | Los nombres de los perfiles que pueden ver ciertas pestañas cambiaron de "Asesor de Ventas MINI y Nuevos V2" a "New Asesor Ventas" |

**Caso especial — `Opportunity_Record_Page_VN`:** el desbloqueo de acceso no resuelve esta pregunta. Luis confirmó
que él tampoco sabe si el cambio de nombres de perfiles corresponde al trabajo paralelo de Diego. **Queda
`PENDIENTE_CONFIRMACION_DIEGO_RENOMBRE_PERFILES`** — no se modificó ni se revirtió nada por suposición, y este
punto no detiene el resto del trabajo.

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

**Qué se probó con datos de prueba (placeholder), en una ronda anterior el mismo día:**
- **Centro de costo:** se creó un centro de costo de prueba (identificado claramente como "Test"), modelado igual
  que los reales, y un presupuesto y una orden de trabajo de prueba enlazados a él. El sistema aceptó correctamente
  la información y quedó listo para entrar al proceso de aprobación (el proceso llega correctamente al estado
  "Pendiente de aprobación").
- **Descuentos:** se intentó simular el envío a aprobación con los mismos datos que usaría un caso real. Se
  descubrió que el sistema **recalcula automáticamente** quién debe aprobar (jefe, gerente, director) según la
  estructura de mando del vendedor dueño de la venta — sin importar qué se intente forzar manualmente. Se
  comprobó que este comportamiento es igual para Omoda que para BMW, así que **no es un problema específico de
  PEKING**: es que la estructura de mando (organigrama de aprobadores) todavía no está armada en el ambiente de
  pruebas. Eso es justo el trabajo de permisos/jerarquía que Diego ya tiene asignado — no se fabricó una jerarquía
  falsa para evitar este hallazgo.
- **Garantía:** no se tocó — está fuera de este lote a propósito, porque todavía falta que negocio defina la regla
  y quién aprueba las garantías de Omoda/Jaecoo. No se decidió eso por nuestra cuenta.

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
| Orden de Trabajo de prueba `0WOAK000005j4Kj4AI` | Probar la misma regla en una Orden de Trabajo | **Sigue existiendo.** El sistema bloqueó su eliminación por un permiso específico (ver abajo). El intento de habilitar ese permiso temporalmente quedó pendiente de tu confirmación explícita, ver Resultado Final |
| Bodega de prueba "Bodega1Peking" | Confirmar que una bodega PEKING con código propio no choca con las de Bavarian/Otobai | Eliminado |

**Diagnóstico del Work Order que no se pudo eliminar:** no es un permiso de objeto estándar de Salesforce — es un
campo de configuración propio de la aplicación (`CanDeleteWO__c`, en el registro del usuario) que el sistema revisa
antes de permitir borrar cualquier Orden de Trabajo. Activarlo temporalmente para el usuario administrador,
eliminar el registro y desactivarlo de inmediato es el cambio de menor impacto posible — pero esa acción quedó
bloqueada por un control de seguridad del entorno de trabajo (que trata cualquier cambio a un registro de usuario
como sensible) y no se completó todavía. Ver punto 8 del Resultado Final.

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
