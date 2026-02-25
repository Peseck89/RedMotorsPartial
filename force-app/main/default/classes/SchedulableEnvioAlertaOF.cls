/**
	@Autor: David Leon Sanchez
	@Fecha creacion: 23/08/2017 
	@Proyecto: Altica
	@Proposito: Clase Schedulable para el envio de una alerta de correo electronico para todas aquellas Oportunidades Financieras tengan 2 horas de haberse creado y el estado
				este pendiente.
**/

global class SchedulableEnvioAlertaOF implements Schedulable {
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		List<String> idsList = new List<String> ();
		String[] toAddresses = new String[] {};
		SavePoint sp = Database.setSavepoint();

        List<Oportunidad_de_Financiamiento__c> listOp = [SELECT Id, name, FechaInicioOF__c, EnvioAlerta__c FROM Oportunidad_de_Financiamiento__c WHERE Estado__c =: ''];

        System.debug('*********************** LISTA DE OP ************************* ' + listOp);

        if(!listOp.isEmpty()){
			for(Oportunidad_de_Financiamiento__c opFi : listOp){
				System.debug('**************************** OF de la lista ************************ ' + opFi);
				Decimal min = (((System.now().getTime() - opFi.FechaInicioOF__c.getTime()) / 1000) / 60);
				System.debug('***************************** minutos de la OF despues de creada ********************** ' + min);
				if(min >= 120 && opFi.EnvioAlerta__c == false){
					System.debug('*********************** entro OF ***************** ' + opFi);
					Group g = [SELECT(SELECT userOrGroupId FROM groupMembers) FROM Group WHERE name = 'Oportunidad de Financiamiento' and Type = 'Queue'];
					
					for (GroupMember gm : g.GroupMembers) {
						idsList.add(gm.UserOrGroupId);
					}
					System.debug('********************** listIdUser ******************** ' + idsList);

					User[] users = [SELECT email, id FROM User WHERE Id IN :idsList];
					System.debug('********************* users ********************** ' + users);
					List<Messaging.SendEmailResult> emails = new List<Messaging.SendEmailResult> ();
					for (User u : users) {
						toAddresses.add(u.Email);
					}
					try {
						Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						mail.setSubject('Alerta oportunidad de financiamiento sin respuesta');
						mail.setPlainTextBody('La oportunidad  de financiamiento con el nombre ' + opFi.Name +  ' creada el día ' + opFi.FechaInicioOF__c.format('dd/MM/yyyy') + 
												' tiene más de 2 horas sin haber recibido atención' + '. \n\n' + 'Link de la Oportunidad de Financiamiento ' +
												URL.getSalesforceBaseUrl().toExternalForm() + '/' + opFi.Id);

						mail.setHtmlBody('La oportunidad  de financiamiento con el nombre ' + opFi.Name +  ' creada el día ' + opFi.FechaInicioOF__c.format('dd/MM/yyyy') + 
										' tiene más de 2 horas sin haber recibido atención'+ '. <br><br>' + 'Si desea ver la Oportunidad de financiamiento, dar click en el ' +
										' siguiente link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opFi.Id);

						mail.setToAddresses(toAddresses);
						emails = Messaging.sendEmail(new Messaging.Email[] { mail });
						if(emails.get(0).isSuccess()) {
							System.debug('envio exitoso');
						}

						//Update al campo EnvioAlerta__c para no hacer duplicidad de correo
						opFi.EnvioAlerta__c = true;
						TriggerHandler.bypass('OportunidadFinanciamientoTriggerHandler');
						update opFi;
						TriggerHandler.clearBypass('OportunidadFinanciamientoTriggerHandler');

						eliminarSchedule(opFi.Name);
					
					}catch(Exception e) {
						System.debug('Excepcion al enviar alerta : ' + e);
						Database.rollback(sp);
					}
				}
			}  
        }
	}

	//Se elimina el apexjob creado cuando se envia el primer correo de aviso
	public void eliminarSchedule(String name){
		Id idJobDetail = [SELECT id FROM CronJobDetail WHERE name =: name][0].Id;
		Id jobId = [SELECT id FROM CronTrigger WHERE CronJobDetailId =: idJobDetail][0].Id;
		System.abortJob(jobId);
		System.debug('************************** se elimino el apex job ********************** ');
	}
}