/*
    @Autor: David Leon Sanchez
    @Fecha creacion: 23/08/2017 
    @Proyecto: Red Motor
    @Proposito: Clase para el envio de email con el registro de Recibo de Usado al Jefe de Usados Moto o Jefe de Usados
    Vehiculos
*/

global class WSEnvioAlertaRU {
    Webservice Static String envioEmailRU(String idRecUsa){
        System.debug('**************** Id Recibo Usado ******************* ' + idRecUsa);
        SavePoint sp = Database.setSavepoint();
        User user = new User();
        String[] toAddresses = new String[] {};
        Opportunity  op = new Opportunity();
        ReciboUsado__c recUsa = new  ReciboUsado__c();
        List<Messaging.SendEmailResult> emails = new List<Messaging.SendEmailResult> ();
        String idOp;
        String name;
        
        recUsa = [SELECT Modelo__c, Name, Oportunidad__c, Placa__c, ValorReciboCliente__c, Estilo__c, Marca__c, Ano__c, Estado__c, Kilometraje__c FROM ReciboUsado__c WHERE id =: idRecUsa];
        System.debug('************************* RECIBO USADO ********************* ' + recUsa);
        
        idOp = (String)recUsa.Oportunidad__c;
        System.debug('************************* ID Oportunidad de Recibo de Usado ********************* ' + idOp.substring(0,14));
        
        op = [SELECT id, Name, RecordTypeId, RecordType.Name, Owner.Name FROM Opportunity WHERE id =: idOp.substring(0,15)];
        System.debug('**************************** Oportunidad ************************* ' + op);
        
        name = [SELECT Id, Name FROM RecordType WHERE Id =: op.RecordTypeId].Name;
        System.debug('*********************** name of record type *************** ' + name);
        
        if(op != null && (name == 'BMW' || name == 'MINI')){
            user = [SELECT name, Email FROM User WHERE Profile.Name =: 'Jefe de Ventas Usados Autos'];
        }else{
            user = [SELECT name, Email FROM User WHERE Profile.Name =: 'Jefe de Ventas Usados Motos'];
        }
        System.debug('******************************* User ************************ ' + user);
        toAddresses.add(user.Email);
        try{
            System.debug('************************** Entro al try *************************');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Oportunidad con recibo de usados nuevo');
            mail.setPlainTextBody('Se a agregado un nuevo registro de Recibo de Usado a la siguiente Oportunidad ' + op.Name + '. \n\n' +
                                    'Información del Recibo de Usado: ' + '\n\n' + 'Placa: ' + recUsa.Placa__c + '\n' + 'Nombre: ' + recUsa.Name + '\n' + 
                                    'Marca: ' + recUsa.Marca__c + '\n' + 'Modelo: ' + recUsa.Modelo__c + '\n' + 'Año: ' + recUsa.Ano__c + '\n' + 
                                    'Estado: ' + recUsa.Estado__c + '\n' + 'Kilometraje: ' + recUsa.Kilometraje__c + '\n' + 'Estilo: ' + recUsa.Estilo__c + 
                                    '\n' + 'Valor Recibo Cliente: ' + recUsa.ValorReciboCliente__c + '\n' + 'Nombre Vendedor: ' + op.Owner.Name + '\n\n' + 
                                    'Link del Recibo de Usado: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + recUsa.Id);
            mail.setHtmlBody('Se a agregado un nuevo registro de Recibo de Usado a la siguiente Oportunidad ' + op.Name + '. <br><br>' +
                                    'Información del Recibo de Usado: ' + '<br><br>' + 'Placa: ' + recUsa.Placa__c + '<br>' + 'Nombre: ' + recUsa.Name + 
                                    '<br>' + 'Marca: ' + recUsa.Marca__c + '<br>' + 'Modelo: ' + recUsa.Modelo__c + '<br>' + 'Año: ' + recUsa.Ano__c + 
                                    '<br>' + 'Estado: ' + recUsa.Estado__c + '<br>' + 'Kilometraje: ' + recUsa.Kilometraje__c + '<br>' + 
                                    'Estilo: ' + recUsa.Estilo__c + '<br>' + 'Valor Recibo Cliente: ' + recUsa.ValorReciboCliente__c + '<br>' + 
                                    'Nombre Vendedor: ' + op.Owner.Name+ '<br><br>' + 'Link del Recibo de Usado: ' + 
                                    URL.getSalesforceBaseUrl().toExternalForm() + '/' + recUsa.Id);
            mail.setToAddresses(toAddresses);
            emails = Messaging.sendEmail(new Messaging.Email[] {mail});
            System.debug('**************************** envio exitoso ***************************');
        }catch(Exception e){
            Database.rollback(sp);
            return 'Envio Fallido';
        }
        return 'Envio Exitoso';
    }    
}