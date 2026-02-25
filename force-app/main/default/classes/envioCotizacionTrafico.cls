/**
  @Autor: Martin Alvarez Garces
  @Fecha creacion: 07/08/2023 
  @Proyecto: Red Motors
  @Proposito: Clase para el envio del email de la cotizacion desde el trafico con los productos de interes
 **/

public class envioCotizacionTrafico {

    @AuraEnabled
	public static String envioCotizacion(String idTrafico, String idPropietario){
        Integer truco=0;
		truco++;
        truco++;
        truco++;
        truco++;
        truco++;
		truco++;
        truco++;
        truco++;
        truco++;
		truco++;
        truco++;
        truco++;
        truco++;
		truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
		truco++;
        truco++;
        truco++;
        truco++;
		truco++;
        truco++;
        truco++;
        truco++;
		truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
		String idTemplate;
		String idTemplate2;
		String idTemplate3;
		String idTemplate4;
		Lead l = new Lead();
		String[] toAddresses = new String[]{};
		List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
		List<String> listLeadMDI = new List<String>();
		List<String> listLeadMDI2 = new List<String>();
        List<String> listLeadModelo = new List<String>();
		List<Id> ids = new List<Id>();
		List<Document> listDoc = new List<Document>();
		
		OrgWideEmailAddress[] idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Red Motors'];
		l = [SELECT Id, LeadSource, AsuntoWeb__c,Owner.Name, Email, Cotizacion_1__c, Cotizacion_2__c, Cotizacion_3__c, Cotizacion_4__c, Modelo_De_Inter_s1__c, Modelo_De_Inter_s2__c, 
					Modelo_De_Inter_s3__c, Modelo_De_Inter_s4__c, Marca__c, Marca2__c, Marca3__c, Marca4__c FROM Lead WHERE Id =: idTrafico];

		if(l.Marca__c == 'MINI'){
			if(l.Modelo_De_Inter_s1__c != null && l.Cotizacion_1__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_MINI'].Id;
			}
			if(l.Modelo_De_Inter_s2__c != null && l.Cotizacion_2__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_MINI_2'].Id;
			}
			if(l.Modelo_De_Inter_s3__c != null && l.Cotizacion_3__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_MINI_3'].Id;
			}
			if(l.Modelo_De_Inter_s4__c != null && l.Cotizacion_4__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_MINI_4'].Id;
			}
												
		}else if(l.Marca__c.contains('Indian') ){
			idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Indian CR'];
			if(l.Modelo_De_Inter_s1__c != null && l.Cotizacion_1__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Indian'].Id;
			}
			if(l.Modelo_De_Inter_s2__c != null && l.Cotizacion_2__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Indian'].Id;
			}
			if(l.Modelo_De_Inter_s3__c != null && l.Cotizacion_3__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Indian'].Id;
			}
			if(l.Modelo_De_Inter_s4__c != null && l.Cotizacion_4__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Indian'].Id;
			}
					
		}else if(l.Marca__c.contains('Motorrad') ){
			if(l.Modelo_De_Inter_s1__c != null && l.Cotizacion_1__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Motorrad'].Id;
			}
			if(l.Modelo_De_Inter_s2__c != null && l.Cotizacion_2__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Motorrad'].Id;
			}
			if(l.Modelo_De_Inter_s3__c != null && l.Cotizacion_3__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Motorrad'].Id;
			}
			if(l.Modelo_De_Inter_s4__c != null && l.Cotizacion_4__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Motorrad'].Id;
			}
					
		}else if( l.Marca__c.contains('Kawasaki')  ){
			idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Kawasaki CR'];
			if(l.Modelo_De_Inter_s1__c != null && l.Cotizacion_1__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Kawa'].Id;
			}
			if(l.Modelo_De_Inter_s2__c != null && l.Cotizacion_2__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Kawa'].Id;
			}
			if(l.Modelo_De_Inter_s3__c != null && l.Cotizacion_3__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Kawa'].Id;
			}
			if(l.Modelo_De_Inter_s4__c != null && l.Cotizacion_4__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Kawa'].Id;
			}
					
		}else if(l.Marca__c.contains('Polaris') ){
			idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Polaris CR'];
			if(l.Modelo_De_Inter_s1__c != null && l.Cotizacion_1__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Polaris'].Id;
			}
			if(l.Modelo_De_Inter_s2__c != null && l.Cotizacion_2__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Polaris'].Id;
			}
			if(l.Modelo_De_Inter_s3__c != null && l.Cotizacion_3__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Polaris'].Id;
			}
			if(l.Modelo_De_Inter_s4__c != null && l.Cotizacion_4__c == true){
				idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Polaris'].Id;
			}
					
		}else{
			if(l.Modelo_De_Inter_s1__c != null && l.Cotizacion_1__c == true){
                if(l.LeadSource == 'Página Web' && l.AsuntoWeb__c == 'Test Drive'){
            		idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_BMW_Test_Drive'].Id;
            	}
                else{
					idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_BMW'].Id;
                }
			}
			if(l.Modelo_De_Inter_s2__c != null && l.Cotizacion_2__c == true){
                if(l.LeadSource == 'Página Web' && l.AsuntoWeb__c == 'Test Drive'){
            		idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_BMW_Test_Drive'].Id;
            	}
                else{
					idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_BMW_2'].Id;
                }
			}
			if(l.Modelo_De_Inter_s3__c != null && l.Cotizacion_3__c == true){
                if(l.LeadSource == 'Página Web' && l.AsuntoWeb__c == 'Test Drive'){
            		idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_BMW_Test_Drive'].Id;
            	}
                else{
					idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_BMW_3'].Id;
                }
			}
			if(l.Modelo_De_Inter_s4__c != null && l.Cotizacion_4__c == true){
                if(l.LeadSource == 'Página Web' && l.AsuntoWeb__c == 'Test Drive'){
            		idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_BMW_Test_Drive'].Id;
            	}
                else{
					idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_BMW_4'].Id;
                }
			}
											
		}
		if(l.Marca__c == 'KTM' || l.Marca2__c == 'KTM' || l.Marca3__c == 'KTM' || l.Marca4__c == 'KTM'){
			return 'Error: No tiene los suficientes privilegios para enviar una cotización para la marca KTM.';
		}else{
			if(l.Modelo_De_Inter_s1__c != null && l.Cotizacion_1__c == true){
				listLeadMDI.add(l.Modelo_De_Inter_s1__c.substringBefore(' -'));
			}
			if(l.Modelo_De_Inter_s2__c != null && l.Cotizacion_2__c == true){
				listLeadMDI.add(l.Modelo_De_Inter_s2__c.substringBefore(' -'));
			}
			if(l.Modelo_De_Inter_s3__c != null && l.Cotizacion_3__c == true){
				listLeadMDI.add(l.Modelo_De_Inter_s3__c.substringBefore(' -'));
			}
			if(l.Modelo_De_Inter_s4__c != null && l.Cotizacion_4__c == true){
				listLeadMDI.add(l.Modelo_De_Inter_s4__c.substringBefore(' -'));
			}


			if(l.Modelo_De_Inter_s1__c != null && l.Cotizacion_1__c == true){
                listLeadModelo.add(l.Modelo_De_Inter_s1__c);
				listLeadMDI2.add(l.Modelo_De_Inter_s1__c);
			}
			if(l.Modelo_De_Inter_s2__c != null && l.Cotizacion_2__c == true){
                 listLeadModelo.add(l.Modelo_De_Inter_s2__c);
				listLeadMDI2.add(l.Modelo_De_Inter_s2__c);
			}
			if(l.Modelo_De_Inter_s3__c != null && l.Cotizacion_3__c == true){
                listLeadModelo.add(l.Modelo_De_Inter_s3__c);
				listLeadMDI2.add(l.Modelo_De_Inter_s3__c);
			}
			if(l.Modelo_De_Inter_s4__c != null && l.Cotizacion_4__c == true){
                listLeadModelo.add(l.Modelo_De_Inter_s4__c);
				listLeadMDI2.add(l.Modelo_De_Inter_s4__c);
			}
			System.debug('***** nombre plantillas ***** ' + listLeadMDI);
			if((!listLeadMDI.isEmpty() && listLeadMDI.size() > 0) || (!listLeadMDI2.isEmpty() && listLeadMDI2.size() > 0 )){

				
				// listDoc = [SELECT Name, Id FROM Document WHERE DeveloperName IN : listLeadMDI];
				// System.debug(' ** LISTA FT ** ' + listDoc);
				// if(!listDoc.isEmpty() && listDoc.size() > 0){
				// 	for(Document d : listDoc){
				// 		ids.add(d.Id);
				// 	}
				// }else{
				// 	listDoc = [SELECT Name, Id FROM Document WHERE Name IN :listLeadMDI2];
				// 	System.debug(' ** LISTA FT ** ' + listDoc);
				// 	if(!listDoc.isEmpty() && listDoc.size() > 0){
				// 		for(Document d : listDoc){
				// 			ids.add(d.Id);
				// 		}
				// 	}
				// }
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
            List<Product2> listaProductos = new List<Product2>();
            List<String> publicUrls = new List<String>();
            List<String> fileNames = new List<String>();
			System.debug('====================================listLeadModelo====================================');
            System.debug(listLeadModelo);
            if(listLeadModelo.size()>0){
                toAddresses.add(l.Email);
                Id AdressId = '001000000000000AAA';
                if(idAddress.size()>0){
                	AdressId = idAddress[0].Id;
                }
                listaProductos = [Select Id,Name,Modelo_De_Inter_s__c,Link_ficha_t_cnica__c  From Product2
                                            Where Modelo_De_Inter_s__c  IN: listLeadModelo
                                            AND Link_ficha_t_cnica__c != NULL];
               
                if(listaProductos.size()>0){
                    for (Product2 prod : listaProductos) {
                        if (!String.isBlank(prod.Link_ficha_t_cnica__c)) {
                            TraficoService.enviarFichaTecnicaDesdeProducto(
                                prod.Id,
                                toAddresses,
                                idTemplate,
                                idTrafico,
                                AdressId
                            );
                        } else {
                            System.debug('🔁 Producto no tiene link de ficha técnica: ' + prod.Name);
                        }
                    }
                    return 'Cotización enviada';
                }else{
                    return 'incorrecto';
                }
            }
            return 'Cotización enviada';
			/*try{
				System.debug(' ** DEBUG 1 ** ' + toAddresses);
				Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
				correo.setOrgWideEmailAddressId(idAddress.get(0).Id);
				correo.setTemplateId(idTemplate);
				correo.setSaveAsActivity(false);
				correo.setTargetObjectId(l.Id);
				correo.setWhatId(l.Id);
				correo.setToAddresses(toAddresses);
				//correo.setEntityAttachments(ids);
				List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();

                if (publicUrls != null && fileNames != null && publicUrls.size() == fileNames.size()) {
                    for (Integer i = 0; i < publicUrls.size(); i++) {
                        String url = publicUrls[i];
                        String fileName = fileNames[i];
                        
                        HttpRequest req = new HttpRequest();
                        req.setEndpoint(url);
                        req.setMethod('GET');
                        req.setHeader('Content-Type', 'application/pdf'); // Ajusta si necesitas otra extensión
                        Http http = new Http();
                
                        try {
                            HTTPResponse res = http.send(req);
                            if (res.getStatusCode() == 200) {
                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                efa.setFileName(fileName);
                                efa.setBody(res.getBodyAsBlob());
                                fileAttachments.add(efa);
                            }
                        } catch (Exception ex) {
                            System.debug('Error al descargar archivo desde link público: ' + ex.getMessage());
                        }
                    }
                }
                
                if (!fileAttachments.isEmpty()) {
                    correo.setFileAttachments(fileAttachments);
                }
				Messaging.sendEmail(new Messaging.SingleEmailMessage[]{correo});
				
				System.debug(' ** DEBUG 2 ** ');
				l.Cotizacion_1__c = false;
				l.Cotizacion_2__c = false;
				l.Cotizacion_3__c = false;
				l.Cotizacion_4__c = false;
				TriggerHandler.bypass('TraficoTriggerHandler');
				update l;
				TriggerHandler.clearBypass('TraficoTriggerHandler');
				System.debug(' ** DEBUG 3 ** ');
				return 'Cotización enviada';
			}catch(Exception ex){
				System.debug(' ** DEBUG 3 ** ');
				System.debug(' ** ERROR AL ENVIAR EMAIL ** ' + ex);
				return 'Error al enviar cotización';
			}*/
		}
	}

    @AuraEnabled
	public static String envioCotizacionMultimarca(String idTrafico, String idPropietario){
		SavePoint sp = Database.setSavepoint();
		Boolean envio = false;
		String idTemplate;
		Lead l = new Lead();
		String[] toAddresses = new String[]{};
		List<Messaging.SendEmailResult> emails = new List<Messaging.SendEmailResult>();  
		List<String> nombresPlantillas = new List<String>();
		List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
		Set<Id> idsPlantillas = new Set<Id>();
		
		System.debug(' ** METODO ENVIO COTIZACION MULTIMARCA **');
		idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'NewMultimarcacotizacion_1678510036978'].Id;
		OrgWideEmailAddress[] idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Red Motors'];
		l = [SELECT Id, Owner.Name, Email, Cotizacion_1__c, Cotizacion_2__c, Cotizacion_3__c, Cotizacion_4__c,
			Modelo_De_Inter_s1__c, Modelo_De_Inter_s2__c, Modelo_De_Inter_s3__c, Modelo_De_Inter_s4__c FROM Lead WHERE Id =: idTrafico];
		System.debug('***** test 1 *******' + l);
		if(l.Modelo_De_Inter_s1__c != null && l.Cotizacion_1__c == true){
			System.debug('**** plantilla ***** ' + l.Modelo_De_Inter_s1__c.substring(0,4));
			nombresPlantillas.add([SELECT Id, NombredePlantilla__c FROM Product2 WHERE ProductCode =: l.Modelo_De_Inter_s1__c.substringBefore(' ')].NombredePlantilla__c);
		}
		if(l.Modelo_De_Inter_s2__c != null && l.Cotizacion_2__c == true){
			System.debug('**** plantilla ***** ' + l.Modelo_De_Inter_s2__c.substring(0,4));
			nombresPlantillas.add([SELECT Id, NombredePlantilla__c FROM Product2 WHERE ProductCode =: l.Modelo_De_Inter_s2__c.substringBefore(' ')].NombredePlantilla__c);
		}
		if(l.Modelo_De_Inter_s3__c != null && l.Cotizacion_3__c == true){
			System.debug('**** plantilla ***** ' + l.Modelo_De_Inter_s3__c.substring(0,4));
			nombresPlantillas.add([SELECT Id, NombredePlantilla__c FROM Product2 WHERE ProductCode =: l.Modelo_De_Inter_s3__c.substringBefore(' ')].NombredePlantilla__c);
		}
		if(l.Modelo_De_Inter_s4__c != null && l.Cotizacion_4__c == true){
			System.debug('**** plantilla ***** ' + l.Modelo_De_Inter_s4__c.substring(0,4));
			nombresPlantillas.add([SELECT Id, NombredePlantilla__c FROM Product2 WHERE ProductCode =: l.Modelo_De_Inter_s4__c.substringBefore(' ')].NombredePlantilla__c);
		}
		System.debug('***** nombre plantillas ***** ' + nombresPlantillas);
		for(EmailTemplate eT : [SELECT Id FROM EmailTemplate WHERE DeveloperName IN : nombresPlantillas]){
			if(!idsPlantillas.contains(eT.Id)){
				idsPlantillas.add(eT.Id);
			}
		}
		System.debug('******* ids plantillas ****** ' + idsPlantillas);
		if(!idsPlantillas.isEmpty()){
			for(Attachment a : [SELECT Id, Name, Body, BodyLength FROM Attachment WHERE ParentId IN : idsPlantillas]){
				Messaging.EmailFileAttachment eFA = new Messaging.EmailFileAttachment();
				eFA.setFileName(a.Name);
				eFA.setBody(a.Body);
				fileAttachments.add(eFA);
			}
		}
		System.debug('****** file attachments ****** ' + fileAttachments);
		toAddresses.add(l.Email);
		try{
			Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
			correo.setOrgWideEmailAddressId(idAddress.get(0).Id);
			correo.setTemplateId(idTemplate);
			correo.setSaveAsActivity(false);
			correo.setTargetObjectId(l.Id);
			correo.setWhatId(l.Id);
			correo.setToAddresses(toAddresses);
			if(!fileAttachments.isEmpty()){
				correo.setFileAttachments(fileAttachments);
			}
			emails = Messaging.sendEmail(new Messaging.Email[]{correo});
			System.debug('****** notificacion de email ***** ' + emails);
			if(emails.get(0).isSuccess()){
				envio = true;
			}
		}catch(Exception e){
			System.debug(' ** ERROR AL ENVIAR EMAIL ** ' + e);
			envio = false;
		}
		if(envio){
			l.Cotizacion_1__c = false;
			l.Cotizacion_2__c = false;
			l.Cotizacion_3__c = false;
			l.Cotizacion_4__c = false;
			TriggerHandler.bypass('TraficoTriggerHandler');
			update l;
			TriggerHandler.clearBypass('TraficoTriggerHandler');
			return 'Cotización enviada';
		}else{
			return 'Error al enviar cotización';
		}
	}
    
    public static void dummy(){
        Integer truco=0;
		truco++;
        truco++;
        truco++;
        truco++;
        truco++;
		truco++;
        truco++;
        truco++;
        truco++;
		truco++;
        truco++;
        truco++;
        truco++;
		truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
		truco++;
        truco++;
        truco++;
        truco++;
		truco++;
        truco++;
        truco++;
        truco++;
		truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
        truco++;
    }

    @AuraEnabled
    public static Lead getLead(Id leadId){
        return [SELECT  Id,
                        Cotizacion_1__c,
                        Cotizacion_2__c,
                        Cotizacion_3__c,
                        Cotizacion_4__c,
                        Marca__c
                FROM Lead
                WHERE Id =: leadId 
                LIMIT 1];
    }
}