# Preguntas pendientes después de S3-0

## Luis — alcance, asignación y autorización

1. **Bloques 8, 12, 13 y 14:** ¿confirma que List Views, Global Value Sets, Pricebooks/PricebookEntry y E2E/regresión continúan fuera de Sprint 3 hasta que se asigne expresamente su Sprint? Desbloquea la planificación sin absorber alcance silenciosamente.
2. **Conciliación técnica de `Opportunity_Record_Page_VN`:** ¿autoriza preparar un lote separado para incorporar en Git la Quick Action que existe en Partial, sin deploy ni cambio funcional? Desbloquea una base técnica consistente.
3. **Primer lote funcional:** una vez resueltos los bloqueos nominales, ¿confirma que debe revisarse nuevamente antes de cualquier implementación? Desbloquea el criterio formal de inicio de S3-1.

## Diego — Softland y configuración técnica

1. **Mecanismo autoritativo:** sin compartir valores sensibles, ¿qué tipo de configuración y nombre lógico deben tomarse como fuente para resolver los endpoints Softland existentes? Desbloquea `Mecanismo_configurable_endpoints_Softland` y S3-4.
2. **Consumidores RMPEKING:** ¿qué consumidores actuales deben reconocer explícitamente el contexto RMPEKING y cuál es la señal verificable de que usan la configuración correcta? Desbloquea la validación de los tres registros Empresa y las dependencias Apex, sin refactorizarlas en Sprint 3.
3. **Bodegas y catálogos:** ¿qué dependencias técnicas deben quedar únicamente registradas como pendientes de Sprint 1 y cuáles forman parte de la validación de configuración del bloque 11? Desbloquea la separación de responsabilidades sin inventar configuración.

## Negocio — reglas y operación

1. **Default VN:** ¿cuál es la regla comercial para resolver el Pricebook VN de PEKING cuando no existe una selección explícita válida? Desbloquea `RM_Config.Default_Price_List_VN`. Recomendación: resolución por Empresa y error controlado, nunca por nombre Bavarian fijo.
2. **Descuentos:** ¿las mismas reglas y niveles de aprobación de BMW/MINI aplican a Omoda y Jaecoo, o existen umbrales distintos? Desbloquea cinco Validation Rules y ocho Approval Processes de Opportunity.
3. **Centros de costo:** ¿qué reglas y responsables aplican a Quote y WorkOrder PEKING? Desbloquea cuatro Validation Rules y dos Approval Processes de centro de costo.
4. **Garantía:** ¿qué criterios y roles funcionales deben aprobar garantías PEKING? Desbloquea `PROCESO_DE_APROB_GARANTIA` y `PROCESO_DE_APROB_GARANTIA_CITA_TALLER`. No se solicitan nombres personales en esta fase.
5. **Identidad y plantillas:** ¿cuáles son la identidad, plantilla y remitente oficiales para correo/PDF PEKING? Desbloquea `BMW_EnviarCorreoPresupuesto`.
6. **Moneda, plantillas y catálogos:** ¿qué configuraciones oficiales aplican a importar plantillas y cambiar moneda en WorkOrder/Quote PEKING? Desbloquea los Quick Actions correspondientes.
7. **Jerarquía y acceso:** ¿qué jerarquía funcional requiere PEKING para ventas y postventa? Desbloquea la decisión sobre los 15 roles actuales y cualquier propuesta separada de seguridad. No se asumirá que la visibilidad de una página equivale a acceso a registros.

## Ajuste posterior S3-0.1 — 2026-08-06

No se repiten preguntas ya resueltas. Se agregan únicamente estas precisiones:

- **Luis — selección de baseline:** de los 46 Layouts y 23 FlexiPages candidatos, ¿autoriza primero un sublote para demostrar asignaciones y luego presentar el subconjunto a versionar? Desbloquea el baseline del bloque 7 sin autorizar `Opportunity_Record_Page_VN`.
- **Diego — identificación Softland:** sin revelar valores, endpoints ni secretos, confirmar el nombre API y tipo de metadata que constituye la fuente autoritativa. Desbloquea el placeholder, que sigue fuera del conteo nominal.

No se formula una nueva pregunta a negocio: las decisiones funcionales sobre descuentos, centros de costo, garantía, identidad, plantillas, moneda, catálogos y jerarquía ya están enumeradas arriba.
