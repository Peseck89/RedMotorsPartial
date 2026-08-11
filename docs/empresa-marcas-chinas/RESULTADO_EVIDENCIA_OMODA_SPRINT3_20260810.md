# Resultado — Evidencia Opportunity Omoda (registro completo listo para grabar)

**Fecha:** 10 de agosto de 2026
**Org:** Partial (`RedMotorsSandbox`) exclusivamente.
**Fuente usada:** `GUIA_CREACION_MANUAL_OPPORTUNITY_OMODA_JAECOO_SPRINT3_20260810.md`, sección 6. No se volvió a
investigar el proceso desde cero.

---

## 1. Registro creado

| Dato | Valor |
|---|---|
| Id de la Opportunity | `006AK00000JOSOPYA5` |
| Nombre final (autogenerado, ver hallazgo abajo) | `QA_PEKING_S3_EVIDENCIA - Cliente Omoda-Omoda-10/08/2026` |
| URL directa en Partial | `https://redmotors--partial.sandbox.my.salesforce.com/lightning/r/Opportunity/006AK00000JOSOPYA5/view` |
| Account usada | `QA_PEKING_S3_EVIDENCIA - Cliente Omoda` (`001AK00000PQ172YAD`) |
| Contact QA creado para el campo Contacto | `003AK00000KcCz7YAF` |

---

## 2. Campos obligatorios — poblados

| Campo | Valor guardado |
|---|---|
| Record Type | Omoda |
| Cuenta | `QA_PEKING_S3_EVIDENCIA - Cliente Omoda` |
| Cuenta de Facturación | La misma cuenta |
| Campaña | `Motorrad Expo 2 Ruedas 2019` (placeholder técnico existente — ver nota) |
| Sucursal | Escazú (placeholder — no hay sucursal oficial PEKING) |
| Nombre del Producto | Omoda C5 (prueba QA) |
| Moneda | CRC |
| Departamento | Ventas |
| Fecha de Cierre | 2026-09-09 |
| Etapa | Interesado |
| Origen del Lead | Página Web |
| Correo del Cliente | `qa.peking.evidencia.omoda@example.com` (corregido — ver hallazgo abajo) |
| Forma de Pago | Contado |
| Entidad | No aplica |
| Tipo de Cliente | Conquista |

## 3. Campos recomendados — poblados

| Campo | Valor guardado |
|---|---|
| Lista de Precios (Pricebook) | **PEKING Local** — selección QA explícita para esta prueba, **no es el default oficial** (sigue sin existir una regla de negocio que decida entre PEKING Local y PEKING Dólares) |
| Observaciones | "Registro QA Sprint 3 - Omoda - evidencia funcional. Pricebook PEKING Local elegido como selección QA para esta prueba, no representa el default oficial de negocio (pendiente de definir entre PEKING Local y PEKING Dólares)." |
| Fecha posible de compra | 1 a 3 meses |
| Contacto | Contact QA ligado a la misma cuenta |
| Monto | ₡15.000.000 (monto ficticio de ejemplo) |
| Vendedor | Verdadero (es una casilla Sí/No, no un nombre — ver corrección en la guía) |

## 4. Campos que permanecen vacíos — y por qué es correcto

| Campo | Por qué está vacío |
|---|---|
| VIN / Placa del vehículo | Etapa posterior — se asigna al reservar un vehículo específico |
| Aprobador / Descuento Aprobado | Etapa posterior — solo si se solicita un descuento |
| Entregado / Fecha de entrega | Etapa posterior — al finalizar la venta |
| Facturado / Fecha de factura | Etapa posterior — al facturar |
| Sección Financiamiento | No aplica — la prueba usa "Contado" |
| **Director de Ventas / Gerente de Sucursal / Jefe de Sucursal** | **No se autocompletan para Omoda** — hallazgo ya documentado (el código que los llena no tiene una rama para Omoda/Jaecoo). **No se falsearon** estos datos, tal como se pidió explícitamente |
| Empresa (`Empresa_Operadora__c`) | Este campo no aparece en el formulario de creación para ninguna marca — no se llenó, es coherente con lo ya documentado |

---

## 5. Hallazgos nuevos encontrados al preparar esta evidencia real (no estaban confirmados antes)

1. **El campo Nombre de la Oportunidad se reemplaza siempre al guardar**, con el patrón
   `{Nombre de la Cuenta}-{Marca}-{Fecha}`. No es un comportamiento especial de esta prueba: está en el código del
   trigger (`OpportunityTriggerHandler`) y aplica a cualquier marca. Se corrigió la guía para dejarlo claro.
2. **El campo Correo del Cliente no toma el valor que se escribe en el formulario de creación** — el mismo trigger
   lo sobrescribe siempre con el correo de la Cuenta (`CorreoElectronicoEmpresarial__c` si es cuenta empresarial).
   Como la Cuenta QA no tenía ese campo cargado, el correo quedó vacío en el primer guardado. Se corrigió
   actualizando el correo de la Cuenta y luego editando el campo directamente en la Oportunidad — ambos pasos
   quedaron reflejados en el registro final. Se corrigió la guía para que la próxima vez (Jaecoo/BMW) se cargue el
   correo en la Cuenta *antes* de crear la Oportunidad, evitando este paso extra.
3. **"Vendedor" (`Vendedor__c`) es una casilla verdadero/falso, no un campo de texto con el nombre del asesor** —
   la guía anterior asumía incorrectamente que era un campo de texto/lookup; se corrigió.

Ninguno de estos 3 hallazgos es específico de PEKING — los tres aplican igual para BMW/MINI. Se documentan aquí
porque se descubrieron al ejecutar la creación real por primera vez, no durante el análisis previo.

---

## 6. Confirmaciones de seguridad

| Verificación | Resultado |
|---|---|
| Emails enviados | 0 (confirmado en los límites acumulados de cada inserción/actualización) |
| Callouts reales | 0 |
| Jobs asíncronos activos generados hoy | 0 (`AsyncApexJob` en estado activo/pendiente = 0) |
| Reservas, pedidos, aprobaciones | Ninguno — no se ejecutó ninguna acción de ese tipo |
| `Flag_Vehiculo_Nuevo_FM__c` | `true` — confirma que el ajuste de la ronda anterior (Omoda como vehículo nuevo) funciona con un registro creado de forma realista, no solo con datos técnicos mínimos |

---

## 7. Capacidad de video — resultado honesto

**`VIDEO_GUI_NO_DISPONIBLE_EN_CODE`**

No tengo control real del escritorio de Windows: no puedo abrir ni manejar un navegador de forma interactiva, no
puedo operar la aplicación "Recortes"/Snipping Tool, ni iniciar/detener una grabación de pantalla. Las
herramientas disponibles en esta sesión son de línea de comandos y archivos (Salesforce CLI, Git, lectura/edición
de archivos) — ninguna controla la interfaz gráfica de Windows. No se simuló ni se afirmó falsamente que existe un
video.

### Pasos exactos para que Claudia grabe el video

1. Abrir el navegador y entrar a Partial (`RedMotorsSandbox`) con el usuario administrador.
2. Ir directamente a esta URL (o buscar el registro por nombre en Oportunidades):
   `https://redmotors--partial.sandbox.my.salesforce.com/lightning/r/Opportunity/006AK00000JOSOPYA5/view`
3. Confirmar visualmente, antes de grabar, que la página carga sin errores.
4. Abrir la aplicación **Recortes** de Windows (Snipping Tool) → elegir la opción de **grabación de video**.
5. Seleccionar la ventana o región donde está el navegador con Salesforce.
6. Iniciar la grabación.
7. Mostrar, deteniéndose 2-3 segundos en cada uno:
   - Que la barra de direcciones/el encabezado confirma que es el Sandbox `Partial` (no Producción).
   - El nombre del registro (`...Cliente Omoda-Omoda-10/08/2026`) y el Record Type "Omoda" visibles en la cabecera.
   - La Cuenta asociada (`QA_PEKING_S3_EVIDENCIA - Cliente Omoda`).
   - La Etapa ("Interesado").
   - La Sucursal.
   - Forma de Pago y Moneda.
   - La Lista de Precios (Pricebook = "PEKING Local").
   - El campo Observaciones con el texto de evidencia QA.
   - Desplazarse brevemente por la sección "Detalles" para mostrar que el registro tiene información suficiente
     (no está vacío ni es un registro técnico mínimo).
8. Detener la grabación.
9. Guardar el archivo localmente, por ejemplo en:
   `evidencias/sprint3/QA_PEKING_S3_EVIDENCIA_OMODA.mp4`
   (fuera del repositorio de Git, o en una carpeta de evidencias separada — no se debe hacer commit de archivos
   binarios de video a este repositorio).

---

## 8. ¿Ya sirve como evidencia profesional?

Sí, el registro en sí ya representa una Oportunidad comercial razonablemente completa en su etapa inicial: tiene
todos los campos obligatorios, los recomendados, un Pricebook explícito, un contacto asociado y observaciones
claras — con paridad estructural frente a lo que tendría una Oportunidad BMW/MINI real en la misma etapa. Lo único
que falta para completar el ciclo de evidencia es la captura visual (video), que requiere que una persona la
grabe — no está al alcance de esta sesión.

---

## 9. Diferencias frente a BMW/MINI que hay que tener presentes

- Director de Ventas / Gerente de Sucursal / Jefe de Sucursal quedan vacíos en Omoda (en BMW se completan solos) —
  ya documentado, pendiente de Diego.
- El Pricebook usado (PEKING Local) es una selección QA explícita, no un default automático como sí lo sería para
  BMW en su flujo habitual.
- Todo lo demás (formulario, campos obligatorios, validaciones, comportamiento del Nombre y el Correo del Cliente)
  es exactamente igual que BMW/MINI — no son diferencias de PEKING, son comportamientos generales del sistema que
  se confirmaron por primera vez con este registro real.

---

Este documento no declara Sprint 3 terminado. Es evidencia de un solo registro (Omoda); Jaecoo y BMW/MINI quedan
pendientes de que se revise este resultado primero.
