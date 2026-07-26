# Cierre verificado del Sprint 1 — 44 horas (Empresa configurable / Marcas chinas)

Worktree: `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint1-Cierre44H`
Rama: `analysis/pc/redmotors-empresa-marcas-chinas-sprint1-cierre44h-20260726`
Base: `origin/feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` en el commit `52e1ef1`, con verificación adicional contra el commit posterior `30f3f569` (ver §5).

Análisis local. No se ejecutó `sf`, no se consultó ningún org directamente en
esta tarea, no se hizo deploy ni dry-run. No se modificó código productivo.
No se tocó `BusquedaDetalladaController` ni `precioProductoJSON` (dominio
exclusivo de Bloque 10).

## 1. Qué pidió Luis para el lunes

Según `BITACORA_IMPLEMENTACION.md` §1 y §4 (hito 6): Luis confirmó un
presupuesto de **30 horas Apex + 14 horas para el objeto Empresa y sus clases
de soporte**, con una referencia total de **44 horas**. La comunicación
inicial de Luis mencionaba de forma aproximada "~33 clases y 3 triggers"
(`PLAN_IMPLEMENTACION_SPRINT1.md` §4), pero el propio plan advierte
explícitamente: *"La referencia de Luis debe tratarse como estimación
inicial, no como criterio de aceptación numérico"*.

El plan técnico (`PLAN_IMPLEMENTACION_SPRINT1.md` §9) tradujo esas 44 horas en
un "primer bloque recomendado" concreto:

- **Modelo y soporte (14 h):** objeto `Empresa__c` (5 campos) + `EmpresaContext`
  + `EmpresaResolver` + `EmpresaConfigurationException` + `EmpresaResolverTest`.
- **Doce consumidores productivos (27 h):** `BMW_LineaPlantillaEmpresa`,
  `QuoteController`, `BMW_ChangeCurrencyWOWOLI`, `QuoteSoftlandPedidoService`,
  `ProductControllerTwo`, `servicioReservas`, `UpdateCurrencyScheduler`,
  `OpportunityServiceInvoker`, `Registrar_Anticipo_Controller`,
  `ServicioConsDispBodegaQuoli`, `ServicioReservaApartadoArticulosQuote`,
  `ServicioEliminarReservaArticuloQuote`.
- **Un trigger (2 h):** `WorkOrderTrigger`.
- **Estabilización (1 h).**

Esto es lo que Luis realmente aprobó como alcance "verde". **No debe
confundirse** con el alcance técnico total detectado (41 clases + 1 trigger,
~96 h, `PLAN_IMPLEMENTACION_SPRINT1.md` §3.1/§5), que es la deuda completa
para que una tercera empresa opere de punta a punta y nunca fue el
compromiso de este Sprint.

## 2. Qué se completó

### 2.1 De los 16 componentes + 1 trigger literalmente listados en el plan (§9.3)

| Componente | Estado real | Evidencia |
|---|---|---|
| `Empresa__c` + 5 campos | Completado | Bloque 1, commit `7f8b919`, deploy `0AfAK000000vhrR0AQ` |
| `EmpresaContext`/`EmpresaResolver`/`EmpresaConfigurationException`/`EmpresaResolverTest` | Completado | Bloque 1, mismo commit/deploy |
| `BMW_LineaPlantillaEmpresa` | Completado | Bloque 2, deploy `0AfAK000000vlTd0AI`; extendido después con lookup `Empresa_Operadora__c` |
| `QuoteController` | Completado | Bloque 2, mismo deploy |
| `BMW_ChangeCurrencyWOWOLI` | Completado | Bloque 2, mismo deploy |
| `UpdateCurrencyScheduler` | Completado | Bloque 3, deploy `0AfAK000000vllN0AQ` |
| `ProductControllerTwo` | Completado | Bloque 6, commit `ae6e0e6` |
| `WorkOrderTrigger` | Completado | Bloque 4, deploy `0AfAK000000vnon0AA`; ajuste de literal "Garantía" en Bloque 5 |
| `QuoteSoftlandPedidoService` | **No ejecutado** | Sin mención en ningún bloque 1-21 |
| `servicioReservas` | **No ejecutado** | Sin mención en ningún bloque 1-21 |
| `OpportunityServiceInvoker` | **No ejecutado** | Sin mención en ningún bloque 1-21 |
| `Registrar_Anticipo_Controller` | **No ejecutado** | Sin mención en ningún bloque 1-21 |
| `ServicioConsDispBodegaQuoli` | **No ejecutado** | Sin mención en ningún bloque 1-21 |
| `ServicioReservaApartadoArticulosQuote` | **No ejecutado** | Sin mención en ningún bloque 1-21 |
| `ServicioEliminarReservaArticuloQuote` | **No ejecutado** | Sin mención en ningún bloque 1-21 |

**10 de 17 componentes exactos del plan se completaron y desplegaron. Los 7
restantes — sin excepción, todos de Softland, reservas o anticipos — nunca
se tocaron en ningún bloque cerrado.**

### 2.2 Por qué eso no es una omisión oculta

Esos 7 componentes no desaparecieron del radar: están documentados y
clasificados explícitamente en `MATRIZ_TRAZABILIDAD_REQUERIMIENTOS_SPRINT1.md`
bajo `H.3` (reservas, estado **Diferido**), `H.4` (anticipos, estado
**Diferido**) y `H.5` (integración Softland, estado **Pendiente decisión** —
depende de un contrato/convención externa, igual que el bloqueo confirmado en
Bloque 10).

A partir del Bloque 11 (`BITACORA_IMPLEMENTACION.md`, hitos 918-919, 968-969,
1016-1017), Luis autorizó explícitamente continuar el Sprint con el criterio
**"cambios claros de bajo riesgo, documentar el resto"**. Bajo ese criterio
autorizado, el equipo sustituyó los 7 componentes Softland/reservas/anticipos
(alto riesgo, dependientes de datos externos) por trabajo de igual o mayor
valor tomado del resto de las 41 clases de deuda técnica total: PDFs de
cotización (Bloques 11-12), `TrabajoQuoteController`/`TrabajoController`
(Bloques 13-14), VIN Scan (Bloque 15), `QuoterController` (Bloque 16), Record
Types de Producto/Opportunity (Bloque 17), cobertura de
`ProductSearcherController` (Bloque 18), `RM_VN_CrearOppModeloInteres_Ctrl`
(Bloque 19), Lead/tráfico PEKING (Bloque 20) y la experiencia declarativa de
Opportunity (Bloque 21).

Esta sustitución fue **autorizada y documentada en cada paso**, no una deriva
silenciosa. La cifra "~33 clases y 3 triggers" de Luis no escondía ningún
componente: los 41 componentes de la deuda técnica total están todos
clasificados con evidencia; los 7 del plan original que no se tocaron están
marcados como diferidos/pendientes de decisión, no como completados ni
ignorados.

## 3. Qué evidencia existe

- `BITACORA_IMPLEMENTACION.md`: 34 secciones numeradas con commit, Deploy ID,
  Test Run ID y resultado exacto de pruebas para cada bloque cerrado.
- `MATRIZ_TRAZABILIDAD_REQUERIMIENTOS_SPRINT1.md`: tabla de control de 39
  filas únicas (`### ID` con un solo estado exclusivo cada una), verificada
  aritméticamente (18+1+2+9+5+4=39 en su última actualización; ver corrección
  en §4 de este documento).
- `IMPLEMENTACION_BLOQUE10_BUSQUEDA_DETALLADA.md` (versión final mergeada a
  `sprint1` en el commit `254c35f`, con investigación directa en
  `RedMotorsSandbox / Partial`): confirma con datos reales de usuarios,
  `ServiceTerritory` y `PricebookEntry` que no existe ninguna sucursal,
  territorio, usuario ni producto PEKING/Omoda/Jaecoo configurado, y que las
  dos convenciones de identificación de producto Bavarian/Otobai son
  incompatibles entre sí sin una tercera convención confirmada por Softland.
- `ANALISIS_QUOTE_EMPRESA_FACTURA.md` (commit `aee6b41`, mergeado a `sprint1`):
  confirma que `Quote.empresaFactura__c` es una fórmula derivada de
  `Opportunity.empresaQueFactura__c` (picklist heredado, con la inconsistencia
  de datos `Otobay`/`Otobai` sin corregir) y que no existe una corrección
  única y segura sin decisión funcional.

## 4. Qué falta exactamente — y una corrección de cifras encontrada en esta auditoría

### 4.1 Corrección: B.4 (Bloque 21) ya está desplegado, no "en progreso"

La última actualización de `MATRIZ_TRAZABILIDAD_REQUERIMIENTOS_SPRINT1.md`
clasificaba `B.4` (experiencia declarativa de Opportunity Omoda/Jaecoo) como
**"En progreso"**, con la nota "implementado localmente, sin dry-run/deploy
todavía".

`BITACORA_IMPLEMENTACION.md` §32 ("Bloque 21"), ya presente en el commit base
`52e1ef1` de este análisis, registra sin embargo:

- Dry-run declarativo `0AfAK000000vtcU0AQ`: 9/9 componentes, 0 fallas.
- Deploy real `0AfAK000000vuTh0AI`: 9/9 componentes, 0 fallas, estado
  `Succeeded`.
- Verificación post-deploy: las 8 List Views y `Opportunity_Record_Page_VN`
  confirmadas desplegadas en `RedMotorsSandbox / Partial`.
- Cierre explícito: *"Bloque 21 completado, validado y desplegado en
  RedMotorsSandbox / Partial."*

**`B.4` debe reclasificarse de "En progreso" a "Completado".** Esto significa
que el conjunto empírico "Sprint 1 comprometido" (los 19 requerimientos que sí
recibieron un bloque numerado 1-21: `A.1-A.5, B.1-B.4, C.1, E.1, E.3, E.4,
F.1-F.3, G.1, H.1, J.3`) queda en **19/19 = 100%**, no en 18/19 = 94.74%.

**Discrepancia detectada:** las secciones más recientes de
`BITACORA_IMPLEMENTACION.md` (§33 "Bloque 10" y §34 "Análisis
`Quote.empresaFactura__c`", ambas escritas y mergeadas después de que el
Bloque 21 ya constaba como desplegado en §32) siguen repitiendo la cifra
**"Sprint 1 permanece en 18/19 bloques funcionales comprometidos cerrados:
94.74%"**, sin reconciliar con el cierre de Bloque 21. Es una cifra
arrastrada sin actualizar, no un hallazgo de un componente nuevo pendiente.
Se deja documentada aquí para que quien mantenga `BITACORA_IMPLEMENTACION.md`
la corrija a 19/19 en la próxima actualización; esta tarea no edita ese
archivo compartido porque ya está integrado en `sprint1` a través de dos
ramas ajenas (`bloque10-cierre`, `quote-empresa-factura`).

### 4.2 Lo que sigue genuinamente pendiente (fuera del conjunto comprometido de 19)

Nada de esto pertenece a las 44 horas verdes comprometidas; pertenece al
alcance técnico total (41 clases) o a dominios explícitamente fuera de
Sprint 1:

- **Softland/reservas/anticipos** (`QuoteSoftlandPedidoService`,
  `servicioReservas`, `OpportunityServiceInvoker`,
  `Registrar_Anticipo_Controller`, `ServicioConsDispBodegaQuoli`,
  `ServicioReservaApartadoArticulosQuote`,
  `ServicioEliminarReservaArticuloQuote`): diferido, depende de contrato
  Softland (H.3/H.4/H.5).
- **`BusquedaDetalladaController`/`precioProductoJSON`** (Bloque 10, `J.1a`):
  cerrado como dependencia externa confirmada por dos investigaciones
  independientes (la mía, local, y la de Codex, con datos reales de
  Partial). No se implementó ni se implementará sin definir la relación
  Sucursal→Empresa y la convención de producto Softland para PEKING.
- **`Quote.empresaFactura__c`** (`F.4`): confirmado como fórmula heredada de
  `Opportunity.empresaQueFactura__c`; requiere decisión funcional sobre
  migrar, mantener o retirar ese picklist, y sobre la inconsistencia de datos
  `Otobay`/`Otobai`.
- Los 9 ítems `Pendiente decisión` y 5 `Diferido` restantes de la matriz de
  trazabilidad (branding/PDF legal, triggers de Account, batches Softland de
  catálogo, Permission Sets de marca, anomalía `Lead.BMW→Opportunity.Polaris`,
  alcance de "usados", modelo relacional completo, LWC de inventario) — todos
  fuera del conjunto comprometido de 19 y todos con una razón de bloqueo
  documentada, no una omisión.
- Los 4 ítems `Fuera de alcance` (Order, Flows, Community/agenda, seguridad
  completa) nunca fueron parte de las 41 clases directas del plan y no
  pertenecen a este Sprint bajo ningún criterio.

## 5. ¿Es Bloque 10 realmente el único pendiente?

**No, y su cierre tampoco "completa" las 44 horas — porque Bloque 10 nunca
fue parte de las 44 horas comprometidas.**

Evidencia:

1. El conjunto empírico "Sprint 1 comprometido" (19 requerimientos con bloque
   numerado asignado) **no incluye `J.1a`** (Bloque 10). Ya estaba
   completo salvo `B.4`, y `B.4` ya está desplegado (§4.1). Es decir: **el
   conjunto comprometido de 44 horas está en 19/19 = 100% independientemente
   de lo que pase con Bloque 10.**
2. Bloque 10 fue trabajo exploratorio adicional sobre el alcance técnico
   total (41 clases), autorizado bajo el mismo criterio de "cambios de bajo
   riesgo, documentar el resto" — un intento honesto de cerrar más deuda
   técnica de la estrictamente comprometida, no una condición de cierre del
   Sprint.
3. Su resultado real (confirmado con evidencia de `RedMotorsSandbox /
   Partial`, no solo análisis local) es que **no había forma segura de
   avanzarlo**: no existe sucursal/territorio/usuario PEKING, y las dos
   convenciones de producto Softland son incompatibles sin un tercer
   contrato confirmado. Esto coincide exactamente con mi propia
   investigación previa (`IMPLEMENTACION_BLOQUE10_BUSQUEDA_DETALLADA.md`
   original), que ya había corregido la clasificación optimista de `J.1a`
   ("resoluble ahora") a "depende de decisión/dato externo" — confirmación
   independiente y por partida doble.
4. El análisis paralelo de `Quote.empresaFactura__c` (también fuera del
   conjunto comprometido) llegó a la misma conclusión: bloqueado por
   decisión funcional, no por falta de tiempo.

**Conclusión:** el Sprint 1 comprometido de 44 horas (19/19 requerimientos
asignados a un bloque) está funcionalmente completo. Bloque 10 y el análisis
de `Quote.empresaFactura__c` fueron intentos adicionales, correctamente
documentados como bloqueados, que no restan ni suman al cierre del
compromiso de 44 horas. Lo que queda pendiente (Softland/reservas/anticipos,
branding, seguridad, triggers de Account, etc.) siempre perteneció al alcance
técnico total de 41 clases, nunca a las 44 horas verdes.

## 6. Diferencia entre las 44 horas del Sprint 1 y el alcance total futuro del proyecto

| | Sprint 1 (44 h, comprometido) | Alcance técnico total |
|---|---|---|
| Tamaño | 17 componentes exactos del plan (§9.3) + reinterpretación autorizada hacia 19 requerimientos de la matriz | 41 clases directas + 1 trigger + 21 dependencias indirectas + 12 de validación funcional |
| Estimación técnica | 44 h | ~96 h solo para las 41 directas, sin metadata/QA/Flows/LWC |
| Estado | 19/19 = 100% (con la corrección de `B.4` en §4.1) | 18/39 = 46.15% de los requerimientos documentados totales (`Resumen A` de la matriz de trazabilidad) |
| Pendientes característicos | Ninguno propio; solo trabajo exploratorio adicional (Bloque 10, `Quote.empresaFactura__c`) ya cerrado como bloqueado | Softland (pedidos, reservas, anticipos, catálogo), branding/PDF legal, seguridad OWD/sharing, triggers de Account, LWC/Aura, Order, Flows, Community |
| Quién debe decidir lo pendiente | Nadie — no hay pendiente dentro del compromiso | Luis/Diego (decisiones comerciales) y proveedor Softland (contrato/convención) para la mayoría; Luis/Diego también para branding, seguridad y alcance de "usados" |

No confundir un Sprint 1 cerrado con un proyecto terminado: el modelo mínimo
de Empresa configurable y los consumidores comprometidos están cerrados y
desplegados; la operación de punta a punta de PEKING (Softland, reservas,
anticipos, seguridad, branding) sigue siendo un proyecto abierto y mucho
mayor.

## 7. Checklist para declarar el Sprint 1 cerrado

- [x] Implementación: 19/19 requerimientos del conjunto comprometido tienen
      cambio productivo o decisión explícita de "no cambiar" con evidencia
      (`B.4` reclasificado en §4.1 de este documento).
- [x] Pruebas: cada bloque cerrado tiene Test Run ID y conteo de
      pruebas/fallas en `BITACORA_IMPLEMENTACION.md`.
- [x] Deploy: cada bloque cerrado tiene Deploy ID con estado `Succeeded` en
      `RedMotorsSandbox / Partial`.
- [x] Integración: todos los bloques 1-21 están mergeados en
      `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724`.
- [x] Documentación: `BITACORA_IMPLEMENTACION.md`,
      `MATRIZ_TRAZABILIDAD_REQUERIMIENTOS_SPRINT1.md` y este documento cubren
      el 100% de los requerimientos comprometidos y documentan con evidencia
      todo lo diferido/pendiente/fuera de alcance del proyecto total.
- [ ] Checkpoint con Luis: confirmar que acepta (a) el cierre de Bloque 10 y
      `Quote.empresaFactura__c` como "dependencia externa confirmada, sin
      cambio", y (b) que reconoce que los 7 componentes Softland/reservas/
      anticipos del plan original quedaron fuera, sustituidos por trabajo de
      igual valor bajo su propia autorización de "bajo riesgo".
- [ ] Corrección de la cifra "18/19" en `BITACORA_IMPLEMENTACION.md` §33-34 a
      "19/19", una vez que el responsable de ese archivo compartido la
      revise (no se edita en esta tarea por pertenecer a ramas ya
      mergeadas ajenas).
- [x] Working tree limpio en esta rama de análisis antes de push (ver Fase 5).

## Mensaje preparado para Luis (NO enviado — solo preparado según instrucción)

> Hola Luis. Confirmo el cierre técnico del Sprint 1 de 44 horas: los 19
> requerimientos asignados a un bloque de trabajo están completos y
> desplegados en Sandbox/Partial, incluyendo la experiencia declarativa de
> Opportunity para Omoda y Jaecoo (Bloque 21), que ya pasó dry-run, deploy
> real y verificación post-deploy.
>
> Además, se investigaron dos puntos adicionales fuera del compromiso
> original: la búsqueda detallada y sincronización de precios (Bloque 10) y
> el campo `Quote.empresaFactura__c`. Ambos quedaron confirmados como
> bloqueados por datos que hoy no existen (relación sucursal-empresa,
> convención de producto Softland para PEKING, y una decisión pendiente
> sobre un picklist heredado de Opportunity). No se forzó ningún cambio en
> ninguno de los dos; quedan documentados con la evidencia exacta para
> cuando haya una decisión de negocio o una confirmación de Softland.
>
> Los componentes de Softland, reservas y anticipos que mencionabas en la
> estimación original (~33 clases) no se tocaron en este Sprint: quedaron
> identificados y clasificados, pero se priorizó completar primero el resto
> del alcance de bajo riesgo, tal como autorizaste sobre la marcha. Si
> quieres, en el próximo ciclo podemos retomar específicamente esos
> componentes, ya con el contrato de Softland confirmado.
>
> Quedo atento a tu confirmación para dar por cerrado formalmente el
> Sprint 1.
