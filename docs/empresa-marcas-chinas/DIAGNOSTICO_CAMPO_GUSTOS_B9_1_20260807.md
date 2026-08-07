# Diagnóstico B9-1 — Campo gustos y aficiones

Fecha: 2026-08-07  
Ambiente consultado: Partial (`RedMotorsSandbox`)  
Regla analizada: `Opportunity.Campo_Gustos_y_aficiones_Obligatorio`  
Estado: `CORRECCION_TECNICA_PROPUESTA_PENDIENTE_REVISION`

## Resultado ejecutivo

La causa raíz está en la fórmula actualmente desplegada y en la semántica del campo relacionado. La condición `ISBLANK(TEXT(Account.Gusto_y_aficiones__c))` no bloqueó la transición a `Oferta` cuando el valor persistido en la Cuenta era realmente `null`. El comportamiento se reprodujo de manera aislada con Omoda, Jaecoo y BMW usando un usuario con perfil `Asesor`.

Además, el picklist define `Por actualizar` como valor predeterminado. Ese valor no está vacío para la fórmula actual, por lo que también permite avanzar a `Oferta`. La decisión de si `Por actualizar` debe considerarse incompleto requiere confirmación funcional; el defecto que permite un `null` real sí quedó demostrado técnicamente.

No se encontró evidencia de que el caso se explique por la etapa, el Record Type, una excepción de usuario, un Flow previo, un trigger o datos que aparentaran estar vacíos.

## Fórmula desplegada

La regla está activa en Partial y su fórmula exacta es:

```text
AND(
NOT(Bypass_CheckIn_Validations_Until__c > NOW()),
NOT(ISCHANGED(alertEmail__c)),
NOT(ISCHANGED(NombreProducto__c)),
NOT(ISCHANGED(Tiene_Vehiculos_Reservados__c)),
NOT(OR(
$Profile.Name = 'System Administrator',
$Profile.Name = 'Administrador del sistema'
)),RecordType.Name = 'BMW' || RecordType.Name = 'MINI' || RecordType.Name = 'Kawasaki' || RecordType.Name = 'Motorrad' || RecordType.Name = 'Polaris' || RecordType.Name = 'Omoda' || RecordType.Name = 'Jaecoo', ISPICKVAL(StageName, "Oferta"),ISBLANK(TEXT(Account.Gusto_y_aficiones__c)))
```

Mensaje configurado:

> Para pasar a "Oferta" por favor llenar el campo “Gusto y aficiones” que se encuentra en la sección "Otra información" de la cuenta.

Ubicación del error: parte superior de la página.

## Campo validado

| Propiedad | Evidencia |
|---|---|
| Objeto y API Name | `Account.Gusto_y_aficiones__c` |
| Etiqueta | Gusto y aficiones |
| Tipo | Picklist restringido |
| Obligatorio en metadata | No |
| Fórmula | No aplica; no es campo calculado |
| Valor predeterminado | `Por actualizar`, marcado como valor default del value set |
| Valores vacíos | Un `null`, una cadena vacía y una cadena de espacios terminaron almacenados/interpretados como `null` en la reproducción Apex |
| Valor derivado | No; la regla lee el campo de la Cuenta relacionada |

La consulta Tooling del campo devolvió `Metadata.defaultValue = null`, pero el value set marca explícitamente `Por actualizar` con `default = true`. La creación con defaults de metadata confirmó que el valor efectivo es `Por actualizar`.

## Condiciones que activan o exceptúan la regla

### Etapa

La condición es exactamente `ISPICKVAL(StageName, "Oferta")`. `Oferta` existe como valor activo. La reproducción realizó la transición desde una etapa distinta hacia el valor exacto `Oferta` y confirmó después del guardado que `StageName = 'Oferta'`.

### Record Types

La fórmula compara `RecordType.Name`, no `DeveloperName`. Incluye exactamente BMW, MINI, Kawasaki, Motorrad, Polaris, Omoda y Jaecoo. Los Record Types Omoda y Jaecoo existen activos y sus nombres coinciden exactamente con la fórmula.

### Excepciones

La regla no se ejecuta cuando ocurre cualquiera de estas condiciones:

- `Bypass_CheckIn_Validations_Until__c > NOW()`.
- Cambia `alertEmail__c`.
- Cambia `NombreProducto__c`.
- Cambia `Tiene_Vehiculos_Reservados__c`.
- El perfil se llama `System Administrator` o `Administrador del sistema`.

El usuario de la reproducción ejecutó bajo el perfil `Asesor`; no coincide directa ni indirectamente con las dos excepciones de perfil. Durante la transición se comprobó: bypass sin valor, `alertEmail__c = false`, `NombreProducto__c = null` y `Tiene_Vehiculos_Reservados__c = true`, sin cambios en esos campos. Por tanto, ninguna excepción documentada explica el guardado.

## Orden de ejecución y automatización relevante

| Momento | Recurso revisado | Relación con el fallo |
|---|---|---|
| Before-save Flow | `Sincroniza_Realiza_Test_Drive` | Solo sincroniza el indicador de test drive; no cambia gustos ni campos de excepción. |
| Before-save Flow | `BodegaDelProductoEnOpp` | Actúa ante cambio de etapa y calcula bodega desde líneas/producto; no cambia gustos ni campos de excepción. |
| Validation Rule | `Campo_Gustos_y_aficiones_Obligatorio` | Evalúa después de los before-save y permite indebidamente el `null`. |
| Apex before update | `OpportunityTriggerHandler` y helpers relacionados | No pueblan `Account.Gusto_y_aficiones__c` ni activan las excepciones observadas. |
| After-save Flow | `Actualiza_Opp_IsLocked`, `ActualizarFechaCierreOportunidad` y automatización posterior | Se ejecuta después de la validación y no puede explicar que la regla haya permitido el guardado. |

La revisión quedó limitada a automatización de Opportunity con relación directa al campo, a la transición o a las excepciones. No se analizaron las otras 94 Validation Rules.

## Reproducción aislada con `@IsTest`

Se construyó una clase temporal fuera del repositorio y se ejecutó exclusivamente mediante validación `check-only`; la clase no fue desplegada. Los registros creados por `@IsTest` fueron transaccionales y se revirtieron.

Validation ID: `0AfAK0000012Bhx0AE`  
Componentes compilados: 1 de 1, sin errores de componente  
Métodos: 7 ejecutados; 3 aprobados y 4 fallidos intencionalmente por la diferencia entre el bloqueo esperado y el guardado real  
Cobertura: no aplica; la prueba temporal diagnostica una Validation Rule y el resultado no reportó cobertura Apex.

| Escenario | Valor almacenado | Resultado esperado | Resultado real |
|---|---:|---|---|
| Omoda vacío | `null` | Bloqueo | Guardó en `Oferta`; la aserción diagnóstica falló. |
| Jaecoo vacío | `null` | Bloqueo | Guardó en `Oferta`; la aserción diagnóstica falló. |
| BMW vacío | `null` | Bloqueo | Guardó en `Oferta`; la aserción diagnóstica falló. |
| Omoda con valor | `Cocina` | Permitir | Permitió correctamente. |
| Omoda con cadena vacía | `null` tras normalización | Bloqueo | Guardó en `Oferta`; la aserción diagnóstica falló. |
| Omoda con espacios | `null` tras normalización | Se comprobó semántica | La regla actual permitió el guardado. |
| Omoda con default de metadata | `Por actualizar` | Se comprobó semántica actual | La regla actual permitió el guardado porque el texto no está vacío. |

En los tres casos principales el mensaje diagnóstico confirmó simultáneamente perfil `Asesor`, etapa solicitada y persistida `Oferta`, gusto `null` y ausencia de activación de las excepciones.

## Evidencia adicional de impacto en Partial

Las consultas agregadas, sin exponer datos personales, encontraron:

- 8,317 cuentas con el campo en `null`.
- 121 cuentas con `Por actualizar`.
- Al menos una Opportunity BMW y una Kawasaki actualmente en `Oferta` con el campo de la Cuenta en `null`.
- Oportunidades Kawasaki y Motorrad en `Oferta` con `Por actualizar`.

Estos conteos no demuestran por sí solos qué interfaz o integración originó cada registro, pero sí corroboran que el comportamiento no es exclusivo del escenario temporal ni de PEKING.

## Causa raíz y descarte de hipótesis

| Hipótesis | Resultado |
|---|---|
| Fórmula de Validation Rule | **Causa confirmada:** el predicado final no detecta el `null` relacionado en el escenario reproducido. |
| Semántica del campo | **Contribuyente confirmado:** picklist opcional, vacío normalizado a `null` y placeholder default `Por actualizar`. |
| Datos de prueba | Descartado: una consulta posterior al insert confirmó `null` real y no un valor visual oculto. |
| Stage | Descartado: se usó y persistió el valor exacto `Oferta`. |
| Record Type | Descartado: Omoda, Jaecoo y BMW activos coinciden con los nombres de la fórmula. |
| Excepción de perfil/usuario | Descartado: perfil `Asesor` y campos de excepción sin cambios. |
| Automatización previa | Descartado con el alcance revisado: los before-save activos relevantes no escriben el campo relacionado ni las excepciones. |
| Automatización posterior | Descartado: ocurre después de la evaluación de Validation Rules. |

## Impacto

- **Omoda:** puede avanzar a `Oferta` con el gusto de la Cuenta realmente en `null`; el requisito no queda garantizado.
- **Jaecoo:** presenta el mismo defecto reproducible.
- **Legacy:** BMW reprodujo el mismo defecto y los agregados de Partial muestran casos BMW/Kawasaki. La falla no fue introducida únicamente por incorporar Omoda/Jaecoo.

## Cambio mínimo propuesto

Estado: `CORRECCION_TECNICA_PROPUESTA_PENDIENTE_REVISION`.

Cambiar únicamente el predicado que determina un gusto incompleto por una comprobación robusta del valor relacionado. Candidato sujeto a validación:

```text
OR(
  LEN(TRIM(TEXT(Account.Gusto_y_aficiones__c))) = 0,
  ISPICKVAL(Account.Gusto_y_aficiones__c, "Por actualizar")
)
```

Antes de aprobar esa fórmula se debe confirmar con negocio si `Por actualizar` es un valor incompleto que debe bloquear. Si negocio lo considera válido, la corrección mínima debe limitarse al vacío real. En ambos casos, la expresión final debe verificarse mediante un dry-run temporal contra la regla propuesta antes de modificar metadata.

También se recomienda, en un cambio separado solo si se autoriza, reemplazar las comparaciones de `RecordType.Name` por una estrategia estable basada en `DeveloperName`; esto no es necesario para corregir el fallo demostrado y no debe mezclarse con el cambio mínimo.

## Riesgo de corrección

El riesgo principal es ampliar correctamente el bloqueo a registros legacy ya existentes. Cuentas con `null` o, si se confirma, `Por actualizar` ya no podrían avanzar a `Oferta` hasta completar el dato. Esto puede afectar procesos BMW, MINI, Kawasaki, Motorrad y Polaris además de Omoda y Jaecoo. Deben conservarse deliberadamente las excepciones vigentes o revisarse como una decisión distinta.

## Prueba requerida después de corregir

1. Repetir Omoda vacío, Jaecoo vacío y BMW vacío; los tres deben recibir el mensaje de la regla.
2. Repetir cadena vacía y espacios; ambos deben bloquear tras su normalización.
3. Probar Omoda y Jaecoo con un valor real; deben avanzar a `Oferta`.
4. Probar el valor `Por actualizar` de acuerdo con la decisión funcional explícita.
5. Probar cada Record Type legacy listado con vacío y con valor para evitar regresión.
6. Verificar cada excepción vigente en pruebas independientes, sin confundirla con el caso normal.
7. Confirmar mediante interfaz que el usuario ve el mensaje en la parte superior y que el campo indicado pertenece a la Cuenta.
8. Adjuntar evidencia antes/después con Record Type, etapa, perfil QA y valor real consultado del campo.

## Controles de ejecución

- No se modificó metadata.
- No se realizó deploy.
- No hubo DML persistente; únicamente datos transaccionales de `@IsTest` con rollback automático.
- No se consultó Producción.
- No se revisaron las otras 94 Validation Rules.

## Actualización posterior — intento controlado de corrección

La validación check-only posterior demostró que sustituir únicamente el predicado final no corrige el defecto. Se probaron `ISPICKVAL(Account.Gusto_y_aficiones__c, "")`, `LEN(TEXT(Account.Gusto_y_aficiones__c)) = 0` y `TEXT(Account.Gusto_y_aficiones__c) = ""`. El último predicado sí detectó el `null` cuando se evaluó de forma aislada, pero la fórmula completa continuó permitiendo `Oferta`.

El aislamiento progresivo confirmó que la condición previa:

```text
NOT(Bypass_CheckIn_Validations_Until__c > NOW())
```

no habilita la regla cuando `Bypass_CheckIn_Validations_Until__c` es `null`. Los otros campos usados en excepciones conservaron exactamente sus valores antes y después de la transición. Al retirar únicamente esa condición en una prueba temporal, el mismo escenario BMW con `null` quedó bloqueado.

La corrección mínima real validada en check-only requiere dos cambios localizados:

```text
OR(
  ISBLANK(Bypass_CheckIn_Validations_Until__c),
  NOT(Bypass_CheckIn_Validations_Until__c > NOW())
)
```

y:

```text
TEXT(Account.Gusto_y_aficiones__c) = ""
```

Con ambos cambios, la validación `0AfAK0000012CNt0AM` aprobó 15 de 15 pruebas: `null` y valor real para Omoda, Jaecoo, BMW, MINI, Kawasaki, Motorrad y Polaris, más Omoda con `Por actualizar`. El valor `Por actualizar` continuó permitido.

Esta alternativa no fue desplegada ni incorporada a la metadata versionada porque modifica también la condición de bypass y la autorización recibida limitaba el cambio al predicado final. El estado permanece `CORRECCION_TECNICA_PROPUESTA_PENDIENTE_REVISION` hasta autorizar expresamente la normalización del bypass nulo.
