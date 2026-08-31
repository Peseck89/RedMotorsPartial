# Continuidad QA Producción — Empresa / Marcas Chinas / PEKING — 30/08/2026

**Ambiente de esta jornada:** RedMotors Producción (`RedMotorsProd`), consultas de solo lectura salvo la excepción documentada en la sección 4.
**Fuentes de autoridad consultadas para este documento** (mandan sobre memorias previas, cierres de Code/Codex y matrices auxiliares):

1. `docs/qa/Template_QA_Equipo-Redmotors_Nueva_Empresa_Marcas_Chinas.xlsm` (leído en modo solo lectura vía `openpyxl`/`data_only=True`; **no se guardó, no se modificaron macros, no se convirtió, no se cambiaron estados/evidencias**). Hojas relevantes: `Produ Casos prueba Nueva Empres`, `Produ Matriz Regresion- Sandra`, `Produ Matriz Regresion- Negocio`.
2. `docs/qa/DEV -Evaluación - Alcance - Inclusión de nueva Empresa- Marcaas chinas Redmotors.docx` (leído en modo solo lectura vía `python-docx`).

Este documento distingue explícitamente entre **requisito oficial** (texto literal de las fuentes de arriba), **hecho técnico verificado** (confirmado por consulta directa a Salesforce hoy), **decisión explícita de Luis** (citada textualmente), **QA realizado** (evidencia generada hoy) y **pendiente/bloqueo**. Ninguna inferencia técnica de esta sesión se presenta como decisión de negocio.

## 0. Regla operativa prioritaria (vigente desde hoy)

Toda decisión, prompt para Code/Codex/Claude, autorización, duda, implementación y criterio QA para este proyecto **debe comenzar consultando la documentación oficial vigente** (los dos documentos citados arriba, y sus versiones vigentes según `README_CONTEXTO_ACTIVO.md`/`FUENTES_AUTORITATIVAS_EMPRESA_MARCAS_CHINAS.md`). No se permiten parches orientados únicamente a "hacer pasar" evidencia. La implementación debe cumplir el comportamiento general definido por Negocio. Si la documentación no define una decisión relevante, se consulta antes de inventarla.

## 1. QA en Producción — resultados de hoy

Para cada CU se cita primero el **requisito oficial** exacto de `Produ Casos prueba Nueva Empres` del XLSM, y después lo que se **validó hoy en Producción**.

### CU-07 — Asignación de Pricebook — QA Producción validado

**Requisito oficial (XLSM, CU-07, Módulo "Asignación de pricebook"):** *"El flujo Encuentra_Price_Book asigna el pricebook de la empresa nueva y mantiene el de Bavarian"* — crear oportunidad de la marca nueva en local y en dólares y verificar el pricebook asignado en cada caso; crear oportunidad BMW en local y dólares y verificar que sigue tomando Bavarian Local/Bavarian Dólar; confirmar que ninguna oportunidad de la marca nueva quedó con pricebook de Bavarian; repetir el control creando desde el LWC de creación de oportunidades. Dependencias declaradas: CU-09, flows `Opportunity_Flow`/`Opp_flow_v4`.

**Validado hoy en Producción:** creación de Opportunity JAECOO PEKING vía LWC (`RM_VN_CrearOportunidad_Ctrl`, ruta de inventario). Resultado observado: RT Jaecoo, Sucursal PEKING QA, producto JAECOO QA, Quote `PT-00086140`, Pricebook `PEKING Dólares`, moneda USD, sin fallback a Bavarian/Otobai.
Evidencia: `CU-07_JAECOO_USD_Creacion_Oportunidad_PEKING_Prod_20260830.mp4`.

**Nota de cobertura:** el requisito oficial pide explícitamente el control en **ambas monedas** (local y dólar) y la comparación cruzada con BMW en la misma corrida. Lo validado hoy cubre la rama USD/JAECOO desde el LWC; no queda registrado en esta jornada un control equivalente en moneda local (CRC) para PEKING dentro de Producción, ni la comparación BMW en la misma sesión de evidencia. Se documenta como **hecho técnico verificado parcial frente al requisito oficial completo**, no como incumplimiento.

### CU-08 — Conversión de Lead — QA Producción validado

**Requisito oficial (XLSM, CU-08, "Conversión de Lead"):** crear Lead con record type de la marca nueva, convertirlo y verificar record type, compañía, empresa que factura y pricebook de la oportunidad resultante; repetir con Lead BMW y comparar; revisar que `RM_RecordTypeMapping` tenga el mapeo del record type nuevo; confirmar que cuenta y contacto quedan asociados a la empresa correcta.

**Validado hoy en Producción:** Lead `QA_PEKING_20260830_LEAD_OMODA` convertido correctamente a Opportunity `QA_PEKING_20260830_ACCOUNT_CLIENTE-Omoda-30/08/2026`. Confirmado: RT Omoda, Account QA PEKING, `BMW_Compania__c = PEKING`, `empresaQueFactura__c = PEKING`, producto OMODA, moneda USD.
Evidencia: `CU-08_Conversion_Lead_OMODA_PEKING_Prod_20260830.mp4`.

**Aclaración explícita:** `Empresa_Operadora__c` vacío en el registro **no invalida** este CU — el requisito oficial de CU-08 no exige ese campo; exige record type, compañía, empresa que factura y pricebook, todos verificados. Esto es una constatación contra el requisito oficial, no una decisión de negocio nueva.

**Corrección técnica previa relacionada (ya en Producción):** se corrigió la ausencia de la Quick Action `Lead.Convertir` en el Layout `Lead-Lead Layout` (usado únicamente por los Record Types Omoda y Jaecoo; verificado que ningún otro Record Type de Lead lo usa) y fue promovida a Producción. Deploy Id de esa promoción: ver hilo de trabajo del día; el detalle técnico completo de diagnóstico y despliegue vive en la conversación de la sesión, no en este documento — si se requiere trazabilidad completa de ese cambio puntual, debe generarse una nota técnica aparte antes de que se pierda ese contexto.

### CU-09 — Creación de oportunidad desde LWC — QA Producción validado

**Requisito oficial (XLSM, CU-09):** abrir el componente de creación de oportunidades en home con usuario de la marca nueva; verificar que los record types de la marca nueva aparecen y que el default no es BMW; crear la oportunidad y verificar record type, marca, empresa y pricebook; repetir con usuario BMW y confirmar que su comportamiento no cambió (regresión).

**Validado hoy en Producción:** creación de Opportunity VN OMODA con usuario PEKING (Jorge Durán Acuña) y regresión BMW ejecutada en la misma jornada.
Evidencia: `CU-09_Creacion_Opp_VN_OMODA_PEKING_Regresion_BMW_Prod_20260830.mp4`.

**Instrucción explícita para reconstrucción futura:** mantener el detalle exacto de pasos según el XLSM oficial citado arriba; no inventar pasos adicionales al reconstruir o repetir este CU.

### CU-10 — Inventario y buscadores — EN REMEDIACIÓN, NO CERRADO

**Requisito oficial (XLSM, CU-10, "Inventario - buscadores"):** abrir el buscador de productos e inventario con usuario de la marca nueva; buscar un **vehículo y un repuesto** de la empresa nueva y verificar marca, bodega, cantidad disponible y precio; verificar que el precio corresponde al pricebook de la empresa nueva y no a un arreglo fijo de dos empresas; crear oportunidad desde el inventario y verificar que arrastra empresa, marca y precio correctos. Comentario oficial del XLSM: *"Crítico: el mapeo de precios estaba quemado a dos empresas (preciosBavarian / preciosFantasia)"*.

**Estado real verificado hoy — parcial:**
- Parte de **vehículo**: funciona. OMODA/JAECOO visibles, con precio, ubicación PEKING y creación de Opportunity correcta.
- Parte de **repuesto** (explícitamente exigida por el mismo requisito oficial, no es un agregado): inicialmente sin resultados. Diagnóstico técnico confirmado por lectura directa de código y datos:
  - El LWC/Apex de búsqueda contenía resolución fija/hardcode de bodegas.
  - Para PEKING, esa resolución podía terminar apuntando a la bodega `BR01` (bodega legacy) en vez de la bodega real de PEKING.
  - Los productos QA de tipo repuesto tenían problemas de clasificación de tipo de producto y/o de stock (`ProductoXBodega__c`) — no exclusivamente un problema de bodega.
  - Durante el diagnóstico aparecieron cambios concurrentes específicos de PEKING/`PKQA01` y ajustes de compatibilidad QA en archivos técnicos (ver sección 2) — **esos cambios no deben considerarse solución final ni baseline autoritativo** todavía.
- Codex se detuvo antes de implementar una solución definitiva porque existían dos posibles mecanismos de resolución de bodega (ver sección 3 — Luis ya resolvió esa ambigüedad hoy).

**Conclusión de este documento:** CU-10 permanece **NO CERRADO**. No se declara PASS.

## 2. Trabajo técnico concurrente observado (Codex) — no tocado por esta sesión de documentación

Al iniciar esta actualización documental se confirmó `git status` con cambios no confirmados en, entre otros: `EmpresaPricebookResolver(.cls/Test)`, `OpportunityLineItemTriggerHandler(.cls/-meta/Test)`, `RM_SyncQuoteService`, `rm_vn_inventario`, `rm_vn_inventario_movil`, `rm_vn_get_record_opp_record_types`, campos `WorkOrder.empresaFacturaCP__c`/`empresaFactura__c`, y metadata de `WorkOrder`/`Quote` recuperada sin comprometer. Estos archivos son consistentes con el trabajo de remediación de bodega VN que Codex tiene en curso para CU-10 (sección 3). **Esta sesión de documentación no leyó su contenido en detalle, no los modificó, no los revirtió y no los tocó.**

## 3. Decisión funcional de Luis — bodega VN (cita textual, hoy)

Luis resolvió explícitamente la ambigüedad de mecanismo de resolución de bodega que tenía detenido a Codex:

> Para Ventas VN, la bodega oficial se resuelve por **configuración de Empresa mediante `RM_Config`**, no por territorio de servicio.

Definición dada por Luis:

- Empresa: `RMPEKING`.
- Configuración actual: `Bodega_Principal_RMPEKING`.
- Bodega QA actual: `PKQA01 / PEKING QA`.

Territorio / `BodegaxTerritorio__c`: puede seguir usándose para taller/postventa/despacho; **no gobierna** la búsqueda principal de inventario VN.

**Intención arquitectónica confirmada por Luis:** cuando Negocio/Softland confirme la bodega productiva definitiva de PEKING, debe bastar con cambiar el valor de configuración, sin modificar lógica. Por tanto la implementación de CU-10 debe generalizar el patrón `Empresa.Codigo_ERP__c → RM_Config.Bodega_Principal_<CodigoERP>`, y explícitamente **no debe introducir**: `if PEKING`, `if OMODA/JAECOO`, `PKQA01` hardcodeado, ni fallback PEKING → Bavarian.

Esta decisión es coherente con el requisito oficial del DOCX de alcance (párrafo ~121 del índice de extracción: *"La separación de bodegas por empresa ya existe"*) y con su advertencia explícita (párrafo ~69 del índice de extracción) de no completar la configuración de PEKING en Softland/bodegas haciendo supuestos — Luis fue quien dio la definición, no se infirió técnicamente.

**Codex está trabajando actualmente en esta corrección** (ver sección 2 para los archivos concurrentes observados). No se ejecutó ningún cambio de este mecanismo desde esta sesión de documentación.

## 4. Autorización excepcional de Producción (cita textual, hoy)

Se consultó explícitamente a Luis:

> "Voy a ver si lo puedo resolver en Partial o lo hago directo en Producción?"

Respuesta de Luis:

> "Hazlo directo en producción mejor."

**Esta autorización es una excepción específica para resolver CU-10**, documentada como tal. **No se extiende** a otros CUs ni a otros cambios sin una autorización equivalente explícita, y no se convierte en una regla global de despliegue.

## 5. Evidencias de Producción en Drive

Carpeta oficial de trabajo de Producción utilizada hoy (confirmada que corresponde a Producción):

- Raíz: <https://drive.google.com/drive/folders/1rjQKZvntDgw9cu7zz72LFvWXLrlTK2Dk>
  - **Respaldo** (mayor valor probatorio/directo): <https://drive.google.com/drive/folders/1Wy9m8I_-VX9LjtaqOrUiTq2V5w3LTROG>
  - **Complementarias** (útiles, no prueban por sí solas el flujo completo del CU): <https://drive.google.com/drive/folders/1YPJ-JmAn-3uOBu9Kbjvcvly8BnU7ajMx>

En la raíz permanecen los videos principales, entre ellos CU-08, CU-09 y CU-10.

**Descartado como evidencia final** (con el motivo exacto):

- Service Territory marcado `NO PRODUCCION`.
- Bodega marcada `PARTIAL - NO USAR EN PRODUCCION`.
- Captura de Sucursal — insuficiente para cerrar CU-05.
- Captura de repuestos de CU-10 tomada durante el estado de parche temporal — **debe repetirse** después de la solución definitiva de bodega VN.

Regla de repositorio: no copiar videos/imágenes grandes dentro de Git. Versionar únicamente índice, nombre, CU, clasificación y link de Drive cuando corresponda — este documento no incluye los archivos binarios, solo referencias.

## 6. Criterio de evidencias (confirmado por María, hoy)

María confirmó que para casos simples una captura puede ser válida si demuestra completamente el resultado esperado. Para escenarios multi-paso, cambios de estado o integraciones, se debe mantener video cuando una captura no demuestre todo el flujo.

Las imágenes recibidas hoy de Luis fueron clasificadas como apoyo para: CU-01, CU-04, CU-06, CU-08, CU-09, CU-10, CU-11, CU-12, CU-18, CU-21, CU-24, CU-25. **Varias de CU-11/CU-12/CU-18/CU-21/CU-24/CU-25 son complementarias, no cierre completo** — no se debe convertir una captura de estado final en PASS cuando el XLSM exige un flujo multi-paso/comparativo (ver, por ejemplo, el requisito de CU-07 arriba, que exige explícitamente dos monedas y comparación cruzada con BMW).

## 7. Pendientes activos (ninguno se declara cerrado)

- **CU-10:** Codex corrigiendo la resolución general de bodega VN (`Empresa.Codigo_ERP__c → RM_Config.Bodega_Principal_<CodigoERP>`) + regresiones asociadas.
- Después de CU-10: **repetir la evidencia de repuestos** con la implementación definitiva (la captura actual quedó descartada, ver sección 5).
- Continuar QA manual desde **CU-11** en adelante.
- Completar evidencias funcionales de los CUs que hoy solo tienen capturas complementarias (CU-11, CU-12, CU-18, CU-21, CU-24, CU-25).
- Mantener pendiente la **regresión BMW/Bavarian** exigida por el XLSM: `Rg-1` ("Ventas BMW/Bavarian") en la hoja `Produ Matriz Regresion- Sandra`/`- Negocio` sigue en estado `PENDING` según el propio XLSM — no confundir con la regresión BMW puntual ya cubierta dentro de CU-09 hoy, que es un control distinto y más acotado.

**No se declara QA Producción 100% cerrado.**

## 8. Datos QA principales de Producción

| Dato | Valor |
|---|---|
| Account | `QA_PEKING_20260830_ACCOUNT_CLIENTE` |
| Cédula | `83020260830` |
| Lead OMODA | `QA_PEKING_20260830_LEAD_OMODA` |
| Usuario PEKING | Jorge Durán Acuña — `jdurana@redmotorscr.com` |
| Empresa | PEKING |
| Sucursal | PEKING QA |
| Admin utilizado | `admin PortalNet` |

**Nota de sharing (no confundir con defecto funcional):** algunos registros QA de hoy pertenecen a `admin PortalNet`, y Jorge Durán puede no tener acceso a ellos por reglas de sharing/OWD del registro. Eso es un tema de visibilidad de registro, no un defecto funcional del CU correspondiente — cualquier reconstrucción futura debe verificar el propietario del registro antes de reportar un "no puedo ver esto" como bloqueo técnico.

## 9. Documentos relacionados en este repositorio

- Índice activo: [`README_CONTEXTO_ACTIVO.md`](README_CONTEXTO_ACTIVO.md).
- Estado funcional QA en **Partial** (jornada 2026-08-29, ambiente distinto de este documento): [`../qa/CODEX_QA_ESTADO_FUNCIONAL.md`](../qa/CODEX_QA_ESTADO_FUNCIONAL.md).
- Guía de evidencias en Partial: [`../qa/CODEX_QA_GUIA_EVIDENCIAS.md`](../qa/CODEX_QA_GUIA_EVIDENCIAS.md).
- Fuentes oficiales de esta jornada (solo lectura, no versionadas como binario aparte de lo ya presente): `../qa/Template_QA_Equipo-Redmotors_Nueva_Empresa_Marcas_Chinas.xlsm`, `../qa/DEV -Evaluación - Alcance - Inclusión de nueva Empresa- Marcaas chinas Redmotors.docx`.

**Importante para continuidad:** los documentos de Partial citados arriba (`CODEX_QA_ESTADO_FUNCIONAL.md`, `CODEX_QA_GUIA_EVIDENCIAS.md`) describen un ambiente y una jornada distintos (Partial, 2026-08-29). Sus conclusiones de PASS en Partial **no equivalen automáticamente** a PASS en Producción — cada ambiente debe validarse por separado según su propia evidencia, tal como hace este documento para Producción/30-08-2026.
