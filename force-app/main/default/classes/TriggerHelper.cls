public with sharing class TriggerHelper {
    public static void createSeguimiento (string pCorreo_electronico,List<Lead> newInvs)
    {
        string idLead = '';
	    User user1 = [Select id, Cantidad__c from User where Alias = 'jdura' limit 1];
        User user2 = [Select id, Cantidad__c from User where Alias = 'jtorr' limit 1];
        List<User> userList = new List<User>();
        decimal user1Cantidad  = user1.Cantidad__c == null ? 0 : user1.Cantidad__c;
        decimal user2Cantidad  = user2.Cantidad__c == null ? 0 : user2.Cantidad__c;
        System.debug('Cantidad usuario uno: '+ user1Cantidad);
        System.debug('Cantidad usuario dos: '+ user2Cantidad);
        for(Lead l : newInvs){
             List<Lead> leads2= [SELECT id, Email,Owner.Alias,OwnerId, Marca__c, MobilePhone, Phone, Modelo_De_Inter_s1__c, Familia1__c, Ano1__c, FechaPosibleCompra__c, Sucursal__c FROM Lead Where Email =: l.Email AND(Owner.Alias = 'jtorr' OR lead.Owner.Alias = 'jdura' )ORDER BY CreatedDate ASC LIMIT 2];
            if(l.Marca__c == 'BMW' && (l.LeadSource == 'Página Web' || l.LeadSource == 'Facebook')){
                idLead = l.Id;
                if(leads2.size() > 0){
                    l.OwnerId = leads2[0].OwnerId;
                    Seguimiento__c seguimiento= new Seguimiento__c();
     				seguimiento.Trafico__c =leads2[0].id;
     				seguimiento.Name= 'Tráfico';
                    seguimiento.Correo_electr_nico__c = l.Email;
                    seguimiento.Tel_fono__c = l.Phone;
                    seguimiento.Celular__c = l.MobilePhone;
                    seguimiento.Marca__c = l.Marca__c;
                    seguimiento.Modelo_de_Inter_s__c = l.Modelo_De_Inter_s1__c;
                    seguimiento.Familia__c = l.Familia1__c;
                    Seguimiento.Ano__c = l.Ano1__c;
                    seguimiento.FechaPosibleDeCompra__c = l.FechaPosibleCompra__c;
                    seguimiento.Sucursal__c = l.Sucursal__c;
                    insert seguimiento;
                }else{
                if(user1Cantidad < user2Cantidad){
                    l.OwnerId = user1.id;
                    user1.Cantidad__c = user1Cantidad + 1;
                    userList.add(user1);
                    system.debug('user1.id--'+user1.id);
                } else {                        
                    l.OwnerId = user2.id;
                    user2.Cantidad__c = user2Cantidad + 1;
                    userList.add(user2);
                    system.debug('user2.id--'+user2.id);                     
                }
                   
                
            }
             
        }
        }
        if(userList.size() > 0){
            update userList;
        } 
//*********************************************************************************************************88
        /*List<Lead> leadsUno= [SELECT id, Email,Owner.Alias,OwnerId, Marca__c, MobilePhone, Phone, Modelo_De_Inter_s1__c, Familia1__c, Ano1__c, FechaPosibleCompra__c, Sucursal__c FROM Lead Where Email =: pCorreo_electronico AND(Owner.Alias = 'rpere' OR Owner.Alias = 'jdura' ) ORDER BY CreatedDate ASC LIMIT 1];
       //Ajuste hecho por Mario Mora 13/07/2020
       //Verificar que la lista devuelta es mayor a 2
       system.debug('Devolvio '+leadsUno.size());
        if ( idLead != '' ) {
          List<Lead> leadsNuevo= [SELECT id, Email,Owner.Alias,OwnerId, Marca__c, MobilePhone, Phone, Modelo_De_Inter_s1__c, Familia1__c, Ano1__c, FechaPosibleCompra__c, Sucursal__c FROM Lead Where id =: idLead ORDER BY CreatedDate ASC LIMIT 1];
       //Ajuste hecho por Mario Mora 13/07/2020
       //Verificar si el lead es de los usuarios 
     Lead lead = leadsuno.get(0);
     Lead newLead = leadsNuevo.get(0);
        System.debug('Lead viejo'+ lead.Owner.Alias);
         System.debug('Lead nuevo' +newLead.Owner.Alias);
        System.debug('El nombre es: '+ newLead.Owner.Alias);
  if((lead.Owner.Alias == 'rpere' || lead.Owner.Alias == 'jdura') ||Test.isRunningTest()){
      System.debug('Entrooooooooooooooooooooooooo');
     GROUP Cola =[SELECT id FROM Group WHERE name = 'Cola de Candidatos Web' AND type = 'queue'];
     
       System.debug('Lead nuevo: ' +newLead);  
     
  }
     
    }*/
    }
}