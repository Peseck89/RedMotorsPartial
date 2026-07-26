# Resumen ejecutivo — Sprint 1 Empresa / Marcas Chinas

## Resultado general

El Sprint 1 comprometido para Empresa / Marcas Chinas quedó cerrado al **100%**:

| Dato | Resultado |
|---|---|
| Alcance comprometido | Aproximadamente 44 horas |
| Estado final | 19/19 requerimientos completados |
| Porcentaje | 100% |
| Ambiente validado | RedMotorsSandbox / Partial |
| HEAD final documentado | `83127dd2e21c6f5a60bf4c15e4b4a26030ffa049` |
| Respaldo Git | `backup/pc/redmotors-sprint1-final-44h-20260726` |
| Tag | `checkpoint/empresa-sprint1-final-44h-20260726` |

## Qué solicitó Luis

Luis solicitó avanzar con un primer alcance aproximado de 44 horas para habilitar una estructura escalable de empresa configurable y permitir la incorporación de la nueva empresa PEKING y las marcas chinas Omoda y Jaecoo, priorizando cambios técnicos claros, de bajo riesgo y documentados.

## Objetivo técnico

El objetivo principal fue dejar de depender de lógica rígida Bavarian/Otobai en los componentes priorizados y avanzar hacia una arquitectura donde la empresa operadora se resuelve mediante configuración, usando `Empresa__c` y códigos estables como `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`.

## Principales resultados

- Se creó la base de configuración de `Empresa__c`.
- Se implementó `EmpresaResolver` como mecanismo central para resolver empresas.
- Se incorporó `RMPEKING` como nueva empresa soportada.
- Se crearon y validaron los Record Types Omoda y Jaecoo.
- Se agregó soporte PEKING en Pricebooks, conversiones, PDF de cotización, WorkOrder, Quote, trabajos, VIN Scan, Product Searcher, Lead/Tráfico y creación de Opportunity desde modelo de interés.
- Se completó la experiencia declarativa de Opportunity para Omoda y Jaecoo con List Views y Lightning Record Page.
- Se documentaron explícitamente los pendientes futuros que no forman parte del cierre de las 44 horas.

## Estado para entrega

El alcance comprometido para el lunes queda completo. Los pendientes identificados son dependencias futuras o decisiones externas, no bloqueos del Sprint 1 de 44 horas.
