@isTest
public with sharing class RM_CT_TestDataFactory {

    public static OperatingHours createOperatingHours(String name,Boolean doInsert){   
        OperatingHours newRecord = new OperatingHours(
            Name = name,
            TimeZone = 'America/Costa_Rica'
        );
    
        if(doInsert){
            insert newRecord;
        }

        return newRecord;
    }

    public static ServiceTerritory createTerritory(String name,OperatingHours oh, Boolean doInsert){            
        ServiceTerritory newRecord = new ServiceTerritory(
            Name = name,
            IsActive = true,
            OperatingHoursId = oh.Id 
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static FSL__User_Territory__c createUserTerritory(String name,ServiceTerritory st, Boolean doInsert){            
        FSL__User_Territory__c newRecord = new FSL__User_Territory__c(
            FSL__User__c = UserInfo.getUserId(),
            FSL__ServiceTerritory__c = st.Id
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }  
    
    public static Account createAccount(String name,Boolean doInsert){            
        Account newRecord = new Account(
            Name = name,
            Cedula__c = '9876543210',
            Tipo_de_Documento__c = '02',
            codigoSoftland__c = '1234'
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }  

    public static Contact createContact(String firstName,String lastName,String middleName,String recordTypeId,Boolean doInsert){            
        Contact newRecord = new Contact(
            FirstName = firstName,
            LastName = lastName,
            MiddleName = middleName,
            RecordTypeId = recordTypeId,
            Usuario__c = UserInfo.getUserId()   
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    } 
    
    public static Asset createAsset(String name,Account acc,Boolean doInsert){            
        Asset newRecord = new Asset(
            Name = name,
            AccountId = acc.Id
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }    
    
    public static Case createCase(Account account,Contact contact,Asset asset,ServiceTerritory serviceTerritory,Boolean doInsert){            
        Case newRecord = new Case(
            Type = 'Mecánica General',
            categoria__c = 'Interno',
            StatusDetail__c = 'Recibido',
            Priority = 'Alta',//Media,Baja
            AccountId = account.Id,
            ContactId = contact.Id,
            AssetId = asset.Id,
            Service_Territory1__c = serviceTerritory.Id
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }   

    public static WorkOrder createWorkOrder(Account acc,Asset asset,Case caso,Contact contact,ServiceTerritory st,Boolean doInsert){
        WorkOrder newRecord = new WorkOrder(
            AccountId = acc.Id,
            AssetId = asset.Id,
            CaseId = caso.Id,
            ContactId = contact.Id,
            Priority = 'Alto',
            Tipo_de_servicio__c = 'Mecánica Rápida',
            empresaFactura__c = 'RMOTOBAI',
            Fecha_de_Entrada__c = System.today(),
            CurrencyIsoCode = 'USD',
            Etapa_de_flujo_de_trabajo__c= 'Nuevo',
            ServiceTerritoryId = st.Id,
            Status = 'Nuevo',
            tipoDeGasto__c = 'Cliente'
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static tiposDeTrabajo__c createTipoTrabajo(String name,Boolean doInsert){
        tiposDeTrabajo__c newRecord = new tiposDeTrabajo__c(
            Name = name
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static tiposDeTrabajoCaso__c createTipoTrabajoCaso(Case caso,WorkOrder workOrder,String tipoCargo,ServiceTerritory st,String tipoTrabajo,Boolean doInsert){
        tiposDeTrabajoCaso__c newRecord = new tiposDeTrabajoCaso__c(
            Caso__c	= caso.Id,
            RM_WorkOrder__c	= workOrder?.Id,
            Tipo_de_cargo__c = tipoCargo, 
            Taller__c = st.Id,
            Tipotrabajo__c	= tipoTrabajo
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static Subtipo_de_trabajo_del_caso__c createSubTipoTrabajoCaso(String name,Case caso,tiposDeTrabajoCaso__c ttc,WorkOrder wo,Boolean doInsert){
        Subtipo_de_trabajo_del_caso__c newRecord = new Subtipo_de_trabajo_del_caso__c(
            Name = name,
            Caso__c	= caso.Id, 
            Tipo_de_trabajo_del_caso__c = ttc.Id, 
            Orden_de_trabajo__c = wo.Id
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    } 

    public static RM_MecanicoTaller__c createMecanicoTaller(ServiceTerritory taller,Contact mecanico,Boolean doInsert){
        RM_MecanicoTaller__c newRecord = new RM_MecanicoTaller__c(
            RM_Taller__c = taller.Id, 
            RM_Mecanico__c = mecanico.Id
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static RM_ActividadMecanico__c createActividadMecanico(Case caso,WorkOrder order,ServiceTerritory taller,WorkStep paso,Contact mecanico,String tipo,Boolean doInsert){
        RM_ActividadMecanico__c newRecord = new RM_ActividadMecanico__c(
            RM_Caso__c = caso?.Id,
            RM_Orden__c	= order?.Id, 
            RM_Taller__c = taller?.Id, 
            RM_Paso__c = paso?.Id,
            RM_Mecanico__c = mecanico?.Id,
            RM_Tipo__c = tipo
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static void createCaseWithWorkSteps() {
        OperatingHours op = createOperatingHours('Test OP',true);
        ServiceTerritory st = createTerritory('Test ST',op,true);
        FSL__User_Territory__c ut = createUserTerritory('Test',st,true);
        Account acc = createAccount('Test Acc',true);
        Contact mechanic = createContact('juan', 'hernandez', '', getMechanicRecordTypeId(), true);
        Contact mechanic2 = createContact('pedro', 'hernandez', '', getMechanicRecordTypeId(), true);
        Asset asset = createAsset('Test Asset',acc,true);
        Case caso = createCase(acc, mechanic, asset, st, true);
        WorkOrder wo = createWorkOrder(acc,asset,caso,mechanic,st,true);
        tiposDeTrabajo__c tipoTrabajo = createTipoTrabajo('Mecánica Rápida',true);
        tiposDeTrabajoCaso__c ttc1 = createTipoTrabajoCaso(caso,wo,'Cliente',st,tipoTrabajo.Id,true);
        tiposDeTrabajoCaso__c ttc2 = createTipoTrabajoCaso(caso,wo,'Cliente',st,tipoTrabajo.Id,true);
        Subtipo_de_trabajo_del_caso__c sttc1 = createSubTipoTrabajoCaso('Test Subtipo',caso,ttc1,wo,true);
        Subtipo_de_trabajo_del_caso__c sttc2 = createSubTipoTrabajoCaso('Test Subtipo',caso,ttc2,wo,true);
        createMecanicoTaller(st,mechanic,true);
        createMecanicoTaller(st,mechanic2,true);
    }

    public static Id getMechanicRecordTypeId(){
        RecordType mechanicRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND IsActive = true AND DeveloperName = 'Contacto_de_Taller' LIMIT 1];  
        return mechanicRT.Id;
    }
}