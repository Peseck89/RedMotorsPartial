# Empresa / Marcas Chinas (Omoda y Jaecoo) — Reporte de avance

## 1. Portada / identificación del proyecto

**Proyecto:** Incorporación de Omoda y Jaecoo (marcas chinas) al proceso comercial de RedMotors.
**Fecha del reporte:** 11 de agosto de 2026.
**Estado general:** en curso — Sprint 3 no está cerrado.
**Naturaleza de este documento:** contenido consolidado para revisión previa a la elaboración del reporte final.

---

## 2. Resumen ejecutivo

El proyecto está adaptando RedMotors para que pueda operar con Omoda y Jaecoo, y en general con nuevas marcas y
empresas, sin depender exclusivamente de la lógica que históricamente solo reconocía BMW, MINI y las demás marcas
existentes.

Avances concretos logrados hasta la fecha:

- Omoda y Jaecoo ya pueden crearse como Prospecto (Lead) y como Oportunidad de venta.
- Ambas marcas reutilizan el mismo proceso de Venta Nueva que ya usa el resto del negocio, en vez de requerir una
  pantalla o un flujo separado.
- Se probaron Oportunidades completas de Omoda y de Jaecoo, con datos representativos de una venta real.
- Los Presupuestos de Omoda y Jaecoo ahora se reconocen correctamente como vehículo nuevo, lo que habilita
  funciones que antes no aparecían para estas marcas.
- Las reglas de negocio principales que ya protegían la calidad de una venta (validaciones de oportunidad) fueron
  ampliadas para cubrir también a Omoda y Jaecoo, y quedaron probadas.
- La lógica de integración con el sistema externo de inventario y facturación ya reconoce el código de empresa de
  Omoda/Jaecoo.
- La estructura para asignar los responsables de aprobación (Director de Ventas, Gerente de Sucursal, Jefe de
  Sucursal) ya está incorporada para Omoda y Jaecoo, replicando la misma lógica que usan las demás marcas.
- Existen evidencias visuales reales, grabadas sobre el ambiente de pruebas, que respaldan varios de estos puntos.

Varios frentes de trabajo siguen abiertos, principalmente porque dependen de decisiones o datos que le
corresponde definir al negocio (por ejemplo, quiénes serán los responsables reales de aprobación, o cuál será el
Precio de Lista por defecto). Estos se detallan en la sección 14.

**Sprint 3 no se declara cerrado.**

---

## 3. Objetivo del proyecto

Permitir que RedMotors venda vehículos de las marcas Omoda y Jaecoo utilizando el mismo sistema, los mismos
procesos y la misma experiencia de usuario que ya usa para sus marcas actuales — evitando construir un sistema
paralelo, y sentando una base que facilite incorporar futuras marcas o empresas con el menor esfuerzo posible.

---

## 4. Alcance general

El alcance cubre, entre otros frentes: la configuración base que permite distinguir empresas y marcas dentro del
sistema; la lógica de programación que sostiene el proceso de ventas; las pantallas y la experiencia de usuario
(formularios, botones, pestañas); las reglas de negocio y de aprobación; la integración con el sistema externo de
inventario y facturación; y las pruebas necesarias para confirmar que todo funciona de forma consistente con las
marcas ya existentes.

El presente reporte cubre el estado consolidado de los tres Sprints ejecutados hasta la fecha (Sprint 1, Sprint 2
y Sprint 3), con énfasis en el estado más reciente de Sprint 3.

---

## 5. Avance consolidado — Sprint 1, Sprint 2 y Sprint 3

| Sprint | Foco principal | Estado general |
|---|---|---|
| Sprint 1 | Base de configuración de empresas/marcas y lógica de programación central | Implementado y probado, con un punto puntual por confirmar |
| Sprint 2 | Automatizaciones y componentes de interfaz existentes | Parcialmente revisado; una parte queda pendiente de desarrollo, otra parte requiere una definición de alcance antes de continuar |
| Sprint 3 | Pantallas, reglas de negocio, aprobaciones e integración para Omoda/Jaecoo | Avance sustancial y validado en varios frentes; otros frentes esperan definiciones de negocio |

El detalle de horas de cada Sprint está en la sección 13.

---

## 6. Detalle Sprint 3

Sprint 3 concentra el trabajo específico de habilitar Omoda y Jaecoo en el proceso comercial. Los resultados se
organizan en los siguientes frentes, cada uno detallado en su propia sección de este documento:

- Pantallas y experiencia de usuario (sección 7).
- Reglas de negocio (sección 8).
- Aprobaciones y jerarquía de responsables (sección 9).
- Integración y catálogos con el sistema externo (sección 10).
- Pruebas realizadas y evidencias visuales (secciones 11 y 12).

---

## 7. Pantallas y experiencia de usuario

Se revisó un universo de **78 elementos de pantalla** (formularios, pestañas y botones de acción) que existen hoy
para las marcas actuales, para determinar cuáles necesitan algún ajuste para funcionar igual con Omoda y Jaecoo.

**Resultado de la revisión:**

| Grupo | Cantidad | Qué significa |
|---|---:|---|
| Ya cuentan con una resolución concreta dentro del alcance evaluado | 19 | No requieren trabajo adicional — funcionan igual para Omoda/Jaecoo que para las marcas existentes, o ya se ajustaron durante esta ronda |
| La página principal de detalle de la Oportunidad | 1 | Caso específico: en vez de crear una pantalla nueva, Omoda y Jaecoo reutilizan la misma experiencia de Venta Nueva que ya usa el resto del negocio (ver más abajo) |
| No aplican a marcas nuevas | 4 | Funcionalidad exclusiva de otros procesos (por ejemplo, taller de una marca específica), confirmado que no tiene relación con Omoda/Jaecoo |
| Quedan pendientes de definición o aplicación posterior | 54 | Ver desglose por categoría abajo |
| **Total revisado** | **78** | |

**Por qué los 54 elementos restantes no se modificaron de forma indiscriminada:** cada uno depende de una
definición de negocio distinta (a qué proceso pertenece, si sigue vigente, o qué contenido debe mostrar), así que
no era responsable aplicar un mismo ajuste genérico a todos. Se agrupan así:

| Categoría | Cantidad | Descripción |
|---|---:|---|
| Sin uso activo demostrado actualmente | 32 | No hay evidencia de que estos elementos se usen hoy en el proceso comercial vigente — antes de invertir esfuerzo en adaptarlos, corresponde confirmar si siguen siendo necesarios |
| Taller / Postventa | 14 | Pertenecen a procesos de mantenimiento y servicio posventa, fuera del alcance de venta de vehículo nuevo que cubre este proyecto |
| Segmentos legacy | 5 | Corresponden a configuraciones de venta anteriores que ya no representan el proceso comercial actual |
| Acciones que requieren contenido o plantilla propia de Omoda/Jaecoo | 3 | Botones o acciones que sí aplican, pero necesitan una plantilla de correo o presupuesto redactada específicamente para estas marcas antes de activarse |
| **Total** | **54** | |

**Página principal de la Oportunidad (Opportunity_Record_Page_VN):** la decisión de que Omoda y Jaecoo reutilicen
la misma pantalla de Venta Nueva que ya usa el resto del negocio ya está tomada — no se construye una pantalla
adicional. La pantalla ya incorpora, en el ambiente de pruebas, las condiciones necesarias para reconocer a Omoda
y Jaecoo. Queda por completar la puesta a punto final de cómo esa pantalla se asigna a cada usuario según su
marca y su rol — un paso de configuración final, no una decisión pendiente.

---

## 8. Reglas de negocio

Las reglas de negocio existentes (validaciones que impiden guardar una venta con datos incompletos o
inconsistentes) fueron revisadas y ampliadas para cubrir Omoda y Jaecoo, sin alterar su comportamiento para las
marcas actuales.

**Ejemplo concreto — identificación de "vehículo nuevo":**

- **Antes:** una función interna identificaba como vehículo nuevo a las marcas existentes (BMW, MINI y otras),
  pero no reconocía a Omoda ni a Jaecoo.
- **Cambio:** Omoda y Jaecoo fueron incorporadas a esa misma identificación de Venta Nueva.
- **Resultado:** los Presupuestos de Omoda y Jaecoo ahora muestran funciones como "Agregar Extra" y la
  sincronización de vehículo, bajo la misma lógica que ya usan las marcas existentes — antes no aparecían.

**Ejemplo concreto — reglas de validación de la Oportunidad:**

- **Antes:** las reglas de validación de una Oportunidad contemplaban únicamente los tipos de marca históricos.
- **Cambio:** se incorporaron Omoda y Jaecoo manteniendo exactamente las mismas condiciones que ya aplican a las
  demás marcas.
- **Resultado:** las validaciones se comportan de forma consistente entre las marcas existentes y las nuevas — se
  probaron 15 escenarios distintos y todos respondieron como se esperaba.

---

## 9. Aprobaciones y jerarquía

**Estado: configuración implementada; validación funcional final por completar.**

Toda venta que incluye un descuento pasa por un proceso de aprobación que involucra, según el nivel de descuento,
al Vendedor, al Jefe de Sucursal, al Gerente de Sucursal o al Director de Ventas. Ese proceso ya existía para las
marcas actuales; el trabajo de esta ronda fue incorporar la misma estructura para Omoda y Jaecoo.

**Qué se incorporó:**
- La misma estructura de asignación de responsables (Director de Ventas, Gerente de Sucursal, Jefe de Sucursal)
  que ya usan las marcas existentes, ahora también para Omoda y Jaecoo.
- Esta estructura permite que, más adelante, se reemplacen los responsables por las personas reales que el
  negocio confirme, sin necesidad de modificar la lógica de nuevo — es un dato de configuración, no algo fijo en
  el sistema.

**Qué falta:** completar la prueba funcional final con los responsables configurados en el ambiente de pruebas —
confirmar que, para una venta Omoda o Jaecoo, el proceso de aprobación efectivamente identifica y asigna
correctamente a cada nivel de responsable, igual que ya ocurre hoy con las marcas existentes.

**Importante:** el usuario administrador que se está usando temporalmente en el ambiente de pruebas para validar
esta configuración **no representa una asignación definitiva de negocio** — es un valor de prueba mientras se
confirman los responsables reales.

---

## 10. Aprobaciones de descuento (procesos de aprobación)

Los procesos de aprobación de descuento que ya existen para las marcas actuales pueden reutilizarse directamente
para Omoda y Jaecoo — **no se necesita crear procesos de aprobación nuevos ni específicos para estas marcas.**

Estos procesos ya utilizan los responsables asociados a cada Oportunidad (ver sección 9) para decidir a quién
enviar la aprobación. La prueba final de este frente queda vinculada a completar la configuración de responsables
descrita en la sección anterior — en cuanto esa configuración esté lista, el proceso de aprobación de descuento
queda listo para operar sin cambios adicionales.

**Centro de costo:** se realizó una prueba con datos representativos, tanto en un escenario positivo (con centro
de costo completo) como en un escenario negativo (sin él), y el sistema respondió correctamente en ambos casos —
entrando al proceso de aprobación cuando corresponde. La aprobación real, de punta a punta, queda pendiente de que
el negocio defina el centro de costo y el aprobador oficiales.

**Garantías:** este frente todavía requiere una definición adicional de negocio — no se ha definido la regla ni
quién debe aprobar las garantías de Omoda/Jaecoo.

---

## 11. Integración y catálogos con el sistema externo

El sistema externo que administra inventario y facturación ya reconoce el código de empresa correspondiente a
Omoda y Jaecoo dentro de la lógica revisada. Los 6 catálogos principales que trae esa integración fueron probados
con datos simulados (no una conexión real al sistema externo) y las **36 pruebas realizadas fueron aprobadas**.
Esta prueba se realizó sobre la misma instancia e integración que ya usa el negocio — no se creó una integración
paralela. Durante estas pruebas no se generó ninguna llamada real al sistema externo.

**Lo que todavía no está definido de forma final** (y que la prueba con datos simulados, deliberadamente, no
reemplaza):

- Las bodegas oficiales que usará Omoda/Jaecoo en el sistema externo.
- La convención definitiva del código con el que cada bodega se identificará (para evitar que choque con el
  código de otra marca).
- El centro de costo oficial para el ciclo de aprobación real.
- El contenido real de los 6 catálogos (hoy se probó la mecánica, no los datos definitivos).
- La regla de qué Precio de Lista (Pricebook) debe aplicarse por defecto.

Los datos usados en las pruebas de esta ronda son representativos, no definitivos — no deben interpretarse como la
configuración final del negocio.

---

## 12. Pruebas realizadas

Además de las pruebas de reglas de validación (sección 8) y de integración (sección 11), se ejecutaron pruebas
funcionales directamente en el ambiente de pruebas:

- Creación completa de una Oportunidad Omoda y una Oportunidad Jaecoo, con datos comerciales representativos de
  una venta real (no registros vacíos ni de solo prueba técnica).
- Comparación directa contra una Oportunidad de una marca existente (BMW), para confirmar que el comportamiento es
  consistente salvo en los puntos donde todavía falta completar configuración (ver sección 9).
- Confirmación de que ninguna de estas pruebas generó correos reales, llamadas a sistemas externos, reservas,
  pedidos ni aprobaciones reales — se usaron exclusivamente datos de prueba, aislados del proceso comercial real.

---

## 13. Evidencias visuales

Se cuenta con **4 evidencias visuales** grabadas directamente sobre el ambiente de pruebas, que respaldan de forma
concreta el estado descrito en este documento:

| # | Evidencia | Qué demuestra |
|---|---|---|
| 1 | Oportunidad Omoda — Venta Nueva | Una Oportunidad Omoda completa, cargando sin errores, con los datos comerciales de una venta representativa |
| 2 | Oportunidad Jaecoo — Venta Nueva | El mismo comportamiento que Omoda, confirmando consistencia entre ambas marcas nuevas |
| 3 | Oportunidad BMW — Comparación | Comparación directa contra una marca existente, mostrando qué partes ya se comportan igual y cuál sigue pendiente de la configuración de responsables (sección 9) |
| 4 | Presupuesto Omoda — Agregar Extras | La función "Agregar Extra", antes no disponible para Omoda, ya visible y funcionando tras el ajuste descrito en la sección 8 |

Estas 4 evidencias corresponden específicamente al trabajo de Sprint 3 — no se repite aquí evidencia de entregas
anteriores del proyecto (por ejemplo, la creación de los Precios de Lista de PEKING), que ya fue reportada en su
momento correspondiente.

---

## 14. Avance y horas

El alcance total documentado del proyecto asciende a **150 horas** (la estimación original hace referencia a un
rango de 144 a 150 horas; el detalle de las estimaciones por bloque, sumado, da 150 horas — la nota se deja aquí
de forma breve, sin mayor efecto sobre el resultado).

De esas 150 horas:

| Categoría | Horas | Qué significa |
|---|---:|---|
| Confirmadas como alcance completado | 51.2h | Bloques donde se puede medir con precisión cuánto se completó, y ese cálculo da un resultado positivo |
| Confirmadas como pendientes | 12.8h | Bloques donde se puede medir con precisión cuánto falta, dentro de esos mismos bloques medibles |
| Bloques cuyo avance no puede traducirse responsablemente a una cifra exacta de horas | 86.0h | Bloques donde sí hay avance real y verificable, pero la forma en que se estimaron originalmente no permite convertir ese avance en una fracción precisa de horas sin inventar un supuesto |

51.2 + 12.8 + 86.0 = 150 horas.

**Importante: no se avanzaron únicamente 51.2 horas del proyecto.** Existen bloques con avance real y sustancial
— por ejemplo, reglas de validación completamente probadas, o una parte importante de las pantallas ya resueltas
— cuya estimación original simplemente no se prestaba para convertir ese avance en una cifra de horas exacta sin
adivinar un supuesto que no está documentado. Para esos bloques, este reporte muestra los resultados concretos
(cuántos componentes, qué estado) en la sección correspondiente, en vez de forzar un porcentaje.

---

## 15. Avance por Sprint

**Sprint 1 — 44 horas.** Este es el único bloque cuya estimación original permite una medición proporcional
completa y precisa: **43.2 horas equivalentes completadas** y **0.8 horas equivalentes pendientes** (98.2%). El
0.8h pendiente corresponde a un componente puntual todavía sin confirmar.

**Sprint 2 — 40 horas**, dividido en dos frentes:
- **Automatizaciones (Flows):** de este frente sí se puede medir con precisión — **8 horas equivalentes
  completadas** y **12 horas equivalentes pendientes**.
- **Componentes de interfaz reutilizables (LWC/Aura):** este frente **no permite una medición exacta en horas**,
  porque la cantidad de componentes que realmente existen hoy es mayor a la que se estimó originalmente, y no hay
  forma de saber con precisión cuáles de esos componentes corresponden al compromiso original. El avance se
  reporta por estado de componente, no en horas: de los componentes revisados, una parte no requiere cambio
  técnico, otra parte ya fue confirmada fuera de alcance para este proyecto, y el resto sigue pendiente de
  desarrollo o de una definición previa.

**Sprint 3 — 23 horas.** Ninguno de los tres frentes que componen Sprint 3 permite convertir su avance en una
cifra exacta de horas, por la misma razón que el frente de componentes de interfaz de Sprint 2. En vez de un
porcentaje artificial, este reporte muestra los resultados concretos alcanzados en cada frente:

- **Pantallas:** 19 de 78 elementos ya resueltos (sección 7).
- **Reglas de validación:** 4 de 4 reglas revisadas, con 15 escenarios de prueba aprobados (sección 8).
- **Aprobaciones:** estructura de responsables implementada; prueba funcional final por completar (sección 9).
  Los procesos de aprobación de descuento no requieren cambios propios y quedan listos para operar en cuanto se
  complete esa configuración (sección 10).
- **Integración con el sistema externo:** 36 de 36 pruebas simuladas aprobadas (sección 11).
- **Evidencias visuales:** 4 de 4 completadas (sección 13).

---

## 16. Pendientes para completar el alcance

**Configuración funcional (definiciones de negocio):**
- Responsables definitivos de aprobación (Director de Ventas, Gerente de Sucursal, Jefe de Sucursal) para Omoda y
  Jaecoo.
- Precio de Lista (Pricebook) por defecto para Omoda/Jaecoo.
- Centro de costo y aprobador oficiales para el ciclo real de aprobación.
- Bodegas oficiales y convención definitiva de código para la integración externa.
- Contenido real y definitivo de los catálogos del sistema externo.
- Definición de la regla y el aprobador de garantías para Omoda/Jaecoo.
- Plantillas y remitentes de correo propios de Omoda/Jaecoo, para las acciones que los requieren (sección 7).

**Configuración de experiencia (pantallas y asignaciones):**
- Puesta a punto final de cómo la pantalla principal de la Oportunidad se asigna por marca y por rol de usuario.
- Definición de qué hacer con los elementos de pantalla que hoy no muestran uso activo demostrado, antes de
  invertir esfuerzo en adaptarlos (sección 7).

**Validación:**
- Prueba funcional final de la asignación de responsables y del proceso de aprobación, una vez configurados los
  responsables en el ambiente de pruebas (sección 9).

**Desarrollo (trabajo técnico que sigue pendiente):**
- Los componentes de interfaz reutilizables de Sprint 2 marcados como pendientes de modificación (sección 15).
- Ningún otro trabajo de desarrollo automatizable identificado en este momento — el resto de los frentes
  pendientes depende de definiciones de negocio o de configuración, no de programación adicional.

---

## 17. Próximos pasos

1. Obtener las definiciones de negocio listadas en la sección 16 (responsables, Precio de Lista, centro de costo,
   bodegas, catálogos, garantías, plantillas).
2. Completar la puesta a punto final de la asignación de pantalla por marca y rol.
3. Ejecutar la prueba funcional final de responsables y aprobaciones en cuanto la configuración esté lista.
4. Con las definiciones anteriores resueltas, evaluar qué elementos de pantalla pendientes (sección 7) requieren
   desarrollo adicional y priorizarlos.
5. Continuar con el desarrollo pendiente de los componentes de interfaz de Sprint 2, sujeto a la verificación de
   alcance que ya rige el resto del proyecto.

**Sprint 3 no se declara cerrado.**

---

## 18. Anexo técnico breve

Este anexo existe únicamente como referencia de respaldo documental para quien necesite el detalle técnico
completo — el cuerpo de este reporte (secciones 1 a 17) es autosuficiente para una lectura funcional.

- El detalle de horas de la sección 14/15 proviene de una conciliación documental dedicada, disponible en el
  repositorio de trabajo del proyecto.
- Las evidencias visuales de la sección 13 corresponden a archivos de video externos, no versionados junto con el
  código del proyecto.
- El detalle componente por componente de las pantallas (sección 7), las reglas de validación (sección 8) y la
  integración externa (sección 11) está documentado en los resultados técnicos de cada frente, disponibles junto
  con este reporte para quien requiera el nivel de detalle técnico completo.

---

**Fin del contenido consolidado. No sustituye al reporte Word final — está preparado para revisión previa.**
