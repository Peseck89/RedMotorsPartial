# Evidencia PDF / Correos - Empresa (Bavarian / Otobai / PEKING)

Fecha: 2026-07-29
Fuente: instrucción de Luis + respuestas de Diego (29/07/2026), respaldada en HEAD `bf1e260`.
Alcance revisado: únicamente los dos componentes indicados como punto de partida por Luis.
No se modificó ningún PDF ni correo. Documento de solo análisis.

**Estado (auditoría final 2026-07-29):** PDFs/correos permanecen pendientes de definición del negocio. Ningún hallazgo de este documento fue implementado en el bloque autorizado por Diego (que cubrió únicamente los 6 catálogos Softland + schedulers para RMPEKING); sigue esperando respuesta de Diego/Luis sobre asunto "BMW Service", direcciones de distribución y territorios PEKING (ver hallazgos 1-3).

## Componentes revisados

1. `force-app/main/default/classes/BMWServiceQuoteApprovalEmailInvocable.cls`
2. `force-app/main/default/classes/savePDFfile.cls`

## Hallazgos

### 1. `BMWServiceQuoteApprovalEmailInvocable.getSubject` (línea 179-181)

```apex
private static String getSubject(Quote quote) {
    return 'Aprobacion de presupuesto BMW Service - ' + safeText(quote != null ? quote.QuoteNumber : null);
}
```

- **Comportamiento:** el asunto del correo (interno y de cliente) siempre incluye literalmente el texto "BMW Service", sin condicionar por empresa/compañía del Quote.
- **Clasificación:** 3. Identidad legal específica — pendiente del negocio.
- **Texto para captura:** asunto de correo mostrando `Aprobacion de presupuesto BMW Service - <QuoteNumber>` para un Quote de una marca distinta a Bavarian/BMW (si aplica a PEKING en el futuro).
- **Nota:** esta clase completa está nombrada `BMWServiceQuoteApprovalEmailInvocable`, lo que sugiere que su alcance funcional actual es específico de Bavarian/BMW Service. No hay evidencia en este archivo de que se invoque para Quotes de RMPEKING.

### 2. `BMWServiceQuoteApprovalEmailInvocable.getInternalRecipients` (línea 235-255)

```apex
private static List<String> getInternalRecipients(String territoryName) {
    List<String> recipients = new List<String>();
    String territory = territoryName == null ? '' : territoryName;

    if (territory.contains('Uruca')) {
        recipients.add('presupuestosurucabms@redmotorscr.com');
    } else if (territory.contains('Escazu') || territory.contains('Escaz')) {
        recipients.add('presupuestosescazubms@redmotorscr.com');
    } else if (territory.contains('Pinares')) {
        recipients.add('presupuestospinaresbms@redmotorscr.com');
    } else if (territory.contains('Motorrad')) {
        recipients.add('prespuestosmotorradbms@redmotorscr.com');
    } else if (territory.contains('Otobai')) {
        recipients.add('prespuestosotobaibms@redmotorscr.com');
    }

    recipients.add('luis.sandoval.rocha@gmail.com');
    recipients.add('admin@portalnetcr.com');
    recipients.add('notificacionestd@redmotorscr.com');
    return recipients;
}
```

- **Comportamiento:** enruta el correo interno por nombre de "Service Territory" (Uruca, Escazú, Pinares, Motorrad = territorios Bavarian/BMW; Otobai = único territorio no-Bavarian contemplado). Si el territorio no coincide con ninguno de estos (por ejemplo, un futuro territorio de PEKING), no se agrega una dirección específica de esa línea de negocio, pero el correo sí se envía a las 3 direcciones fijas del final.
- **Clasificación:** 2. Diferencia Bavarian/Otobai — requiere evidencia para Diego.
- **Texto para captura:** lista de destinatarios generada para un Quote asociado a un Service Territory de PEKING (hoy no produciría ninguna dirección "presupuestos...bms" dedicada).
- **Pregunta para Diego/Luis:** ¿Existe o se debe crear una dirección de distribución (`presupuestos<sede>...@redmotorscr.com`) para talleres/territorios de PEKING? Hoy no hay ninguna prevista.

### 3. `savePDFfile.getRecipientEmail` (línea 257-274)

```apex
public static String getRecipientEmail(Id serviceTerritoryId){
    String emailUruca = 'despachouruca@redmotorscr.com';
    String emailEscazu = 'despachoescazu@redmotorscr.com';
    String emailPinares = 'despachopinares@redmotorscr.com';
    String emailPavas = 'despachopavas@redmotorscr.com';
    String emailOtobai = 'despachootobai@redmotorscr.com';
    ...
    if(stName.contains('Uruca')) return emailUruca;
    if(stName.contains('Escaz')) return emailEscazu;
    if(stName.contains('Pinares')) return emailPinares;
    if(stName.contains('Pavas')) return emailPavas;
    if(stName.contains('Motorrad')) return emailPavas;
    if(stName.contains('Otobai')) return emailOtobai;
    return null;
}
```

- **Comportamiento:** resuelve la dirección de "despacho de repuestos" por nombre de Service Territory. Igual que el caso anterior, contempla Bavarian (Uruca/Escazú/Pinares/Pavas/Motorrad) y Otobai, pero no PEKING. Si no hay coincidencia, retorna `null`.
- **Efecto aguas abajo (línea 292 y 310-321 de la misma clase, método `sendEmailPDFAttachmentWo`):** si `recipientEmail` llega `null` como parámetro y `getRecipientEmail` también retorna `null` (caso de un territorio de PEKING sin mapear), el método retorna `'Email Error'` y **no se envía la alerta de despacho**, de forma silenciosa (sin excepción visible para el usuario).
- **Clasificación:** 2. Diferencia Bavarian/Otobai — requiere evidencia para Diego.
- **Texto para captura:** intento de envío de alerta de despacho para una Orden de Trabajo de un territorio PEKING sin `recipientEmail` explícito, mostrando el resultado `'Email Error'`.
- **Pregunta para Diego/Luis:** ¿Cuál es la dirección de despacho de repuestos para los talleres/territorios de PEKING?

### 4. Resto de `savePDFfile.cls` (generación de PDF, adjuntos, `attachPDFinCase/WO/Quote/Opportunity`, `generatePDFblob`, `generateOrUpdatePDFfile`)

- **Comportamiento:** genérico; no contiene literales `RMBAVARIAN`, `RMOTOBAI`, `Bavarian` ni `Otobai`. La selección de plantilla Visualforce se hace por el parámetro `fromButton`/`vfNamePage`, no por empresa.
- **Clasificación:** 1. Genérico — no requiere cambio.
- **Nota:** el contenido visual de las páginas Visualforce (`CaseChecklistPDFBeta`, `ChecklistMotosPDFBeta`, `ChecklistCuadraPDF`, `ChecklistMulaPDF`, etc.) no fue revisado en este bloque — está fuera del alcance autorizado (solo se revisaron los dos componentes Apex indicados). Si esas plantillas incluyen logo/nombre legal de Bavarian, quedaría pendiente de un bloque futuro.

## Fuera de alcance de este bloque

Existen otros componentes de Sprint 1 relacionados con PDFs documentados en `docs/empresa-marcas-chinas/IMPLEMENTACION_BLOQUE11_QUOTE_USD_PDF.md` e `IMPLEMENTACION_BLOQUE12_QUOTE_CRC_PDF.md` (p. ej. `cT_QuoteUsdPDFController`, `cT_QuoteCrcPDFController`) que no fueron revisados aquí porque el alcance autorizado indicaba explícitamente empezar solo por `BMWServiceQuoteApprovalEmailInvocable` y `savePDFfile`. Se deja como pendiente para un bloque futuro si Luis lo confirma.
