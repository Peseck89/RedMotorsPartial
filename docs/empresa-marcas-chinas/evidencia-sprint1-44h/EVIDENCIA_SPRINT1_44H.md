# Evidencia de cierre — Sprint 1 Empresa / Marcas Chinas

## 1. Resumen ejecutivo

El Sprint 1 de Empresa / Marcas Chinas quedó cerrado al **100%** respecto al alcance comprometido de aproximadamente 44 horas.

| Dato | Resultado |
|---|---|
| Alcance comprometido | Aproximadamente 44 horas |
| Estado | 19/19 requerimientos completados |
| Porcentaje | 100% |
| Ambiente | RedMotorsSandbox / Partial |
| HEAD final | `83127dd2e21c6f5a60bf4c15e4b4a26030ffa049` |
| Backup | `backup/pc/redmotors-sprint1-final-44h-20260726` |
| Tag | `checkpoint/empresa-sprint1-final-44h-20260726` |

El objetivo fue crear una base escalable para manejar empresas configurables e incorporar RMPEKING, Omoda y Jaecoo sin depender de lógica fija Bavarian/Otobai en los componentes priorizados.

## 2. Alcance cubierto

- Objeto `Empresa__c` y clases de soporte.
- Resolución centralizada de empresa mediante códigos estables.
- PEKING como tercera empresa soportada.
- Record Types Omoda y Jaecoo.
- Permisos y visibilidad requeridos para el alcance.
- Pricebooks y conversiones de moneda.
- WorkOrder, Quote, trabajos, VIN Scan, Product Searcher y PDFs.
- Lead/Tráfico Omoda/Jaecoo y mappings Lead → Opportunity.
- Experiencia declarativa de Opportunity: List Views y Lightning Record Page.

## 3. Evidencia técnica resumida

| Área | Evidencia principal | Estado |
|---|---|---|
| Empresa configurable | Deploy `0AfAK000000vhrR0AQ`, commit `7f8b919` | Completado |
| Pricebooks y moneda | Deploy `0AfAK000000vlTd0AI`, deploy scheduler `0AfAK000000vllN0AQ` | Completado |
| WorkOrder | Deploy `0AfAK000000vnon0AA`, fix garantía `0AfAK000000vo4v0AA` | Completado |
| Opportunity / ProductControllerTwo | Deploy `0AfAK000000vokr0AA`, cobertura 88.046% | Completado |
| Crear Plan de Venta | Deploy `0AfAK000000vpIj0AI`, cobertura 90.55% | Completado |
| Plantillas | Deploy `0AfAK000000vpU10AI`, cobertura 76.19% | Completado |
| PDFs Quote USD/CRC | Deploys `0AfAK000000vpfJ0AQ`, `0AfAK000000vpk90AA` | Completado |
| Trabajos Quote / WorkOrder | Deploys `0AfAK000000vpx30AA`, `0AfAK000000vqGP0AY` | Completado |
| VIN Scan | Deploy `0AfAK000000vqeb0AA`, cobertura 86.74% | Completado |
| Quoter | Deploy `0AfAK000000vqt70AA`, cobertura 86.77% | Completado |
| Metadata PEKING/Omoda/Jaecoo | Deploy `0AfAK000000vrNl0AI` | Completado |
| Product Searcher | Deploy `0AfAK000000vuBx0AI`, Test Run `707AK00000GwtdT`, cobertura 94.79% | Completado |
| Modelo de interés | Deploy `0AfAK000000vtnl0AA`, Test Run `707AK00000GwjmT`, cobertura 90.066% | Completado |
| Lead/Tráfico | Deploy `0AfAK000000vuQT0AY`, Test Run `707AK00000GxONW` | Completado |
| Opportunity UI | Deploy `0AfAK000000vuTh0AI`, 8 List Views y `Opportunity_Record_Page_VN` | Completado |
| Git final | Commit `83127dd`, backup y tag final publicados | Completado |

## 4. Estado 100%

El cierre consolidado del Sprint 1 comprometido queda en:

**19/19 requerimientos completados = 100%.**

Bloque 21 está completado y desplegado. Bloque 10 no se presenta como implementado: quedó como investigación adicional bloqueada por dependencias externas y no forma parte del pendiente de las 44 horas.

## 5. Pendientes futuros no bloqueantes

| Pendiente | Motivo |
|---|---|
| Sucursal → Empresa → Pricebook / Service Territory PEKING | No existe relación operativa comprobada en Partial. |
| Llave de producto RMPEKING para Softland | No hay convención confirmada entre `Codigo_de_Producto__c` y `CodigoProductoInterno__c`. |
| `Quote.empresaFactura__c` | Es fórmula heredada desde `Opportunity.empresaQueFactura__c`; requiere decisión funcional. |
| BMW→Polaris | Anomalía histórica documentada, no modificada. |
| Softland, reservas y anticipos | Diferidos por contrato, datos y reglas financieras futuras. |
| Datos operativos PEKING | Faltan productos y PricebookEntry PEKING para operación real. |

## 6. Conclusión

El Sprint 1 de 44 horas está listo para entrega. La base técnica de empresa configurable quedó implementada, validada y documentada para el alcance comprometido. Los puntos pendientes están identificados como decisiones o datos futuros y no bloquean la entrega del lunes.
