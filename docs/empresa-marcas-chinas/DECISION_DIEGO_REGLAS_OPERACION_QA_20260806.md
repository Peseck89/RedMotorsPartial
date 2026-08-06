# Decisión de Diego — reglas, operación y QA

**Fecha:** 6 de agosto de 2026  
**Tipo:** definición funcional y asignación de dependencias.  
**Alcance:** análisis y documentación; no autoriza implementación, configuración ni creación de datos.

## Confirmado

- A nivel de reglas, PEKING debe mantener el mismo comportamiento que las áreas existentes.
- Las reservas, devoluciones y procesos equivalentes se gestionan según la Empresa enviada al proceso. Si la Empresa recibida es correcta, el proceso vigente debe gestionarla.
- Actualmente no existen registros específicos PEKING para asesores, territorios, centros de costo y otros registros operativos equivalentes requeridos para una simulación integral.
- Una prueba integral de PEKING requiere registros mínimos de esos tipos.
- Diego creará la jerarquía y los perfiles. No deben crearse ni duplicarse dentro de los lotes del proyecto mientras esta dependencia siga a su cargo.

La confirmación de comportamiento equivalente no define por sí misma valores, responsables, registros, aprobadores ni configuración. Tampoco demuestra que una regla existente incluya técnicamente a PEKING, Omoda o Jaecoo.

## Pendiente

- Qué registros mínimos exactos deben existir para la prueba integral.
- Qué registros existentes deben tomarse como referencia para construirlos.
- Los valores oficiales de asesores, territorios, centros de costo y registros equivalentes.
- El responsable de proporcionar o validar cada dato.
- La fecha y el ambiente en que estarán disponibles para QA.
- Los aprobadores y responsables funcionales de descuentos, centros de costo y garantías.
- La configuración autoritativa de Softland, que no queda resuelta por la definición de reservas y devoluciones.

No existe evidencia inequívoca de autorización para crear registros QA. Por tanto, ningún dato fue creado y su preparación permanece pendiente de confirmación explícita.

## Consecuencias para la planificación

1. La pregunta general sobre si PEKING debe operar con reglas distintas deja de ser un bloqueo: se conserva el comportamiento existente.
2. Reservas y devoluciones quedan definidas a nivel de arquitectura funcional; su QA integral permanece pendiente por datos operativos.
3. Las reglas deben inspeccionarse individualmente. Las que ya sean neutrales a Empresa pueden quedar sin cambio técnico y requerir regresión; las que enumeren marcas, Record Types o Empresas requieren evaluación técnica explícita.
4. Los Approval Processes no quedan desbloqueados si todavía requieren aprobadores, niveles, centros de costo o criterios de garantía.
5. Jerarquía y perfiles se registran como `DEPENDENCIA_DIEGO`, no como trabajo a implementar por el equipo en un lote propio.

