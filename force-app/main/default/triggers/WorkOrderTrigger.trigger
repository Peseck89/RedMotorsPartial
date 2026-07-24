trigger WorkOrderTrigger on WorkOrder (after update, before insert, before update,before delete) {

    if(trigger.isBefore && !Trigger.isDelete)
    {
        Map<String, String> pricebookMap = new Map<String, String>();

        for(Pricebook2 rec : [SELECT id, Name from Pricebook2])
        {
            pricebookMap.put(rec.Name, rec.Id);
        }

        for(WorkOrder rec : trigger.new)
        {
            if(rec.CurrencyISOCode == 'USD' && !Test.isRunningTest() && rec.empresaFactura__c == 'RMOTOBAI')
                rec.Pricebook2Id = pricebookMap.get('Otobai Dólares');
            else if(rec.CurrencyISOCode == 'CRC' && !Test.isRunningTest() && rec.empresaFactura__c == 'RMOTOBAI')
                rec.Pricebook2Id = pricebookMap.get('Otobai Local');
            else if(rec.CurrencyISOCode == 'USD'&& !Test.isRunningTest() && rec.empresaFactura__c == 'RMBAVARIAN')
                rec.Pricebook2Id = pricebookMap.get('Bavarian Dólar');
            else if(rec.CurrencyISOCode == 'CRC'&& !Test.isRunningTest() && rec.empresaFactura__c == 'RMBAVARIAN')
                rec.Pricebook2Id = pricebookMap.get('Bavarian Local');
        }
    }
    if(trigger.isBefore && trigger.isUpdate && !Trigger.isDelete)
    {
        List<Id> workOrderIds = new List<Id>();
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        List<WorkOrder> workOrdersToProcess = new List<WorkOrder>();
        String correoCliente = '';
        for(WorkOrder wo : trigger.new)
        {
            WorkOrder old = Trigger.oldMap.get(wo.Id);
            if( wo.isLocked__c && old.isLocked__c && wo.Etapa_de_flujo_de_trabajo__c == old.Etapa_de_flujo_de_trabajo__c && wo.Etapa_de_flujo_de_trabajo__c != 'Facturada'&& wo.Etapa_de_flujo_de_trabajo__c != 'Anulada' && profileName != 'System Administrator' && profileName != 'Administrador del sistema'){
                wo.addError('NO se puede actualizar una orden ya FACTURADA, favor consulte un administrador');
            }else if(!wo.isLocked__c && old.isLocked__c){
                wo.Etapa_de_flujo_de_trabajo__c= 'Proceso';
            }


            if (wo.Etapa_de_flujo_de_trabajo__c == 'Anulado' && Trigger.oldMap.get(wo.Id).Etapa_de_flujo_de_trabajo__c != 'Anulado') {
                workOrderIds.add(wo.Id);
            }

            // Verificar si el campo cambió de false a true
            if (wo.Enviar_presupuesto_a_service__c == true &&
            old.Enviar_presupuesto_a_service__c != true &&
            wo.ContactId != null) {
            workOrdersToProcess.add(wo);
                String emailBuscar = '';
            if (!workOrdersToProcess.isEmpty()) {
                Set<Id> contactIds = new Set<Id>();
                for (WorkOrder wo1 : workOrdersToProcess) {
                    contactIds.add(wo1.ContactId);

                }

                // Consultar usuarios existentes
                Map<Id, User> existingUsers = new Map<Id, User>();
                for (User u : [SELECT Id, ContactId FROM User WHERE ContactId IN :contactIds ]) {
                    existingUsers.put(u.ContactId, u);
                }

                // Procesar WorkOrders que no tienen usuario asociado
                List<User> usersToCreate = new List<User>();
                List<Peticion_de_envio__c> petitionsToInsert = new List<Peticion_de_envio__c>();

                for (WorkOrder wo2 : workOrdersToProcess) {
                    if (!existingUsers.containsKey(wo2.ContactId)) {
                        // Consultar información del contacto
                        Contact contact = [SELECT FirstName, LastName, Email FROM Contact WHERE Id = :wo2.ContactId LIMIT 1];
                        correoCliente = contact.Email;
                        // Crear nuevo usuario
                        User newUser = new User(
                            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community User Test' LIMIT 1].Id,
                            Username = contact.Email,
                            Alias = contact.Email.left(8),
                            Email = contact.Email,
                            EmailEncodingKey = 'UTF-8',
                            Firstname = contact.FirstName,
                            Lastname = contact.LastName,
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US',
                            ContactId = wo.ContactId,
                            TimeZoneSidKey = 'America/Chicago',
                            IsActive = true
                        );
                        usersToCreate.add(newUser);
                    }
                }

                // Insertar usuarios nuevos y crear peticiones de envío
                if (!usersToCreate.isEmpty()) {
                    try {
                        insert usersToCreate;
                        System.debug('Statement after insert.');

                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                        //mail.setReplyTo('escsol1f@gmail.com');
                        //String correoEnviar = availableUsers[0].Asesor__r.Email;
                        //String ccAddresses = 'antonio.dorantesperez@outlook.com';
                        //correoEnviar = 'antonio.dorantesperez@outlook.com';
                        mail.setToAddresses(new String[]{correoCliente});
                    // mail.setCcAddresses(new String[]{ccAddresses});
                        mail.setSubject('Bienvenido a BMW Service​');
                        mail.setHtmlBody('<head>    <meta charset="utf-8">    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <meta http-equiv="Content-Type" content="text/html charset=UTF-8" />    <link href="https://db.onlinewebfonts.com/c/8503adf008ebf781c6342c58254552e4?family=BMWTypeNext+Pro" rel="stylesheet">    <title>Bienvenido a BMW SERVICE</title></head><body style="width:100%;font-family: BMWTypeNext Pro, arial; font-size: 18px;"><table role="presentation" style="max-width:600px;border-collapse:collapse;border:0;border-spacing:0;background:#ffffff; margin: 0 auto"><tr>        <td align="center" style="padding:0;">            <table role="presentation" style="width:602px;border-collapse:collapse;border:1px solid #cccccc;border-spacing:0;text-align:left;">                <tr>                    <td align="center" >                        <img src="https://redmotors.file.force.com/servlet/servlet.ImageServer?id=015PH000002H2It&oid=00D0P000000Dvkz" alt="" width="100%" style="height:auto;display:block;" />                    </td>                </tr>                <tr>                    <td style="padding:36px 20px 10px 20px;">                        <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">                            <tr>                                <td style="color:#707070;">                                    <h1 style="font-size:24px;margin:0 0 20px 0;">Estimado cliente,</h1>                                    <p style="font-weight: light; color: #707070">                                        Red Motors le da la bienvenida a nuestro portal BMW Service.                                    </p>                                </td>                            </tr>                            <tr>                                <td style="padding:0;">                                    <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">                                        <p style="font-weight: light; color: #707070; margin: 7px 0">                                          Desde este sitio podrás gestionar las citas de mantenimiento de tu vehículo o moto BMW y MINI de manera más ágil.                                        </p>                                    </table>                                </td>                            </tr>                            <tr>                              <td style="padding:0;">                                  <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">                                    <p style="font-weight: light; color: #707070; margin-bottom:45px">                                      Para registrarte solo debés de ingresar en el siguiente botón.                                    </p>                                  </table>                              </td>                          </tr>                          <tr>                            <td>                              <a href="https://redmotors.my.site.com/ForgotPassword?Email='+correoCliente+'"><img alt="logo"                                  src="https://redmotors.file.force.com/servlet/servlet.ImageServer?id=015PH000002Jh9l&oid=00D0P000000Dvkz"                                  style="max-width: 676.207px; height:40px;" title="logo" /></a>                            </td>                          </tr>                        </table>                    </td>                </tr>                <tr>                    <td style="padding:30px 20px;">                        <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;font-size:9px;font-family:Arial,sans-serif;">                            <tr>                                <td style="padding:0;width:50%;line-height:4px;color:#707070" align="left">                                    <p><b>                                      RedMotors CR                                    </b></p>                                    <p>Agencia BMW, diagonal a la</p>                                    <p>gasolinera Delta en La Uruca, San José</p>                                    <p>BMW La Uruca: 2547 5000</p>                                    <p><a href="https://www.bmw.co.cr" style="color: #707070;">www.bmw.co.cr</a></p>                                </td>                            </tr>                        </table>                    </td>                </tr>            </table>        </td>    </tr></table></body></html>');
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});

                        for (User user : usersToCreate) {
                            Peticion_de_envio__c resetPass = new Peticion_de_envio__c();
                            resetPass.Email__c = user.Username;
                            resetPass.First_Name__c = user.FirstName;
                            resetPass.Last_Name__c = user.LastName;
                            petitionsToInsert.add(resetPass);
                        }
                    } catch(DmlException e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }

                }

                // Insertar peticiones de envío
                if (!petitionsToInsert.isEmpty()) {
                    insert petitionsToInsert;
                }
            }
    }

        }


        List<WorkOrderLineItem> facturadoLineItems = [
                    SELECT Id, WorkOrderId, aseguradora__c, Bodega__c, centroCosto__c, Comentario__c, cuentaContable__c,
                    Description, descuento__c, EndDate, Impuesto__c, ListPrice, porcentajeCargoAseguradora__c, porcentajeCargoCliente__c, Total__c,Trabajo__c,
                    porcentajeCargoGarantia__c, porcentajeCargoInterno__c, PricebookEntryId, Product2Id, Quantity, regalia__c, StartDate,Producto_OR_Alias__c,Subtotal__c,ImpuestoReal__c,
                    tipoDeTrabajo__c, totalItem__c, Created_From__c, UnitPrice, (select Id, productoPedido__c from Tipo_de_cargos__r )
                    FROM WorkOrderLineItem
                    WHERE WorkOrderId IN :workOrderIds AND Estado__c = 'Facturado'
                ];

        for (WorkOrder wo : Trigger.new) {
            for (WorkOrderLineItem line : facturadoLineItems) {
                if (wo.Id == line.WorkOrderId) {
                    wo.addError('No se puede colocar como rechazada una orden de trabajo que tiene líneas facturadas.');
                    break; // Salir del bucle interno después de agregar el error
                }
            }
        }




    }
    if(Trigger.isUpdate && Trigger.isAfter && !Trigger.isDelete)
    {
        Map<Id, List<WorkOrderLineItem>> mapIdList = new Map<Id, List<WorkOrderLineItem>>();
        List<WorkOrderLineItem> olis = new List<WorkOrderLineItem>();
        Set<Id> ids = new Set<ID>();
        Set<Id> woIds = new Set<Id>();
        Set<Id> woliIds = new Set<Id>();
        List<WorkOrderLineItem> wolistBSI = new List<WorkOrderLineItem>();
        List<Id> woToSync = new List<Id>(); //IDs de ordenes a sincronizar con softland
        List<String> stagesToSync =new List<string>{'Enviar a facturar','En proceso'}; //Etapas de ordenes a sincronizar con softland
        Map<Id,String> woliTipoGasto = new Map<Id,String>();
        Map<Id,String> woliAseguradora = new Map<Id,Id>();
        Map<Id,String> woliCostos = new Map<Id,Id>();
        //Set<Id> orderIds = new Set<Id>();
        for(WorkOrder wo : Trigger.New)
        {
            ids.add(wo.Id);
            WorkOrder old = Trigger.oldMap.get(wo.Id);

            if( wo.tipoDeGasto__c != old.tipoDeGasto__c || wo.BMW_Aseguradora__c != old.BMW_Aseguradora__c
              || wo.BMW_CentroDeCosto__c != old.BMW_CentroDeCosto__c){
                woIds.add(wo.Id);
            }

            //Automatización de Reservar en Softland al estar en las etapas {stagesToSync} y actualizar los campos:
            //if((wo.AccountId!=old.AccountId)&&(stagesToSync.indexOf(wo.Etapa_de_flujo_de_trabajo__c)>=0)){
                //ProductController.syncOrderWithSoftland(wo.id);//Función que envía nuevamente la order a Softland
            //}
           // orderIds.add(wo.Original_Order__c);
        }
        if(woIds.size()>0){
            wolistBSI=   [
                    SELECT Id, WorkOrderId, WorkOrder.tipoDeGasto__c, WorkOrder.BMW_Aseguradora__c,WorkOrder.BMW_CentroDeCosto__c
                    FROM WorkOrderLineItem
                    WHERE WorkOrderId =:woIds AND Estado__c != 'Facturado'
                ];
            if(wolistBSI.size()>0){
                for(WorkOrderLineItem woli : wolistBSI){
                    woliTipoGasto.put(woli.Id, woli.WorkOrder.tipoDeGasto__c);
                    woliAseguradora.put(woli.Id,woli.WorkOrder.BMW_Aseguradora__c);
                    woliCostos.put(woli.Id,woli.WorkOrder.BMW_CentroDeCosto__c);
                    woliIds.add(woli.Id);
                }
                List<tipoCargo__c> TCList = [Select Id, tipoCargo__c,Work_Order_Line_Item__c From tipoCargo__c Where Work_Order_Line_Item__c IN: woliIds];
                if(TCList.size()>0){
                    for(tipoCargo__c tc : TCList){
                        String tipoCargo = woliTipoGasto.get(tc.Work_Order_Line_Item__c);
                        String codTipoCargo;
                        Id Aseguradora;
                        Id CentroDeCostos;
                        switch on tipoCargo{
                            when 'Cliente'{
                                codTipoCargo = '1';tc.Cliente__c = null;tc.centroCosto__c = null;

                            }
                            when 'Garantía' {
                                codTipoCargo = '4';tc.Cliente__c = null;tc.centroCosto__c = null;
                            }
                            when 'BCI'{
                                codTipoCargo = '5';
                                tc.Cliente__c = null;
                                tc.centroCosto__c = null;
                            }
                            when 'BSI Interno'{
                                codTipoCargo = '6';tc.Cliente__c = null;tc.centroCosto__c = null;
                            }
                            when 'Aseguradora'{
                                codTipoCargo = '3';
                                Aseguradora = woliAseguradora.get(tc.Work_Order_Line_Item__c);
                                tc.Cliente__c = Aseguradora;
                                tc.centroCosto__c = null;

                            }
                            when 'Interno'{
                                codTipoCargo = '2';
                                CentroDeCostos= woliCostos.get(tc.Work_Order_Line_Item__c);tc.Cliente__c = null;
                                tc.centroCosto__c = CentroDeCostos;
                            }
                        }
                        tc.tipoCargo__c = codTipoCargo;
                        System.debug('cargo '+tc.tipoCargo__c);

                    }
                    update TCList;
                }
            }
        }
        olis=   [
                    SELECT Id, WorkOrderId, aseguradora__c, Bodega__c, centroCosto__c, Comentario__c, cuentaContable__c,
                    Description, descuento__c, EndDate, Impuesto__c, ListPrice, porcentajeCargoAseguradora__c, porcentajeCargoCliente__c, Total__c,Trabajo__c,
                    porcentajeCargoGarantia__c, porcentajeCargoInterno__c, PricebookEntryId, Product2Id, Quantity, regalia__c, StartDate,Producto_OR_Alias__c,Subtotal__c,ImpuestoReal__c,
                    tipoDeTrabajo__c, totalItem__c, Created_From__c, UnitPrice, (select Id, productoPedido__c from Tipo_de_cargos__r )
                    FROM WorkOrderLineItem
                    WHERE WorkOrderId =:ids
                ];

        //System.assert(false, olis);
        for(WorkOrderLineItem woli :olis )
        {
            if(mapIdList.containsKey(woli.WorkOrderId))
            {
                mapIdList.get(woli.WorkOrderId).add(woli);
            }
            else
            {
                mapIdList.put(woli.WorkOrderId, new List<WorkOrderLineItem>{woli});
            }
        }



    }
    if (Trigger.isDelete) {
        // Obtener el ID del usuario actual
        String userId = UserInfo.getUserId();

        // Consultar el campo custom CanDeleteWO__c del usuario actual
        User currentUser = [SELECT CanDeleteWO__c FROM User WHERE Id = :userId];
        Boolean canDeleteWO = currentUser.CanDeleteWO__c;

        // Si el usuario no tiene permiso para eliminar, recorrer las WorkOrders
        if (canDeleteWO == false) {
            for (WorkOrder wo : Trigger.old) {
                // Evitar la eliminación mostrando un mensaje de error
                wo.addError('El usuario no cuenta con los permisos para eliminar órdenes de trabajo.');
            }
        }
    }
}