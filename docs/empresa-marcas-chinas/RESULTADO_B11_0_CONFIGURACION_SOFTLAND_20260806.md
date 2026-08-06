# Resultado B11-0 — configuración Softland, Empresa y Pricebook

**Fecha:** 6 de agosto de 2026

**Estado:** `COMPLETADO_COMO_ANALISIS`

## Pregunta resuelta

¿Qué mecanismo de configuración existente controla actualmente Empresa/Softland/Pricebook y qué configuración necesita PEKING dentro del bloque 11?

**Respuesta:** no existe un único Custom Metadata autoritativo para los tres frentes. La configuración vigente está fragmentada:

1. `Empresa__c`, consumida por `EmpresaResolver`, es la fuente autoritativa del contexto de Empresa y código ERP.
2. `Pricebook2.Empresa__c`, `CurrencyIsoCode` y `IsActive`, consumidos por `EmpresaPricebookResolver`, son la fuente autoritativa para resolver Pricebooks dinámicamente.
3. Los endpoints, ambiente y autenticación Softland están en Custom Labels compartidos y son configuración auxiliar/sensible, no un mapping por Empresa.
4. `RM_Config__mdt.Default_Price_List_VN` es un default global por nombre y no constituye una fuente autoritativa escalable por Empresa.

## Fuente autoritativa encontrada

### Contexto Empresa → ERP

`EmpresaResolver` consulta `Empresa__c` y exige:

- `Codigo__c`;
- `Codigo_ERP__c`;
- `Activa__c=true`;
- configuración completa.

Partial contiene una Empresa activa cuyo código y código ERP son `RMPEKING`. `QuoteSoftlandPedidoService` ya usa este contexto y soporta RMPEKING en el payload, priorizando `Opportunity.Empresa_Operadora__c` y conservando fallback legacy controlado.

### Empresa → Pricebook

`EmpresaPricebookResolver` consulta Pricebooks activos por `Pricebook2.Empresa__c` y filtra opcionalmente por `CurrencyIsoCode`. No selecciona por nombre ni ID fijo y devuelve estados controlados cuando falta configuración o hay varias opciones.

Partial contiene:

- `PEKING Local`: activo, CRC, asociado a la Empresa RMPEKING;
- `PEKING Dólares`: activo, USD, asociado a la Empresa RMPEKING.

Esto demuestra estructura y asociación, no PricebookEntry, precios ni una selección default.

### Endpoints y autenticación

La instancia compartida se configura mediante los Custom Labels existentes para URL, ambiente y autenticación. Sus nombres existen en Partial. Sus valores no fueron consultados ni documentados.

No se encontró una Named Credential Softland consumida por el código actual. Existen además consumidores con URLs literales, que son deuda legacy y no una fuente autoritativa.

## Mecanismos encontrados

La matriz B11-0 contiene 18 mecanismos o grupos de consumidores:

| Clasificación | Cantidad |
|---|---:|
| `SIN_CAMBIO_REQUIERE_REGRESION` | 8 |
| `CANDIDATO_AJUSTE_TECNICO` | 0 |
| `BLOQUEADO_DATO_NEGOCIO` | 3 |
| `BLOQUEADO_CONFIGURACION_SENSIBLE` | 0 |
| `HARDCODE_LEGACY_REQUIERE_EVALUACION` | 5 |
| `NO_APLICA` | 2 |
| **Total** | **18** |

La trazabilidad completa está en `MATRIZ_CONFIGURACION_SOFTLAND_B11_0_20260806.csv`.

## Consumidores

### Dinámicos o ya compatibles

- `EmpresaResolver` y `EmpresaContext`: resuelven contexto por registro de Empresa.
- `EmpresaPricebookResolver`: resuelve Pricebook por Empresa y moneda.
- `QuoteSoftlandPedidoService`: envía el código ERP resuelto y admite RMPEKING.
- `RM_SoftlandClient` y `HttpCalloutAuth`: comparten endpoint/autenticación sin lógica específica por Empresa.

### Parametrizados, pero invocados solo para legacy

`BatchGetCatalogoSoftland` junto con `HttpCalloutBodega`, `HttpCalloutAseguradora` y `HttpCalloutActividadComercial` acepta un parámetro `company`. Sin embargo, los schedulers observados solo encolan RMBAVARIAN y RMOTOBAI. La capacidad del método no autoriza cargar catálogos PEKING ni demuestra los datos operativos requeridos.

### Hardcodes legacy

- Categoría de cliente, centro de costo, condición de pago, cuenta contable, impuesto y subtipo de documento construyen llamadas con RMBAVARIAN fijo.
- `RM_VN_Service` y `RM_VN_CambiarVehiculo_Ctrl` consumen un nombre global de Pricebook y realizan consultas por nombre.
- `QuoterController` contiene un mapping código Empresa → nombre de Pricebook, incluido PEKING Dólares.
- Varios consumidores puntuales usan endpoints literales en lugar del mecanismo compartido.

Estos elementos requieren evaluación y regresión por proceso; no son un alta aislada de Custom Metadata.

### Bloqueo controlado para PEKING

Procesos de enlace de pago, anticipos, cambio de ubicación, disponibilidad, solicitudes de compra y reservas ya reconocen RMPEKING, pero se detienen de forma controlada antes de un callout no confirmado. Esto evita que PEKING caiga en Bavarian u Otobai, pero no demuestra el contrato operativo necesario para habilitarlos.

## Estado de RMPEKING

- Está versionado en metadata de campos y en código productivo/test.
- Existe en Partial como código y código ERP de una Empresa activa.
- Es consumido dinámicamente por `EmpresaResolver` y `QuoteSoftlandPedidoService`.
- Los Pricebooks PEKING están asociados a esa Empresa.
- No existe un registro de Custom Metadata demostrado que mapee por Empresa endpoints, catálogos y defaults.
- Algunos consumidores lo soportan; otros lo bloquean expresamente; otros permanecen hardcodeados a Bavarian/Otobai.

## Estado del mapping Empresa

El mapping autoritativo de contexto es el propio registro `Empresa__c`, no `RM_Config__mdt`. `Codigo_ERP__c=RMPEKING` es suficiente para consumidores que utilizan `EmpresaResolver`.

Los registros `RM_RecordTypeMapping__mdt` para Omoda y Jaecoo existen y están activos, pero solo mapean Lead → Opportunity. Son configuración auxiliar y no controlan Softland ni Pricebook.

## Estado de endpoints

- La misma instancia y endpoints existentes están confirmados funcionalmente.
- El código principal usa Custom Labels compartidos para URL, ambiente y autenticación.
- No se necesita crear una nueva instancia ni credencial por PEKING.
- Persisten URLs literales en consumidores legacy; su refactor pertenece a un frente técnico histórico y no se absorbe automáticamente en B11.
- Configuración sensible existente: valores omitidos.

## Estado de Pricebook defaults

`RM_Config__mdt.Default_Price_List_VN` existe en Partial, pero representa un único nombre global legacy. No contiene Empresa ni moneda y no puede resolver simultáneamente `PEKING Local` y `PEKING Dólares`.

La arquitectura dinámica ya disponible es `EmpresaPricebookResolver`. Cuando RMPEKING tiene dos opciones y no se indica moneda o Pricebook actual compatible, el resultado correcto es `SELECCION_REQUERIDA`; no debe elegirse un nombre fijo.

La regla comercial del default cuando no hay selección explícita sigue pendiente. Por ello no se propone crear un mapping nuevo ni cambiar el valor global.

## Bloqueos

- Default comercial de Pricebook cuando no existe selección explícita.
- Catálogos, grupos y monedas oficiales para inventario.
- Bodegas, centros de costo y demás datos operativos PEKING.
- Contrato funcional por proceso para reservas, anticipos, disponibilidad, solicitudes de compra y enlace de pago.
- Conciliación de consumidores con hardcodes legacy y endpoints literales.

No se identificó un bloqueo que requiera revelar o modificar credenciales durante B11-0.

## Candidatos técnicos

No existe un candidato seguro para B11-1. La estructura autoritativa de Empresa y Pricebook ya soporta PEKING sin cambio. Los faltantes restantes requieren datos/decisiones, o son refactors de consumidores históricos que no pueden tratarse como un alta aislada de configuración.

Por ello no se crea `PROPUESTA_LOTE_B11_1_CONFIGURACION_20260806.md`.

## Qué pertenece realmente a Sprint 3

- Documentar y validar `Empresa__c` como fuente del contexto ERP.
- Documentar y validar la relación `Pricebook2.Empresa__c` y selección por moneda.
- Determinar la estrategia configurable del default VN sin usar nombres fijos.
- Mantener los endpoints existentes y evitar nueva instancia/credenciales.
- Incorporar un mapping configurable solo después de contar con valor y modelo autoritativos aprobados.

## Qué pertenece a Sprint 1 o a otros bloques

- Refactorizar batches, schedulers y servicios Apex hardcodeados a RMBAVARIAN/RMOTOBAI.
- Sustituir URLs literales de consumidores históricos.
- Habilitar contratos específicos de reservas, anticipos, disponibilidad, solicitudes de compra o pago.
- Crear o poblar PricebookEntry, productos, precios, catálogos o monedas.
- QA E2E y regresión integral.

Estos pendientes no se absorben automáticamente en Sprint 3.

## Controles

- Análisis limitado al bloque 11 y consumidores dirigidos.
- No se repitió el inventario general ni se revisaron B7/B9.
- Partial se consultó únicamente en lectura para registros concretos.
- Producción no fue consultada.
- No se modificó Salesforce, metadata ni datos.
- No hubo retrieve, deploy, dry-run ni DML.
- No se expusieron endpoints, credenciales, tokens ni otros valores sensibles.
