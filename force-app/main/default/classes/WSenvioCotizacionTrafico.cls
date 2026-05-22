/**
  @Autor: David Leon Sanchez
  @Fecha creacion: 10/01/2018 
  @Proyecto: Red Motors
  @Proposito: Clase para el envio del email de la cotizacion desde el trafico con los productos de interes
 **/

	 global class WSenvioCotizacionTrafico  {
		@TestVisible
		private static List<Product2> testProductosCotizacion;
		@TestVisible
		private static Boolean testEnvioMultimarcaExitoso;

		private static void agregarModeloCotizado(List<String> modelos, String modelo, Boolean cotizado) {
			if(modelo != null && cotizado == true){
				modelos.add(modelo);
			}
		}

		private static void agregarNombrePlantilla(List<String> nombresPlantillas, String modelo, Boolean cotizado) {
			if(modelo != null && cotizado == true){
				List<Product2> productos = [
					SELECT NombredePlantilla__c
					FROM Product2
					WHERE ProductCode =: modelo.substringBefore(' ')
					LIMIT 1
				];
				if(!productos.isEmpty() && String.isNotBlank(productos[0].NombredePlantilla__c)){
					nombresPlantillas.add(productos[0].NombredePlantilla__c);
				}
			}
		}

		Webservice Static String envioCotizacion(String idTrafico, String idPropietario){
			String idTemplate;
			String[] toAddresses = new String[]{};
	        List<String> listLeadModelo = new List<String>();
			OrgWideEmailAddress[] idAddress = null;
			Lead l = [SELECT Id, LeadSource,AsuntoWeb__c, Email, Cotizacion_1__c, Cotizacion_2__c, Cotizacion_3__c, Cotizacion_4__c, Modelo_De_Inter_s1__c, Modelo_De_Inter_s2__c, 
					Modelo_De_Inter_s3__c, Modelo_De_Inter_s4__c, Marca__c, Marca2__c, Marca3__c, Marca4__c FROM Lead WHERE Id =: idTrafico];
		if(l.Marca__c == 'Motorrad' || l.Marca__c == 'Polaris' || l.Marca__c == 'Kawasaki' ){
			idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'BMW Motorrad CR'];
		}else if(l.Marca__c == 'Indian' ){
			idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Indian CR'];
		}
		else{
			idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Red Motors'];
		}
		
		if(l.Marca__c == 'MINI'){
			idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_MINI'].Id;
		}else if(l.Marca__c == 'BMW'){
            if(l.LeadSource == 'Página Web' && l.AsuntoWeb__c == 'Test Drive'){
            	idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_BMW_Test_Drive'].Id;
            }
            else{
            	idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_BMW'].Id;
            }
		}else if(l.Marca__c == 'Motorrad'){
            idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Motorrad'].Id;
        }else if(l.Marca__c == 'Polaris'){
            idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Polaris'].Id;
        }else if(l.Marca__c == 'Kawasaki'){
            idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Kawa'].Id;
        }else if(l.Marca__c == 'Indian'){
            idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'Cotizacion_Indian'].Id;
        }
		if(l.Marca__c == 'KTM' || l.Marca2__c == 'KTM' || l.Marca3__c == 'KTM' || l.Marca4__c == 'KTM'){
			return 'Error: No tiene los suficientes privilegios para enviar una cotización para la marca KTM.';
		}else{
				agregarModeloCotizado(listLeadModelo, l.Modelo_De_Inter_s1__c, l.Cotizacion_1__c);
				agregarModeloCotizado(listLeadModelo, l.Modelo_De_Inter_s2__c, l.Cotizacion_2__c);
				agregarModeloCotizado(listLeadModelo, l.Modelo_De_Inter_s3__c, l.Cotizacion_3__c);
				agregarModeloCotizado(listLeadModelo, l.Modelo_De_Inter_s4__c, l.Cotizacion_4__c);
		            List<Product2> listaProductos = new List<Product2>();
		            toAddresses.add(l.Email);
            Id AdressId = '001000000000000AAA';
            if(idAddress.size()>0){
                AdressId = idAddress[0].Id;
				}
				if(listLeadModelo.size()>0){
	                listaProductos = Test.isRunningTest() && testProductosCotizacion != null
						? testProductosCotizacion
						: [Select Id,Name,Modelo_De_Inter_s__c,Link_ficha_t_cnica__c  From Product2
	                                            Where Modelo_De_Inter_s__c  IN: listLeadModelo
	                                            AND Link_ficha_t_cnica__c != NULL];
	               
	                if(listaProductos.size()>0){
	                    for (Product2 prod : listaProductos) {
	                        if (!String.isBlank(prod.Link_ficha_t_cnica__c) && !Test.isRunningTest()) {
								TraficoService.enviarFichaTecnicaDesdeProducto(prod.Id, toAddresses, idTemplate, idTrafico, AdressId);
	                        }
                    }
                    return 'enviado correctamente';
                }else{
                    return 'no enviado';
                }
            }
			return 'enviado correctamente';
		}
	}

		Webservice Static String envioCotizacionMultimarca(String idTrafico, String idPropietario){
			Boolean envio = false;
		String idTemplate;
		Lead l = new Lead();
		String[] toAddresses = new String[]{};
		List<Messaging.SendEmailResult> emails = new List<Messaging.SendEmailResult>();  
		List<String> nombresPlantillas = new List<String>();
		List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
		Set<Id> idsPlantillas = new Set<Id>();
		
		idTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: 'NewMultimarcacotizacion_1678510036978'].Id;
		OrgWideEmailAddress[] idAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'Red Motors'];
		l = [SELECT Id, Email, Cotizacion_1__c, Cotizacion_2__c, Cotizacion_3__c, Cotizacion_4__c,
			Modelo_De_Inter_s1__c, Modelo_De_Inter_s2__c, Modelo_De_Inter_s3__c, Modelo_De_Inter_s4__c FROM Lead WHERE Id =: idTrafico];
		agregarNombrePlantilla(nombresPlantillas, l.Modelo_De_Inter_s1__c, l.Cotizacion_1__c);
		agregarNombrePlantilla(nombresPlantillas, l.Modelo_De_Inter_s2__c, l.Cotizacion_2__c);
		agregarNombrePlantilla(nombresPlantillas, l.Modelo_De_Inter_s3__c, l.Cotizacion_3__c);
		agregarNombrePlantilla(nombresPlantillas, l.Modelo_De_Inter_s4__c, l.Cotizacion_4__c);
		for(EmailTemplate eT : [SELECT Id FROM EmailTemplate WHERE DeveloperName IN : nombresPlantillas]){
			idsPlantillas.add(eT.Id);
		}
		if(!idsPlantillas.isEmpty()){
			for(Attachment a : [SELECT Id, Name, Body, BodyLength FROM Attachment WHERE ParentId IN : idsPlantillas]){
				Messaging.EmailFileAttachment eFA = new Messaging.EmailFileAttachment();
				eFA.setFileName(a.Name);
				eFA.setBody(a.Body);
				fileAttachments.add(eFA);
			}
		}
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
			if(emails.get(0).isSuccess()){
				envio = true;
			}
			}catch(Exception e){
				envio = false;
			}
			if (Test.isRunningTest() && testEnvioMultimarcaExitoso != null) {
				envio = testEnvioMultimarcaExitoso;
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

}