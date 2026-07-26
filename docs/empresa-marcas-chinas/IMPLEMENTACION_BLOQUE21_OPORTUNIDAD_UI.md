# Bloque 21 — Experiencia declarativa de Opportunity para Omoda y Jaecoo

## Objetivo

Completar la experiencia declarativa de Opportunity para las nuevas marcas
Omoda y Jaecoo replicando únicamente patrones existentes de BMW que fueran
equivalentes y comprobables.

Ambiente autorizado: RedMotorsSandbox / Partial. Producción queda fuera de
alcance.

## Evidencia recuperada

Se revisó metadata declarativa de Opportunity relacionada con:

- Record Types;
- layouts;
- Lightning Record Pages;
- List Views;
- Quick Actions;
- PathAssistant.

La comparación confirmó:

- `Opportunity.Omoda` y `Opportunity.Jaecoo` ya existen, están activos y
  conservan el patrón de `Opportunity.BMW` definido previamente:
  `businessProcess=Autos`, `compactLayoutAssignment=Vehiculos_Nuevos` y mismos
  valores de picklist relevantes.
- No se requiere crear layouts ni Lightning Record Pages nuevas.
- `Opportunity_Record_Page_VN` es la Lightning Record Page relevante para
  vehículos nuevos.
- En esa página existen campos visibles solo para `BMW` y `MINI` mediante
  `Record.RecordTypeName__c`.
- Las List Views de BMW tienen un patrón directo por marca para oportunidades
  abiertas, ganadas, perdidas propias y perdidas de equipo.

No se encontró evidencia técnica que justificara modificar:

- Flows;
- perfiles;
- permisos;
- seguridad;
- datos;
- sucursales;
- territorios;
- Softland;
- reservas;
- anticipos.

## Cambios implementados

### Lightning Record Page

Se actualizó `Opportunity_Record_Page_VN` para que los mismos campos visibles
en BMW/MINI también sean visibles en Omoda/Jaecoo:

- `Asignado_original__c`;
- `Reasignado_por__c`;
- `Fecha_de_reasignaci_n__c`.

La regla cambió de `BMW OR MINI` a `BMW OR MINI OR Omoda OR Jaecoo`.

No se modificaron acciones, componentes, perfiles, permisos ni activaciones.

### List Views

Se crearon ocho List Views copiadas desde el patrón BMW:

- `Oportunidades_abiertas_Omoda`;
- `Oportunidades_ganadas_Omoda`;
- `Oportunidades_Perdidas_Omoda`;
- `Todas_Oportunidades_Perdidas_Omoda`;
- `Oportunidades_abiertas_Jaecoo`;
- `Oportunidades_ganadas_Jaecoo`;
- `Oportunidades_Perdidas_Jaecoo`;
- `Todas_Oportunidades_Perdidas_Jaecoo`.

Cada List View conserva:

- columnas;
- alcance de filtro;
- filtros de etapa;
- compartición declarativa;
- y cambia únicamente el filtro de Record Type hacia `Opportunity.Omoda` o
  `Opportunity.Jaecoo`.

## Fuera de alcance

No se modificaron:

- Apex;
- Lead;
- seguridad;
- perfiles;
- Flows;
- datos;
- Softland;
- reservas;
- anticipos;
- sucursales;
- territorios;
- anomalías previas de mappings.

## Manifest

El manifest del bloque incluye únicamente:

- `FlexiPage`: `Opportunity_Record_Page_VN`;
- ocho `ListView` de Opportunity para Omoda y Jaecoo.

## Estado de validación

Dry-run declarativo:

- Deploy ID: `0AfAK000000vtcU0AQ`
- Componentes: 9/9
- Pruebas Apex: NoTestRun
- Fallas: 0
- Estado: Succeeded

Deploy real:

- Deploy ID: `0AfAK000000vuTh0AI`
- Ambiente: RedMotorsSandbox / Partial
- Componentes: 9/9
- Pruebas Apex: NoTestRun
- Fallas: 0
- Estado: Succeeded

Verificación post-deploy:

- Existen las ocho List Views de Opportunity para Omoda y Jaecoo.
- `Opportunity_Record_Page_VN` existe y fue actualizada.
- No se modificaron Apex, Lead, seguridad, perfiles, Flows, datos, Softland,
  reservas, anticipos, sucursales ni territorios.

Estado final: Bloque 21 completado, validado y desplegado.

Avance técnico estimado: 87% completado y 13% pendiente. Corresponde al alcance
técnico y no representa horas oficiales, trabajadas ni facturables.
