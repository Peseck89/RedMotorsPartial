/**
  @Autor: David Leon Sanchez
  @Fecha creacion: 21/08/2017 
  @Proyecto: Altica
  @Proposito: Clase Schedulable para el envio de la plantilla con las Oportunidades con financiamiento aprobado y que no han tenido seguimiento
 
  **/

global class SchedulableEnvioPlantillaOpAprobadas implements Schedulable {
    /**
     * @description Executes the scheduled Apex job. 
     * @param sc contains the job ID
     */
    global void execute(SchedulableContext sc) {
        List<String> idsList = new List<String> ();

        List<Opportunity> listOp = [SELECT o.Importetotaldelnegocio__c, o.UltimaModificacion__c, o.Sucursal__c, o.OwnerId, o.Owner.Name, o.Name, o.Id,
        (SELECT Id, Name, Producto__c From Oportunidades_de_Financiamiento1__r) FROM Opportunity o WHERE EstadoOF__c = :'Aprobada' AND DiasSinSeguimiento__c > 0 AND EnvioAlertaOF__c = false];

        System.debug('*********************** LISTA DE OP ************************* ' + listOp);

        if(!listOp.isEmpty()){
            Group g = [SELECT(SELECT userOrGroupId FROM groupMembers) FROM Group WHERE name = 'Oportunidad de Financiamiento' and Type = 'Queue'];
            for (GroupMember gm : g.GroupMembers) {
                idsList.add(gm.UserOrGroupId);
            }
            System.debug('********************** listIdUser ******************** ' + idsList);

            User[] users = [SELECT email, id FROM User WHERE Id IN :idsList];
            System.debug('********************* users ********************** ' + users);
            Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'OportunidadesFinanciamientoAprobadoOF'].id;
            System.debug('****************************** emailTemplate *********************** ' + templateId);
            List<Messaging.SendEmailResult> emails = new List<Messaging.SendEmailResult> ();

            SavePoint sp = Database.setSavepoint();
            try {
                for (User u : users) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(templateId);
                    mail.setTargetObjectId(u.Id);
                    mail.setSaveAsActivity(false);
                    emails = Messaging.sendEmail(new Messaging.Email[] { mail });
                    if (emails.get(0).isSuccess()) {
                        System.debug('envio exitoso');
                    }
                }
            } catch(Exception e) {
                System.debug('Excepcion al enviar alerta : ' + e);
                Database.rollback(sp);
            }
        }
    }
}