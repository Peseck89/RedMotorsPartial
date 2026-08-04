# Plan propuesto de remediación — Sprint 2

Este documento es una propuesta. **No autoriza ni ejecuta cambios.** Sprint 2 permanece abierto hasta resolver bloqueos, implementar con aprobación y completar QA.

## Definiciones confirmadas por Luis

- Solo se remedia un Flow legacy si tiene definición activa en Producción y su lógica tiene impacto Empresa/PEKING.
- Un Flow activo sin impacto PEKING queda `SIN CAMBIO TÉCNICO`.
- Un Flow sin versión activa en Producción no se trabaja.
- Los procesos y componentes exclusivos de vehículos usados no soportan PEKING y quedan `NO APLICA`.
- Producción confirmó 19 Flows activos y `Carga_MO_26_Lavado_a_Caso` sin versión activa (latest v4 Obsolete).

## Prioridad 0 — impedir asignaciones empresariales incorrectas

1. Tomar como objetivo funcional únicamente las versiones activas en Producción: `Opp_Flow_V5` v29 y `Opp_Flow_v6` v79. No activar sus versiones Draft. No trabajar `Carga_MO_26_Lavado_a_Caso`.
2. Migrar `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`, `CreateWoliFromExpense`, `aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent` y `AgregarManoObra` a resolución explícita por `Empresa_Operadora__c`.
3. Eliminar nombres fijos de Pricebooks de los Flows legacy que continúen vigentes. El resolver debe devolver error/no configurado, nunca una empresa por `else`.
4. Sustituir el Record Type Id fijo de `SegregateWOLIs` por DeveloperName o configuración aprobada y definir la segregación PEKING.
5. Filtrar Pricebooks en `busquedaDetallada` por Empresa y validar del lado servidor que el Id seleccionado pertenece a esa Empresa.

## Prioridad 0 — reconciliación Git/Partial

Antes de cualquier cambio funcional, obtener aprobación para reconciliar:

- `productSearcher`
- `quoliGridDespacho`
- `woliGridDespacho`
- `busquedaDetallada`
- `qoSearchDetailProduct`
- `woSearchDetailProduct`
- `pricebookReferenceDetails`
- `CommunityMenu`
- `CommunityControl`
- `customerCommunity_lwc`
- `callcenterCommunity_lwc`

No debe asumirse que Git o Partial es correcto en bloque. El diff debe revisarse por recurso y asignarse una fuente autoritativa.

También debe decidirse si se incorporan a control de versiones `kpiSucursales` y `cT_Estadisticas_Inventario_lwc`; hasta entonces permanecen `BLOQUEADO`.

## Prioridad 1 — contratos Apex y Softland

1. Cambiar `preciosBavarian`/`pbeBavarian` en `ProductSearcherController` y `RM_VN_CrearOportunidad_Ctrl` por un resultado neutral asociado a Empresa/Pricebook.
2. Revisar `RM_VN_Inventario_Ctrl`, `WoliGridController`, `WoliGridController2`, `AssetGarantiaController` y controladores de comunidad para garantizar que Empresa sea entrada explícita o se derive del registro principal.
3. Reemplazar `empresaFactura` por un contrato inequívoco: lookup Empresa o clave ERP estable confirmada. No usar nombre de empresa.
4. Mover sucursales, servicios, usuarios, bodegas y reglas Softland a configuración aprobada. No crear valores PEKING durante esta fase.
5. Inventariar campos y Permission Sets requeridos por cada ruta, con mínimo privilegio y perfiles QA.

## Prioridad 1 — decisiones funcionales previas

Solicitar confirmación escrita de:

- Pricebooks y monedas aplicables por Empresa.
- Catálogos, productos y precios autorizados.
- Bodegas, sucursales y territorios oficiales.
- Record Types por Empresa y proceso.
- Garantía, usados, mantenimiento, mano de obra, despacho y reserva PEKING.
- Códigos/mapeos Softland.
- Textos legales de comunidad.
- Permisos por perfil.

Sin estas respuestas, los elementos correspondientes no pasan de `BLOQUEADO`.

Quedan fuera de estas decisiones `ReciboUsadosFlow`, `rm_vu_inventario` y `rm_vu_crear_opp`: son exclusivos de usados y PEKING no aplica. Su acción es no extenderlos para PEKING, no inventar configuración y mantener regresión de usados separada.

## Prioridad 2 — retirada controlada de legacy

1. Medir oportunidades y plantillas que aún dependen de `BMW_Compania__c`.
2. Completar migración del lookup Empresa.
3. Retirar el fallback solo con cobertura de datos y aprobación.
4. No activar, desactivar ni retirar Flows como parte de esta remediación. `Carga_MO_26_Lavado_a_Caso` permanece fuera por no tener versión activa en Producción.
5. No agregar PEKING a picklists legacy como atajo.

## Secuencia propuesta de aprobación

1. Aprobar reconciliación Git–Partial y tomar como referencia las versiones activas verificadas en Producción.
2. Resolver las preguntas restantes de Luis, Diego y negocio; no reabrir las decisiones ya confirmadas sobre vigencia productiva y usados.
3. Aprobar diseño técnico por lote.
4. Implementar en rama Sprint 2.
5. Ejecutar pruebas unitarias y de integración.
6. Ejecutar QA funcional en Partial con datos reales del flujo autorizado.
7. Recopilar videos/capturas y actualizar matriz.
8. Evaluar cierre; no declarar completo por deploy exitoso.

## Criterios de aceptación

- Ninguna Empresa desconocida cae en Bavarian/Otobai.
- Ninguna lógica productiva usa nombre/Id fijo de Pricebook.
- `Empresa_Operadora__c`/Empresa gobierna; el legacy es solo fallback temporal medido.
- Pricebook/PricebookEntry pertenecen a la Empresa correcta.
- No se inventaron datos funcionales.
- Git y Partial quedan reconciliados para el recurso desplegado.
- Pruebas y videos cubren éxito, ausencia de configuración, ambigüedad y regresión Bavarian/Otobai.
- Permisos validados con perfiles QA.
- Existe rollback documentado antes de deploy.

## Estado

Plan pendiente de revisión y aprobación. No se implementó ninguna corrección.
