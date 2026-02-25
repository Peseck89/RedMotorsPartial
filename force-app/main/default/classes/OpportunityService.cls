public without sharing class OpportunityService {
    
    /*
@autor: DSL
@proyecto: Red Motors - Fase II
*/
    public static void updateFieldOF(Map<Id, String> mapOps){
        List<Oportunidad_de_Financiamiento__c> listUpdateOF = new List<Oportunidad_de_Financiamiento__c>();
        
        for(Oportunidad_de_Financiamiento__c opF : [SELECT Oportunidad__c, ComentariosFinancieros__c FROM Oportunidad_de_Financiamiento__c WHERE Oportunidad__c IN : mapOps.keySet()]){
            opF.ComentariosFinancieros__c = mapOps.get(opF.Oportunidad__c); listUpdateOF.add(opF);
        }
        if(listUpdateOF.size() > 0){
            TriggerHandler.bypass('OportunidadFinanciamientoTriggerHandler'); update listUpdateOF; TriggerHandler.clearBypass('OportunidadFinanciamientoTriggerHandler');
        }
    }
    
    public static void envioAlertaOppDuplicada(Map<Id, Opportunity> cuentaOpMap, Set<Id> setOpp){
        System.debug('*********************************** ENTRA AL METODO ENVIO DE ALERTA ****************************');
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Map<String,String> mapUsuarioCorreo = new Map<String,String>();
        Map<String,Id> mapUsuarioProfileId = new Map<String,Id>();
        List<String> ids = new List<String>();
        List<Opportunity> listOpp = new List<Opportunity>();
        List<User> listUser = new List<User>();
        List<Opportunity> oppActualizar = new List<Opportunity>();
        
        if(cuentaOpMap.size() > 0){
            System.debug('*********************************** CARGA LOS IDS DE JEFE-GERENTE-DIRECTOR****************************');
            for(Opportunity op : cuentaOpMap.values()){
                if(op.JefeSucursal__c!=null) {ids.add(op.JefeSucursal__c);}
                if(op.GerenteSucursal__c!=null) {ids.add(op.GerenteSucursal__c);}
                if(op.DirectorVentas__c!=null) {ids.add(op.DirectorVentas__c);}
                if(op.OwnerId!=null) {ids.add(op.OwnerId);}
            }
            
            if(ids != null && ids.size() > 0){
                listUser = [SELECT Id, Email,ProfileId FROM User WHERE Id IN:ids];
                System.debug('*********************************** CARGA LOS EMAIL DE JEFE-GERENTE-DIRECTOR****************************');
                for(User u : listUser){
                    if(u.Email != null) {mapUsuarioCorreo.put(u.Id,u.Email);mapUsuarioProfileId.put(u.Id,u.ProfileId);}
                }           
            }
            
            set<String> setIdsAdd = new set<String>(); 
            Profile asesor = [Select Id, Name From Profile Where Name='Asesor' LIMIT 1];
            Profile asesorBetaGrid = [Select Id, Name From Profile Where Name='Asesor Beta Grid' LIMIT 1];
            listOpp = [Select o.RT_Lead__c, o.alertEmail__c, o.Name, o.Account.Name, o.Account.Id, o.Sucursal__c, o.StageName, o.RecordTypeId, o.Owner.Email, o.Owner.Name,o.Owner.ProfileId, o.OwnerId, o.JefeSucursal__r.Email,JefeSucursal__r.ProfileId, o.JefeSucursal__c, o.GerenteSucursal__c, o.GerenteSucursal__r.Email,o.GerenteSucursal__r.ProfileId, o.DirectorVentas__c, o.DirectorVentas__r.Email,o.DirectorVentas__r.ProfileId, o.IsClosed From Opportunity o Where AccountId IN:cuentaOpMap.keySet() and IsClosed = false and Id NOT IN:setOpp];
            Set<Id> cuentasProcesadas = new Set<Id>();
            for(Opportunity op : listOpp){
                Id accountId = op.Account.Id;
                if(!cuentasProcesadas.contains(accountId)){
                    System.debug('**************************************** Op encontrada *************************' + op);
                    System.debug('**************************************** Op Nueva ******************************** ' + cuentaOpMap);
                    system.debug('ID OWNER:::: ' + op.OwnerId + ':::: ENVIO DE ALERTA DUPLICADA');
                    String[] toAddresses = new String[] {};
                        System.debug('************************************ CUENTA ID ***************************' + cuentaOpMap.containsKey(op.Account.Id));
                    System.debug('************************************ TIPO DE REGISTRO ***************************' + cuentaOpMap.get(op.Account.Id).RecordTypeId + ' ************ ' + op.RecordTypeId + '******************');
                    If(cuentaOpMap.containsKey(op.Account.Id) && cuentaOpMap.get(op.Account.Id).RT_Lead__c == op.RT_Lead__c && op.alertEmail__c == false){
                        System.debug('*********************************** SI ES EL MISMO TIPO DE REGISTRO ****************************');
                        if(cuentaOpMap.get(op.Account.Id).Sucursal__c == op.Sucursal__c){
                            System.debug('*********************************** SI ES LA MISMA SUCURSAL ****************************');
                            if(op.JefeSucursal__c != null && op.JefeSucursal__r.ProfileId != asesor.Id && op.JefeSucursal__r.ProfileId != asesorBetaGrid.Id){
                                toAddresses.add(op.JefeSucursal__r.Email);
                                System.debug('*********************************** CORREO JEFE ****************************');
                            }else if(op.JefeSucursal__c == null && op.GerenteSucursal__c != null){
                                if(op.GerenteSucursal__r.ProfileId != asesor.Id && op.GerenteSucursal__r.ProfileId != asesorBetaGrid.Id){
                                    toAddresses.add(op.GerenteSucursal__r.Email);  
                                }
                                System.debug('*********************************** CORREO GERENTE ****************************');
                            }else if(op.JefeSucursal__c == null && op.GerenteSucursal__c == null && op.DirectorVentas__c != null){
                                if(op.DirectorVentas__r.ProfileId != asesor.Id && op.DirectorVentas__r.ProfileId != asesorBetaGrid.Id){
                                    toAddresses.add(op.DirectorVentas__r.Email);
                                }
                                System.debug('*********************************** CORREO DIRECTOR ****************************');
                            }else{
                                if(op.Owner.ProfileId != asesor.Id && op.Owner.ProfileId != asesorBetaGrid.Id){
                                    toAddresses.add(op.Owner.Email);
                                }
                                System.debug('*********************************** CORREO OWNER****************************');
                            }
                        }else{
                            //Validación sobre la Oportunidad vieja
                            if(op.JefeSucursal__c != null){
                                if(op.JefeSucursal__r.ProfileId != asesor.Id && op.JefeSucursal__r.ProfileId != asesorBetaGrid.Id){
                                    toAddresses.add(op.JefeSucursal__r.Email);
                                }
                            }else if(op.JefeSucursal__c == null && op.GerenteSucursal__c != null){
                                if(op.GerenteSucursal__r.ProfileId != asesor.Id && op.GerenteSucursal__r.ProfileId != asesorBetaGrid.Id){
                                    toAddresses.add(op.GerenteSucursal__r.Email);  
                                }
                            }else if(op.JefeSucursal__c == null && op.GerenteSucursal__c == null && op.DirectorVentas__c != null){
                                if(op.DirectorVentas__r.ProfileId != asesor.Id && op.DirectorVentas__r.ProfileId != asesorBetaGrid.Id){
                                    toAddresses.add(op.DirectorVentas__r.Email);
                                }
                            }else{
                                if(op.Owner.ProfileId != asesor.Id && op.Owner.ProfileId != asesorBetaGrid.Id){
                                    toAddresses.add(op.Owner.Email);
                                }
                            }
                            //Validación sobre la Oportunidad Nueva
                            if(cuentaOpMap.get(op.Account.Id).JefeSucursal__c != null){
                                //toAddresses.add(mapUsuarioCorreo.get(cuentaOpMap.get(op.Account.Id).JefeSucursal__r.Id));
                                if(mapUsuarioCorreo.containsKey(cuentaOpMap.get(op.Account.Id).JefeSucursal__c)){
                                    if(mapUsuarioProfileId.get(cuentaOpMap.get(op.Account.Id).JefeSucursal__c) != asesor.Id &&
                                       mapUsuarioProfileId.get(cuentaOpMap.get(op.Account.Id).JefeSucursal__c) != asesorBetaGrid.Id){
                                           toAddresses.add(mapUsuarioCorreo.get(cuentaOpMap.get(op.Account.Id).JefeSucursal__c));
                                       }
                                }
                            }else if(cuentaOpMap.get(op.Account.Id).JefeSucursal__c == null && cuentaOpMap.get(op.Account.Id).GerenteSucursal__c != null){
                                //toAddresses.add(mapUsuarioCorreo.get(cuentaOpMap.get(op.Account.Id).GerenteSucursal__r.Id));  
                                if(mapUsuarioCorreo.containsKey(cuentaOpMap.get(op.Account.Id).GerenteSucursal__c)){
                                    if(mapUsuarioProfileId.get(cuentaOpMap.get(op.Account.Id).GerenteSucursal__c) != asesor.Id &&
                                       mapUsuarioProfileId.get(cuentaOpMap.get(op.Account.Id).GerenteSucursal__c) != asesorBetaGrid.Id){
                                           toAddresses.add(mapUsuarioCorreo.get(cuentaOpMap.get(op.Account.Id).GerenteSucursal__c));
                                       }
                                }
                            }else if(cuentaOpMap.get(op.Account.Id).JefeSucursal__c == null && cuentaOpMap.get(op.Account.Id).GerenteSucursal__c == null && cuentaOpMap.get(op.Account.Id).DirectorVentas__c != null){
                                //toAddresses.add(mapUsuarioCorreo.get(cuentaOpMap.get(op.Account.Id).DirectorVentas__r.Id));
                                if(mapUsuarioCorreo.containsKey(cuentaOpMap.get(op.Account.Id).DirectorVentas__c)){
                                    if(mapUsuarioProfileId.get(cuentaOpMap.get(op.Account.Id).DirectorVentas__c) != asesor.Id &&mapUsuarioProfileId.get(cuentaOpMap.get(op.Account.Id).DirectorVentas__c) != asesorBetaGrid.Id){toAddresses.add(mapUsuarioCorreo.get(cuentaOpMap.get(op.Account.Id).DirectorVentas__c));
                                                                                                                                                                                                                               }
                                }
                            }else if(mapUsuarioCorreo.containsKey(cuentaOpMap.get(op.Account.Id).OwnerId)){
                                if(mapUsuarioProfileId.get(cuentaOpMap.get(op.Account.Id).OwnerId) != asesor.Id && mapUsuarioProfileId.get(cuentaOpMap.get(op.Account.Id).OwnerId) != asesorBetaGrid.Id){ toAddresses.add(mapUsuarioCorreo.get(cuentaOpMap.get(op.Account.Id).OwnerId));
                                                                                                                                                                                                        }
                            }
                        }
                        System.debug('*********************************** LLENA EL CONTENIDO DEL EMAIL****************************');
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(toAddresses);
                        email.setSubject('Oportunidad Duplicada para Cliente Activo');
                        
                        email.setPlainTextBody('El día de hoy se ha abierto una nueva oportunidad para el cliente ' + op.Account.Name + ' en la sucursal: ' + 
                                               cuentaOpMap.get(op.Account.Id).Sucursal__c + ', quién actualmente tiene una oportunidad abierta en la sucursal ' + op.Sucursal__c +
                                               ', la cual esta siendo atendida por ' + op.Owner.Name + ' y se encuentra en la etapa de ' + op.StageName + '. \n\n' +
                                               'Las oportunidades abiertas existentes son: ' + op.Name + '. Id: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + op.Id + ' y ' +
                                               cuentaOpMap.get(op.AccountId).Name + Url.getSalesforceBaseUrl().toExternalForm() + '/' + cuentaOpMap.get(op.AccountId).Id + '\n\n' + 
                                               'Por favor verificar.');
                        
                        email.setHtmlBody('El día de hoy se ha abierto una nueva oportunidad para el cliente ' + op.Account.Name + ' en la sucursal: ' + 
                                          cuentaOpMap.get(op.Account.Id).Sucursal__c + ', quién actualmente tiene una oportunidad abierta en la sucursal ' + op.Sucursal__c +
                                          ', la cual esta siendo atendida por ' + op.Owner.Name + ' y se encuentra en la etapa de ' + op.StageName + '. <br><br>' +
                                          'Las oportunidades abiertas existentes son: ' + op.Name + ' Id: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + op.Id + ' y ' +
                                          cuentaOpMap.get(op.AccountId).Name + Url.getSalesforceBaseUrl().toExternalForm() + '/' + cuentaOpMap.get(op.AccountId).Id + '<br><br>' + 
                                          'Por favor verificar.');
                        if(toAddresses != null && toAddresses.size()>0){
                            mails.add(email);
                        }
                        setIdsAdd.add(op.Account.Id);
                        System.debug('*********************************** CORREOS LISTOS ****************************');
                        op.alertEmail__c = true;
                        
                        TriggerHandler.bypass('OpportunityTriggerHandler');
                        oppActualizar.add(op);    
                        TriggerHandler.clearBypass('OpportunityTriggerHandler');
                    }
                    cuentasProcesadas.add(accountId);
                }
            }//end for
            
            if (oppActualizar.size() > 0) {
                update oppActualizar;
            }
            
            if(mails.size() > 0){
                if(!test.isRunningTest()){  Messaging.sendEmail(mails);
                                         }
                System.debug('*********************************** CORREOS ENVIADOS ****************************');
            }
        }
    }  
    
    /*
@autor: JCG
@proyecto: Red Motors - Fase II
*/
    
    public static void reasignarOportunidadVendedores(List<Opportunity> setOpp){  
        Set<String> setSucursalMarcaConteo = new Set<String>();
        Map<String,Vendedor_Asignacion_Contador__c> mapSucursalMarcaConteo = new Map<String,Vendedor_Asignacion_Contador__c>();
        
        for( Vendedor_Asignacion_Contador__c vendAsigContItem : [Select  Sucursal__c,Marca__c,Conteo__c From Vendedor_Asignacion_Contador__c]) {
            String sucursalMarca = vendAsigContItem.Sucursal__c + '|' + vendAsigContItem.Marca__c;
            setSucursalMarcaConteo.add(sucursalMarca);
            if(!mapSucursalMarcaConteo.containsKey(sucursalMarca)){ mapSucursalMarcaConteo.put(sucursalMarca,vendAsigContItem);
                                                                  }
        }
        Map<String,Map<String,Map<Decimal,String>>> mapUsusariosSucuralMarca = new Map<String,Map<String,Map<Decimal,String>>> ();
        for(Vendedor_Asignaciones__c vendedorItem : [Select Vendedor__c, Vendedor__r.Usuario__c ,Vendedor__r.Usuario__r.Name, Vendedor__r.Marcas__c,
                                                     Vendedor__r.Sucursal__c, Vendedor__r.Sucursal__r.Name From Vendedor_Asignaciones__c Where 
                                                     //Vendedor__r.Marcas__c =: marca And  Vendedor__r.Sucursal__c =: sucursalId
                                                     Fecha_Asignacion__c = TODAY And Activo__c = true
                                                     and  Vendedor__c != null Order by Vendedor__c]){
                                                         
                                                         String sucursal = vendedorItem.Vendedor__r.Sucursal__c;
                                                         if(!mapUsusariosSucuralMarca.containsKey(sucursal)){ mapUsusariosSucuralMarca.put(sucursal, new Map<String,Map<Decimal,String>>());
                                                                                                            }               
                                                         Map<String,Map<Decimal,String>>  mapSucursal = mapUsusariosSucuralMarca.get(sucursal);
                                                         if(vendedorItem.Vendedor__r.Marcas__c != null){
                                                             String[] marcaList = vendedorItem.Vendedor__r.Marcas__c.split(';');
                                                             System.debug('************* marcaList: ' + marcaList);   
                                                             for(String marca: marcaList){
                                                                 //Agrega al mapa de contadores en caso de no existir
                                                                 String sucursalMarca =  sucursal + '|' + marca;
                                                                 
                                                                 if (!setSucursalMarcaConteo.contains(sucursalMarca)){
                                                                     Vendedor_Asignacion_Contador__c vendAsigContItem = new Vendedor_Asignacion_Contador__c(Sucursal__c = sucursal,Marca__c = marca,Conteo__c = 0);  mapSucursalMarcaConteo.put(sucursalMarca,vendAsigContItem);
                                                                 }
                                                                 if (!mapSucursal.containsKey(marca)){
                                                                     Map<Decimal,String> vendedoresList = new Map<Decimal,String>();
                                                                     vendedoresList.put(0,vendedorItem.Vendedor__r.Usuario__c); mapSucursal.put(marca,vendedoresList);
                                                                 }else{
                                                                     Map<Decimal,String> vendedoresList = mapSucursal.get(marca);  Decimal contador = vendedoresList.size();
                                                                     vendedoresList.put(contador,vendedorItem.Vendedor__r.Usuario__c);
                                                                 }
                                                                 
                                                             }
                                                         }
                                                         
                                                     }
        /*****************************************************************************/
        Map<String,String> sucursalMap = new Map<String,String>();
        for(Sucursal__c sucursal : [Select id,name From Sucursal__c]){
            sucursalMap.put(sucursal.name,sucursal.Id);
        }
        System.debug('************* sucursalMap: ' + sucursalMap);
        System.debug('************* mapUsusariosSucuralMarca: ' + mapUsusariosSucuralMarca);   
        for(Opportunity opp : setOpp){
            String marcaOportunidad = '';
            if (opp.RT_Lead__c != null || !String.isBlank(opp.RT_Lead__c)){
                marcaOportunidad = opp.RT_Lead__c ;
            } else if(opp.RecordType.Name != null){ marcaOportunidad = opp.RecordType.Name;
                                                  } else if (opp.RecordTypeId != null){
                                                      for(RecordType item : [Select id,name from RecordType where id =: opp.RecordTypeId]){ marcaOportunidad =  item.Name;
                                                                                                                                          }
                                                  } 
            System.debug('************* opp: ' + opp);   
            System.debug('************* sucursalMap.containsKey(opp.Sucursal__c): ' + sucursalMap.containsKey(opp.Sucursal__c));     
            System.debug('************* opp.LeadSource: ' + (opp.LeadSource == 'Facebook' ||    opp.LeadSource == 'Página Web'));    
            System.debug('************* opp.RecordType.Name: ' + opp.RecordType.Name);   
            System.debug('************* opp.RecordType: ' + opp.RecordType);
            System.debug('************* opp.RT_Lead__c: ' + opp.RT_Lead__c);
            System.debug('************* marcaOportunidad: ' + marcaOportunidad);
            System.debug('************* opp.RecordTypeId: ' + opp.RecordTypeId);
            
            if(!String.isBlank(marcaOportunidad) && sucursalMap.containsKey(opp.Sucursal__c) && (opp.LeadSource == 'Facebook' ||    opp.LeadSource == 'Página Web')){
                String idSucursal = sucursalMap.get(opp.Sucursal__c);
                System.debug('************* idSucursal: ' + idSucursal);              
                //if(mapUsusariosSucuralMarca.containsKey(idSucursal) 
                //      && mapUsusariosSucuralMarca.get(idSucursal).containsKey(opp.Marca_de_Veh_culo_Actual__c))
                if(mapUsusariosSucuralMarca.containsKey(idSucursal) && mapUsusariosSucuralMarca.get(idSucursal).containsKey(marcaOportunidad)){
                    System.debug('************* mapUsusariosSucuralMarca: ' + mapUsusariosSucuralMarca);   
                    String sucursalMarca = idSucursal + '|' + marcaOportunidad;
                    Map<Decimal,String> mapUsuarioTemporal = mapUsusariosSucuralMarca.get(idSucursal).get(marcaOportunidad);
                    Decimal tamanioMapa = mapUsuarioTemporal.size() - 1;
                    //Map<String,Vendedor_Asignacion_Contador__c> mapSucursalMarcaConteo ;
                    if(mapSucursalMarcaConteo.containsKey(sucursalMarca)){
                        System.debug('************* mapUsuarioTemporal: ' + mapUsuarioTemporal);     
                        Vendedor_Asignacion_Contador__c vendContador = mapSucursalMarcaConteo.get(sucursalMarca);
                        Decimal conteo = vendContador.Conteo__c;
                        String usuario = mapUsuarioTemporal.get(conteo);
                        if(conteo < tamanioMapa){ conteo += 1;
                                                }else{  conteo  = 0;
                                                     }
                        vendContador.Conteo__c = conteo; opp.ownerId = usuario;
                        System.debug('************* opp usuario ****** %%%%%%%%%%% : ' + usuario);
                        System.debug('************* opp Usuario: ' + opp);   
                    }
                }
            }
        }
        List<Vendedor_Asignacion_Contador__c> vendedorConteoList = new List<Vendedor_Asignacion_Contador__c>();
        for (String key : mapSucursalMarcaConteo.keySet()) {
            Vendedor_Asignacion_Contador__c vendedorConteoItem = mapSucursalMarcaConteo.get(key); vendedorConteoList.add(vendedorConteoItem);
        }
        upsert vendedorConteoList;
    }
    
    //Metodo para crear tareas de seguimiento cuando una oportunidad = cerrada ganada
    public static void crearTareasOportunidad(Set<Id> tempIdsOp, Set<Id> tempActOpIds){
        List<Task> listTasksCreate = new List<Task>();
        List<Opportunity> tempListOp = new List<Opportunity>();
        List<Contact> tempListContact = new List<Contact>();
        Map<Id,Id> mapIds = new Map<Id,Id>();
        
        tempListOp = [SELECT Id, RecordType.Name, Owner.Id, tareasCreadas__c, AccountId FROM Opportunity WHERE Id IN : tempIdsOp];
        tempListContact = [SELECT Id, AccountId FROM Contact WHERE AccountId IN : tempActOpIds];
        for(Contact c : tempListContact){
            mapIds.put(c.AccountId, c.Id);
        }
        System.debug(' ** oportunidades ** ' + tempListOp);
        
        for(Opportunity op : tempListOp){
            if(!op.tareasCreadas__c){
               // No se deben crear tareas para oportunidades de tipo Taller o Mostrador
               if (op.RecordType.Name == 'Taller' || op.RecordType.Name == 'Mostrador') {
               continue;
               } 
                if(op.RecordType.Name == 'BMW' || op.RecordType.Name == 'MINI'){
                    System.debug(' ** nombre tipo registro ** ' + op.RecordType.Name);
                    Task t = new Task();
                    t.Subject = 'Llamada';
                    t.OwnerId = op.Owner.Id;
                    t.ActivityDate = Date.today().addDays(3);
                    t.WhatId = op.Id;
                    t.Priority = 'Normal';
                    t.Status = 'Open';
                    t.IsReminderSet = true;
                    t.WhoId = mapIds.get(op.AccountId);
                    listTasksCreate.add(t);
                    Task t2 = new Task();
                    t2.Subject = 'Llamada';
                    t2.OwnerId = op.Owner.Id;
                    t2.ActivityDate = Date.today().addDays(21);
                    t2.WhatId = op.Id;
                    t2.Priority = 'Normal';
                    t2.Status = 'Open';
                    t2.IsReminderSet = true;
                    t2.WhoId = mapIds.get(op.AccountId);
                    listTasksCreate.add(t2);
                    Task t3 = new Task();
                    t3.Subject = 'Llamada';
                    t3.OwnerId = op.Owner.Id;
                    t3.ActivityDate = Date.today().addMonths(3);
                    t3.WhatId = op.Id;
                    t3.Priority = 'Normal';
                    t3.Status = 'Open';
                    t3.IsReminderSet = true;
                    t3.WhoId = mapIds.get(op.AccountId);
                    listTasksCreate.add(t3);
                }else{
                    System.debug(' ** nombre tipo registro ** ' + op.RecordType.Name);
                    Task t = new Task();
                    t.Subject = 'Llamada';
                    t.OwnerId = op.Owner.Id;
                    t.ActivityDate = Date.today().addDays(1);
                    t.WhatId = op.Id;
                    t.Priority = 'Normal';
                    t.Status = 'Open';
                    t.IsReminderSet = true;
                    t.WhoId = mapIds.get(op.AccountId);
                    listTasksCreate.add(t);
                    Task t2 = new Task();
                    t2.Subject = 'Llamada';
                    t2.OwnerId = op.Owner.Id;
                    t2.ActivityDate = Date.today().addDays(7);
                    t2.WhatId = op.Id;
                    t2.Priority = 'Normal';
                    t2.Status = 'Open';
                    t2.IsReminderSet = true;
                    t2.WhoId = mapIds.get(op.AccountId);
                    listTasksCreate.add(t2);
                    Task t3 = new Task();
                    t3.Subject = 'Llamada';
                    t3.OwnerId = op.Owner.Id;
                    t3.ActivityDate = Date.today().addMonths(15);
                    t3.WhatId = op.Id;
                    t3.Priority = 'Normal';
                    t3.Status = 'Open';
                    t3.IsReminderSet = true;
                    t3.WhoId = mapIds.get(op.AccountId);
                    listTasksCreate.add(t3);
                    Task t4 = new Task();
                    t4.Subject = 'Llamada';
                    t4.OwnerId = op.Owner.Id;
                    t4.ActivityDate = Date.today().addMonths(30);
                    t4.WhatId = op.Id;
                    t4.Priority = 'Normal';
                    t4.Status = 'Open';
                    t4.IsReminderSet = true;
                    t4.WhoId = mapIds.get(op.AccountId);
                    listTasksCreate.add(t4);
                }
                op.tareasCreadas__c = true;
            }
        }
        System.debug(' ** tareas nuevas ** ' + listTasksCreate);
        if(!listTasksCreate.isEmpty() && listTasksCreate.size() > 0){
            try{
                System.debug(' ** insert  tasks  **');
                insert listTasksCreate;
                update tempListOp;
            }catch(Exception ex){
                System.debug(' ** error al crear tareas ** ' +  ex.getMessage());
            }
        }
    }
}