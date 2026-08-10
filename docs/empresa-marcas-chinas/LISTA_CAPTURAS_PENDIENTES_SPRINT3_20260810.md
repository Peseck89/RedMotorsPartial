# Lista de capturas pendientes para Claudia — Sprint 3 PEKING (actualizada)

**Fecha:** 10 de agosto de 2026 — actualizada tras aplicar el criterio "Ventas Nuevas" y el desbloqueo de Record Type.
**Org:** Partial (`RedMotorsSandbox`) — nunca Producción.
**Usuario a usar:** el administrador actual (Claudia Pérez), ya tiene el acceso Omoda/Jaecoo habilitado.

Reducida al conjunto mínimo: 5 evidencias, no 10. Varias piezas de la lista anterior demostraban lo mismo o ya
quedaron resueltas por análisis técnico (la Quick Action ya no requiere confirmación urgente — ver evidencia 5).
No es necesario crear ningún dato nuevo — todos los registros ya existen (prefijo `QA_PEKING_S3_RT_20260810`). Al
terminar de grabar, avisar para eliminarlos.

---

## Evidencia 1 — Opportunity Omoda (Layout Opportunity-Autos V1.4)

- **Pantalla:** vista de registro de Oportunidad.
- **Registro QA:** `QA_PEKING_S3_RT_20260810 - Opportunity Omoda` (Id `006AK00000JOCQ5YAP`).
- **Pasos:** abrir el registro directamente por su Id o buscándolo por nombre.
- **Qué debe verse:** el registro carga sin error, con las secciones Datos generales, Test Drive, Financiamiento,
  Detalles del Negocio, Vehículo Actual, Información de vehículos nuevos y Pedido Especial.
- **Qué demuestra para negocio:** que el formulario que Omoda ya tiene asignado desde antes funciona en la
  práctica, no solo en la configuración técnica.

## Evidencia 2 — Opportunity Jaecoo y comparación con BMW (mismo video)

- **Pantalla:** vista de registro de Oportunidad.
- **Registros QA:** `QA_PEKING_S3_RT_20260810 - Opportunity Jaecoo` (Id `006AK00000JOCQ6YAP`) y `QA_PEKING_S3_RT_20260810
  - Opportunity BMW Regresion` (Id `006AK00000JOCQ7YAP`).
- **Pasos:** abrir primero Jaecoo, confirmar que se ve igual que la Evidencia 1; abrir después BMW y confirmar que
  también se ve igual (regresión — nada cambió para BMW).
- **Qué debe verse:** las mismas secciones en los tres registros, sin diferencias.
- **Qué demuestra para negocio:** paridad total entre Omoda, Jaecoo y BMW — habilitar Omoda/Jaecoo no rompió nada
  para las marcas existentes, y las tres ven exactamente el mismo formulario de venta de autos nuevos.

## Evidencia 3 — Lead Omoda y Lead Jaecoo (mismo video, rápido)

- **Pantalla:** vista de registro de Lead.
- **Registros QA:** `QA_PEKING_S3_RT_20260810 - Lead Omoda` (Id `00QAK00000I45jW2AR`) y `- Lead Jaecoo` (Id
  `00QAK00000I45jX2AR`).
- **Pasos:** abrir ambos, uno tras otro.
- **Qué debe verse:** ambos abren sin error, con su tipo de registro (Omoda / Jaecoo) visible.
- **Qué demuestra para negocio:** que el desbloqueo de acceso también aplicó a Lead, no solo a Oportunidad — un
  asesor podrá registrar un cliente potencial Omoda/Jaecoo desde el inicio del proceso de venta.

## Evidencia 4 — Quote Omoda, Jaecoo y BMW (mismo video) — Layout real de Ventas Nuevas

- **Pantalla:** vista de registro de Quote.
- **Registros QA:** `QA_PEKING_S3_RT_20260810 - Quote Omoda` (Id `0Q0AK000001y2BF0AY`), `- Quote Jaecoo` (Id
  `0Q0AK000001y2BG0AY`), `- Quote BMW Regresion` (Id `0Q0AK000001y2BH0AY`). Los tres ya tienen el Record Type
  `Nuevos` — el mismo que usa cualquier venta de auto nuevo, confirmado por consulta directa al sistema.
- **Pasos:** abrir los tres, uno tras otro.
- **Qué debe verse:** los tres cargan sin error, con las mismas secciones (Datos del presupuesto, Información de
  cliente, Totales, Preparado para, Dirección, Información del sistema). **El botón "Duplicar Partidas de
  Presupuesto" NO debería aparecer en ninguno de los tres** — eso es lo esperado y correcto (ver siguiente punto).
- **Qué demuestra para negocio:** que la pantalla de Presupuesto real de Ventas Nuevas funciona igual para las tres
  marcas, sin diferencias.

## Evidencia 5 — Confirmación de que el botón "Duplicar Partidas" se comporta igual en BMW y en Omoda (opcional, de refuerzo)

- **Contexto:** ya se determinó técnicamente que el botón "Duplicar Partidas de Presupuesto" **no está disponible
  en ningún Presupuesto de auto nuevo, sea BMW, Omoda o Jaecoo** — el botón solo existe en una pantalla distinta
  que ningún asesor de ventas activo usa hoy. No es una diferencia de PEKING, es el comportamiento ya existente del
  sistema.
- **Pantalla:** la misma vista de la Evidencia 4, revisando el panel de acciones/botones.
- **Qué debe verse:** ausencia del botón en los tres Quotes de la Evidencia 4 (se puede confirmar en el mismo
  video, sin grabación adicional).
- **Qué demuestra para negocio:** que no hace falta ninguna corrección — el comportamiento ya es idéntico para
  todas las marcas.

---

## Ya no incluidas en esta lista (resueltas por análisis técnico, no requieren grabación)

- Las páginas `Opportunity_Record_Page1`, `Quote_Record_Page` y `Quote_Record_Page2` (FlexiPages APP_DEFAULT):
  cargan como parte de las Evidencias 1, 2 y 4 — no necesitan un video separado.
- Confirmación de errores de consola del navegador: si Claudia nota algún error visible al grabar las Evidencias
  1-4, anotarlo; no se pide una captura dedicada solo para esto.

## Después de grabar

Avisar para que estos registros (prefijo `QA_PEKING_S3_RT_20260810`) se eliminen. Ninguno tiene datos reales,
correos enviados, ni conexiones a otros sistemas.
