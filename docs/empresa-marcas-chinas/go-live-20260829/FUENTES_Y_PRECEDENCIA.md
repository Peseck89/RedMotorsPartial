# Fuentes y precedencia

## Orden de precedencia para decisiones de go-live

1. **Instrucción explícita posterior y vigente de responsables del pase** (María / Diego / Luis / QA / negocio), si está documentada y no contradice una restricción de seguridad superior.
2. **Reunión del 26/08/2026 09:00 CST** — transcripción íntegra en `sources/originals/TRANSCRIPCION_REUNION_20260826_0900_CST.txt`.
3. **Plan de Pase a Producción Conjunto** — original en `sources/originals/Plan_de_Pase_Produccion_Conjunto.docx`.
4. **Template QA vigente** — original en `sources/originals/Template_QA_Equipo_RedMotors_Nueva_Empresa_Marcas_Chinas.xlsx`.
5. **Estado live** de Partial, Producción, Git y Copado para hechos técnicos actuales. El estado live confirma existencia/versiones, pero no inventa decisiones de negocio.
6. **Reporte oficial Empresa/Marcas Chinas** y cierres Sprint 1–5 como evidencia histórica.
7. **Auditorías derivadas de agentes**, incluido `CODEX_RESULTADO_EJECUTIVO_NO_GO_20260826.md`. Sirven para detectar riesgos; deben reconciliarse contra fuentes 1–6.

## Regla de contradicción

- Una fuente más reciente no invalida automáticamente una fuente anterior si habla de otro proyecto o nivel de detalle.
- Si dos fuentes oficiales son incompatibles y el conflicto afecta Producción, marcar `BLOCKER_DECISION` y solicitar resolución.
- No convertir una inferencia en una instrucción.

## Fuentes preservadas en Git

- Resultado Codex NO GO, verbatim.
- Transcripción íntegra de reunión, verbatim.
- Plan de Pase original DOCX.
- Matriz QA original XLSX.
- Reporte oficial simplificado del proyecto.

## Evidencia fuera de Git

Las capturas de WhatsApp/board se preservan fuera del payload Git por contener datos personales visibles. El paquete externo incluye copia de esas imágenes y `SOURCE_MANIFEST_SHA256.txt` permite verificar integridad. La grabación MP4 no se incluye por tamaño; su hash y referencia están en `VIDEO_REFERENCE.md`, y la transcripción íntegra sí queda en Git.
