# Cierre técnico — Sprint 3 Empresa / PEKING

**Fecha de corte:** 13 de agosto de 2026

**Fuente autoritativa:** decisiones finales de cierre de Sprint 3 y `MATRIZ_CIERRE_SPRINT3.csv`

**Ambiente funcional de referencia:** RedMotors Sandbox Partial

**Naturaleza:** cierre exclusivamente documental; no incorpora funcionalidad, datos ni configuración productiva

## Conclusión

**SPRINT 3 TÉCNICAMENTE CERRABLE CON DATOS Y CONFIGURACIONES FINALES DIFERIDOS Y PENDIENTES EXTERNOS DOCUMENTADOS.**

El alcance explícito de Sprint 3 comprende B7, B9 y B11, con un total de 23 horas. La reconciliación final confirma que no queda trabajo técnico nuevo, autorizado y desbloqueado dentro de esos bloques. Las estructuras requeridas ya existen o pueden continuar con el baseline Bavarian y la configuración por `Empresa__c`, sin copiar identificadores, usuarios, códigos ni datos maestros específicos.

Los perfiles funcionales, responsables, códigos y catálogos definitivos pueden incorporarse posteriormente. Esa información no bloquea el cierre técnico ni autoriza declarar completos los datos productivos o la validación E2E que dependa de ellos.

## Alcance cerrado

| Bloque | Alcance | Horas | Resultado de cierre |
|---|---|---:|---|
| B7 | Layouts, FlexiPages y Quick Actions | 5 | Estructura reutilizable y configuración final diferible. |
| B9 | Validation Rules, Approval Processes y roles | 10 | Estructura preparada; QA funcional completado donde correspondía y E2E final diferible. |
| B11 | Custom Metadata e integración Softland configurable | 8 | Patrón por Empresa resuelto; catálogos y datos oficiales diferibles. |
| **Total** |  | **23** | **Sin trabajo técnico nuevo desbloqueado.** |

## Criterio de baseline y configuración

- Bavarian se utiliza como baseline provisional únicamente cuando existe equivalencia funcional real.
- La lógica reutilizable debe conservar el modelo configurable por `Empresa__c`.
- No se copian identificadores, usuarios, códigos, nombres ni datos maestros específicos de Bavarian.
- La falta de un dato definitivo no constituye un bloqueo cuando la estructura técnica puede continuar y el dato puede incorporarse posteriormente.
- Las configuraciones temporales de QA no se convierten en diseño productivo definitivo.

## B7 — Layouts, FlexiPages y Quick Actions

### `Opportunity_Record_Page_VN`

- Se reutiliza para Omoda y Jaecoo conforme a la confirmación funcional recibida.
- El patrón de asignación existente de Bavarian constituye la referencia técnica para App, Record Type y Profile.
- Las aplicaciones y perfiles definitivos pueden configurarse posteriormente sin crear otra Lightning Record Page.
- No se crea una página específica de PEKING.

### Permisos

- El Permission Set existente mantiene carácter temporal de QA.
- No se promueve como diseño productivo definitivo.
- La población final de perfiles y usuarios puede definirse posteriormente sin bloquear el cierre.

**Estado B7:** cerrado técnicamente; configuración funcional definitiva diferida.

## B9 — Validation Rules, Approval Processes y roles

### Director de Ventas / Gerente de Sucursal / Jefe de Sucursal

- La estructura de responsables está preparada mediante configuración de Sucursal y Empresa.
- No se requieren personas definitivas para completar la estructura técnica.
- No se hardcodean usuarios.
- La asignación de responsables reales puede incorporarse posteriormente.
- La validación E2E de aprobaciones que dependa de responsables reales queda diferida.

### Centros de costo

- El mecanismo existente y el aprobador dinámico son reutilizables.
- Los códigos de centro de costo y aprobadores oficiales pueden incorporarse después.
- Los valores temporales utilizados en QA no representan datos maestros productivos.

### Approval Processes

- Los procesos de descuento revisados son neutrales a marca y reutilizables.
- La resolución dinámica de aprobadores conserva la estructura existente.
- El QA final con datos y responsables reales puede ejecutarse posteriormente.

### Validation Rules

- El QA funcional aplicable ya fue completado.
- No se requiere repetir pruebas exclusivamente para producir nueva evidencia de cierre.

**Estado B9:** cerrado técnicamente; responsables y datos oficiales diferidos, con QA E2E final pendiente cuando estén disponibles.

## B11 — Custom Metadata e integración Softland configurable

### Bodegas

- El patrón técnico segregado por Empresa está resuelto.
- Los códigos y datos oficiales de las bodegas pueden incorporarse posteriormente.
- Cualquier registro temporal conserva carácter exclusivo de QA y no debe tratarse como catálogo productivo.

### Softland

- Los endpoints y la instancia aplicables a PEKING están confirmados como compartidos.
- Los procesos existentes son compatibles con PEKING mediante configuración por Empresa.
- Los mocks y pruebas técnicas ya fueron validados.
- El contenido oficial de los catálogos y las llamadas reales quedan para una etapa posterior controlada.

### Pricebook

- Bavarian permite establecer provisionalmente el comportamiento VN en USD.
- VN / USD resuelve `PEKING Dólares`.
- CRC resuelve `PEKING Local`.
- La resolución debe mantenerse por Empresa y moneda, sin hardcodear nombres ni identificadores.
- Una regla comercial productiva diferente puede incorporarse posteriormente sin reabrir el cierre técnico.

**Estado B11:** cerrado técnicamente; datos maestros y validación integrada con información oficial diferidos.

## Datos y QA diferidos que no bloquean

| Pendiente posterior | Tratamiento | ¿Bloquea Sprint 3? |
|---|---|---|
| Aplicaciones y perfiles funcionales definitivos | Configurar cuando se confirme la población productiva. | No. |
| Director, Gerente y Jefe definitivos | Incorporar en Sucursal/Empresa sin modificar la estructura. | No. |
| Códigos y aprobadores oficiales de centros de costo | Sustituir valores temporales por datos maestros aprobados. | No. |
| E2E de aprobaciones con responsables reales | Ejecutar cuando existan responsables y datos definitivos. | No. |
| Códigos y catálogo oficial de bodegas | Incorporar mediante el patrón por Empresa existente. | No. |
| Contenido oficial de catálogos Softland | Validar en una ejecución real controlada. | No. |
| Regla comercial productiva de Pricebook, si difiere del baseline | Ajustar mediante configuración por Empresa y moneda. | No. |

## Pendientes externos congelados — Sprint 2

Los siguientes temas se mantienen separados del cierre de Sprint 3. No se implementan, no se infieren y no constituyen impedimento para cerrar B7, B9 o B11.

| Pendiente | Sprint | Estado | Tratamiento |
|---|---|---|---|
| N3 — Garantías PEKING / `SegregateWOLIs` | Sprint 2 | CONGELADO — SIN EQUIVALENTE BAVARIAN REAL | Esperar definición funcional de garantía PEKING antes de cualquier intervención. |
| N4 — Service Territories / taller / agenda / enrutamiento | Sprint 2 | CONGELADO — SIN EQUIVALENCIA BAVARIAN SUFICIENTE | Esperar definición oficial de territorios y relación con Empresa. |

## Preguntas actuales de Sprint 3

**Cero preguntas inevitables.**

Los datos finales identificados pueden incorporarse después y no impiden continuar ni cerrar técnicamente los componentes pertenecientes a Sprint 3. Las definiciones pendientes de N3 y N4 corresponden a Sprint 2 y permanecen congeladas fuera de este cierre.

## Criterio final de cierre

Sprint 3 queda **técnicamente cerrable con datos/configuraciones finales diferidos y pendientes externos documentados**, bajo las siguientes precisiones:

- no se declara completa la configuración productiva definitiva;
- no se declara E2E final de aprobaciones cuando depende de responsables reales;
- no se convierten placeholders ni Permission Sets de QA en configuración productiva;
- no se reabren N3 o N4 dentro de Sprint 3;
- cualquier ajuste posterior debe limitarse al dato o configuración autorizado y conservar el modelo por Empresa.

## Límites de este cierre

- No se implementó funcionalidad nueva.
- No se modificaron datos, permisos, metadata ni configuración de Salesforce.
- No se ejecutó deploy.
- No se consultó ni modificó Producción.
- No se repitió QA funcional ya completado.
