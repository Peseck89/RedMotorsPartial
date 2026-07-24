# Implementación del Bloque 1 — Modelo Empresa y soporte

## Estado

Bloque 1 desplegado correctamente en `RedMotorsSandbox`.

El objeto `Empresa__c` y las clases de soporte
`EmpresaConfigurationException`, `EmpresaContext` y `EmpresaResolver` están
disponibles en el Sandbox. Ningún consumidor ni trigger utiliza todavía
`EmpresaResolver`.

No se crearon registros de Empresa. La nueva empresa todavía no está activa
operativamente.

## Archivos creados

### Metadata

- `objects/Empresa__c/Empresa__c.object-meta.xml`
- `objects/Empresa__c/fields/Codigo__c.field-meta.xml`
- `objects/Empresa__c/fields/Codigo_ERP__c.field-meta.xml`
- `objects/Empresa__c/fields/Nombre_Legal__c.field-meta.xml`
- `objects/Empresa__c/fields/Activa__c.field-meta.xml`

### Apex

- `EmpresaContext.cls`
- `EmpresaContextTest.cls`
- `EmpresaConfigurationException.cls`
- `EmpresaResolver.cls`
- `EmpresaResolverTest.cls`
- archivos `.cls-meta.xml` correspondientes.

## Decisiones de metadata

| Elemento | Decisión | Motivo |
|---|---|---|
| API Apex | 61.0 | Coincide con clases actuales del repositorio. |
| Name | Texto, etiqueta “Nombre de Empresa” | Nombre visible; no se usa como clave técnica. |
| `Codigo__c` | Text(80), requerido, Unique, External ID, case-insensitive | Clave estable y portable. |
| `Codigo_ERP__c` | Text(80), opcional en metadata | El resolver lo exige para una empresa activa/configurada; permite preparar registros incompletos sin activarlos funcionalmente. |
| `Nombre_Legal__c` | Text(255), opcional en metadata | El resolver lo exige para considerar completa una empresa. |
| `Activa__c` | Checkbox, default true | Requisito aprobado. El resolver rechaza valores falsos. |
| Sharing | ReadWrite | Maestro operativo sin modelo de acceso definido todavía. Debe revisarse antes de producción. |
| Reportes | Habilitados | Facilita validación y gobierno del maestro. |
| Actividades/Feeds/History | Deshabilitados | No requeridos por el alcance mínimo. |

El repositorio no contenía metadata de objetos comparable. Las longitudes y propiedades anteriores son decisiones explícitas del Bloque 1, no convenciones inferidas.

## APIs públicas

### `EmpresaResolver`

```apex
EmpresaContext resolve(Id empresaId)
EmpresaContext resolveByCodigo(String codigo)
Map<Id, EmpresaContext> resolveAll(Set<Id> empresaIds)
Map<String, EmpresaContext> resolveAllByCodigo(Set<String> codigos)
```

Características:

- consultas por colección;
- una consulta para cada conjunto no cacheado;
- cache estático por transacción;
- normalización del código con `trim().toUpperCase()`;
- ninguna consulta por `Name`;
- ninguna rama default a Bavarian;
- excepciones ante nulo, desconocido, inactivo o incompleto.

### `EmpresaContext`

Propiedades de solo lectura externa:

- `empresaId`;
- `codigo`;
- `codigoErp`;
- `nombreLegal`;
- `activa`;
- `configurationStatus`.

Métodos:

```apex
Boolean isConfigured()
Boolean isActive()
String requireCodigoErp()
String requireNombreLegal()
```

No contiene SOQL ni conoce consumidores.

El constructor valida todas las invariantes antes de asignar
`configurationStatus = CONFIGURED`: Id no nulo, código no vacío, empresa activa,
código ERP presente y nombre legal presente. Por tanto, un consumidor no puede
crear directamente un contexto incompleto que se anuncie como configurado.

### `EmpresaConfigurationException`

Excepción controlada usada por resolver y contexto para impedir continuidad silenciosa.

## Pruebas creadas

`EmpresaResolverTest` cubre:

- Bavarian;
- Otobai;
- empresa nueva genérica;
- empresa activa;
- empresa inactiva;
- Id nulo;
- código nulo, vacío o compuesto por espacios;
- código inexistente;
- configuración sin código ERP;
- configuración sin nombre legal;
- resolución bulk de 200 códigos con una consulta;
- resolución bulk de 200 Ids con una consulta y claves idénticas a las solicitadas;
- colecciones vacías sin consultas;
- ausencia de fallback implícito a Bavarian;
- resolución independiente del campo `Name`.

Los tests crean todos sus datos y no dependen de registros del org.

`EmpresaContextTest` cubre directamente:

- construcción válida;
- getters de Id, código, código ERP, nombre legal, activa y estado;
- estado `CONFIGURED` únicamente después de validar todas las invariantes;
- Id nulo;
- código nulo;
- código vacío;
- empresa inactiva;
- código ERP faltante;
- nombre legal faltante;
- métodos `isConfigured`, `isActive`, `requireCodigoErp` y
  `requireNombreLegal`;
- defensas de código ERP y nombre legal ante un contexto incompleto
  deserializado sin pasar por el constructor;
- tipo y contenido funcional de las excepciones.

## Resultado del primer dry-run

| Dato | Resultado |
|---|---|
| Deploy ID | `0AfAK000000vhkz0AA` |
| Componentes | 9/9 correctos |
| Tests | 9/9 aprobados |
| Fallas de tests | 0 |
| Único bloqueo | `EmpresaContext` con 52.381% de cobertura; mínimo requerido 75% |

Corrección aplicada: se agregó `EmpresaContextTest` con cobertura directa de todas
las ramas alcanzables del constructor, getters y métodos públicos. La corrección
quedó validada por el deploy real, que ejecutó `EmpresaResolverTest` y
`EmpresaContextTest` sin fallas.

## Resultado del deploy real

| Dato | Resultado |
|---|---|
| Estado | Exitoso |
| Deploy ID | `0AfAK000000vhrR0AQ` |
| Componentes | 10/10 desplegados |
| Tests | 18/18 aprobados |
| Fallas | 0 |
| Ambiente | `RedMotorsSandbox` |

El deploy confirmó la disponibilidad del objeto `Empresa__c`, sus campos y las
clases de soporte. Este resultado no habilita funcionalmente una empresa nueva:
todavía no existen registros de Empresa ni consumidores conectados al resolver.

## Recomendación de permisos

El repositorio no contiene metadata de Permission Sets ni perfiles que permita
identificar un patrón existente reutilizable para este maestro. Por trazabilidad
y mínimo privilegio, se recomienda crear un Permission Set específico para la
administración de Empresas en una tarea posterior.

El permiso propuesto debe contemplar:

- acceso de lectura, creación y edición a `Empresa__c`;
- acceso de lectura y edición a `Codigo__c`, `Codigo_ERP__c`,
  `Nombre_Legal__c` y `Activa__c`;
- acceso a las clases Apex `EmpresaResolver` y `EmpresaContext`;
- eliminación de registros únicamente si negocio confirma que forma parte de
  las responsabilidades del administrador de Empresas.

Los permisos para usuarios consumidores deben evaluarse separadamente cuando se
integren las clases funcionales. No se creó ni modificó ningún Permission Set en
este bloque.

## Supuestos

- Una empresa activa solo está completamente configurada cuando tiene `Codigo__c`, `Codigo_ERP__c` y `Nombre_Legal__c`.
- La misma configuración mínima se valida tanto en `EmpresaResolver` como en el
  constructor público de `EmpresaContext`, como defensa ante construcción directa.
- Los códigos se comparan sin distinguir mayúsculas/minúsculas.
- La nueva empresa utilizará Softland; si existen empresas activas sin ERP, deberá incorporarse un indicador explícito en un sprint posterior.
- No se crean todavía registros semilla, permisos ni relaciones con objetos transaccionales.

## Riesgos y decisiones pendientes

1. Confirmar si `ReadWrite` es el sharing definitivo.
2. Aprobar la creación del Permission Set específico y definir responsables de
   mantenimiento.
3. Confirmar si todas las empresas activas requieren integración ERP.
4. Confirmar códigos finales de Bavarian, Otobai y la nueva empresa.
5. Definir estrategia de carga inicial sin guardar Ids en código.
6. Evaluar Field History para cambios en códigos y estado.
7. Los consumidores existentes todavía no usan el resolver; la nueva empresa no debe activarse operativamente.

## Cómo validar el bloque

1. Revisar metadata y nombres API.
2. Confirmar el deploy exitoso `0AfAK000000vhrR0AQ` en `RedMotorsSandbox`.
3. Ejecutar `EmpresaResolverTest` y `EmpresaContextTest`.
4. Confirmar que la prueba bulk usa una sola consulta.
5. Crear registros controlados de Bavarian, Otobai y empresa nueva.
6. Verificar unicidad de `Codigo__c`.
7. Verificar que empresa inactiva, nula, desconocida o incompleta produzca excepción.
8. No habilitar consumidores hasta completar los siguientes bloques.

## Estimación consumida

Estimación técnica equivalente del trabajo local realizado:

| Actividad | Horas estimadas |
|---|---:|
| Revisión de línea base, restricciones y patrones locales | 1.0 |
| Diseño y creación de metadata | 1.5 |
| Diseño de contexto, excepción y resolver bulkificado | 2.0 |
| Pruebas unitarias y casos negativos | 2.0 |
| Pruebas específicas y corrección de cobertura de `EmpresaContext` | 1.0 |
| Validación estática, revisión de permisos y documentación | 1.0 |
| **Consumido estimado** | **8.5** |
| **Reserva del bloque de 14 horas** | **5.5** |

La reserva debe cubrir definición e implementación posterior de permisos,
configuración inicial controlada, evidencia y ajustes derivados de la adopción
por los primeros consumidores. No se contabiliza como trabajo ya ejecutado.
