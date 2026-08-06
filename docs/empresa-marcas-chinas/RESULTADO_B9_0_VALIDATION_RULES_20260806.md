# Resultado B9-0 — revisión nominal de Validation Rules

**Fecha:** 6 de agosto de 2026

**Estado:** `COMPLETADO_COMO_ANALISIS`

## Resultado

Se revisaron exactamente 94 Validation Rules ya identificadas por S3-0. Cada regla fue contrastada nominalmente con su estado, fórmula y dependencias recuperadas de Partial en la ubicación temporal de S3-0. No se modificó ninguna fórmula ni metadata.

| Clasificación | Cantidad |
|---|---:|
| `SIN_CAMBIO_REQUIERE_REGRESION` | 32 |
| `CANDIDATO_AJUSTE_TECNICO` | 0 |
| `BLOQUEADO_DATOS_OPERATIVOS` | 9 |
| `BLOQUEADO_NEGOCIO` | 4 |
| `DEPENDENCIA_DIEGO` | 46 |
| `NO_APLICA` | 3 |
| **Total** | **94** |

La fuente nominal por regla es `MATRIZ_VALIDATION_RULES_B9_0_20260806.csv`.

## Candidatos técnicos

No existe una regla elegible para `CANDIDATO_AJUSTE_TECNICO`. Las fórmulas que enumeran marcas o Record Types legacy y dejan fuera Omoda/Jaecoo también presentan al menos una dependencia todavía abierta: perfiles, datos operativos o decisiones de aprobación. Separar solo la condición de marca sin resolver esas dependencias no produciría un lote aislado y verificable.

Por este motivo:

- no se propone una fórmula final;
- no se crea `PROPUESTA_LOTE_B9_1_VALIDATION_RULES_20260806.md`;
- no se crea `BASELINE_REQUERIDO_B9_1_20260806.md`;
- no se copia metadata temporal al worktree.

## Bloqueadas

### Datos operativos — 9

- `Opportunity.BMW_OportunidadCerradaGanada`
- `Opportunity.Bodega_Vehiculos_Nuevos_Uruca`
- `Opportunity.Campo_Sucursal_Obligatorio`
- `Opportunity.MusthaveActivity`
- `Quote.CentrodeCostoLlenoCuandoCostoFijo`
- `WorkOrder.BMW_Centro_de_Costos_Obligatorio`
- `WorkOrder.RealizarEncuestaNoDebeCategorizar`
- `WorkOrder.reglaaprobacioncentroDeCosto`
- `WorkOrder.Validacion_que_impide_ir_a_otras_etapas`

Faltan bodegas, sucursales, asesores, centros de costo u otros registros operativos oficiales y datos mínimos de QA. La paridad de comportamiento no proporciona esos valores.

### Decisión de negocio — 4

- `Opportunity.AprobadorModificaDescuento`
- `Opportunity.NoModificaAprobador`
- `WorkOrder.BMW_Aseguradora_Obligatoria`
- `WorkOrder.SoloAseguradoraReprogramada`

Estas reglas requieren aprobador, responsable o criterio de aseguradora que no queda definido por “mismo comportamiento”.

### Dependencia de Diego — 46

Las 46 reglas clasificadas `DEPENDENCIA_DIEGO` referencian directamente Profile, ProfileId o ProfileName. Diego confirmó que creará perfiles y jerarquía; no se propone duplicarlos. La lista nominal y la referencia exacta de cada fórmula están en la matriz B9-0.

## Sin cambio

Las 32 reglas `SIN_CAMBIO_REQUIERE_REGRESION` son neutrales a Empresa/marca/Record Type o incluyen PEKING mediante una condición general. No necesitan modificación técnica con la evidencia actual, pero sí pruebas positivas, negativas y regresión posterior para Bavarian y Otobai, conservando su estado activo o inactivo.

Son:

- Opportunity: `Justificacion_Cerrada_Perdida`, `OfertaDescuentoNoAprobado`, `Razon_de_Venta_perdida`, `Validacion_Campo_entregado`, `Validacion_Campo_entregado_fechaentrega`, `Validacion_Campo_fechafactura`, `Validacion_RT_Lead`, `ValidacionContactoPersonalCuandoCuentaE`, `Validar_Origen`, `ValidarCamposCerradaGanada`, `ValidarPrima`.
- Product2: `No_permita_mas_del_descuento_maximo`, `VINNoMasDe5Iguales`.
- Quote: `NoCambioCuentaFacturacion`, `PresupuestoCostoFijoEmpleado`.
- WorkOrder: `Acepto_financiamiento_disponible`, `CambiarAFacturada`, `Cantidad_nula_en_financiamiento_aceptado`, `Encuesta_Obligatoria`, `Enviar_a_Facturar`, `Etapa_en_recepcion`, `Opcion_de_financiamiento`, `OrdenFacturadaDebeTenerCategorizacion`, `OwnerDistinto`, `Realizar_encuesta_obligatorio_Kawa_Polar`, `Rechazo_financiamiento_disponible`, `Respuesta_financiamiento_disponible`, `Validacion_contribuyente_y_factura`, `Validacion_de_campos_cuenta`, `Validacion_Encuesta`, `ValidacionContactoPersonalCuandoCuentaWO`, `ValidaKilometrajeWOConAsset`.

## No aplica

- `Opportunity.PlanMantenimientoFinalizado`: su fórmula está limitada a Record Types de usados; Luis confirmó que PEKING no aplica a usados.
- `Opportunity.NoCuentaBavarianMotors`: validación específica de cuenta Bavarian y exclusión de usados, sin alcance PEKING demostrado.
- `Opportunity.RM_ValidaOppRelacionadaBavarianMotors`: relación específica Bavarian/Autos usados; no corresponde a PEKING.

Una regla inactiva no fue clasificada como `NO_APLICA` por su estado; en los tres casos existe evidencia funcional nominal adicional.

## Conclusión para B9-1

B9-0 queda completado como selección técnica, pero no produce un primer lote funcional seguro. El siguiente paso es obtener perfiles de Diego y resolver datos operativos y responsables. Después deberá repetirse únicamente la selección de candidatas sobre estas 59 reglas dependientes o bloqueadas, sin reabrir las 94 ni el universo de S3-0.

No se realizó implementación, retrieve al worktree, dry-run, deploy, DML ni consulta a Producción.

## Corrección B9-0.1 — dependencia real de perfiles

La clasificación original se conserva como historia, pero fue corregida después de revisar exclusivamente sus 46 `DEPENDENCIA_DIEGO`. Una exclusión genérica de Admin no requiere conocer el perfil PEKING.

Resultado vigente: 66 `SIN_CAMBIO_REQUIERE_REGRESION`, 4 `CANDIDATO_AJUSTE_TECNICO`, 9 `BLOQUEADO_DATOS_OPERATIVOS`, 4 `BLOQUEADO_NEGOCIO`, 8 `DEPENDENCIA_DIEGO` y 3 `NO_APLICA`; total 94.

Treinta y cuatro referencias genéricas pasaron a sin cambio, cuatro reglas mixtas pasaron a candidatas y ocho dependencias reales se conservaron: seis por perfiles funcionales y dos por ProfileId. La fuente vigente es `MATRIZ_VALIDATION_RULES_B9_0_V2_20260806.csv`; el detalle está en `AUDITORIA_DEPENDENCIA_PERFILES_B9_0_20260806.md` y la propuesta no autorizada en `PROPUESTA_LOTE_B9_1_VALIDATION_RULES_20260806.md`.
