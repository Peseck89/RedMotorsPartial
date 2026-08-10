# Lista de capturas pendientes para Claudia — Sprint 3 PEKING

**Fecha:** 10 de agosto de 2026
**Org:** Partial (`RedMotorsSandbox`) — nunca Producción.
**Usuario a usar:** el administrador actual (Claudia Pérez), ya tiene el acceso Omoda/Jaecoo habilitado.

No es necesario crear ningún dato nuevo — todos los registros ya existen (prefijo `QA_PEKING_S3_RT_20260810`). Al
terminar de grabar, avisar para eliminarlos.

---

## Captura 1 — Oportunidad Omoda, Layout Opportunity-Autos V1.4

- **Título:** Oportunidad Omoda carga sin error con su Layout asignado.
- **Pantalla:** vista de registro de Oportunidad.
- **Registro QA:** `QA_PEKING_S3_RT_20260810 - Opportunity Omoda` (Id `006AK00000JOCQ5YAP`).
- **Qué debe verse:** el registro abre sin mensajes de error; se ven las secciones Datos generales, Test Drive,
  Financiamiento, Detalles del Negocio, Vehículo Actual, Información de vehículos nuevos y Pedido Especial.
- **Qué demuestra:** que el formulario ya asignado a Omoda funciona en la práctica, no solo en la configuración.

## Captura 2 — Oportunidad Jaecoo, mismo Layout

- **Título:** Oportunidad Jaecoo carga sin error, en paridad con Omoda.
- **Pantalla:** vista de registro de Oportunidad.
- **Registro QA:** `QA_PEKING_S3_RT_20260810 - Opportunity Jaecoo` (Id `006AK00000JOCQ6YAP`).
- **Qué debe verse:** las mismas secciones que en la Captura 1, sin diferencias.
- **Qué demuestra:** paridad entre Omoda y Jaecoo.

## Captura 3 — Oportunidad BMW, regresión

- **Título:** Regresión — BMW sigue funcionando igual que antes.
- **Pantalla:** vista de registro de Oportunidad.
- **Registro QA:** `QA_PEKING_S3_RT_20260810 - Opportunity BMW Regresion` (Id `006AK00000JOCQ7YAP`).
- **Qué debe verse:** las mismas secciones, sin ningún cambio respecto a como se veía BMW antes de este Sprint.
- **Qué demuestra:** que habilitar Omoda/Jaecoo no rompió nada para las marcas existentes.

## Captura 4 — Lead Omoda

- **Título:** Lead Omoda se puede crear y abrir.
- **Pantalla:** vista de registro de Lead (y, si es rápido, también el formulario de creación).
- **Registro QA:** `QA_PEKING_S3_RT_20260810 - Lead Omoda` (Id `00QAK00000I45jW2AR`).
- **Qué debe verse:** el Lead abre sin error, con el tipo de registro "Omoda" visible.
- **Qué demuestra:** que el bloqueo de acceso también se resolvió para Lead, no solo para Oportunidad.

## Captura 5 — Lead Jaecoo

- **Título:** Lead Jaecoo se puede crear y abrir.
- **Pantalla:** vista de registro de Lead.
- **Registro QA:** `QA_PEKING_S3_RT_20260810 - Lead Jaecoo` (Id `00QAK00000I45jX2AR`).
- **Qué debe verse:** igual que la Captura 4, para Jaecoo.
- **Qué demuestra:** paridad Omoda/Jaecoo también en Lead.

## Captura 6 — Presupuesto (Quote) Omoda

- **Título:** Presupuesto Omoda carga sin error.
- **Pantalla:** vista de registro de Quote.
- **Registro QA:** `QA_PEKING_S3_RT_20260810 - Quote Omoda` (Id `0Q0AK000001y2BF0AY`).
- **Qué debe verse:** el registro abre sin error, con sus secciones (Datos del presupuesto, Información de
  cliente, Totales, Preparado para, Dirección, Información del sistema).
- **Qué demuestra:** que la página de Presupuesto funciona para Omoda.

## Captura 7 — Presupuesto (Quote) Jaecoo

- **Título:** Presupuesto Jaecoo carga sin error.
- **Pantalla:** vista de registro de Quote.
- **Registro QA:** `QA_PEKING_S3_RT_20260810 - Quote Jaecoo` (Id `0Q0AK000001y2BG0AY`).
- **Qué debe verse:** igual que la Captura 6, para Jaecoo.
- **Qué demuestra:** paridad Omoda/Jaecoo en Presupuesto.

## Captura 8 — Verificación del botón "Duplicar Partidas de Presupuesto" (LA MÁS IMPORTANTE DE CONFIRMAR)

- **Título:** ¿Aparece el botón "Duplicar Partidas de Presupuesto" en un Presupuesto Omoda?
- **Pantalla:** vista de registro de Quote, panel de acciones rápidas (botones en la parte superior o el menú de
  acciones).
- **Registro QA:** `QA_PEKING_S3_RT_20260810 - Quote Omoda` (Id `0Q0AK000001y2BF0AY`).
- **Qué debe verse:** si el botón aparece o no en la pantalla real. Una consulta técnica directa al sistema
  (hecha hoy) no lo encontró en la lista de acciones disponibles, lo cual contradice el análisis anterior de la
  configuración. **Esta captura decide cuál de los dos análisis es el correcto.**
- **Qué demuestra:** si el botón está realmente disponible para Omoda o no. Si aparece, tomar también una segunda
  captura ejecutándolo (aunque no haya líneas de presupuesto que duplicar, para confirmar que no da error).

## Captura 9 — Página general de Oportunidad (Opportunity_Record_Page1)

- **Título:** La página general de Oportunidad carga sin error para Omoda.
- **Pantalla:** vista de registro de Oportunidad, confirmando que no hay errores de componente en la parte
  superior/inferior de la pantalla ni en la consola del navegador (F12).
- **Registro QA:** el mismo de la Captura 1.
- **Qué debe verse:** ausencia de mensajes de error rojos o de componentes "en blanco".
- **Qué demuestra:** que la página activada de forma genérica (para todas las marcas) sigue funcionando bien con
  Omoda.

## Captura 10 — Página general de Presupuesto (Quote_Record_Page / Quote_Record_Page2)

- **Título:** La página general de Presupuesto carga sin error para Omoda.
- **Pantalla:** vista de registro de Quote, mismo chequeo de errores.
- **Registro QA:** el mismo de la Captura 6.
- **Qué debe verse:** ausencia de errores.
- **Qué demuestra:** igual que la Captura 9, para Presupuesto.

---

## Después de grabar

Avisar para que estos registros (prefijo `QA_PEKING_S3_RT_20260810`) se eliminen. Ninguno tiene datos reales,
correos enviados, ni conexiones a otros sistemas.
