# Plan de evidencias finales — Sprint 3 (B7, B9, B11)

**Fecha:** 7 de agosto de 2026

Este documento lista **exclusivamente** las evidencias manuales (video) todavía necesarias y actualmente ejecutables — es decir, componentes cuyo QA técnico ya está agotado y cuyo único pendiente real es una verificación visual, no una decisión externa o un dato que aún no existe. No se pide grabar nada que siga bloqueado por negocio, datos oficiales o Diego: esos casos se listan al final solo para dejar constancia de por qué no están aquí.

Precondición común a todos los videos: perfil QA autorizado por Diego para cada Record Type (Omoda/Jaecoo), sesión en Partial (`RedMotorsSandbox`) — nunca Producción.

---

## Video 1 — Layouts de Opportunity (Omoda/Jaecoo) sin cambio técnico

**Objetivo:** confirmar visualmente que los 6 Layouts de Opportunity ya asignados a Omoda y Jaecoo renderizan campos, secciones y acciones sin errores, en paridad con BMW/MINI.

**Precondición:** usuario de prueba con perfil QA autorizado por Diego, con acceso efectivo a los Record Types Omoda y Jaecoo. Una Opportunity de prueba por Record Type (Omoda, Jaecoo) y una legacy (BMW o MINI) para comparar.

**Pantalla:** vista de registro de Opportunity, alternando entre los 6 Layouts según el Record Type/perfil que los activa (`Opportunity-Autos V1.3`, `Opportunity-Autos V1.3 - Inventario`, `Opportunity-Autos V1.4`, `Opportunity-Autos V1.4 Sin Botones`, `Opportunity-Opportunity Layout`, `Opportunity-Vehiculos Nuevos V1.1`).

**Datos QA:** Opportunities de prueba Omoda/Jaecoo/BMW ya identificadas como claramente ficticias (prefijo QA), sin vehículos, reservas ni montos reales.

**Pasos visuales:**
1. Abrir una Opportunity Omoda con el perfil QA correspondiente a cada Layout.
2. Confirmar que las secciones, campos y botones visibles coinciden con lo documentado en `PLAN_REGRESION_UI_B7_20260806.md` para ese Layout.
3. Repetir para Jaecoo.
4. Repetir para BMW/MINI (regresión) y comparar.
5. Verificar ausencia de errores de componente en consola del navegador.

**Qué demuestra:** que la asignación ya existente de estos 6 Layouts a Omoda/Jaecoo funciona igual que en BMW/MINI, sin regresión introducida.

**Qué NO demuestra:** no valida qué Layout debería usar PEKING en el futuro (eso es una decisión funcional pendiente para los 63 componentes bloqueados por asignación), ni valida datos de negocio reales.

---

## Video 2 — FlexiPages APP_DEFAULT (Opportunity y Quote genéricas)

**Objetivo:** confirmar que `Opportunity_Record_Page1`, `Quote_Record_Page` y `Quote_Record_Page2` cargan sin error para Omoda/Jaecoo a través de su activación genérica App Default.

**Precondición:** mismo perfil QA autorizado; una Opportunity y un Quote de prueba por marca (Omoda, Jaecoo, y BMW como regresión).

**Pantalla:** vista de registro de Opportunity y de Quote.

**Datos QA:** los mismos registros de prueba del Video 1, más un Quote de prueba asociado.

**Pasos visuales:**
1. Abrir la Opportunity de prueba Omoda y confirmar carga completa de `Opportunity_Record_Page1` (regiones, componentes, acciones).
2. Abrir el Quote de prueba Omoda y confirmar carga de `Quote_Record_Page`/`Quote_Record_Page2`.
3. Repetir para Jaecoo.
4. Repetir para BMW (regresión).
5. Confirmar ausencia de errores de consola.

**Qué demuestra:** que la ruta de activación genérica (sin condición de Empresa/Marca) sigue funcionando para PEKING sin regresión.

**Qué NO demuestra:** no reemplaza la conciliación pendiente del drift de `Opportunity_Record_Page_VN` (ver Video 4) ni decide asignaciones para las 19 FlexiPages restantes aún bloqueadas.

---

## Video 3 — Quick Action genérica de Quote

**Objetivo:** confirmar que `Quote.BMW_Duplicar_Partidas_de_Presupuesto` es visible y ejecuta correctamente sobre un Quote Omoda/Jaecoo.

**Precondición:** Quote de prueba con al menos una línea de presupuesto ficticia (producto de prueba, sin precios ni catálogo oficial).

**Pantalla:** vista de registro de Quote, acción rápida "Duplicar Partidas de Presupuesto".

**Datos QA:** Quote de prueba Omoda con una línea de presupuesto de prueba.

**Pasos visuales:**
1. Abrir el Quote de prueba Omoda.
2. Ejecutar la Quick Action y confirmar que duplica la(s) línea(s) sin error.
3. Repetir para Jaecoo.
4. Repetir para BMW (regresión).

**Qué demuestra:** que la exposición y ejecución genérica de esta Quick Action no tiene regresión para PEKING.

**Qué NO demuestra:** no valida el proceso de negocio completo de presupuestación con datos oficiales.

---

## No incluidos en este plan (bloqueados externamente — no grabar todavía)

| Componente/proceso | Por qué no se pide video ahora |
|---|---|
| `Opportunity_Record_Page_VN` | El drift real (cambios de Profile en `visibilityRule`, no solo `Plan_del_cliente_save_PDF`) debe conciliarse primero — grabar ahora produciría evidencia sobre un estado que puede cambiar. Depende de Diego (perfiles) y de una decisión funcional. |
| 63 Layouts/FlexiPages/Quick Actions bloqueados por asignación funcional | No hay asignación PEKING confirmada — grabar un video sin saber qué Layout/página corresponde no produce evidencia válida. |
| 8 Approval Processes de descuento (ciclo completo aprobar/rechazar) | El QA técnico de la submission ya se hizo (ver `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md`); el ciclo visual completo requiere un Owner con jerarquía real de Diego, no disponible todavía. |
| Approval Processes de Centro de Costo (aprobación real) | Requiere un aprobador y centro de costo oficiales, no un placeholder de `@IsTest`. |
| Approval Processes de Garantía | Bloqueados por cobertura, regla funcional y aprobador autorizado — sin definición, no hay nada que grabar. |
| `Campo_Gustos_y_aficiones_Obligatorio` y `Cambiar_Oportunidad_a_Finalizado_VH` (E2E de reserva) | `Campo_Gustos_y_aficiones_Obligatorio` ya tiene QA funcional completo (B9-1, no requiere video). El E2E real de reserva del VH requiere autorización específica de negocio, no de QA técnico. |
| `Campo_Sucursal_Obligatorio` | El intento de QA técnico dio un resultado inconcluyente (posible interferencia de otra automatización activa) — grabar un video antes de resolver esa duda documentaría un comportamiento no explicado. |
| `Opportunity.MusthaveActivity` | Confirmado `NO_APLICA_CONFIRMADO` por QA técnico (Validation ID `0AfAK0000012DWr0AM`): exclusión estructural por fórmula (`Flag_Vehiculo_Nuevo_FM__c` no incluye Omoda/Jaecoo). No requiere evidencia manual. |
| Bodega (segregación PEKING/Bavarian) | La prueba técnica confirmó la colisión de clave — no hay nada que grabar hasta que exista una estrategia de clave y bodegas oficiales. |
| Seis catálogos Softland (contenido real) | Requieren datos oficiales de catálogo — grabar con mocks no aporta evidencia de negocio. |
| Pricebook default | Sin regla comercial definida, no hay comportamiento que grabar. |

---

## Notas de seguridad para la grabación

- Usar exclusivamente Partial (`RedMotorsSandbox`).
- Usar solo registros de prueba con prefijo `QA_PEKING_*` o equivalente, nunca datos reales ni cuentas de clientes reales.
- No enviar correos reales durante la grabación (evitar acciones que disparen `BMW_EnviarCorreoPresupuesto` u otras plantillas reales).
- No dejar reservas, aprobaciones ni registros QA persistentes al finalizar — eliminar cualquier dato de prueba creado durante la grabación.
