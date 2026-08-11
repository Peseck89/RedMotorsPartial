# Grabar 3 videos cortos — Omoda, Jaecoo, BMW (Sprint 3)

**Org:** Partial (`RedMotorsSandbox`) — nunca Producción.
**Duración objetivo:** 30-45 segundos cada video. No hace falta recorrer todos los campos.

Code no puede controlar el navegador ni Snipping Tool — estos 3 videos los graba Claudia siguiendo estos pasos.

---

## Antes de empezar

Usar la app **Recortes** (Snipping Tool) de Windows → opción de grabación de video → seleccionar la ventana del
navegador con Salesforce.

## Video 1 — Omoda

**Abrir:** `https://redmotors--partial.sandbox.my.salesforce.com/lightning/r/Opportunity/006AK00000JOSOPYA5/view`

**Mostrar, deteniéndote 2-3 segundos en cada punto:**
1. Encabezado del registro: nombre y **Record Type = Omoda** visibles.
2. Cuenta asociada (`QA_PEKING_S3_EVIDENCIA - Cliente Omoda`).
3. Etapa: **Interesado**.
4. Sucursal, Forma de Pago y Moneda (CRC).
5. Lista de Precios: **PEKING Local**.
6. Campo Observaciones (muestra el texto de evidencia QA).

**No hace falta mostrar:** VIN, financiamiento, aprobador, entrega, facturación — están vacíos porque
corresponden a etapas posteriores de la venta, no porque falte algo.

## Video 2 — Jaecoo

**Abrir:** `https://redmotors--partial.sandbox.my.salesforce.com/lightning/r/Opportunity/006AK00000JOORHYA5/view`

**Mostrar los mismos 6 puntos que en el Video 1**, cambiando únicamente:
- Record Type = **Jaecoo**.
- Cuenta = `QA_PEKING_S3_EVIDENCIA - Cliente Jaecoo`.

## Video 3 — BMW (comparación)

**Abrir:** `https://redmotors--partial.sandbox.my.salesforce.com/lightning/r/Opportunity/006AK00000JOORIYA5/view`

**Mostrar los mismos puntos**, y agregar uno más al final:
7. Desplazarse hasta los campos **Director de Ventas / Gerente de Sucursal / Jefe de Sucursal** y mostrar que
   **sí están poblados** (a diferencia de Omoda y Jaecoo, donde quedan vacíos). Esta es la única diferencia real
   que vale la pena señalar en el video de comparación.

---

## Cómo demostrar que cada Opportunity está completa para su etapa

No hace falta abrir cada campo uno por uno. Basta con mostrar la sección "Detalles" desplazándote una sola vez de
arriba a abajo, sin detenerte en cada línea — es suficiente para que se vea que el registro tiene información real,
no que es un registro vacío o técnico mínimo.

## Qué campos vacíos NO deben preocupar

VIN/Placa, Aprobador, Entregado, Facturado, sección de Financiamiento — todos corresponden a pasos posteriores de
la venta (reserva de vehículo, aprobación de descuento, entrega, facturación) que todavía no ocurren en la etapa
"Interesado". No es necesario explicarlo en el video ni buscar llenarlos.

## Al terminar

Guardar los 3 archivos localmente, por ejemplo:
- `evidencias/sprint3/QA_PEKING_S3_EVIDENCIA_OMODA.mp4`
- `evidencias/sprint3/QA_PEKING_S3_EVIDENCIA_JAECOO.mp4`
- `evidencias/sprint3/QA_PEKING_S3_EVIDENCIA_BMW.mp4`

No hacer commit de estos archivos de video al repositorio de Git.
