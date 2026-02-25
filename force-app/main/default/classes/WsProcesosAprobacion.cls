global class WsProcesosAprobacion {
   
    
	webservice static String AprobacionDescuento(String idop){
        string respuesta = '';
        List<Opportunity> oportunidades = [
            Select 
            o.Id, 
            o.HasOpportunityLineItem, 
            o.AccountId, 
            o.Jefe__c,
            o.Gerente__c,
            o.Director__c,
            o.Vendedor__c,
			o.ConsecutivoOportunidad__c,
			o.PendienteDescuento__c,
			o.Descuento_Total_Moneda__c 
            From Opportunity o where o.Id =:idop and DescuentoAprobado__c = false and Vendedor__c = false
        ];
		
        if(oportunidades!=null&&oportunidades.size()>0){
			List<Opportunity> opsActualizadas = new List<Opportunity>();
			Integer numOli = 0;
			Integer director = 0;
			Integer gerente = 0;
			Integer jefe = 0;
			

            for(Opportunity op:oportunidades){

                if(op.HasOpportunityLineItem&&(op.Director__c||op.Gerente__c||op.Jefe__c)){
                	
					System.debug('op ' + op.ConsecutivoOportunidad__c + ' si tiene productos...');
					
					op.PendienteDescuento__c = true;
					opsActualizadas.add(op);
					
					director = 	op.Director__c?1:0;
					gerente = op.Gerente__c?1:0;
					jefe = op.Jefe__c?1:0;					
          			
                }               

            }
            
			System.debug('director '+ director);
			System.debug('gerente '+ gerente);
			System.debug('jefe '+ jefe);
			           
            
            if(opsActualizadas!=null&&opsActualizadas.size()>0){
				
				SavePoint sp = DataBase.setSavePoint();  
				try{
                
					if(director>0||gerente>0||jefe>0){
						
						update opsActualizadas;
						
						respuesta = 'La solicitud de aprobacion ha sido enviada';
						
						Approval.ProcessSubmitRequest aprobacion = new Approval.ProcessSubmitRequest();
	
						aprobacion.setComments('Se ha enviado para aprobación!');
	
						aprobacion.setObjectId(idop);
	      
	      					EnviarNotificacionDeAprobacion.enviarNoti(idop);
						Approval.ProcessResult approvalResul = Approval.process(aprobacion);

	                
						return respuesta;				
					}
				}catch (Exception ex){
					
					System.debug('ERROR: ' + ex);
					 DataBase.rollback(sp);
					
					if(ex.getMessage().contains('NO_APPLICABLE_PROCESS')){
						return 'No se ha podido enviar para la aprobación.\nEste registro no cumple con los criterios de entrada o remitentes iniciales de cualquier proceso de aprobación activo. Póngase en contacto con su administrador para obtener ayuda.';
					}else{
						if(ex.getMessage().contains('MANAGER_NOT_DEFINED')){
							return 'No se ha podido enviar para la aprobación.\nEste registro no tiene todos los nombres de los aprobadores ingresados en los campos de Jefes de Ventas o Gerentes. Póngase en contacto con su administrador para obtener ayuda.';
						}else{
						return 'Esta oportunidad ya fue enviada a aprobación.';
						}
					}
				}
								

            }
        }else{
			respuesta = 'Por favor tome en cuenta que para aprobar un descuento, la oportunidad debe requerir de uno para ser aprobado (Casilla Descuento Aprobado debe estar desmarcada)';
		}
        return respuesta;
    }
        
}