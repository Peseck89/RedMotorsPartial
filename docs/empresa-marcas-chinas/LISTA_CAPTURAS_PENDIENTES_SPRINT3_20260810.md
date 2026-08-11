# Lista de capturas pendientes para Claudia — Sprint 3 PEKING (actualizada tras revisión de los 3 videos)

**Fecha:** 10 de agosto de 2026 — actualizada después de que Claudia grabó y revisó:
`Evidencia Sprint 3 - Opportunity Omoda - Venta Nueva PEKING.mp4`,
`Evidencia Sprint 3 - Opportunity Jaecoo - Venta Nueva PEKING.mp4`,
`Evidencia Sprint 3 - Opportunity BMW - Comparacion Venta Nueva.mp4`.

**Org:** Partial (`RedMotorsSandbox`) — nunca Producción.

---

## Ya grabado y revisado — no repetir

Los 3 videos anteriores ya cubren, con evidencia visual completa: la carga sin errores de la Opportunity para
Omoda/Jaecoo/BMW, el Record Type correcto en cada una, la Etapa "Interesado", Sucursal, Pricebook "PEKING Local"
(identificado como selección QA), Forma de Pago, datos comerciales suficientes, y la diferencia real de jerarquía
(Director/Gerente/Jefe de Sucursal poblados en BMW, vacíos en Omoda/Jaecoo). Ver el detalle exacto de qué muestra
cada uno en `EVIDENCIAS_NEGOCIO_SPRINT3_20260810.md` sección 6.1.

**No se necesita** video de Lead Omoda/Jaecoo (ya hay evidencia técnica suficiente: se probó por dos vías
independientes que el registro se puede crear) ni un recorrido adicional de Quote — con la única excepción de la
Evidencia 1 de abajo.

---

## Evidencia 1 — Pestaña "Agregar extras" en el Presupuesto Omoda (única captura pendiente)

- **Por qué:** antes de esta ronda, esta pestaña no aparecía en el Presupuesto de una venta Omoda/Jaecoo; ahora sí,
  por el ajuste hecho el mismo día al indicador interno de "vehículo nuevo". Es un antes/después concreto que se
  explica mucho mejor viéndolo que describiéndolo.
- **Duración:** 10-15 segundos — no hace falta un recorrido completo del Presupuesto.
- **Pantalla:** vista de registro de Quote/Presupuesto.
- **Registro a usar:** cualquier Presupuesto QA de Omoda ya existente (o el que se use para la evidencia de
  Presupuesto), o crear uno nuevo siguiendo el mismo patrón de las Opportunities ya grabadas.
- **Qué debe verse:** abrir el Presupuesto Omoda y mostrar que la pestaña "Agregar extras" está presente y
  disponible.
- **Qué demuestra para negocio:** que el ajuste que se hizo para reconocer a Omoda/Jaecoo como "vehículo nuevo" ya
  tiene efecto visible en la pantalla real, no solo en los datos internos.

---

## Todo lo demás — no requiere captura, por qué

| Frente | Por qué no hace falta una captura |
|---|---|
| Validation Rules | Ya se probaron 15/15 escenarios de forma dirigida y documentada — no es algo que se vea mejor en video |
| Approval Processes de descuento | La lógica ya está resuelta; falta que Diego termine la jerarquía — grabar ahora no aportaría nada nuevo |
| Centro de costo | Ya se confirmó dos veces que entra correctamente a "Pendiente de aprobación" — la aprobación real depende de datos oficiales, no de una grabación |
| Softland / catálogos | 36/36 pruebas automatizadas ya documentadas; el contenido real depende de datos oficiales |
| 54 elementos UI restantes | La mayoría requiere una decisión de negocio (Taller, otros segmentos, plantillas) antes de que grabar tenga sentido — grabar un elemento sin saber su asignación final no sería evidencia útil |
| `Opportunity_Record_Page_VN` | Bloqueado por la confirmación de Diego sobre el renombre de perfiles, no por falta de grabación |

---

## Al terminar

Avisar cuando la Evidencia 1 esté grabada. Si se crea algún registro QA adicional solo para esta captura, seguir
el mismo prefijo (`QA_PEKING_S3_EVIDENCIA`) y avisar para poder eliminarlo después si no hace falta conservarlo.
