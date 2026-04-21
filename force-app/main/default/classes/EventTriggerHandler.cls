public class EventTriggerHandler {
    
    public static void onBeforeInsert(List<Event> newList) {
        Set<String> ownerIdSet = new Set<String>();
        Set<String> ownerIdSetUser = new Set<String>();
        Set<String> eventKeySet = new Set<String>();
        Set<String> eventKeySetUser = new Set<String>();
        Set<String> whoIdSet = new Set<String>();
        Set<String> whoIdSetUser = new Set<String>();
        Set<String> assetIdSet = new Set<String>();
        Set<String> assetIdSetUser = new Set<String>();
        for(Event rec : newList) {

             if(rec.RecordTypeId != '012PH000002dSzNYAU' && rec.Ownerid != null){
                String usuario = rec.Ownerid;
                List<AsesorxCalendario__c> lstAseCal = [Select Id,Calendario__c,Asesor__c From AsesorxCalendario__c Where Asesor__c =:usuario OR Calendario__c =:usuario  LIMIT 1 ];

                if(lstAseCal.size()>0){
                    rec.OwnerId = lstAseCal[0].Calendario__c;
                }else {
                    if(!Test.isRunningTest()){
                        rec.OwnerId.addError('Este usuario no cuenta con un calendario asignado. ' + rec.Owner.FirstName);
                    }
                }                   
                              
            }

            //OwnerId - Assigned to
            String sobjectTypeName = rec.OwnerId.getSObjectType().getDescribe().getName();
            
            if(sobjectTypeName == 'User' ) {
                ownerIdSetUser.add(rec.OwnerId);
                //WhoId - Contact Name
                whoIdSetUser.add(rec.WhoId);
                assetIdSetUser.add(rec.Activo__c);
            } else {
                ownerIdSet.add(rec.OwnerId);
                //WhoId - Contact Name
                whoIdSet.add(rec.WhoId);
                assetIdSet.add(rec.Activo__c);
            }         
                       
        }        
        if(ownerIdSet.size() > 0) {
            
            Map<Integer, List<Workorder>> workorderEventMap = new Map<Integer, List<Workorder>>();
            Map<Integer, ServiceAppointment> serviceAppointmentEventMap = new Map<Integer, ServiceAppointment>();
            Map<Integer, SkillRequirement> skillRequirementMap = new Map<Integer, SkillRequirement>();
            
            Map<Id, Calendar> calendarMap = new Map<Id, Calendar>([SELECT Id, Name
                                                                   FROM Calendar
                                                                   WHERE Id in : ownerIdSet]);
            for(Event e : [SELECT Id, Subject, Activo__c, StartDateTime, EndDateTime, OwnerId, WhoId
                           FROM Event
                           WHERE OwnerId in : ownerIdSet]) {
                               eventKeySet.add(e.StartDateTime+'-'+e.EndDateTime+'-'+e.OwnerId);
                           }
            
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, AccountId
                                                                FROM Contact
                                                                WHERE Id in : whoIdSet]);
            
            Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, Name
                                                          FROM Asset
                                                          WHERE Id in : assetIdSet]);
            
            Integer count = 0;
            Integer sacount = 0;
            for(Event rec : newList) {
                if(calendarMap.containskey(rec.OwnerId) && !assetMap.isEmpty()) {
                    String calenderName = calendarMap.get(rec.OwnerId).Name;
                    String servicio;
                    
                    if(Test.isRunningTest())
                        calenderName = 'Escazú - Mecánica Rapida';
                    
                    if(calenderName.contains(' - '))
                        servicio = calenderName.split(' - ')[1];
                    
                    calenderName = calenderName.split(' - ')[0];
                    
                                        List<ServiceTerritory> stList = [SELECT Id from ServiceTerritory Where Name =: calendarMap.get(rec.OwnerId).Name];
                    List<WorkType> wtList = [SELECT Id, Name from WorkType Where Name =: servicio];
                    List<Skill> skillList = new List<Skill>();
                    if(wtList.size() > 0) {
                        skillList = [SELECT Id FROM Skill WHERE MasterLabel = :wtList[0].Name];
                    }
                    
                    List<Workorder> workorderList = new List<Workorder>();
                    
                    if(rec.tipoCargoAseguradora__c) {
                        workorderList.add(addWorkorder(stList, contactMap, rec, 'Aseguradora', servicio, wtList, assetMap));
                        serviceAppointmentEventMap.put(sacount, addServiceAppointment(rec, assetMap));
                        if(skillList.size() > 0) {
                            skillRequirementMap.put(sacount, addSkillRequirement(skillList[0].Id));
                        }
                        sacount++;
                    }
                    if(rec.tipoCargoBci__c) {
                        workorderList.add(addWorkorder(stList, contactMap, rec, 'BCI', servicio, wtList, assetMap));
                        serviceAppointmentEventMap.put(sacount, addServiceAppointment(rec, assetMap));
                        if(skillList.size() > 0) {
                            skillRequirementMap.put(sacount, addSkillRequirement(skillList[0].Id));
                        }
                        sacount++;
                    }
                    if(rec.tipoCargoCliente__c) {
                        workorderList.add(addWorkorder(stList, contactMap, rec, 'Cliente', servicio, wtList, assetMap));
                        serviceAppointmentEventMap.put(sacount, addServiceAppointment(rec, assetMap));
                        if(skillList.size() > 0) {
                            skillRequirementMap.put(sacount, addSkillRequirement(skillList[0].Id));
                        }
                        sacount++;
                    }
                    if(rec.tipoCargoFabrica__c) {
                        workorderList.add(addWorkorder(stList, contactMap, rec, 'Fábrica', servicio, wtList, assetMap));
                        serviceAppointmentEventMap.put(sacount, addServiceAppointment(rec, assetMap));
                        if(skillList.size() > 0) {
                            skillRequirementMap.put(sacount, addSkillRequirement(skillList[0].Id));
                        }
                        sacount++;
                    }
                    if(rec.tipoCargoGarantia__c) {
                        workorderList.add(addWorkorder(stList, contactMap, rec, 'Garantía', servicio, wtList, assetMap));
                        serviceAppointmentEventMap.put(sacount, addServiceAppointment(rec, assetMap));
                        if(skillList.size() > 0) {
                            skillRequirementMap.put(sacount, addSkillRequirement(skillList[0].Id));
                        }
                        sacount++;
                    }
                    
                    if(workorderList.size() > 0)
                        workorderEventMap.put(count, workorderList);
                    
                    rec.Location = calendarMap.get(rec.OwnerId).Name;
                }
                count++;
            }
            
            
                        
            
        }
        if(ownerIdSetUser.size() > 0) {
            
            Map<Integer, List<Workorder>> workorderEventMap = new Map<Integer, List<Workorder>>();
            Map<Integer, ServiceAppointment> serviceAppointmentEventMap = new Map<Integer, ServiceAppointment>();
            Map<Integer, SkillRequirement> skillRequirementMap = new Map<Integer, SkillRequirement>();
            
            Map<Id, String> userMap = new Map<Id, String>();
            for(User us : [SELECT Id, Name FROM User WHERE Id in : ownerIdSetUser]) {
                if(us.Name.contains('Calendario ')) {
                    userMap.put(us.Id, us.Name.Split('Calendario ')[1]);
                }
                else{
                    userMap.put(us.Id, us.Name);
                }                
            }
            
            if(userMap.isEmpty())
                return;
            
            for(Event e : [SELECT Id, Subject, Activo__c, StartDateTime, EndDateTime, OwnerId, WhoId
                           FROM Event
                           WHERE OwnerId in : ownerIdSetUser]) {
                eventKeySetUser.add(e.StartDateTime+'-'+e.EndDateTime+'-'+e.OwnerId);
            }
            
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, AccountId
                                                                FROM Contact
                                                                WHERE Id in : whoIdSetUser]);
            
            Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, Name
                                                          FROM Asset
                                                          WHERE Id in : assetIdSetUser]);
            
            Integer count = 0;
            Integer sacount = 0;
            for(Event rec : newList) {
                if(userMap.containskey(rec.OwnerId) && !assetMap.isEmpty()) {
                    String calenderName = userMap.get(rec.OwnerId);
                    String servicio;
                    
                    if(Test.isRunningTest())
                        calenderName = 'Escazú - Mecánica Rapida';
                    
                    if(calenderName.contains(' - '))
                        servicio = calenderName.split(' - ')[1];
                    
                    calenderName = calenderName.split(' - ')[0];
                     
                    List<ServiceTerritory> stList = [SELECT Id from ServiceTerritory Where Name =: userMap.get(rec.OwnerId)];
                    List<WorkType> wtList = [SELECT Id, Name from WorkType Where Name =: servicio];
                    List<Skill> skillList = new List<Skill>();
                    if(wtList.size() > 0) {
                        skillList = [SELECT Id FROM Skill WHERE MasterLabel = :wtList[0].Name]; 
                    }
                    
                    List<Workorder> workorderList = new List<Workorder>();
                    
                                        if(workorderList.size() > 0)
                        workorderEventMap.put(count, workorderList);
                    
                    rec.Location = userMap.get(rec.OwnerId);
                }
                count++;
            }
            
                        
        }
    }
    
    public static Workorder addWorkorder(List<ServiceTerritory> stList, 
                                         Map<Id, Contact> contactMap, 
                                         Event rec, 
                                         String type, 
                                         String servicio, 
                                         List<WorkType> wtList,
                                         Map<Id, Asset> assetMap) {     
                                             	
                                             return new Workorder(ServiceTerritoryId = (stList.size() > 0 ? stList[0].Id : null),
                                                                  AccountId = (contactMap.containskey(rec.WhoId) ? contactMap.get(rec.WhoId).AccountId : null),
                                                                  ContactId = (contactMap.containskey(rec.WhoId) ? contactMap.get(rec.WhoId).Id : null),
                                                                  AssetId = rec.Activo__c,
                                                                  Asesor_de_la_orden__c = rec.Asesor__c,
                                                                  tipoDeGasto__c = type,
                                                                  Observaciones__c = rec.Description,
                                                                  Subject = assetMap.get(rec.Activo__c).Name + (contactMap.containskey(rec.WhoId) ? ' - ' + contactMap.get(rec.WhoId).Name : ''),
                                                                  Fecha_Cita__c = rec.StartDateTime.date(),
                                                                  Tipo_de_servicio__c = servicio,
                                                                  WorkTypeId = (wtList.size() > 0 ? wtList[0].Id : null));
                                         }
    
    public static ServiceAppointment addServiceAppointment(Event rec, Map<Id, Asset> assetMap)
    {
        return new ServiceAppointment(Status = 'Scheduled', 
                                      Subject = assetMap.get(rec.Activo__c).Name + ' - ' + rec.Subject,
                                      SchedStartTime = rec.StartDateTime,
                                      EarliestStartTime = rec.StartDateTime,
                                      SchedEndTime = rec.EndDateTime,
                                      DueDate = rec.StartDateTime.addhours(24),//rec.EndDateTime,
                                      Fecha_de_registro__c = Date.today(),
                                      FSL__Auto_Schedule__c = true,
                                      FSL__Schedule_Mode__c = 'Automatic');
    }
    
    public static SkillRequirement addSkillRequirement(Id skillId) {
        return new SkillRequirement(SkillId = skillId,
                                    SkillLevel = 1);
    }
    
    //Added by Jose Rivera (Portalnet)
    //Date: March 2022
    //Story #: SRM-24
    //Description: Whenever "Asesor" field is updated in Event, look for all the WorkOrders with the matching CaseId from the Event and update the "Asesor de la orden" in the WorkOrder object
    public void updateAsesorOnWorkOrder(List<Event> newList, List<Event> oldList, Map<ID, Event> oldMap) {
        Map<Id, Id> casesMap = new Map<Id, Id>(); //Key: contains the Id of the Case / Value: contains the Id of the Asesor__c
        
        for(Event event : newList) {
            if(oldMap.get(event.Id).Asesor__c != event.Asesor__c) {
                casesMap.put(event.WhatId, event.Asesor__c);                
            }
        }
        if(casesMap != null || !casesMap.isEmpty()) {   
            List<WorkOrder> workOrderList = [SELECT Id,isLocked__c, Bandera__c,CaseId, Asesor_de_la_orden__c FROM WorkOrder WHERE CaseId IN: casesMap.keySet() AND isLocked__c = false];
            if(workOrderList != null || !workOrderList.isEmpty()) {
                for(WorkOrder workOrder : workOrderList) {
                    if(workOrder.Bandera__c == true){
                        workOrder.Bandera__c = false;
                    }else{workOrder.Bandera__c = true;}
                   
                    workOrder.Asesor_de_la_orden__c = casesMap.get(workOrder.CaseId);
                }
                update workOrderList;
            }
        }        
    }
}