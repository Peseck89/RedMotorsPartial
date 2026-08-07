# Plan de regresión UI — bloque 7

**Fecha:** 6 de agosto de 2026  
**Estado:** checklist preparado; sin cambios en Layouts, FlexiPages o Quick Actions

| Tipo | Componente | Record Type / activación | Perfil o asignación conocida | Verificación visual/manual | No debe cambiar | Evidencia requerida |
|---|---|---|---|---|---|---|
| Quick Action | `Quote.BMW_Duplicar_Partidas_de_Presupuesto` | Exposición genérica en Quote | Una referencia desde FlexiPage y una desde Page Layout; sin perfil demostrado | Confirmar visibilidad donde corresponda y duplicación controlada en Quote PEKING QA | Rutas Bavarian/Otobai y aislamiento de usados | Video de exposición y ejecución; captura de Quote antes/después |
| Layout | `Opportunity-Autos V1.3 - Inventario` | Omoda y Jaecoo explícitos | Una asignación por Record Type para Administrador de Sistema | Secciones, campos, botones e inventario visibles según layout | Layouts BMW/MINI y datos de usados | Capturas Omoda/Jaecoo y comparación legacy |
| Layout | `Opportunity-Autos V1.3` | Omoda y Jaecoo explícitos | 36 perfiles por cada Record Type; detalle en matriz de asignaciones | Campos, secciones, acciones y edición con perfil QA autorizado | Asignaciones de otros Record Types | Video Omoda/Jaecoo y regresión BMW/MINI |
| Layout | `Opportunity-Autos V1.4 Sin Botones` | Omoda y Jaecoo explícitos | Una asignación por Record Type para Consulta básica móvil | Ausencia esperada de botones y acceso de solo consulta | No exponer acciones ocultas; no afectar otros Record Types | Capturas móvil/escritorio con perfil QA |
| Layout | `Opportunity-Autos V1.4` | Omoda y Jaecoo explícitos | Cinco perfiles por cada Record Type; detalle en matriz | Secciones, campos, acciones y edición esperada | Asignaciones legacy y aislamiento de usados | Video por perfil QA representativo y comparación legacy |
| Layout | `Opportunity-Opportunity Layout` | Omoda y Jaecoo explícitos | 117 perfiles por cada Record Type; detalle en matriz | Render, campos y acciones con un perfil QA autorizado por función | No ampliar acceso por la sola exposición visual | Capturas por función representativa y regresión |
| Layout | `Opportunity-Vehiculos Nuevos V1.1` | Omoda y Jaecoo explícitos | Una asignación por Record Type para Administrador del sistema - Custom | Campos y acciones de vehículos nuevos | Procesos de usados excluidos | Video Omoda/Jaecoo y comparación BMW/MINI |
| FlexiPage | `Opportunity_Record_Page1` | Activación genérica App Default | Cuatro asignaciones App Default; sin perfil específico demostrado | Carga, regiones, componentes, acciones y errores de consola visibles | Activaciones existentes y rutas legacy | Video de carga Omoda/Jaecoo y regresión |
| FlexiPage | `Quote_Record_Page` | Activación genérica App Default | Una asignación App Default | Carga de página, componentes y acciones disponibles | Cotización legacy y permisos efectivos | Video de Quote PEKING QA y regresión |
| FlexiPage | `Quote_Record_Page2` | Activación genérica App Default | Dos asignaciones App Default | Carga de página, componentes y acciones disponibles | Cotización legacy y permisos efectivos | Video de Quote PEKING QA y regresión |

## Controles comunes

- Usar perfiles QA autorizados; una asignación visual no demuestra permiso de campo u objeto.
- Probar Omoda y Jaecoo por separado.
- Comparar al menos BMW y MINI sin alterar registros operativos.
- Confirmar que errores de componentes y consola no aparecen durante carga o acción.
- No modificar activaciones, Layouts, páginas ni acciones para completar la evidencia.

## Criterio de terminado

Los diez componentes pasan regresión cuando existe evidencia visual/manual de Omoda y Jaecoo, una comparación legacy representativa y ausencia de cambio en usados. La disponibilidad de perfiles QA depende de los entregables de Diego.
