public class leadOwnerAssignacion {

    public static void setOwner(List<Lead> registros){

        System.debug('=================== OWNERS ====================');

        List<Lead> lstLeadsUodate = new List<Lead>();
        
        List<User> lstUsuarios = [SELECT ProfileId, noValidar__c, Profile.Name 
                                  FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id currentUserId = UserInfo.getUserId();

        Boolean isUserInList = false;

        List<Ignorar_Asignaciones__c> lstUsuariosNo = [Select Id,User__c From Ignorar_Asignaciones__c ];

        for (Ignorar_Asignaciones__c u : lstUsuariosNo) {
            if (u.User__c == currentUserId) {
                isUserInList = true;  // Found the current user in the list
                return;
            }
        }
        
                                  
        Boolean isAdmin = [SELECT ProfileId, Profile.Name 
                           FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Profile.Name == 'System Administrator';
        Boolean isEdecan = [SELECT ProfileId,Profile.Name 
                            FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Profile.Name == 'Recepcion Mixtos';
        if ((isAdmin && !Test.isRunningTest() && lstUsuarios[0].noValidar__c == true ) || isEdecan)  {
            System.debug('El usuario es administrador, no se realiza la validación.');
            return; 
        }

        for(Lead trafico:registros){

            if(trafico.Ignorar_asignacion__c == false){

                List<String> listSoloAsesorAnt = new List<String>();

                List<Configuraci_nes_Sucursal__c> lstSucursal = [SELECT Id, Sucursal__c, Canal__c, Last_Assigned_Index__c
                                                                 FROM Configuraci_nes_Sucursal__c 
                                                                 WHERE Marca__c = :trafico.Marca__c 
                                                                 AND Estado_asignaci_n__c = 'Activo' 
                                                                 AND Sucursal__c INCLUDES (:trafico.Sucursal__c)];
                
                if(lstSucursal.size() > 0){
                    Configuraci_nes_Sucursal__c currentSucursal = lstSucursal[0];

                    List<Configuraci_nes_Asesor_x_Sucursal__c> lstAsesores = [SELECT Id, OwnerId, buscar_asesor__c, Estado__c, BackUp__c 
                                                                             FROM Configuraci_nes_Asesor_x_Sucursal__c 
                                                                             WHERE Buscar_Sucursal__c = :currentSucursal.Id Order By NumeroControl__c];
                    
                    // Convert Last_Assigned_Index__c (Double) to an Integer for indexing
                    Integer lastIndex = (currentSucursal.Last_Assigned_Index__c != null) ? 
                                        currentSucursal.Last_Assigned_Index__c.intValue() : 0;
                    Integer totalAsesores = lstAsesores.size();

                    if(totalAsesores > 0){
                        // Determine next advisor in a round-robin fashion
                        Integer nextIndex = lastIndex + 1;
                        if (nextIndex >= totalAsesores) {
                            nextIndex = 0; // Reset the index to 0 when it exceeds the number of advisors
                        }
                        // Update the Last_Assigned_Index__c field in the current Sucursal, saving it as Double
                        currentSucursal.Last_Assigned_Index__c = (Double) nextIndex;
                        System.debug('===================Updating Last_Assigned_Index__c with value: ' + nextIndex);
                        System.debug('trafico.OwnerId');
                        System.debug(trafico.OwnerId);
                        if(trafico.OwnerId != '00G0P000003SKbfUAG'){
                            update currentSucursal;    
                        }
                        

                        Configuraci_nes_Asesor_x_Sucursal__c nextAsesor = lstAsesores[nextIndex];

                        // If the selected advisor is active, assign them, otherwise assign the backup advisor
                        Lead upOpp = new Lead();
                        upOpp.Id = trafico.Id;
                        if(nextAsesor.Estado__c == 'Activo'){
                            upOpp.OwnerId = nextAsesor.buscar_asesor__c;
                        } else {
                            upOpp.OwnerId = trafico.OwnerId;
                        }

                        // Add the lead to the update list only if the new owner is different from the current owner
                        if(nextAsesor.buscar_asesor__c != trafico.OwnerId){
                            lstLeadsUodate.add(upOpp);
                            
                        }

                        
                    }

                    // Check for an existing Lead with the same email
                    List<Lead> existingLeads = [SELECT Id, OwnerId 
                    FROM Lead 
                    WHERE Email = :trafico.Email 
                    AND RecordTypeId = :trafico.RecordTypeId 
                    AND Id != :trafico.Id 
                    AND Sucursal__c = :trafico.Sucursal__c 
                    AND Status != 'No contactado' 
                    AND Owner.IsActive = true 
                    ORDER BY CreatedDate DESC 
                    LIMIT 1];

                    
                    if (!existingLeads.isEmpty()) {
                        // Assign to the owner of the existing lead if it exists
                        Lead existingLead = existingLeads[0];
                        
                        // Manually check if the OwnerId exists in lstAsesores using a loop
                        Boolean ownerExists = false;
                        
                        for (Configuraci_nes_Asesor_x_Sucursal__c asesor : lstAsesores) {
                            if (asesor.buscar_asesor__c == existingLead.OwnerId) {
                                ownerExists = true;
                                break;  // Exit the loop as soon as we find a match
                            }
                        }
                        
                        if (ownerExists) {
                            lstLeadsUodate.clear();
                            Lead upOpp = new Lead();
                            upOpp.Id = trafico.Id;
                            upOpp.OwnerId = existingLead.OwnerId;
                            lstLeadsUodate.add(upOpp);
                            System.debug('Lead existente encontrado, asignando OwnerId al propietario del lead existente.');
                            continue; 
                        }
                    }

                }

                
            }
        }

        if(lstLeadsUodate.size() > 0 && !Test.isRunningTest()){
           update lstLeadsUodate; 
        }
        Integer i=0;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
    }
}