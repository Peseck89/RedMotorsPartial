/*
	Creado por David Leon
	Fecha: 1/12/2020
	Descripcion: Clase para crear el flujo de aprobacion de una oportunidad de financiamiento
*/
global class WsProcesoAprobacionOpF_Altica{

	webservice static String aprobacionOpF(String idop){
        string respuesta = ''; 
			
		try{
			respuesta = 'La solicitud de aprobacion ha sido enviada';
			Approval.ProcessSubmitRequest aprobacion = new Approval.ProcessSubmitRequest();
			aprobacion.setComments('Se ha enviado para aprobación!');
			aprobacion.setObjectId(idop);
			Approval.ProcessResult approvalResul = Approval.process(aprobacion);
	                
			return respuesta;				
		}catch (Exception ex){
			System.debug('ERROR: ' + ex);
					
			if(ex.getMessage().contains('NO_APPLICABLE_PROCESS')){
				return 'No se ha podido enviar para la aprobación.\nEste registro no cumple con los criterios de entrada o remitentes iniciales de cualquier proceso de aprobación activo. Póngase en contacto con su administrador para obtener ayuda.';
			}else{
				if(ex.getMessage().contains('MANAGER_NOT_DEFINED')){
					return 'No se ha podido enviar para la aprobación.\nEste registro no cumple con los criterios de entrada o remitentes iniciales de cualquier proceso de aprobación activo. Póngase en contacto con su administrador para obtener ayuda.';
				}else{
					return 'La oportunidad de financiamiento ya fue enviada a aprobación.';
				}
			}
		}				
    }
}