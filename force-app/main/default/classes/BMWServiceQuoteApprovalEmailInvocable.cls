public with sharing class BMWServiceQuoteApprovalEmailInvocable {
    private static final String SENDER_ADDRESS = 'info@redmotorscr.com';
    private static Set<Id> quoteIdsHandled = new Set<Id>();

    public class Request {
        @InvocableVariable(label='Quote Line Item Id' required=true)
        public Id quoteLineItemId;
    }

    public class Response {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String message;

        @InvocableVariable
        public Integer emailsQueued;
    }

    @InvocableMethod(label='Enviar correos BMW Service desde Quote')
    public static List<Response> sendApprovalEmails(List<Request> requests) {
        Response response = new Response();
        response.success = true;
        response.emailsQueued = 0;

        if (requests == null || requests.isEmpty()) {
            response.message = 'Sin Quote Line Items para procesar.';
            return new List<Response>{ response };
        }

        Set<Id> qliIds = new Set<Id>();
        for (Request request : requests) {
            if (request != null && request.quoteLineItemId != null) {
                qliIds.add(request.quoteLineItemId);
            }
        }

        if (qliIds.isEmpty()) {
            response.message = 'Sin Quote Line Items validos para procesar.';
            return new List<Response>{ response };
        }

        Map<Id, QuoteLineItem> triggerQlis = new Map<Id, QuoteLineItem>([
            SELECT Id, QuoteId
            FROM QuoteLineItem
            WHERE Id IN :qliIds
        ]);

        Set<Id> quoteIds = new Set<Id>();
        for (QuoteLineItem qli : triggerQlis.values()) {
            if (qli.QuoteId != null && !quoteIdsHandled.contains(qli.QuoteId)) {
                quoteIds.add(qli.QuoteId);
            }
        }

        if (quoteIds.isEmpty()) {
            response.message = 'Los Quotes ya fueron procesados en esta transaccion.';
            return new List<Response>{ response };
        }

        Map<Id, Quote> quotesById = new Map<Id, Quote>([
            SELECT Id, QuoteNumber, Name, Placa__c, CurrencyIsoCode,
                   Account.Name, Account.PersonEmail, Account.CorreoElectronicoEmpresarial__c, Account.Invoice_Email__c,
                   Contact.Name, Contact.Email, Contact.Phone, Contact.MobilePhone,
                   Opportunity.BMW_TallerDeServicio__r.Name,
                   Opportunity.Owner.Name, Opportunity.Owner.Email, Opportunity.Owner.Phone,
                   CreatedBy.Name, CreatedBy.Email
            FROM Quote
            WHERE Id IN :quoteIds
        ]);

        Map<Id, List<QuoteLineItem>> approvedQlisByQuote = new Map<Id, List<QuoteLineItem>>();
        for (QuoteLineItem qli : [
            SELECT Id, QuoteId, Quantity, UnitPrice, TotalPrice, CurrencyIsoCode,
                   BMW_Alias__c, Incluir_al_presupuesto__c, Estado_aprobaci_n_service__c,
                   Aprobado_service__c, Enviar_presupuesto_a_service__c, tipoCargo__c,
                   Product2.Name, Product2.Codigo_de_Producto__c,
                   TrabajoARealizar__r.Name, Tarea__r.Name
            FROM QuoteLineItem
            WHERE QuoteId IN :quoteIds
            ORDER BY TrabajoARealizar__r.Name, CreatedDate, Id
        ]) {
            if (!shouldInclude(qli)) {
                continue;
            }
            if (!approvedQlisByQuote.containsKey(qli.QuoteId)) {
                approvedQlisByQuote.put(qli.QuoteId, new List<QuoteLineItem>());
            }
            approvedQlisByQuote.get(qli.QuoteId).add(qli);
        }

        Id orgWideId = getOrgWideEmailAddressId();
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        for (Id quoteId : quoteIds) {
            Quote quote = quotesById.get(quoteId);
            List<QuoteLineItem> approvedLines = approvedQlisByQuote.get(quoteId);

            if (quote == null || approvedLines == null || approvedLines.isEmpty()) {
                continue;
            }

            List<String> internalRecipients = getInternalRecipients(getTerritoryName(quote));
            if (!internalRecipients.isEmpty()) {
                messages.add(buildEmail(
                    internalRecipients,
                    getSubject(quote),
                    buildInternalBody(quote, approvedLines),
                    orgWideId
                ));
            }

            String customerEmail = getCustomerEmail(quote);
            if (!String.isBlank(customerEmail)) {
                messages.add(buildEmail(
                    new List<String>{ customerEmail },
                    getSubject(quote),
                    buildCustomerBody(quote, approvedLines),
                    orgWideId
                ));
            }

            quoteIdsHandled.add(quoteId);
        }

        if (!messages.isEmpty()) {
            Messaging.sendEmail(messages, false);
            response.emailsQueued = messages.size();
        }

        response.message = 'Correos preparados: ' + response.emailsQueued;
        return new List<Response>{ response };
    }

    private static Boolean shouldInclude(QuoteLineItem qli) {
        if (qli == null) {
            return false;
        }

        Boolean sentToService = qli.Enviar_presupuesto_a_service__c == true;
        Boolean included = String.isBlank(qli.Incluir_al_presupuesto__c)
            || qli.Incluir_al_presupuesto__c.trim().toLowerCase() != 'no';
        Boolean approved = qli.Aprobado_service__c == true
            || (!String.isBlank(qli.Estado_aprobaci_n_service__c)
                && qli.Estado_aprobaci_n_service__c.trim().equalsIgnoreCase('Aprobado'));
        Boolean customerCharge = String.isBlank(qli.tipoCargo__c) || qli.tipoCargo__c == '1';

        return sentToService && included && approved && customerCharge;
    }

    private static Messaging.SingleEmailMessage buildEmail(
        List<String> recipients,
        String subject,
        String body,
        Id orgWideId
    ) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(recipients);
        message.setSubject(subject);
        message.setHtmlBody(body);
        message.setSaveAsActivity(false);
        if (orgWideId != null) {
            message.setOrgWideEmailAddressId(orgWideId);
        }
        return message;
    }

    private static Id getOrgWideEmailAddressId() {
        List<OrgWideEmailAddress> senders = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE Address = :SENDER_ADDRESS
            LIMIT 1
        ];
        return senders.isEmpty() ? null : senders[0].Id;
    }

    private static String getSubject(Quote quote) {
        return 'Aprobacion de presupuesto BMW Service - ' + safeText(quote != null ? quote.QuoteNumber : null);
    }

    private static String getTerritoryName(Quote quote) {
        if (quote == null || quote.Opportunity == null || quote.Opportunity.BMW_TallerDeServicio__r == null) {
            return null;
        }
        return quote.Opportunity.BMW_TallerDeServicio__r.Name;
    }

    private static String getAdvisorName(Quote quote) {
        if (quote != null && quote.Opportunity != null && quote.Opportunity.Owner != null) {
            return quote.Opportunity.Owner.Name;
        }
        return quote != null && quote.CreatedBy != null ? quote.CreatedBy.Name : '';
    }

    private static String getAdvisorPhone(Quote quote) {
        if (quote != null && quote.Opportunity != null && quote.Opportunity.Owner != null) {
            return quote.Opportunity.Owner.Phone;
        }
        return null;
    }

    private static String getCustomerName(Quote quote) {
        if (quote != null && quote.Contact != null && !String.isBlank(quote.Contact.Name)) {
            return quote.Contact.Name;
        }
        if (quote != null && quote.Account != null) {
            return quote.Account.Name;
        }
        return '';
    }

    private static String getCustomerEmail(Quote quote) {
        if (quote == null) {
            return null;
        }
        if (quote.Contact != null && !String.isBlank(quote.Contact.Email)) {
            return quote.Contact.Email;
        }
        if (quote.Account != null) {
            if (!String.isBlank(quote.Account.PersonEmail)) {
                return quote.Account.PersonEmail;
            }
            if (!String.isBlank(quote.Account.CorreoElectronicoEmpresarial__c)) {
                return quote.Account.CorreoElectronicoEmpresarial__c;
            }
            if (!String.isBlank(quote.Account.Invoice_Email__c)) {
                return quote.Account.Invoice_Email__c;
            }
        }
        return null;
    }

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

    private static String buildInternalBody(Quote quote, List<QuoteLineItem> lines) {
        String quoteNumber = safeText(quote != null ? quote.QuoteNumber : null);

        return '<html><body style="font-family: Arial, sans-serif; font-size: 14px; color: #333;">'
            + '<p>Estimado equipo,</p>'
            + '<p>A continuacion, encontrara un desglose de los puntos aprobados en el presupuesto '
            + h(quoteNumber) + '.</p>'
            + buildTable(lines, true)
            + '<p>Saludos.</p>'
            + '</body></html>';
    }

    private static String buildCustomerBody(Quote quote, List<QuoteLineItem> lines) {
        String customerName = safeText(getCustomerName(quote));
        String quoteNumber = safeText(quote != null ? quote.QuoteNumber : null);
        String plate = safeText(quote != null ? quote.Placa__c : null);
        String advisorName = safeText(getAdvisorName(quote));
        String advisorPhone = safeText(getAdvisorPhone(quote));

        String advisorText = h(advisorName);
        if (!String.isBlank(advisorPhone)) {
            advisorText += ' ' + h(advisorPhone);
        }

        return '<html><body style="font-family: Arial, sans-serif; font-size: 14px; color: #333;">'
            + '<p>Estimado ' + h(customerName) + ':</p>'
            + '<p>Le notificamos que hemos recibido la aprobacion del presupuesto '
            + h(quoteNumber) + ' correspondiente al vehiculo ' + h(plate) + '.</p>'
            + '<p>Detallamos para su referencia los puntos que fueron aprobados:</p>'
            + buildTable(lines, false)
            + '<p>Si tiene alguna pregunta adicional ' + advisorText + ' le asistira.</p>'
            + '<p>!Agradecemos su preferencia!</p>'
            + '</body></html>';
    }

    private static String buildTable(List<QuoteLineItem> lines, Boolean includeCode) {
        Map<String, List<QuoteLineItem>> grouped = new Map<String, List<QuoteLineItem>>();
        List<String> groupOrder = new List<String>();

        for (QuoteLineItem line : lines) {
            String groupName = getGroupName(line);
            if (!grouped.containsKey(groupName)) {
                grouped.put(groupName, new List<QuoteLineItem>());
                groupOrder.add(groupName);
            }
            grouped.get(groupName).add(line);
        }

        String html = '';
        for (String groupName : groupOrder) {
            Decimal amountTotal = 0;
            Decimal invoiceTotal = 0;

            html += '<table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;color:#333;margin-bottom:16px;">'
                + '<caption style="text-align:left;font-weight:bold;margin-bottom:6px;">' + h(groupName) + '</caption>'
                + '<tr>';

            if (includeCode) {
                html += '<th style="font-size:12px;border:1px solid black;text-align:center;">Codigo Articulo</th>';
            }

            html += '<th style="font-size:12px;border:1px solid black;text-align:center;">Nombre</th>'
                + '<th style="font-size:12px;border:1px solid black;text-align:center;">Cantidad</th>'
                + '<th style="font-size:12px;border:1px solid black;text-align:center;">Monto</th>'
                + '<th style="font-size:12px;border:1px solid black;text-align:center;">Precio a facturar</th>'
                + '</tr>';

            for (QuoteLineItem line : grouped.get(groupName)) {
                Decimal amount = line.UnitPrice == null ? 0 : line.UnitPrice;
                Decimal invoice = line.TotalPrice == null ? amount * (line.Quantity == null ? 0 : line.Quantity) : line.TotalPrice;
                amountTotal += amount;
                invoiceTotal += invoice;

                html += '<tr>';
                if (includeCode) {
                    html += '<td style="font-size:12px;border:1px solid black;text-align:center;">'
                        + h(line.Product2 != null ? line.Product2.Codigo_de_Producto__c : null)
                        + '</td>';
                }
                html += '<td style="font-size:12px;border:1px solid black;text-align:center;">' + h(getLineName(line)) + '</td>'
                    + '<td style="font-size:12px;border:1px solid black;text-align:center;">' + h(formatQuantity(line.Quantity)) + '</td>'
                    + '<td style="font-size:12px;border:1px solid black;text-align:center;">' + h(formatMoney(amount, line.CurrencyIsoCode)) + '</td>'
                    + '<td style="font-size:12px;border:1px solid black;text-align:center;">' + h(formatMoney(invoice, line.CurrencyIsoCode)) + '</td>'
                    + '</tr>';
            }

            Integer totalColspan = includeCode ? 3 : 2;
            String currencyIso = grouped.get(groupName).isEmpty() ? '' : grouped.get(groupName)[0].CurrencyIsoCode;
            html += '<tr>'
                + '<td style="font-size:14px;border:1px solid black;" colspan="' + totalColspan + '">Total:</td>'
                + '<td style="font-size:14px;border:1px solid black;text-align:center;">' + h(formatMoney(amountTotal, currencyIso)) + '</td>'
                + '<td style="font-size:14px;border:1px solid black;text-align:center;">' + h(formatMoney(invoiceTotal, currencyIso)) + '</td>'
                + '</tr>'
                + '</table>';
        }

        return html;
    }

    private static String getGroupName(QuoteLineItem line) {
        if (line != null && line.TrabajoARealizar__r != null && !String.isBlank(line.TrabajoARealizar__r.Name)) {
            return line.TrabajoARealizar__r.Name;
        }
        if (line != null && line.Tarea__r != null && !String.isBlank(line.Tarea__r.Name)) {
            return line.Tarea__r.Name;
        }
        return 'Puntos aprobados';
    }

    private static String getLineName(QuoteLineItem line) {
        if (line == null) {
            return '';
        }
        if (!String.isBlank(line.BMW_Alias__c)) {
            return line.BMW_Alias__c;
        }
        return line.Product2 != null ? line.Product2.Name : '';
    }

    private static String formatQuantity(Decimal quantity) {
        return quantity == null ? '0' : String.valueOf(quantity.stripTrailingZeros());
    }

    private static String formatMoney(Decimal amount, String currencyIso) {
        Decimal value = amount == null ? 0 : amount.setScale(2, RoundingMode.HALF_UP);
        return (String.isBlank(currencyIso) ? '' : currencyIso + ' ') + String.valueOf(value);
    }

    private static String safeText(String value) {
        return String.isBlank(value) ? '' : value;
    }

    private static String h(Object value) {
        String text = value == null ? '' : String.valueOf(value);
        return text.escapeHtml4();
    }
}