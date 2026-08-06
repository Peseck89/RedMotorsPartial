# Selección propuesta de baseline Git–Partial — Sprint 3

**Estado:** propuesta; no ejecutada. No autoriza lote funcional.

## 1. Asignación PEKING demostrada nominalmente

La evidencia nominal corresponde a Record Types cuyo nombre contiene Omoda, Jaecoo o PEKING; requiere confirmar equivalencia funcional.

### Layouts candidatos

- `Opportunity-Autos V1.3`
- `Opportunity-Autos V1.3 - Inventario`
- `Opportunity-Autos V1.4`
- `Opportunity-Autos V1.4 Sin Botones`
- `Opportunity-Opportunity Layout`
- `Opportunity-Vehiculos Nuevos V1.1`

### FlexiPages candidatas

- Ninguno demostrado.

## 2. Posible aplicación; asignación o aplicabilidad pendiente

No recuperar en bloque. Primeros candidatos por evidencia de ProfileLayout:

- `Account-Account Layout`
- `Account-BMW Cuenta Empresarial`
- `Account-BMW Cuenta Empresarial  V2`
- `Account-BMW Cuenta Empresarial - RO`
- `Account-Cuenta Empresarial Sin Botones`
- `Account-RM Asesor Taller`
- `Account-RM Asistente Taller - RO`
- `Account-RM Lider Taller`
- `Account-RM Lider Taller - RO`
- `Account-Taller`
- `Opportunity-Autos`
- `Opportunity-Autos V1.3`
- `Opportunity-Autos V1.3 - Inventario`
- `Opportunity-Autos V1.4`
- `Opportunity-Autos V1.4 Sin Botones`
- `Opportunity-Motocicletas`
- `Opportunity-Opportunity Layout`
- `Opportunity-Taller Autos`
- `Opportunity-Vehiculos Nuevos V1.1`
- `Product2-Articulos sin Editar`
- `Product2-Artículos`
- `Product2-Product Layout`
- `Product2-Product Layout V1.2`
- `Product2-Vehiculos`
- `Quote-Mostrador y Taller`
- `WorkOrder-RM Asesor Taller`
- `WorkOrder-RM Lider Taller`
- `WorkOrder-Work Order Layout`
- `WorkOrder-Work Order Layout Copy`
- `WorkOrder-Work Order Main`

## 3. Metadata exclusiva de usados

- `Opportunity_Record_Page_VU`
- `Quote_Record_Page_VU`

No se adapta a PEKING. Solo requiere regresión indirecta cuando comparta consumidores o páginas.

Un Layout compartido que aparezca en una combinación de perfil o Record Type de usados no se clasifica por ello como componente exclusivamente VU. La matriz conserva la marca a nivel de asignación para permitir esa regresión específica.

## 4. Legacy que solo requiere regresión

Validation Rules inactivas, mappings legacy no usados y configuraciones Bavarian/Otobai permanecen fuera de cambio funcional. Deben entrar únicamente en un paquete de regresión tras seleccionar consumidores.

## 5. Bloqueada por negocio

Reglas de descuento, Approval Processes, centros de costo, garantía, identidad, moneda, plantillas y catálogos no se versionan como preparación funcional hasta resolver sus decisiones.

## 6. Metadata que no debe versionarse

- registros de datos de Empresa;
- credenciales o valores sensibles;
- páginas sin asignación demostrada solo por existir;
- los 219 elementos en bloque;
- acciones adicionales fuera de las cinco nominales.

## 7. Placeholder Softland

`Mecanismo_configurable_endpoints_Softland` sigue fuera del conteo y no debe generar archivos ficticios.

## Lotes futuros propuestos

| Lote | Alcance | Riesgo | Dependencia | Validación | Reversión |
|---|---|---|---|---|---|
| B0-UI-1 | Solo Layouts con Record Type Omoda/Jaecoo/PEKING demostrado | Alto | Confirmar equivalencia PEKING y perfiles | Diff XML, asignaciones y QA negativa | Retirar commit del lote; conservar retrieve temporal |
| B0-UI-2 | FlexiPages con activación demostrada y aprobada | Alto | Aplicación, perfil, RT y form factor | Diff semántico y matriz de activación | Restaurar archivo versionado previo |
| B0-QA | Cinco Quick Actions nominales expuestas | Medio/alto | Flow/Visualforce/componente y permisos | Target, parámetros y ejecución controlada | Revertir solo archivos del lote |
| B0-RULES | Subconjunto de reglas/procesos aprobado por negocio | Alto | Decisiones funcionales | Fórmulas, criterios, negativos y regresión | Restaurar baseline por componente |

Cada candidato debe conservar API name, evidencia en `MATRIZ_ASIGNACIONES_UI_S3_0_20260806.csv`, riesgo, dependencia y prueba. Ningún lote está listo ni autorizado.
