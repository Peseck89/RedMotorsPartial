# VN-RQ106 - Saldo pendiente: análisis y decisiones

Fecha: 2026-05-28
Fuente de instrucción: Luis Sandoval / sesión PC.
Respuestas: Diego (WhatsApp 2026-05-28).

---

## Respuesta de Diego

| Pregunta | Respuesta |
|---|---|
| ¿Qué campo usar como base para el precio de venta? | Usar `Valor_Total_Oportunidad_FX__c` |
| ¿Cómo manejar diferencias de moneda en anticipos legacy? | Sumar sin importar la diferencia de moneda |
| ¿Qué estados deben sumar en el total de anticipos aprobados? | Solo estados finales: `Aplicado` y `Vehículo reservado` |

---

## Base confirmada: Valor_Total_Oportunidad_FX__c

| Campo | Label en UI | Tipo | Fórmula |
|---|---|---|---|
| `Valor_Total_Oportunidad_FX__c` | Valor Total Oportunidad | Formula Currency | `IF(ISNULL(ValorTotal__c),0,ValorTotal__c) - IF(ISNULL(MontodeRegalias__c),0,MontodeRegalias__c)` |

Este campo descuenta regalías del total bruto de líneas de oportunidad.
Diego confirmó que es la base correcta para el cálculo de saldo.

El campo `ValorTotal__c` (SUM bruto de `OpportunityLineItem.TotalPrice`) NO se usa como base.

---

## Estados que suman en Total_Anticipos_Aprobados__c

| Estado | Suma | Motivo |
|---|---|---|
| `Aplicado` | Sí | Estado final del flujo legacy. Confirmado por Diego |
| `Vehículo reservado` | Sí | Estado final del flujo VN-RQ106. Confirmado por Diego |
| Todos los demás estados | No | No confirmados como finales |

Estados que explícitamente NO suman: `Borrador`, `En validación de Tesorería`, `Corrección requerida por Tesorería`, `Rechazada por Tesorería`, `Confirmada por Tesorería`, `Anticipo en creación`, `Anticipo creado`, `PDF de anticipo pendiente`, `Pendiente reserva de vehículo`, `Reserva rechazada`, `Error de integración`, `Cancelado`, `Abierto`.

Nota: estados como `Anticipo creado`, `PDF de anticipo pendiente` y `Pendiente reserva de vehículo` quedaron fuera por instrucción explícita de Diego. Solo los dos estados finales (`Aplicado`, `Vehículo reservado`) suman.

---

## Riesgo de multi-moneda — aceptado por Diego

El análisis previo detectó que existen anticipos legacy en RedMotorsSandbox con `CurrencyIsoCode` diferente al de su Opportunity padre (por ejemplo, CRC sobre Opportunity en USD).

Diego autorizó explícitamente sumar sin importar la diferencia de moneda. El Roll-Up Summary de Salesforce convertirá automáticamente usando el tipo de cambio activo del día.

Riesgo residual documentado: si los tipos de cambio históricos difieren del tipo activo, el total puede no coincidir con el valor original de cada anticipo legacy. Diego aceptó esta condición.

---

## Decisión técnica

| Campo | Tipo | Motivo |
|---|---|---|
| `Total_Anticipos_Aprobados__c` en Opportunity | Roll-Up Summary (SUM) | La relación `Anticipo__c.Oportunidad__c` es Master-Detail. Roll-Up nativo soportado sin código |
| `Saldo_Pendiente__c` en Opportunity | Formula Currency | Derivado directo de dos campos de Opportunity. Sin lógica adicional |

No se usa Flow ni Apex para estos campos. El Roll-Up recalcula automáticamente en insert, update y delete de Anticipo__c.

---

## Especificación técnica de los campos creados

### Total_Anticipos_Aprobados__c

```
Objeto:          Opportunity
Tipo:            Roll-Up Summary
Operación:       SUM
Campo sumado:    Anticipo__c.Monto__c
Relación:        Anticipo__c.Oportunidad__c
Filtro:          Estatus__c equals Aplicado, Vehículo reservado
Label:           Total anticipos aprobados
```

### Saldo_Pendiente__c

```
Objeto:          Opportunity
Tipo:            Formula Currency
Fórmula:         BLANKVALUE(Valor_Total_Oportunidad_FX__c, 0) - BLANKVALUE(Total_Anticipos_Aprobados__c, 0)
Label:           Saldo pendiente
Precision:       18
Scale:           2
```

---

## Archivos creados en esta sesión

| Archivo | Tipo | Contenido |
|---|---|---|
| `force-app/main/default/objects/Opportunity/fields/Total_Anticipos_Aprobados__c.field-meta.xml` | Campo nuevo | Roll-Up Summary con filtro de estados |
| `force-app/main/default/objects/Opportunity/fields/Saldo_Pendiente__c.field-meta.xml` | Campo nuevo | Formula Currency |
| `force-app/main/default/permissionsets/VN_RQ106_Anticipo.permissionset-meta.xml` | Actualizado | Read access a ambos campos en Opportunity |

---

## Pendientes antes del deploy

1. Confirmar en Sandbox si el filtro de Roll-Up con valor `Aplicado,Vehículo reservado` es aceptado por el parser de Salesforce, o si requiere ajuste de sintaxis (punto y coma en lugar de coma).
2. Validar que `Valor_Total_Oportunidad_FX__c` no sea nulo en registros reales de Sandbox.
3. Confirmar si se quiere mostrar `Total_Anticipos_Aprobados__c` y `Saldo_Pendiente__c` en el modal LWC VN-RQ106. Si sí, requiere agregar campos al SOQL de `getOpportunityContext` y al HTML del componente (cambio futuro, no de esta sesión).
4. Agregar ambos campos al Permission Set de producción si aplica (fuera del alcance de esta sesión).

---

## Nota sobre estados pendientes de confirmación

En el análisis previo se identificaron estos estados como zona gris para la suma:
- `Confirmada por Tesorería` — Tesorería aprobó, pero Softland aún no procesó.
- `Anticipo en creación` — Softland en proceso.
- `Anticipo creado` — Softland creó el anticipo.
- `PDF de anticipo pendiente` — Anticipo en Softland, esperando PDF.

Diego confirmó que solo `Aplicado` y `Vehículo reservado` suman. Los estados intermedios del flujo VN-RQ106 quedan fuera del total hasta que se actualice el estado al final del proceso.
