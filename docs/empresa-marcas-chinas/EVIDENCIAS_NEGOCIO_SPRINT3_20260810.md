# Evidencias para negocio — Sprint 3 PEKING (Omoda / Jaecoo)

**Fecha:** 10 de agosto de 2026
**Proyecto:** RedMotors — Empresa / Marcas Chinas / PEKING
**Org de pruebas:** ambiente de pruebas interno de Salesforce (Partial), nunca el sistema de producción real.

Este documento resume, en lenguaje de negocio, qué se probó en esta ronda de trabajo (10 de agosto), aprovechando
que se autorizó crear datos de ejemplo para pruebas (QA). No repite auditorías generales ya hechas en rondas
anteriores; se apoya en ellas.

---

## 1. Pantallas / Interfaz de usuario (UI)

**Qué se revisó:** las pantallas y layouts (formularios) que usa la Oportunidad de venta y el Presupuesto (Quote)
en Salesforce.

**Los 10 elementos que ya funcionan sin cambio, listos para regresión:**

| # | Elemento | Objeto | Dónde aplica | Puede probarse hoy con datos de prueba? |
|---|---|---|---|---|
| 1 | `Opportunity-Autos V1.3` | Oportunidad | Asignado a Omoda y Jaecoo (36 perfiles cada uno) | No — requiere abrir una Oportunidad Omoda/Jaecoo, bloqueado (ver sección "Qué queda pendiente") |
| 2 | `Opportunity-Autos V1.3 - Inventario` | Oportunidad | Asignado a Omoda y Jaecoo (1 perfil cada uno) | No — mismo bloqueo |
| 3 | `Opportunity-Autos V1.4` | Oportunidad | Asignado a Omoda y Jaecoo (5 perfiles cada uno) | No — mismo bloqueo |
| 4 | `Opportunity-Autos V1.4 Sin Botones` | Oportunidad | Asignado a Omoda y Jaecoo (1 perfil cada uno) | No — mismo bloqueo |
| 5 | `Opportunity-Opportunity Layout` | Oportunidad | Asignado a Omoda y Jaecoo (117 perfiles cada uno) | No — mismo bloqueo |
| 6 | `Opportunity-Vehiculos Nuevos V1.1` | Oportunidad | Asignado a Omoda y Jaecoo (1 perfil cada uno) | No — mismo bloqueo |
| 7 | Página `Opportunity_Record_Page1` | Oportunidad | Activación general (todas las marcas, sin distinción) | No — mismo bloqueo |
| 8 | Página `Quote_Record_Page` | Presupuesto | Activación general | No — mismo bloqueo (depende de una Oportunidad Omoda/Jaecoo previa) |
| 9 | Página `Quote_Record_Page2` | Presupuesto | Activación general | No — mismo bloqueo |
| 10 | Botón "Duplicar Partidas de Presupuesto" | Presupuesto | Disponible para todas las marcas | No — mismo bloqueo |

**Por qué ninguno pudo probarse visualmente hoy — ejemplo concreto:** se intentó crear una Oportunidad de prueba
marcada como "Omoda" (y por separado como "Jaecoo") usando el usuario administrador, el más alto permiso técnico
disponible. El sistema rechazó la creación con el error "este tipo de registro no es válido para este usuario". Se
repitió la prueba también con un "Lead" (un posible cliente antes de convertirse en Oportunidad) marcado como Omoda
o Jaecoo, y ocurrió lo mismo. Es decir: **hoy, ningún usuario del sistema — ni siquiera el administrador — puede
abrir una pantalla de Oportunidad o Lead marcada como Omoda o Jaecoo**, porque esa combinación específica todavía
no está habilitada a nivel de permisos. No es un problema de la pantalla en sí (los 10 elementos de arriba ya están
correctamente asignados); es un permiso previo que falta habilitar. Diego es quien puede resolverlo.

**Lo que sí se logró probar con datos de ejemplo:** se creó una Oportunidad de prueba de la marca BMW (para no
depender del permiso bloqueado) pero con la referencia a "PEKING" como empresa dueña del negocio, y a partir de
ella un Presupuesto y una Orden de Trabajo de prueba. Todo el flujo funcionó sin errores y sin efectos secundarios
(no se enviaron correos, no se hicieron conexiones a otros sistemas). Esto confirma que el mecanismo interno que
conecta una venta con la empresa PEKING funciona correctamente; lo único que falta para ver las pantallas reales de
Omoda/Jaecoo es el permiso mencionado arriba.

**Los 63 elementos restantes — clasificados para negocio (no se dice "63 variantes nuevas", se agrupan):**

| Grupo | Cantidad | Qué significa | Ejemplo concreto |
|---|---:|---|---|
| Reutilizar probable | 0 | Ninguno cumple hoy los cuatro requisitos a la vez (asignación clara a PEKING, sin conflictos de versión, sin depender de perfiles pendientes, y que se pueda aislar para prueba) | — |
| Requiere decisión de asignación | 40 formularios (Layouts) | Existen varias versiones legacy (para BMW, MINI, motos, etc.) y hace falta que negocio decida cuál usará Omoda/Jaecoo — no se puede adivinar | Ej.: decidir si Omoda usa el mismo formulario que MINI o necesita uno propio |
| Requiere decisión de asignación | 19 páginas (FlexiPages) | Igual que arriba, pero para páginas completas de registro | Ej.: qué página ve un asesor de Omoda al abrir un Presupuesto |
| Requiere definición de negocio | 4 botones de acción rápida | El proceso de negocio que activan (enviar correo de presupuesto, cambiar moneda, importar plantilla) aún no está definido para Omoda/Jaecoo | Ej.: "Enviar Correo de Presupuesto" necesita una plantilla y remitente propios de PEKING que negocio debe aprobar |
| No aplicable | 4 páginas | Son exclusivas del proceso de vehículos usados; Luis ya confirmó que PEKING no vende usados en esta etapa | Páginas de "Inventario de Usados" |
| Requiere conciliación técnica previa | 1 página (`Opportunity_Record_Page_VN`) | Esta página tiene una diferencia entre lo que hay en el ambiente de pruebas y lo que está documentado (posiblemente porque Diego ya empezó a renombrar perfiles) — hay que confirmar con Diego antes de tocarla | Los nombres de los perfiles que pueden ver ciertas pestañas cambiaron de "Asesor de Ventas MINI y Nuevos V2" a "New Asesor Ventas" |

**Caso especial — `Opportunity_Record_Page_VN`:**
- **Qué usa hoy:** la misma página que usan BMW y MINI, sin ninguna condición especial por marca.
- **Qué falta definir para Omoda/Jaecoo:** (a) confirmar con Diego si el cambio de nombres de perfiles que se
  detectó es intencional (parte de su trabajo de permisos) o un error a corregir; (b) decidir si Omoda/Jaecoo deben
  usar esta misma página o una propia.
- **Qué podría probarse con un registro de prueba si el permiso existiera:** abrir una Oportunidad Omoda de prueba
  en esta página y confirmar visualmente que carga sin errores, igual que ya se demostró para BMW.

---

## 2. Reglas de validación (Validation Rules)

Se modificaron 4 reglas de la Oportunidad para que reconozcan Omoda y Jaecoo, no solo BMW/MINI y otras marcas
existentes. Las 4 ya se probaron a fondo en una ronda anterior (15 escenarios en la regla más compleja, con
resultado 15 de 15 correctos). En esta ronda no se repitieron esas pruebas porque no hay ningún dato nuevo que
cambie el resultado; se resume aquí en lenguaje de negocio para el documento final.

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
- **"Por actualizar" sigue permitido:** el valor especial "Por actualizar" (que el equipo de ventas usa quando aún
  no tiene el dato pero necesita avanzar) sigue funcionando exactamente igual que antes — no se retiró ni se
  restringió.

---

## 3. Procesos de aprobación (Approval Processes)

**Qué funciona igual para todas las marcas (común):** 8 procesos de aprobación de descuento y 2 procesos de
aprobación de centro de costo (uno para Presupuesto, uno para Orden de Trabajo) están escritos de forma neutral —
no distinguen por marca ni tipo de vehículo, así que Omoda y Jaecoo ya quedan cubiertos sin cambios.

**Qué se probó con datos de prueba (placeholder):**
- **Centro de costo:** se creó un centro de costo de prueba (identificado claramente como "Test"), modelado igual
  que los reales, y un presupuesto y una orden de trabajo de prueba enlazados a él. El sistema aceptó correctamente
  la información y quedó listo para entrar al proceso de aprobación (confirmado en una ronda anterior, el 7 de
  agosto, con el mismo tipo de dato de prueba: el proceso llega correctamente al estado "Pendiente de aprobación").
- **Descuentos:** se intentó simular el envío a aprobación con los mismos datos que usaría un caso real. Se
  descubrió que el sistema **recalcula automáticamente** quién debe aprobar (jefe, gerente, director) según la
  estructura de mando del vendedor dueño de la venta — sin importar qué se intente forzar manualmente. Se
  comprobó que este comportamiento es igual para Omoda que para BMW, así que **no es un problema específico de
  PEKING**: es que la estructura de mando (organigrama de aprobadores) todavía no está armada en el ambiente de
  pruebas. Eso es justo el trabajo de permisos/jerarquía que Diego ya tiene asignado — no se fabricó una jerarquía
  falsa para evitar este hallazgo, como indica la instrucción de no inventar esa estructura.
- **Garantía:** no se tocó — está fuera de este lote a propósito, porque todavía falta que negocio defina la regla
  y quién aprueba las garantías de Omoda/Jaecoo. No se decidió eso por nuestra cuenta.

**Qué requiere negocio:**
- La aprobación *real* (no solo la entrada al proceso) de centro de costo necesita un aprobador y un centro de
  costo oficiales, no de prueba.
- Los 8 procesos de descuento necesitan que exista la estructura de mando real de aprobadores.
- Garantía necesita que negocio defina la regla y el aprobador.

---

## 4. Softland (integración de catálogos e inventario)

- **Qué reconoce el sistema hoy para PEKING:** el código de empresa `RMPEKING` ya está reconocido en las 13 clases
  técnicas que traen los 6 catálogos desde Softland (el sistema externo de inventario/facturación) y en los
  procesos automáticos (schedulers) asociados — verificado documentalmente en una ronda anterior, sin cambios
  nuevos en esta ronda porque nada se modificó en esos componentes.
- **Qué catálogos se probaron:** los 6 catálogos ya cuentan con pruebas técnicas automatizadas (36 de 36 exitosas)
  usando datos simulados (mocks), no una conexión real a Softland — nunca se ejecutó un batch real ni se llamó al
  sistema externo real, conforme a la restricción explícita de no hacer callouts ni cargar catálogo real.
- **Qué placeholder se usó (bodega):** se creó una bodega de prueba llamada "Bodega1Peking" con un código propio
  (`PK01`) que no coincide con ningún código ya usado por Bavarian u Otobai, modelada con los mismos campos que las
  bodegas reales de BMW.
- **Resultado:** la funcionalidad local (que el sistema acepte y muestre una bodega PEKING) puede validarse sin
  problema con el placeholder. Sigue aparte, sin resolver, la pregunta de negocio: ¿cuál será la convención oficial
  de código para que una bodega de PEKING nunca choque por accidente con una de Bavarian? (Ya se demostró
  técnicamente, en una ronda anterior, que si se usara el mismo patrón de código que Bavarian, sí habría choque —
  por eso la bodega de prueba de esta ronda usa un código distinto a propósito, y por eso ese hallazgo sigue
  pendiente de una decisión oficial de negocio/operaciones.)

---

## 5. Datos QA — listado de placeholders creados y su destino

Todos con prefijo `QA_PEKING_S3_20260810`, todos ficticios, ninguno con datos reales de cliente. Ver
`RESULTADO_QA_PLACEHOLDERS_SPRINT3_20260810.md` para el detalle técnico completo (IDs, campos exactos).

| Placeholder | Propósito | ¿Quedó o se eliminó? |
|---|---|---|
| Cuenta de prueba "BMW Regresión" | Contenedor aislado para la Oportunidad de prueba, evitando efectos secundarios de alertas de duplicados | Eliminado al cierre de esta ronda |
| Oportunidad de prueba BMW con referencia a PEKING | Demostrar que la conexión Oportunidad↔Empresa PEKING funciona sin el permiso de Record Type bloqueado | Eliminado al cierre de esta ronda |
| Centro de costo de prueba | Probar la regla de centro de costo obligatorio y la entrada al proceso de aprobación | Eliminado al cierre de esta ronda |
| Presupuesto (Quote) de prueba | Probar la regla de centro de costo obligatorio en un Presupuesto real, casos positivo y negativo | Eliminado al cierre de esta ronda |
| Orden de Trabajo de prueba | Probar la misma regla en una Orden de Trabajo | **No se pudo eliminar** — el propio sistema bloqueó el borrado ("el usuario no cuenta con permisos para eliminar órdenes de trabajo"), una regla de negocio existente, no una decisión de este equipo. El registro no tiene datos sensibles, monto real ni aprobación pendiente; queda huérfano (su Cuenta y Oportunidad padre ya se eliminaron) hasta que alguien con el permiso adecuado lo elimine |
| Bodega de prueba "Bodega1Peking" | Confirmar que una bodega PEKING con código propio no choca con las de Bavarian/Otobai | Eliminado al cierre de esta ronda |

Ningún dato quedó pendiente a propósito para grabar video (ningún video de este lote es ejecutable todavía, ver
sección 1). La única excepción es la Orden de Trabajo de prueba, que no pudo eliminarse por una restricción de
permisos del propio sistema, no por necesidad de evidencia.

---

## Nota final

Este documento no declara Sprint 3 terminado. Su propósito es dejar evidencia clara, en lenguaje de negocio, de lo
que ya se probó y de lo que todavía depende de una decisión o un permiso fuera del alcance técnico de este equipo.
