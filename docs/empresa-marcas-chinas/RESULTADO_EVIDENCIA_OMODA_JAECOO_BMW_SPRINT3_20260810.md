# Resultado — Evidencia Omoda / Jaecoo / BMW (los 3 registros completos)

**Fecha:** 10 de agosto de 2026
**Org:** Partial (`RedMotorsSandbox`) exclusivamente.
**Continúa de:** `RESULTADO_EVIDENCIA_OMODA_SPRINT3_20260810.md` (registro Omoda inicial). Este documento agrega
Jaecoo y BMW, y la comparación entre los tres.

---

## 1. Bloqueo real — Campaign QA no se pudo crear

Se intentó crear la Campaign `QA_PEKING_S3_EVIDENCIA - Campaña Ventas Nuevas` pedida. **No fue posible**: el
describe de Salesforce confirma que el usuario administrador conectado tiene `createable=False` sobre el **objeto
Campaign completo** (no es un campo específico, es el objeto entero) — es decir, este usuario no tiene permiso de
creación de Campañas en Partial, sin importar qué campo se use. No es una automatización riesgosa, es una
restricción de permisos de objeto.

**No se forzó el acceso** (no se creó ni modificó ningún Permission Set para otorgar ese permiso, por estar fuera
del alcance autorizado de esta tarea puntual). Se mantuvo, para los tres registros, la misma campaña placeholder ya
usada en Omoda (`Motorrad Expo 2 Ruedas 2019`, Id `7010P000000soKKQAY`) — así los tres quedan consistentes entre
sí, aunque ninguna represente una campaña real de PEKING.

---

## 2. Omoda — sin cambios respecto al resultado anterior

No se modificó la Campaign de Omoda (`006AK00000JOSOPYA5`) porque no existe una Campaign QA nueva a la cual
cambiarla — sigue usando el mismo placeholder que ya tenían Jaecoo y BMW. El resto del registro permanece
exactamente como se validó y documentó en `RESULTADO_EVIDENCIA_OMODA_SPRINT3_20260810.md`.

---

## 3. Jaecoo — registro nuevo

| Dato | Valor |
|---|---|
| Id | `006AK00000JOORHYA5` |
| Nombre final (autogenerado) | `QA_PEKING_S3_EVIDENCIA - Cliente Jaecoo-Jaecoo-10/08/2026` |
| Account | `QA_PEKING_S3_EVIDENCIA - Cliente Jaecoo` (`001AK00000PQ173YAD`) |
| Contact QA | `003AK00000KcAyxYAF` |

## 4. BMW de comparación — registro nuevo

| Dato | Valor |
|---|---|
| Id | `006AK00000JOORIYA5` |
| Nombre final (autogenerado) | `QA_PEKING_S3_EVIDENCIA - Cliente BMW-BMW-10/08/2026` |
| Account | `QA_PEKING_S3_EVIDENCIA - Cliente BMW` (`001AK00000PQ174YAD`) |
| Contact QA | `003AK00000KcAyyYAF` |
| Pricebook usado | `BMW - 2024` (el más reciente y activo en Partial, USD) |

**Lección aplicada:** para Jaecoo y BMW se cargó primero el correo empresarial en la Cuenta (`qa.peking.evidencia.jaecoo@example.com`,
`qa.peking.evidencia.bmw@example.com`) **antes** de crear la Oportunidad — por eso ambas quedaron con el correo
correcto desde el primer intento, sin necesitar el paso de corrección que sí hizo falta en Omoda.

---

## 5. Comparación de los tres registros

| Campo / comportamiento | Omoda | Jaecoo | BMW | Observación |
|---|---|---|---|---|
| Record Type | Omoda | Jaecoo | BMW | Cada uno el suyo, correcto |
| Etapa (Stage) | Interesado | Interesado | Interesado | Igual en los tres |
| Formulario/Layout usado | `Opportunity-Autos V1.4` | El mismo | El mismo | Sin distinción por marca |
| Campos obligatorios (15) | Completos | Completos | Completos | Mismo formulario, mismas exigencias |
| Campaign | Placeholder compartido (`Motorrad Expo 2 Ruedas 2019`) | El mismo placeholder | El mismo placeholder | Ninguna marca tiene campaña oficial propia todavía; ver hallazgo sección 1 |
| Sucursal | Escazú (placeholder) | Escazú (placeholder) | Escazú (real, sin necesidad de placeholder) | Para PEKING no existe sucursal oficial; para BMW "Escazú" ya es una sucursal real de venta |
| Moneda | CRC | CRC | USD | Cada una coherente con su Pricebook |
| Pricebook | PEKING Local (selección QA, no default oficial) | PEKING Local (selección QA, no default oficial) | BMW - 2024 (uso normal, sin ambigüedad) | Para PEKING sigue sin existir una regla de "cuál usar por defecto"; para BMW la elección es la habitual |
| Forma de Pago | Contado | Contado | Contado | Igual en los tres |
| Empresa (`Empresa_Operadora__c`) | Vacío | Vacío | Vacío | **Ninguna de las tres lo llena** — confirma que no es un problema de PEKING, el campo no está en el formulario para ninguna marca |
| Indicador "Vehículo Nuevo" (`Flag_Vehiculo_Nuevo_FM__c`) | `true` | `true` | `true` | Las tres se reconocen igual como vehículo nuevo, confirmando el ajuste ya desplegado |
| Director de Ventas | Vacío | Vacío | **Poblado automáticamente** | Diferencia real — pendiente de Diego para Omoda/Jaecoo |
| Gerente de Sucursal | Vacío | Vacío | **Poblado automáticamente** | Misma diferencia |
| Jefe de Sucursal | Vacío | Vacío | **Poblado automáticamente** | Misma diferencia |
| Nombre generado automáticamente | `...Cliente Omoda-Omoda-10/08/2026` | `...Cliente Jaecoo-Jaecoo-10/08/2026` | `...Cliente BMW-BMW-10/08/2026` | Mismo patrón `{Cuenta}-{Marca}-{Fecha}` para las tres, sin excepción |
| Correo generado automáticamente | Correcto (con corrección manual aplicada después) | Correcto desde el primer intento | Correcto desde el primer intento | El mecanismo (copiar desde el correo de la Cuenta) es idéntico para las tres marcas |

**Lo que esto permite decir a negocio:** *"Omoda y Jaecoo se comportan exactamente igual entre sí, y exactamente
igual que BMW en todo lo que depende del formulario y las validaciones. La única diferencia real y medible es que
BMW ya tiene asignados automáticamente Director de Ventas, Gerente de Sucursal y Jefe de Sucursal según la
sucursal, y Omoda/Jaecoo todavía no — porque esa configuración (que vive en el código y en los datos de Sucursal)
nunca se creó para estas dos marcas nuevas. No es un defecto de la pantalla ni de las validaciones; es trabajo de
jerarquía pendiente, ya identificado y asignado a Diego."*

---

## 6. Qué permanece vacío legítimamente (los tres registros)

VIN/Placa, Aprobador/Descuento Aprobado, Entregado/Fecha de entrega, Facturado/Fecha de factura, sección de
Financiamiento (los tres usan "Contado") — todos corresponden a etapas posteriores del proceso de venta, no a la
etapa "Interesado" en la que se crearon estos registros.

---

## 7. Confirmaciones de seguridad (las 2 creaciones de esta ronda)

| Verificación | Resultado |
|---|---|
| Emails enviados | 0 |
| Callouts reales | 0 |
| Jobs asíncronos activos | 0 |
| Reservas, pedidos, aprobaciones | Ninguno |

---

## 8. Guía de creación manual — verificada, sin cambios adicionales necesarios

Se confirmó que `GUIA_CREACION_MANUAL_OPPORTUNITY_OMODA_JAECOO_SPRINT3_20260810.md` ya refleja, desde la corrección
de la ronda anterior, que el Nombre y el Correo del Cliente se recalculan siempre por el trigger — no requiere
ningún cambio adicional.

---

Este documento no declara Sprint 3 terminado. Los tres registros están listos para que Claudia grabe la evidencia
visual — ver `VIDEO_EVIDENCIAS_OPPORTUNITIES_SPRINT3_20260810.md`.
