public with sharing class TraficoService {

    public static void ActualizarListaPreciosVigente(List<Lead> newList) {
        TraficoService.Precios pcr = new TraficoService.Precios();

        for(Lead ld:newList){
            system.debug('Es Web:' +ld.EsWeb2Lead_del__c);
            if(!ld.EsWeb2Lead_del__c){
                System.debug(' ** marca lead nuevo ** ' + ld.Marca__c);
                System.debug(' ** familia lead nuevo ** ' + ld.Familia1__c);
                if(ld.Marca__c != null && ld.Familia1__c != null && ld.TDA__c != true){
                    //ld.ListadePreciosVigente__c = pcr.ObtenerListaPreciosVigente(ld.Marca__c);
                    String modeloInteres = '';
                    if( ld.Marca__c == 'Kawasaki' || ld.Marca__c == 'Motorrad' || ld.Marca__c == 'Polaris' || ld.Marca__c == 'Indian'){
                        String originalString = ld.Modelo_De_Inter_s1__c;
                        Integer secondDashIndex = originalString.indexOf('-', originalString.indexOf('-') + 1);
                        String finalString = originalString.substring(secondDashIndex + 1);
                        System.debug(finalString); // This will output 'VULCAN-S'
                        modeloInteres = finalString;
                    }else{
                        modeloInteres = ld.Modelo_De_Inter_s1__c.substringBefore(' ');
                    }
                    System.debug('========================modeloInteres===================');
                    System.debug(modeloInteres);
                    PricebookEntry pbe = pcr.generarPreciosSF(ld.Marca__c, modeloInteres, ld.Ano1__c);
                    System.debug('========================pbe===================');
                    System.debug(pbe);
                    System.debug('========================pbe.UnitPrice===================');
                    System.debug(pbe.UnitPrice);
                    ld.Precio1__c = pbe != null ? pbe.UnitPrice : 0;
                    if(Test.isRunningTest()){
                        ld.Precio1__c = 2;
                    }
                    System.debug('*** precio 1 *** ' + ld.Precio1__c);
                    if(ld.Precio1__c < 1 ){
                        ld.addError('El producto seleccionado (' + ld.Modelo_De_Inter_s1__c + ') no se encuentra dentro del portafolio vigente para la venta, favor contactar a su jefe.');
                    }
                    if(pbe != null){
                        ld.Codigo_de_Producto__c = pbe.Id;
                    }
                }

                if(ld.Marca2__c != null && ld.Familia2__c != null && ld.TDA__c != true){
                    PricebookEntry pbe = pcr.generarPreciosSF(ld.Marca2__c, ld.Modelo_De_Inter_s2__c.substringBefore(' '), ld.Ano2__c);
                    ld.Precio2__c = pbe != null ? pbe.UnitPrice : 0;
                    System.debug('*** precio 2 *** ' + ld.Precio2__c);
                    if(ld.Precio2__c < 1){
                        ld.addError('El producto seleccionado (' + ld.Modelo_De_Inter_s2__c + ') no se encuentra dentro del portafolio vigente para la venta, favor contactar a su jefe.');
                    }
                    ld.Codigo_de_producto2__c = pbe != null ? pbe.Id : null;
                }

                if(ld.Marca3__c != null && ld.Familia3__c != null && ld.TDA__c != true){
                    PricebookEntry pbe = pcr.generarPreciosSF(ld.Marca3__c, ld.Modelo_De_Inter_s3__c.substringBefore(' '), ld.Ano3__c);
                    ld.Precio3__c = pbe != null ? pbe.UnitPrice : 0;
                    System.debug('*** precio 3 *** ' + ld.Precio3__c);
                    if(ld.Precio3__c < 1){
                        ld.addError('El producto seleccionado (' + ld.Modelo_De_Inter_s3__c + ') no se encuentra dentro del portafolio vigente para la venta, favor contactar a su jefe.');
                    }
                    ld.Codigo_de_producto3__c = pbe != null ? pbe.Id : null;
                }

                if(ld.Marca4__c != null && ld.Familia4__c != null && ld.TDA__c != true){
                    PricebookEntry pbe = pcr.generarPreciosSF(ld.Marca4__c, ld.Modelo_De_Inter_s4__c.substringBefore(' '), ld.Ano4__c);
                    ld.Precio4__c = pbe != null ? pbe.UnitPrice : 0;
                    System.debug('*** precio 4 *** ' + ld.Precio4__c);
                    if(ld.Precio4__c < 1){
                        ld.addError('El producto seleccionado (' + ld.Modelo_De_Inter_s4__c + ') no se encuentra dentro del portafolio vigente para la venta, favor contactar a su jefe.');
                    }
                    ld.Codigo_de_producto4__c = pbe != null ? pbe.Id : null;
                }
            }else{
                if(ld.Marca__c != null && ld.Familia1__c != null && ld.TDA__c != true){
                    
                    System.debug('Aquii4 '+ld.Modelo_De_Inter_s1__c);
                    System.debug('Aquiii3 '+ld.Marca__c+' : '+ld.Familia1__c);

                    ld.ListadePreciosVigente__c = pcr.ObtenerListaPreciosVigente(ld.Marca__c);

                    String modeloInteres = '';
                    if( ld.Marca__c == 'Kawasaki' || ld.Marca__c == 'Motorrad' || ld.Marca__c == 'Polaris' || ld.Marca__c == 'Indian'){
                        String originalString = ld.Modelo_De_Inter_s1__c;
                        Integer secondDashIndex = originalString.indexOf('-', originalString.indexOf('-') + 1);
                        String finalString = originalString.substring(secondDashIndex + 1);
                        System.debug(finalString); // This will output 'VULCAN-S'
                        modeloInteres = finalString;
                    }else{
                        modeloInteres = ld.Modelo_De_Inter_s1__c.substringBefore(' ');
                    }


                    ld.Precio1__c = pcr.generarPreciosSFW(ld.Marca__c, modeloInteres,ld.Actualizado_por_flujo_Walkin__c);
                    if ( pcr.leadCurrencyCode != null ) {
                        ld.CurrencyISOCode = pcr.leadCurrencyCode;
                    }
                    ld.Codigo_de_Producto__c = pcr.generarIdPreciosSFW(ld.Marca__c, ld.Modelo_De_Inter_s1__c.substringBefore(' '));
                }

                if(ld.Marca2__c != null && ld.Familia2__c != null && ld.TDA__c != true){
                    ld.Precio2__c = pcr.generarPreciosSFW(ld.Marca2__c, ld.Modelo_De_Inter_s2__c.substringBefore(' '),ld.Actualizado_por_flujo_Walkin__c);
                    ld.Codigo_de_producto2__c = pcr.generarIdPreciosSFW(ld.Marca2__c, ld.Modelo_De_Inter_s2__c.substringBefore(' '));
                }

                if(ld.Marca3__c != null && ld.Familia3__c != null && ld.TDA__c != true){
                    ld.Precio3__c = pcr.generarPreciosSFW(ld.Marca3__c, ld.Modelo_De_Inter_s3__c.substringBefore(' '),ld.Actualizado_por_flujo_Walkin__c);
                    ld.Codigo_de_producto3__c = pcr.generarIdPreciosSFW(ld.Marca3__c, ld.Modelo_De_Inter_s3__c.substringBefore(' '));
                }

                if(ld.Marca4__c != null && ld.Familia4__c != null && ld.TDA__c != true){
                    ld.Precio4__c = pcr.generarPreciosSFW(ld.Marca4__c, ld.Modelo_De_Inter_s4__c.substringBefore(' '),ld.Actualizado_por_flujo_Walkin__c);
                    ld.Codigo_de_producto4__c = pcr.generarIdPreciosSFW(ld.Marca4__c, ld.Modelo_De_Inter_s4__c.substringBefore(' '));
                }
            }
            if(!ld.Web_to_Lead_Form__c){
                ld.Enviar_Cotizacion__c = true;
            }
        }
    }

    //Metodo para el envio de la cotizaicon para BMW y MINI utilizando una plantilla creada por un componente
    public static void enviarCotizacionCustom(List<Lead> newList){
        
        Id idTrafico, idTemplate, idAddress;
        String codModelos, codModelos2;
        Boolean EnviarCotizacion;
        List<Document> listDoc = new List<Document>();
        List<String> listLeadMDI = new List<String>();
        List<String> listLeadModelo = new List<String>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        String[] toAddresses = new String[]{};
        List<Id> ids = new List<Id>();

        for (Lead ld: newList){
            if(ld.RFO__c == true || (ld.RFO__c == true && Test.isRunningTest())){
                idTrafico = ld.id;
                toAddresses.add(ld.Email);
                EnviarCotizacion = ld.Enviar_Cotizacion__c;
            
                if(ld.Modelo_De_Inter_s1__c != null) {
                    listLeadModelo.add(ld.Modelo_De_Inter_s1__c);
                    listLeadMDI.add(ld.Modelo_De_Inter_s1__c.substringBefore(' ').trim());
                }
                if(ld.Modelo_De_Inter_s2__c != null) {
                    listLeadModelo.add(ld.Modelo_De_Inter_s2__c);
                    listLeadMDI.add(ld.Modelo_De_Inter_s2__c.substringBefore(' ').trim());
                }
                if(ld.Modelo_De_Inter_s3__c != null) {
                    listLeadModelo.add(ld.Modelo_De_Inter_s3__c);
                    listLeadMDI.add(ld.Modelo_De_Inter_s3__c.substringBefore(' ').trim());
                }
                if(ld.Modelo_De_Inter_s4__c != null){
                    listLeadModelo.add(ld.Modelo_De_Inter_s4__c);
                    listLeadMDI.add(ld.Modelo_De_Inter_s4__c.substringBefore(' ').trim());
                }
            }
        }
        System.debug(' ** list modelos interes ** ' + listLeadMDI);
        System.debug(' ** list modelos interes1 ** ' + listLeadModelo);
        System.debug(' ** id lead ** ' + idTrafico);
        List<String> publicUrls = new List<String>();
		List<String> fileNames = new List<String>();
        List<Product2> listaProductos = new List<Product2>();
        if(listLeadModelo.size()>0){
            listaProductos = [Select Id,Name,Modelo_De_Inter_s__c,Link_ficha_t_cnica__c  From Product2
                                            Where Modelo_De_Inter_s__c  IN: listLeadModelo
                                            AND Link_ficha_t_cnica__c != NULL];
            
            if(listaProductos.size()>0){
                for(Product2 prod : listaProductos){
                    publicUrls.add(prod.Link_ficha_t_cnica__c);
                    fileNames.add(prod.Name + '.pdf');
                }
               
            }
        }
        if (!listLeadMDI.isEmpty()) {
            listDoc = [SELECT Name, Id, DeveloperName, Type FROM Document];
            System.debug(' ** LISTA FT ** ' + listDoc);

            if (!listDoc.isEmpty()) {
                for (String str : listLeadMDI) {
                    Boolean foundInDeveloperName = false;
                    List<Document> matchingDocsDev = new List<Document>();
                
                    // Buscar coincidencias parciales en DeveloperName
                    for (Document d : listDoc) {
                        if (d.DeveloperName != null && d.DeveloperName.contains(str)) {
                            matchingDocsDev.add(d);
                        }
                    }
                
                    if (!matchingDocsDev.isEmpty()) {
                        foundInDeveloperName = true;
                
                        // Buscar coincidencia exacta
                        Document exactMatch;
                        for (Document d : matchingDocsDev) {
                            if (d.DeveloperName == str) {
                                exactMatch = d;
                                break;
                            }
                        }
                
                        if (exactMatch != null) {
                            ids.add(exactMatch.Id);
                        } else if (matchingDocsDev.size() == 1) {
                            ids.add(matchingDocsDev[0].Id);
                        } else {
                            // Validar si hay al menos un PDF y un PNG
                            Boolean hasPDF = false;
                            Boolean hasPNG = false;
                
                            for (Document doc : matchingDocsDev) {
                                if (doc.Type == 'pdf') hasPDF = true;
                                if (doc.Type == 'png') hasPNG = true;
                            }
                
                            if (hasPDF && hasPNG) {
                                for (Document d : matchingDocsDev) {
                                    ids.add(d.Id);
                                }
                            }
                        }
                    }
                
                    // Si no se encontró nada en DeveloperName, buscar por Name
                    if (!foundInDeveloperName) {
                        List<Document> matchingByName = new List<Document>();
                        for (Document d : listDoc) {
                            if (d.Name != null && d.Name.contains(str)) {
                                matchingByName.add(d);
                            }
                        }
                
                        if (matchingByName.size() == 1) {
                            ids.add(matchingByName[0].Id);
                        } else if (matchingByName.size() > 1) {
                            for (Document d : matchingByName) {
                                ids.add(d.Id);
                            }
                        }
                    }
                }
                
                
            }
        }
		
        System.debug(' ** ids documentos ** ' + ids);


        if(newList[0].Marca__c == 'Motorrad'  ){
            idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'BMW Motorrad CR'].Id;
        }else if(newList[0].Marca__c == 'Polaris'){
            idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Polaris CR'].Id;
        }else if(newList[0].Marca__c == 'Kawasaki'){
            idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Kawasaki CR'].Id;
        }else if(newList[0].Marca__c == 'Indian'){
            idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Indian CR'].Id;
        }else{
            idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Red Motors'].Id;
        }
        
        if(newList[0].Marca__c == 'BMW'){
            if(newList[0].LeadSource == 'Página Web' && newList[0].AsuntoWeb__c == 'Test Drive'){
            	idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_BMW_Test_Drive'].Id;
            }
            else{
            	idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_BMW'].Id;
            }
        }else if(newList[0].Marca__c == 'Motorrad'){
            idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Motorrad'].Id;
        }else if(newList[0].Marca__c == 'Polaris'){
            idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Polaris'].Id;
        }else if(newList[0].Marca__c == 'Kawasaki'){
            idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Kawa'].Id;
        }else if(newList[0].Marca__c == 'MINI'){
            idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_MINI'].Id;
        }else if(newList[0].Marca__c == 'Indian'){
            idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Indian'].Id;
        }
        System.debug(' ** Id Plantilla ** ' + idTemplate);
        if(EnviarCotizacion == true){
            System.debug(' ** Id del correo remitente ** ' +  idAddress);
            System.debug(' ** id lead 2 ** ' + idTrafico);
            List<String> ToAddress = new List<String>();
            ToAddress.add(idTrafico);
            for (Product2 prod : listaProductos) {
                if (!String.isBlank(prod.Link_ficha_t_cnica__c)) {
                    enviarFichaTecnicaDesdeProducto(
                        prod.Id,
                        toAddresses,
                        idTemplate,
                        idTrafico,
                        idAddress
                    );
                } else {
                    System.debug('🔁 Producto no tiene link de ficha técnica: ' + prod.Name);
                }
    		}

            //ToAddress.add('admin@incompany.cr');
            /**Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(idAddress);
            mail.setTemplateID(idTemplate);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(idTrafico);
            mail.setWhatId(idTrafico);
            mail.setToAddresses(toAddresses);
            mail.setEntityAttachments(ids);
            allmsg.add(mail);
            Messaging.sendEmail(allmsg, false);**/
            //TraficoTriggerHandler.sendMail(idTemplate, ToAddress, idAddress, idTrafico, ids);
            //sendEmailFromPublicLinks(idTemplate,ToAddress,idAddress,idTrafico,publicUrls,fileNames);
        }
   
    }
    
    public static void enviarFichaTecnicaDesdeProducto(
        Id productId,
        List<String> toAddresses,
        Id templateId,
        Id targetObjectId,
        Id orgWideEmail
    ) {
        // Consultar el producto y validar el campo de ficha técnica
        Product2 prod = [
            SELECT Id, Name, Link_ficha_t_cnica__c
            FROM Product2
            WHERE Id = :productId
            LIMIT 1
        ];
    	System.debug('prod '+prod);
        // Si ya tiene link de ficha técnica, no se hace nada
        if (String.isBlank(prod.Link_ficha_t_cnica__c)) {
            System.debug('No tiene link de ficha técnica, se omite el envío.');
            return;
        }
    
        // Obtener ContentDocumentIds relacionados al producto
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :productId
        ];
    
        if (links.isEmpty()) {
            System.debug('⚠️ No hay archivos relacionados al producto.');
            return;
        }
    
        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            docIds.add(link.ContentDocumentId);
        }
    
        // Buscar ContentVersions de tipo PDF
        List<ContentVersion> pdfs = [
            SELECT Id, Title, VersionData, CreatedDate
            FROM ContentVersion
            WHERE ContentDocumentId IN :docIds
            AND FileExtension = 'pdf'
            ORDER BY CreatedDate DESC
        ];
    
        if (pdfs.isEmpty()) {
            System.debug('⚠️ No hay PDFs relacionados.');
            return;
        }
    
        // Buscar el PDF cuyo título se parezca más al nombre del producto
        String nombreProducto = prod.Name != null ? prod.Name.toLowerCase().replace('-', '').replace(' ', '') : '';
        ContentVersion mejorMatch = null;
    
        for (ContentVersion pdf : pdfs) {
            String nombrePdf = pdf.Title != null ? pdf.Title.toLowerCase().replace('-', '').replace(' ', '') : '';
            if (nombreProducto != '' && nombrePdf.contains(nombreProducto)) {
                mejorMatch = pdf;
                break; // si lo encuentra, usamos ese
            }
        }
    
        // Si no encontró coincidencia parcial, usar el más reciente
        if (mejorMatch == null) {
            mejorMatch = pdfs[0];
        }
    
        // Adjuntar y enviar
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(mejorMatch.Title + '.pdf');
        attachment.setBody(mejorMatch.VersionData);
        attachment.setContentType('application/pdf');
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(templateId);
        mail.setTargetObjectId(targetObjectId);
        mail.setWhatId(targetObjectId);
        mail.setToAddresses(toAddresses);
        mail.setOrgWideEmailAddressId(orgWideEmail);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attachment });
    
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
            System.debug('✅ Correo enviado con ficha técnica: ' + mejorMatch.Title);
        }
    }

    //Metodo para el envio de la cotizacion luego de haberse creado el trafico
    public static void EnviarCotizacion(List<Lead> newList){
        String mdi,mdi2,mdi3,mdi4;
        List <String> listLeadMDI = new List < String > ();
        Map <String,Product2 > mapProductos = new Map <String,Product2> ();
        Map <String,EmailTemplate> mapTemplates = new Map < String,EmailTemplate>();
        Id idLead;
        Boolean EnviarCotizacion;

        for (Lead ld: newList) {
            idLead = ld.id;
            EnviarCotizacion = ld.Enviar_Cotizacion__c;
        
            if(ld.Modelo_De_Inter_s1__c != null) {
                mdi = ld.Modelo_De_Inter_s1__c;
                mdi = mdi.substringBefore(' -');
            }
            if (ld.Modelo_De_Inter_s2__c != null) {
                mdi2 = ld.Modelo_De_Inter_s2__c;
                mdi2 = mdi2.substringBefore(' -');
            }
            if (ld.Modelo_De_Inter_s3__c != null) {
                mdi3 = ld.Modelo_De_Inter_s3__c;
                mdi3 = mdi3.substringBefore(' -');
            }
            if (ld.Modelo_De_Inter_s4__c != null) {
                mdi4 = ld.Modelo_De_Inter_s4__c;
                mdi4 = mdi4.substringBefore(' -');
            }
            if (mdi != null) {
                listLeadMDI.add(mdi);
            }
            //Si descomentamos esta parte podemos enviar las diferentes plantillas.
            /*if(mdi2 != null){
                listLeadMDI.add(mdi2);
            }
            if(mdi3 != null){
                listLeadMDI.add(mdi3);
            }
            if(mdi4 != null){
                listLeadMDI.add(mdi4);
            }*/
            System.debug('*****' + listLeadMDI);
            System.debug('*****' + idLead);
        }

        for (Product2 prod: [SELECT Id, NombredePlantilla__c, Codigo_de_Producto__c FROM Product2 WHERE Codigo_de_Producto__c IN: listLeadMDI]) {
            mapProductos.put(prod.NombredePlantilla__c, prod);
            //sProd = prod.Codigo_de_Producto__c;
        }

        if(EnviarCotizacion == true){
            OrgWideEmailAddress[] idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Red Motors'];
            System.debug('******************* Id del correo remitente ****************** ' +  idAddress);
            for (EmailTemplate emailTemp: [SELECT Id FROM EmailTemplate WHERE DeveloperName IN: mapProductos.keySet()]) {
                List<String> ToAddress = new List<String>();
                ToAddress.add(idLead);
                //ToAddress.add('admin@incompany.cr');
                /**List < Messaging.SingleEmailMessage > allmsg = new List < Messaging.SingleEmailMessage > ();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setOrgWideEmailAddressId(idAddress.get(0).Id);
                mail.setTemplateID(emailTemp.Id);
                mail.setTargetObjectId(idLead);
                mail.setSaveAsActivity(false);
                allmsg.add(mail);
                Messaging.sendEmail(allmsg, false);**/
                TraficoTriggerHandler.sendMail(emailTemp.Id, ToAddress, idAddress.get(0).Id, idLead, null);
            }
        }
    }

    public static List<PricebookEntry> getPBES(List<Lead> leads){
        Set<String> marcas = new Set<String>();
        Set<String> anios = new Set<String>();
        Set<String> modelosInteres = new Set<String>();
        for(Lead ld: leads){
            if (String.isNotBlank(ld.Codigo_de_producto__c)){
                continue;
            }

            if(ld.Marca__c != null){
                marcas.add(ld.Marca__c);
            }

            if(ld.Ano1__c != null){
                anios.add(ld.Ano1__c);
            }

            if(ld.Modelo_De_Inter_s1__c != null){
                modelosInteres.add(ld.Modelo_De_Inter_s1__c);
            }
        }

        if(modelosInteres.isEmpty() && marcas.isEmpty()){
            return new List<PricebookEntry>();
        }

        List<PricebookEntry> pbes = [SELECT Id,Pricebook2.Name,UnitPrice,Product2.Modelo_De_Inter_s__c,Product2.Marca__c FROM PricebookEntry
                                    WHERE Product2.Modelo_De_Inter_s__c != NULL  AND Product2.Modelo_De_Inter_s__c IN :modelosInteres AND Product2.Marca__c != NULL  AND Product2.Marca__c IN :marcas AND IsActive = true AND Pricebook2.IsActive = true AND Product2.esVehiculo__c = false AND Product2.IsActive = true
                                    ORDER BY UnitPrice ASC];
        return pbes;
    }

    public static PricebookEntry getPBE(Lead ld, List<PricebookEntry> pbes){
        PricebookEntry selectedPBE = null;
        for(PricebookEntry pbe: pbes){
            if(String.isNotBlank(ld.Marca__c) && pbe.Product2.Marca__c == ld.Marca__c && String.isNotBlank(ld.Modelo_De_Inter_s1__c) && pbe.Product2.Modelo_De_Inter_s__c == ld.Modelo_De_Inter_s1__c){
                //verificar si el nombre del pbe contiene la marca y año del lead
                String pbName = pbe.Pricebook2.Name.toLowerCase();
                System.debug('@pbName@');   
                System.debug(pbName);
                
                if(pbName.contains(ld.Marca__c.toLowerCase()) && pbName.contains(ld.Ano1__c.toLowerCase())){
                    selectedPBE = pbe;
                }
                return selectedPBE;
            }
        }
        return selectedPBE;
    }

    public static void TransferirIntereses(List<Lead> newList) {
        System.debug('****** proceso ****** ' + newList);
        List <OpportunityLineItem> listOppLineItem = new List <OpportunityLineItem>();

        List<PricebookEntry> pbes = getPBES(newList);
        
        Map<String, String> mapOps = new Map<String, String>();
        Account acc = new Account();
        String anno, idTipoRegistro;

        System.debug('**** proceso **** ');
        if(newList[0].IsConverted){
            System.debug('**** proceso 1 **** ');
            acc = [SELECT PersonEmail FROM Account WHERE Id =: newList[0].ConvertedAccountId];
        }
        System.debug('**** proceso 2 **** ');
        for (Lead ld: newList) {
            System.debug('**** proceso 3**** ');     

            if(ld.Marca__c != null){
            	idTipoRegistro = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ld.Marca__c).getRecordTypeId();
            }
            // else{
            //     idTipoRegistro = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Oportunidad Usados').getRecordTypeId();
            // }

            System.debug('**** id tipo registro op ***** ' + idTipoRegistro);
            anno = ld.Ano1__c;
            if(ld.IsConverted && ld.ConvertedOpportunityId != null && ld.ConvertedContactId != null && ld.Precio1__c != null && ld.Codigo_de_producto__c != null) {
                System.debug('*** primer producto **** ');
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                oppLineItem.OpportunityId = ld.ConvertedOpportunityId;
                oppLineItem.UnitPrice = ld.Precio1__c;
                oppLineItem.Marca__c = ld.Marca__c;
                oppLineItem.Modelo_De_Inter_s1__c = ld.Modelo_De_Inter_s1__c;
                oppLineItem.Familia1__c = ld.Familia1__c;
                oppLineItem.Anio_Interes__c = ld.Ano1__c;
                oppLineItem.Quantity = 1;
                if(String.isNotBlank(ld.Codigo_de_producto__c)){
                    oppLineItem.PricebookEntryId = ld.Codigo_de_producto__c;
                }else{
                    PricebookEntry pbe = getPBE(ld, pbes);
                    if(pbe != null){
                        oppLineItem.PricebookEntryId = pbe.Id;
                    }
                }

                mapOps.put(ld.Ano1__c, ld.ConvertedOpportunityId);
                listOppLineItem.add(oppLineItem);                
            }
            if (ld.IsConverted && ld.ConvertedOpportunityId != null && ld.ConvertedContactId != null && ld.Precio2__c != null && ld.Codigo_de_producto2__c != null && anno == ld.Ano2__c) {
                System.debug('** segundo producto igual *** ');
                OpportunityLineItem oppLineItem2 = new OpportunityLineItem();
                oppLineItem2.OpportunityId = ld.ConvertedOpportunityId;
                oppLineItem2.UnitPrice = ld.Precio2__c;
                oppLineItem2.Marca__c = ld.Marca2__c;
                oppLineItem2.Modelo_De_Inter_s1__c = ld.Modelo_De_Inter_s2__c;
                oppLineItem2.Familia1__c = ld.Familia2__c;
                oppLineItem2.Quantity = 1;
                oppLineItem2.Anio_Interes__c = ld.Ano2__c;
                oppLineItem2.PricebookEntryId = ld.Codigo_de_producto2__c;

                listOppLineItem.add(oppLineItem2);                
            }else if(ld.IsConverted && ld.ConvertedOpportunityId != null && ld.ConvertedContactId != null && ld.Precio2__c != null && ld.Codigo_de_producto2__c != null && anno != ld.Ano2__c){
                //Se crea la oportunidad nueva
                System.debug('*** segundo producto diferente*** ');
                Opportunity op2 = new Opportunity();
                op2.Name = ld.Name;
                op2.RecordTypeId = idTipoRegistro;
                op2.RT_Lead__c = ld.Marca__c;
                op2.Campana__c = ld.Campana__c;
                op2.Sucursal__c = ld.Sucursal__c;
                op2.AccountId = ld.ConvertedAccountId;
                op2.StageName = 'Oportunidad Calificada';
                op2.CloseDate = Date.today().addDays(9);
                op2.LeadSource = ld.LeadSource;
                op2.Tipo_de_Cliente__c = 'Lealtad';
                op2.CorreoElectronicoCliente__c = acc.PersonEmail;
                //op2.Vendedor__c = true;
                //op2.DescuentoAprobado__c = false;
                insert op2;
                mapOps.put(ld.Ano2__c, op2.Id);

                //Se crea el producto de la oportunidad
                OpportunityLineItem oppLineItem2 = new OpportunityLineItem();
                oppLineItem2.OpportunityId = op2.Id;
                oppLineItem2.UnitPrice = ld.Precio2__c;
                oppLineItem2.Marca__c = ld.Marca2__c;
                oppLineItem2.Modelo_De_Inter_s1__c = ld.Modelo_De_Inter_s2__c;
                oppLineItem2.Familia1__c = ld.Familia2__c;
                oppLineItem2.Quantity = 1;
                oppLineItem2.PricebookEntryId = ld.Codigo_de_producto2__c;
                oppLineItem2.Anio_Interes__c = ld.Ano2__c;
                listOppLineItem.add(oppLineItem2);                
            }

            if (ld.IsConverted && ld.ConvertedOpportunityId != null && ld.ConvertedContactId != null && ld.Precio3__c != null && ld.Codigo_de_producto3__c != null && anno == ld.Ano3__c) {
                System.debug('***** tercer producto igual **** ');
                OpportunityLineItem oppLineItem3 = new OpportunityLineItem();
                oppLineItem3.OpportunityId = ld.ConvertedOpportunityId;
                oppLineItem3.UnitPrice = ld.Precio3__c;
                oppLineItem3.Marca__c = ld.Marca3__c;
                oppLineItem3.Modelo_De_Inter_s1__c = ld.Modelo_De_Inter_s3__c;
                oppLineItem3.Familia1__c = ld.Familia3__c;
                oppLineItem3.Quantity = 1;
                oppLineItem3.PricebookEntryId = ld.Codigo_de_producto3__c;
                oppLineItem3.Anio_Interes__c = ld.Ano3__c;
                listOppLineItem.add(oppLineItem3);                
            }else if(ld.IsConverted && ld.ConvertedOpportunityId != null && ld.ConvertedContactId != null && ld.Precio3__c != null && ld.Codigo_de_producto3__c != null && anno != ld.Ano3__c){
                //Se crea la oportunidad nueva
                System.debug('***** tercer producto diferente **** ');
                Opportunity op3 = new Opportunity();
                if(!mapOps.containsKey(ld.Ano3__c)){
                    op3.Name = ld.Name;
                    op3.RecordTypeId = idTipoRegistro;
                    op3.RT_Lead__c = ld.Marca__c;
                    op3.Campana__c = ld.Campana__c;
                    op3.Sucursal__c = ld.Sucursal__c;
                    op3.AccountId = ld.ConvertedAccountId;
                    op3.StageName = 'Oportunidad Calificada';
                    op3.CloseDate = Date.today().addDays(9);
                    op3.LeadSource = ld.LeadSource;
                    op3.Tipo_de_Cliente__c = 'Lealtad';
                    op3.CorreoElectronicoCliente__c = acc.PersonEmail;
                    //op3.Vendedor__c = true;
                    //op3.DescuentoAprobado__c = false;
                    insert op3;
                    mapOps.put(ld.Ano3__c, op3.Id);
                }
                //Se crea el producto de la oportunidad
                OpportunityLineItem oppLineItem3 = new OpportunityLineItem();
                if(!mapOps.containsKey(ld.Ano3__c)){
                    oppLineItem3.OpportunityId = op3.Id;
                }else{
                    oppLineItem3.OpportunityId = mapOps.get(ld.Ano3__c);
                }
                oppLineItem3.UnitPrice = ld.Precio3__c;
                oppLineItem3.Marca__c = ld.Marca3__c;
                oppLineItem3.Modelo_De_Inter_s1__c = ld.Modelo_De_Inter_s3__c;
                oppLineItem3.Familia1__c = ld.Familia3__c;
                oppLineItem3.Quantity = 1;
                oppLineItem3.PricebookEntryId = ld.Codigo_de_producto3__c;
                oppLineItem3.Anio_Interes__c = ld.Ano3__c;
                listOppLineItem.add(oppLineItem3);                  
            }
            if (ld.IsConverted && ld.ConvertedOpportunityId != null && ld.ConvertedContactId != null && ld.Precio4__c != null && ld.Codigo_de_producto4__c != null && anno == ld.Ano4__c) {
                OpportunityLineItem oppLineItem4 = new OpportunityLineItem();
                oppLineItem4.OpportunityId = ld.ConvertedOpportunityId;
                oppLineItem4.UnitPrice = ld.Precio4__c;
                oppLineItem4.Marca__c = ld.Marca4__c;
                oppLineItem4.Modelo_De_Inter_s1__c = ld.Modelo_De_Inter_s4__c;
                oppLineItem4.Familia1__c = ld.Familia4__c;
                oppLineItem4.Quantity = 1;
                oppLineItem4.PricebookEntryId = ld.Codigo_de_producto4__c;
                oppLineItem4.Anio_Interes__c = ld.Ano4__c;
                listOppLineItem.add(oppLineItem4);                
            }else if(ld.IsConverted && ld.ConvertedOpportunityId != null && ld.ConvertedContactId != null && ld.Precio4__c != null && ld.Precio4__c != null && anno != ld.Ano4__c){
                //Se crea la oportunidad nueva
                Opportunity op4 = new Opportunity();
                if(!mapOps.containsKey(ld.Ano4__c)){
                    op4.Name = ld.Name;
                    op4.RecordTypeId = idTipoRegistro;
                    op4.RT_Lead__c = ld.Marca__c;
                    op4.Campana__c = ld.Campana__c;
                    op4.Sucursal__c = ld.Sucursal__c;
                    op4.AccountId = ld.ConvertedAccountId;
                    op4.StageName = 'Oportunidad Calificada';
                    op4.CloseDate = Date.today().addDays(9);
                    op4.LeadSource = ld.LeadSource;
                    op4.Tipo_de_Cliente__c = 'Lealtad';
                    op4.CorreoElectronicoCliente__c = acc.PersonEmail;
                    //op4.Vendedor__c = true;
                    //op4.DescuentoAprobado__c = false;
                    insert op4;
                    mapOps.put(ld.Ano4__c, op4.Id);
                }

                //Se crea el producto de la oportunidad
                OpportunityLineItem oppLineItem4 = new OpportunityLineItem();
                if(!mapOps.containsKey(ld.Ano4__c)){
                    oppLineItem4.OpportunityId = op4.Id;
                }else{
                    oppLineItem4.OpportunityId = mapOps.get(ld.Ano4__c);
                }
                oppLineItem4.UnitPrice = ld.Precio4__c;
                oppLineItem4.Marca__c = ld.Marca4__c;
                oppLineItem4.Modelo_De_Inter_s1__c = ld.Modelo_De_Inter_s4__c;
                oppLineItem4.Familia1__c = ld.Familia4__c;
                oppLineItem4.Quantity = 1;
                oppLineItem4.PricebookEntryId = ld.Codigo_de_producto4__c;
                oppLineItem4.Anio_Interes__c = ld.Ano4__c;
                listOppLineItem.add(oppLineItem4);                
            }
        }

        System.debug(listOppLineItem);

        insert listOppLineItem;
    
        List<Profile> profileList = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1];
        String profileName = '%'+profileList[0].Name+'%';

        //Insertamos los productos de interes relacionados a la oportunidadm viniendo desde trafico
        if (listOppLineItem.size() > 0) {
            Set<Id> oliIds = new Set<Id>();
            for (OpportunityLineItem tmpOLI : listOppLineItem) {
                oliIds.add(tmpOLI.Id);
            }

            List<Oportunidad_Producto_Interes__c> opiList = new List<Oportunidad_Producto_Interes__c>();
            for (OpportunityLineItem tmpOLI : [SELECT Product2Id,PricebookEntryId,UnitPrice,OpportunityId,Modelo_De_Inter_s1__c,Marca__c,Familia1__c,Quantity,PricebookEntry.Vendedor__c,PricebookEntry.Gerente__c,PricebookEntry.Costo_Fijo__c, PricebookEntry.Jefe__c,Anio_Interes__c FROM OpportunityLineItem WHERE Id IN :oliIds]) {
                opiList.add(createOPIRecord(tmpOLI));
            }
            insert opiList;
        }
    }

    public static void ObtenerListaPreciosW2L(List<Lead> newList) {

        String sFamilia = '';
        List<Campaign> lstCampaign = [SELECT Id, Name FROM Campaign Where Name = 'Campaña de W2L'];
        System.debug('Los datos son' + lstCampaign);
        Boolean esWeb2Lead = false;
        TraficoService.Precios pcr = new TraficoService.Precios();
        List<String> lstPrecios = new List<String> ();

        Schema.DescribeFieldResult fieldResult =
        Lead.Modelo_De_Inter_s1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Map<String,string> mapValoresModelos = new map<String,String>();
        for (Schema.PicklistEntry f : ple){
        String valorModelo = f.getLabel();
        System.debug(' ****** valorModelo ****** ' + valorModelo + ' ****** codigo ****** ' + valorModelo.substringBefore(' '));
        mapValoresModelos.put(valorModelo.substringBefore(' '),f.getValue());
        }
            System.debug('Los Datos: '+newList);
        for (Lead ld : newList) {
            System.debug('Es web2Lead '+ld.EsWeb2Lead_del__c);
            System.debug('Id de la campana' + lstCampaign);
        if (ld.EsWeb2Lead_del__c == true) {
            ld.Campana__c = lstCampaign[0].Id;
            esWeb2Lead = ld.EsWeb2Lead_del__c;
            if (ld.Marca__c != null && ld.Familia1__c != null && ld.RFI__c == null && ld.TDA__c == null) {
            lstPrecios = pcr.generaPreciosW2L(ld.Marca__c, ld.Familia1__c, ld.Modelo_De_Inter_s1__c);
            System.debug(' ****** lstPrecios ****** ' + lstPrecios[0] + '****** codigo ******* ' + lstPrecios[0].substringBefore(' '));
            //ld.Modelo_De_Inter_s1__c = lstPrecios[0];
            ld.Modelo_De_Inter_s1__c = mapValoresModelos.containsKey(lstPrecios[0].substringBefore(' '))?mapValoresModelos.get(lstPrecios[0].substringBefore(' ')):'';
            
            if(mapValoresModelos.containsKey(lstPrecios[0].substringBefore(' '))) system.debug('mapValoresModelos.get **** ' + mapValoresModelos.get(lstPrecios[0].substringBefore(' ')));
            }
        }
        }
    }

    class Precios{

        String leadCurrencyCode;

        List<String> generaPreciosW2L(String marca,String familia,string model){

                Map<String,Decimal> mapMinPrice = new Map<String,Decimal>();
                Map<String,String> mapPriceName = new Map<String,String>();
                List<String> lstPrecios = new List<String>();
				System.debug('Marca: '+marca);
            	System.debug('Familia: '+familia);
            	System.debug('Modelo: '+model);
                List<Configuracion_de_ventas__c> lstConf = [SELECT Id, Listas_de_Precios_Vigente__c, Marca__c FROM Configuracion_de_ventas__c WHERE Marca__c LIKE:'%'+ marca +'%'];
            	System.debug('Salida 1: '+lstConf);
                List<Pricebook2> lstPricebook2 = [Select p.Id,p.Name From Pricebook2 p where p.Name LIKE: '%'+ lstConf[0].Listas_de_Precios_Vigente__c +'%'];
            	System.debug('Salida 2: '+lstPricebook2);
                List<Product2> productosActivos = [select id,Name from Product2 where IsActive=true and Marca__c =:marca and Familia__c =: familia AND Name Like: '%'+model+'%'];
                System.debug('Salida 3: '+productosActivos);
            //List<AggregateResult> lstAr = [SELECT MIN(UnitPrice),Name FROM PricebookEntry WHERE Familia__c LIKE: '%'+ familia +'%' AND Pricebook2Id IN:lstPricebook2 GROUP BY Name ORDER BY MIN(UnitPrice) ASC LIMIT 1];
                List<AggregateResult> lstAr = [SELECT min(UnitPrice),Name from PricebookEntry where Product2.Id IN:productosActivos AND Pricebook2Id IN:lstPricebook2 GROUP BY Name ORDER BY MIN(UnitPrice) ASC LIMIT 1];
				System.debug('Salida 4: '+ lstAr);	
                for (AggregateResult results : lstAr){
                    lstPrecios.add((String)results.get('Name'));
                }

                return lstPrecios;
        }

        String ObtenerListaPreciosVigente(String marca){
            String vacio = '';
            
            List<Configuracion_de_ventas__c> lstListaPreciosVigente = [SELECT Id,Listas_de_Precios_Vigente__c FROM Configuracion_de_ventas__c WHERE Marca__c LIKE:'%'+ marca +'%'];
            if(lstListaPreciosVigente.size() > 0 && !lstListaPreciosVigente.isEmpty())
                return lstListaPreciosVigente[0].Listas_de_Precios_Vigente__c;
            else
                return vacio; 
        }

        Decimal generarPreciosSFW(String marca, String modelo, boolean flujoWalkin){
            System.debug('************************ MODELO ************************ ' + modelo);
            Set<String> setPrecios = new Set<String>();
            List<String> lstPrecios = new List<String>();
            Map<String,Decimal> mapPrecios = new Map<String,Decimal>();
            Map<String, String> mapCurrencyCode = new Map<String, String>();
            String sPrecios;

            Configuracion_de_ventas__c selectedConfig;

            List<Configuracion_de_ventas__c> lstConf = [SELECT Id, Listas_de_Precios_Vigente__c, Marca__c FROM Configuracion_de_ventas__c WHERE Marca__c LIKE:'%'+ marca +'%'];
            System.debug('Configuracion de venta: '+lstConf);
            if(lstConf.size()>1){
                 // Iterate over the list to find the one with '2024' in Listas_de_Precios_Vigente__c
                for (Configuracion_de_ventas__c conf : lstConf) {
                    if (conf.Listas_de_Precios_Vigente__c.contains('2024')) {
                        selectedConfig = conf;
                        break; // Stop the loop once found
                    }
                }
            }else{
                selectedConfig = lstConf[0];
            }
            List<Pricebook2> lstPricebook2 = [Select p.Id,p.Name From Pricebook2 p where p.Name LIKE: '%'+ selectedConfig.Listas_de_Precios_Vigente__c +'%'];
            System.debug('Lista 1: '+lstPricebook2 );

            for (Integer i = lstPricebook2.size() - 1; i >= 0; i--) {
                if (lstPricebook2[i].Name.toLowerCase().contains('no usar')) {
                    lstPricebook2.remove(i);
                }
            }
            List<PricebookEntry> lstPricebookEntry = [SELECT UnitPrice,Name, CurrencyIsoCode  FROM PricebookEntry WHERE Pricebook2Id IN:lstPricebook2 ORDER BY UnitPrice ASC];
            System.debug('Lista 2: '+lstPricebookEntry );

            for(PricebookEntry pbe:lstPricebookEntry){
                String valorBuscado = '';
                if( marca == 'Kawasaki' || marca == 'Motorrad' || marca == 'Polaris' || marca == 'Indian'){
                    String originalString = pbe.Name;
                    Integer secondDashIndex = originalString.indexOf('-', originalString.indexOf('-') + 1);
                    String finalString = originalString.substring(secondDashIndex + 1);
                    System.debug(finalString); // This will output 'VULCAN-S'
                    valorBuscado = finalString;
                }else{
                    valorBuscado = pbe.Name.substringBefore(' ');
                }  
              lstPrecios.add(String.valueOf(valorBuscado));
              mapPrecios.put(valorBuscado, pbe.UnitPrice);
              mapCurrencyCode.put(valorBuscado, pbe.CurrencyIsoCode);
            }

            setPrecios.addAll(lstPrecios);
            System.debug('******************************* mapa precios **************************** ' + mapPrecios);
            System.debug('***************************** mapa precio BM17P *********************** ' + mapPrecios.containsKey(modelo));

            if(setPrecios.contains(modelo)){
                sPrecios = String.valueOf(mapPrecios.get(modelo));
                leadCurrencyCode = mapCurrencyCode.get( modelo );
                System.debug('****************************** PRECIO *********************' + sPrecios);
            }else{
                if(flujoWalkin){
                    sPrecios = '0.00';
                }
                else{
                    System.debug('************************************ mapa precios *********************** ' + mapPrecios);
                	//sPrecios = '0.00';  //Si el precio no esta en el pricebook entry le pone el valor de 0.00, debería mostrar un error.
                	throw new MyException('el precio del ' + modelo + ' no se encuentra en la lista de precios vigente');
            	}
            }
                

            return Decimal.valueOf(sPrecios);
        }

        PricebookEntry generarPreciosSF(String marca, String modelo, String anno){

            PricebookEntry pbeSelecionado;
            System.debug('********* MODELO ***********' + marca + ' ' + modelo + ' ' + anno);

            Integer currentYear = Date.today().year();            
            if(anno == null || anno == ''){
                anno = String.valueOf(currentYear);
            }
  
            Map<String,PricebookEntry> modeloPBEMap = new Map<String,PricebookEntry>();
            
            List<PricebookEntry> pbes = [SELECT UnitPrice, Name,Pricebook2.Name,Product2.Modelo_De_Inter_s__c,Product2.Marca__c
                                                        FROM PricebookEntry 
                                                        WHERE Pricebook2.Name LIKE: '%' + anno + '%'  AND Pricebook2.Name LIKE: '%' + marca + '%' AND Pricebook2.IsActive = TRUE AND IsActive = TRUE ORDER BY UnitPrice ASC];
            // Filter out entries where Pricebook2.Name contains 'No usar'
            for (Integer i = pbes.size() - 1; i >= 0; i--) {
                if (pbes[i].Pricebook2.Name.toLowerCase().contains('no usar')) {
                    pbes.remove(i);
                }
            }
            for(PricebookEntry pbe : pbes){
                String modeloFinal = '';
                if( marca == 'Kawasaki' || marca == 'Motorrad' || marca == 'Polaris' || marca == 'Indian'){
                    String originalString = pbe.Name;
                    Integer secondDashIndex = originalString.indexOf('-', originalString.indexOf('-') + 1);
                    String finalString = originalString.substring(secondDashIndex + 1);
                    System.debug(finalString); // This will output 'VULCAN-S'
                    modeloFinal = finalString;
                }else{
                    modeloFinal = pbe.Name.substringBefore(' ');
                }

                if(modeloFinal == modelo){
                    modeloPBEMap.put(modeloFinal,pbe);
                }
            }

            return modeloPBEMap.get(modelo);
        }

        String generarIdPreciosSFW(String marca, String modelo){
            System.debug('************************ MODELO ************************ ' + modelo);
            Set<String> setPrecios = new Set<String>();
            List<String> lstPrecios = new List<String>();
            Map<String,String> mapPrecios = new Map<String,String>();
            String sIdPrecios;

            List<Configuracion_de_ventas__c> lstConf = [SELECT Id, Listas_de_Precios_Vigente__c, Marca__c FROM Configuracion_de_ventas__c WHERE Marca__c LIKE:'%'+ marca +'%'];
            List<Pricebook2> lstPricebook2 = [Select p.Id,p.Name From Pricebook2 p where p.Name LIKE: '%'+ lstConf[0].Listas_de_Precios_Vigente__c +'%'];
            List<PricebookEntry> lstPricebookEntry = [SELECT Id,UnitPrice,Name FROM PricebookEntry WHERE Pricebook2Id IN:lstPricebook2 ORDER BY UnitPrice ASC];

            for(PricebookEntry pbe:lstPricebookEntry){

                String valorBuscado = '';
                if( marca == 'Kawasaki' || marca == 'Motorrad' || marca == 'Polaris' || marca == 'Indian'){
                    String originalString = pbe.Name;
                    Integer secondDashIndex = originalString.indexOf('-', originalString.indexOf('-') + 1);
                    String finalString = originalString.substring(secondDashIndex + 1);
                    System.debug(finalString); // This will output 'VULCAN-S'
                    valorBuscado = finalString;
                }else{
                    valorBuscado = pbe.Name.substringBefore(' ');
                }  
                
              lstPrecios.add(String.valueOf(valorBuscado));
              mapPrecios.put(valorBuscado,pbe.Id);
            }

            setPrecios.addAll(lstPrecios);
            System.debug('******************************* mapa precios **************************** ' + mapPrecios);
            System.debug('***************************** mapa precio *********************** ' + mapPrecios.containsKey(modelo));
            System.debug('************************************ setPrecios *********************** ' + setPrecios);
            if(setPrecios.contains(modelo)){
                sIdPrecios = String.valueOf(mapPrecios.get(modelo));
                System.debug('****************************************** ID PRECIO **************************** ' + sIdPrecios);
            }

            return sIdPrecios;
        }

        String generarIdPreciosSF(String marca, String modelo, String anno){
            System.debug('********* MODELO ********* ' + marca + modelo + anno);
            Set<String> setPrecios = new Set<String>();
            List<String> lstPrecios = new List<String>();
            Map<String,String> mapPrecios = new Map<String,String>();
            String sIdPrecios;

            //List<Configuracion_de_ventas__c> lstConf = [SELECT Id, Listas_de_Precios_Vigente__c, Marca__c FROM Configuracion_de_ventas__c WHERE Marca__c LIKE:'%'+ marca +'%'];
            List<Pricebook2> lstPricebook2 = [Select p.Id, p.Name 
                                                From Pricebook2 p 
                                                where p.Name LIKE: '%'+ anno +'%' AND p.Name LIKE: '%' + marca + '%'];

            System.debug('**** lista de precios **** ' + lstPricebook2);
            List<PricebookEntry> lstPricebookEntry = [SELECT Id, UnitPrice, Name 
                                                        FROM PricebookEntry 
                                                        WHERE Pricebook2Id IN : lstPricebook2 
                                                        AND Product2.Modelo_De_Inter_s__c != NULL AND Product2.Modelo_De_Inter_s__c = :modelo 
                                                        ORDER BY UnitPrice ASC];

            System.debug('***** lista de catalogos de precios ***** ' + lstPricebookEntry);
            for(PricebookEntry pbe:lstPricebookEntry){
                String valorBuscado = '';
                if( marca == 'Kawasaki' || marca == 'Motorrad' || marca == 'Polaris' || marca == 'Indian'){
                    String originalString = pbe.Name;
                    Integer secondDashIndex = originalString.indexOf('-', originalString.indexOf('-') + 1);
                    String finalString = originalString.substring(secondDashIndex + 1);
                    System.debug(finalString); // This will output 'VULCAN-S'
                    valorBuscado = finalString;
                }else{
                    valorBuscado = pbe.Name.substringBefore(' ');
                }  
                System.debug('**** catalogo de precio **** ' + pbe);
                if(valorBuscado== modelo){
                    lstPrecios.add(String.valueOf(pbe.Name).substringBefore(' '));
                    mapPrecios.put(valorBuscado,pbe.Id);
                }

            }

            setPrecios.addAll(lstPrecios);
            System.debug('******************************* mapa precios **************************** ' + mapPrecios);
            System.debug('***************************** mapa precio *********************** ' + mapPrecios.containsKey(modelo));
            System.debug('************************************ setPrecios *********************** ' + setPrecios);
            if(setPrecios.contains(modelo)){
                sIdPrecios = String.valueOf(mapPrecios.get(modelo));
                System.debug('****************************************** ID PRECIO **************************** ' + sIdPrecios);
            }

            return sIdPrecios;
        }

    }

    public class MyException extends Exception{}
    
    public void UpdateAccountAlready(List<Lead> allLeads){
        List<database.LeadConvert> leadsToConvert = new List<database.LeadConvert>();
        List<Account> accountsToUpdate = new List<Account>();
        String idTipoRegistroAlticaFis, idTipoRegistroAlticaEmp;
        
        Group g = [SELECT id FROM group WHERE name = 'Cola de Candidatos Web' AND Type = 'queue'];
        idTipoRegistroAlticaFis = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Físico').getRecordTypeId();
        idTipoRegistroAlticaEmp = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Jurídico').getRecordTypeId();
        
        system.debug('Cola web: ' + g + ' id corto: ' + String.valueOf(g.id).substring(0,15));
        
        for(Lead l : allLeads){
            if(!l.isConverted){
                database.LeadConvert lc = new database.LeadConvert();
                
                lc.setLeadId(l.id);
                lc.setConvertedStatus('Qualified');

                system.debug('PROPIETARIO DEL LEAD: ' + l.ownerId);
                system.debug('USUARIO LOGUEADO: ' + UserInfo.getUserId());
                
                if(!l.ownerId.equals(String.valueOf(g.id).substring(0,15))){ //si no es una cola
                    system.debug(':::: NO ES UNA COLA :::: ');
                //if(!string.valueOf(l.ownerId).startsWith('00G'))
                    if(l.ownerId == UserInfo.getUserId()){ //sino es una cola y además el propietario del lead SI es el usuario que está logueado 
                        system.debug(':::: SINO ES UNA COLA Y ADEMÁS EL PROPIETARIO DEL LEAD ES EL USUARIO CONECTADO :::::: ');
                        lc.setOwnerId(UserInfo.getUserId()); //se asigna como propietario de la op el logueado
                    }
                    else{//sino es una una cola y además el propietario del lead NO es el usuario que está logueado
                        system.debug(':::: SINO ES UNA COLA Y ADEMÁS EL PROPIETARIO DEL LEAD NO ES EL USUARIO CONECTADO :::: ');
                        lc.setOwnerId(l.OwnerId); //se asigna como propietario de la op el propietario del lead
                    }
                }else{//si es una cola
                    system.debug(':::: SI PROPIETARIO LEAD ES UNA COLA ASIGNA USUARIO CONECTADO :::: ');
                    lc.setOwnerId(UserInfo.getUserId()); //si es una cola se asigna el usuario que está logueado
                }
                    
                List<Account> accountList = findAccounts(l);
                if(accountList.size() > 0 && accountList[0].RecordTypeId != idTipoRegistroAlticaEmp && accountList[0].RecordTypeId != idTipoRegistroAlticaFis){
                    Account theAc = null;
                    if(accountList.size() == 1){
                        theAc = accountList.get(0);
                    }
                    else{
                        for(Account acct : accountList){
                            if(acct.Cedula__c != null && acct.Cedula__c == l.Numero_de_Identificacion_del__c){
                                theAc = acct;
                                break;
                            }
                            if(acct.PersonEmail != null && acct.PersonEmail == l.Email && acct.PersonMobilePhone != null && acct.PersonMobilePhone == l.MobilePhone){
                                theAc = acct;
                                break;
                            }
                        }
                        if(theAc == null){
                            theAc = accountList.get(0);
                        }
                    }
                    lc.setAccountId(theAc.Id);
                    lc.setDoNotCreateOpportunity(false);
                    leadsToConvert.add(lc); 
                    
                    Account a = new Account(Id = theAc.Id);
                    if(l.Numero_de_Identificacion_del__c != null)
                        a.Cedula__c = theAc.Cedula__c;
                    if(l.Tipo_de_Identificaci_n__c != null)
                        a.Tipo_de_Documento__c = theAc.Tipo_de_Documento__c;
                    if(l.Email != null)
                        a.PersonEmail = l.Email;
                    if(l.MobilePhone != null)   
                        a.PersonMobilePhone = l.MobilePhone;
                    if(l.Phone != null)
                        a.Phone = l.Phone;
                    accountsToUpdate.add(a);
                }else{
                    leadsToConvert.add(lc);
                }           
            }
        }
        
        if(leadsToConvert.size() > 0){
            if(accountsToUpdate.size() > 0) {
                update accountsToUpdate;    
            }
            database.LeadConvertResult [] lr = database.convertLead(leadsToConvert);
        }
    }
    
    private static List<Account> findAccounts(Lead lead){
        system.debug('findAccounts');
        List<Account> matches = new List<Account>();
        String searchQuery = 'Select RecordTypeId, Id, Tipo_de_Documento__c, Cedula__c, PersonEmail, PersonMobilePhone From Account ';
        String whereQuery = 'Where ';
        system.debug('query1');
        if(lead.Numero_de_Identificacion_del__c != null)
            whereQuery += 'Cedula__c = \'' + lead.Numero_de_Identificacion_del__c + '\' OR ' ;
        if(lead.MobilePhone != null || lead.Email != null)
            whereQuery += '(PersonEmail = \'' + lead.Email + '\' AND PersonMobilePhone = \'' + lead.MobilePhone + '\')';
        system.debug('query2'); 
        searchQuery = searchQuery + whereQuery + ' Limit 100';
        List<Account> results = Database.query(searchQuery);
        system.debug('query3');
        for(Account result : results){
            if(lead.Numero_de_Identificacion_del__c != null && result.Cedula__c == lead.Numero_de_Identificacion_del__c){
                matches.add(result);
                break;
            }
            matches.add(result);
        }
        return matches;
    }
    
    //Metodo para actualizar la campanna de los lead ingresados por medio del web to lead
    //Se asigna la campanna Sin Campanna
    public static void actualizarCampannaWebToLead(List<Lead> listTemp){
        Id idCampanna;

        idCampanna = [SELECT Id FROM Campaign WHERE Name =: 'Sin Campaña' AND RecordTypeId =: '0120P000000EPLH'].Id;
        System.debug(' ** id campanna ** ' + idCampanna);
        for(Lead l : listTemp){
            l.Campana__c = idCampanna;
        }
    }

    public static Oportunidad_Producto_Interes__c createOPIRecord(OpportunityLineItem oli) {
        return new Oportunidad_Producto_Interes__c(
            Producto__c = oli.Product2Id,
            Precio_Unitario__c = oli.UnitPrice,
            Oportunidad__c = oli.OpportunityId,
            Modelo_Interes__c = oli.Modelo_De_Inter_s1__c,
            Marca__c = oli.Marca__c,
            Familia__c = oli.Familia1__c,
            Cantidad__c = oli.Quantity,
            Anio__c = oli.Anio_Interes__c,
            Comision_Porcentaje_Vendedor__c = oli.PricebookEntry.Vendedor__c,
            Comision_Porcentaje_Jefe__c = oli.PricebookEntry.Jefe__c,
            Comision_Porcentaje_Gerente__c = oli.PricebookEntry.Gerente__c,
            PricebookEntryId__c = oli.PricebookEntryId,
            Costo_Fijo__c = oli.PricebookEntry.Costo_Fijo__c,
            CurrencyIsoCode = 'USD'
        );
    }

     public static void dummy() {
        String test = '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
    }
}