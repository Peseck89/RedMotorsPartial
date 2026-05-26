public with sharing class walkingCommunityControllerBeta {

    @AuraEnabled
    public static Map<String, List<String>> getModelos(){
        string objectName = 'Lead';
        string controllingField = 'Marca__c';
        string dependentField = 'Familia1__c';
        List<String> bmwModels = new List<String>();
        System.debug(getFieldDependencies(objectName,controllingField,dependentField));
        Map<String, List<String>> carModels = getFieldDependencies(objectName,controllingField,dependentField);
        for (String brand : carModels.keySet()) {
            if (brand == 'BMW') {
                bmwModels.addAll(carModels.get(brand));
                break;
            }
        }
        System.debug(bmwModels);
        
        objectName = 'Lead';
        controllingField = 'Familia1__c';
        dependentField = 'Modelo_De_Inter_s1__c';
        List<String> bmwModelsCars = new List<String>();
        Map<String, List<String>> originalMap = getFieldDependencies(objectName,controllingField,dependentField);
        Map<String, List<String>> filteredMap = new Map<String, List<String>>();
        
        List<Document> listDoc = new List<Document>();
        List<String> listLeadMDI = new List<String>();
        List<Id> ids = new List<Id>();
        
        
        for (String key : originalMap.keySet()) {
            for (String model : originalMap.get(key)) {
                if (bmwModels.contains(key)) {
                    if (!filteredMap.containsKey(key)) {
                        filteredMap.put(key, new List<String>());
                    }
                    listLeadMDI.add(model.substringBefore(' ').trim());
                    filteredMap.get(key).add(model);
                }
            }
        }
        System.debug(listLeadMDI);
        if(!listLeadMDI.isEmpty() && listLeadMDI.size() > 0){
            listDoc = [SELECT Name, Id, DeveloperName FROM Document];
            System.debug(' ** LISTA FT ** ' + listDoc);
            if(!listDoc.isEmpty() && listDoc.size() > 0){
                for(String str : listLeadMDI){
                    for(Document d : listDoc){
                        if(d.DeveloperName.contains(str)||d.Name.contains(str)) ids.add(d.Id);
                    }
                }
            }
        }
        System.debug(' ** ids documentos ** ' + ids);
        System.debug(filteredMap); // This will print out the filtered map
        return filteredMap;
    }

    // @AuraEnabled
    // public static List<Object> getFamilia(String marca){
    //     List<Object> lstProds = new List<Object>();
    //     if(marca == 'Motorrad'){
    //         lstProds = [SELECT Marca__c, Grupo__c FROM Product2 WHERE walking_product__c = true AND Marca__c IN ('Motorrad','Kawasaki','Polaris','Indian') AND Grupo__c != null GROUP BY Grupo__c, Marca__c ORDER BY Marca__c,Grupo__c];
    //     }else{
    //         lstProds = [SELECT Marca__c, Grupo__c FROM Product2 WHERE walking_product__c = true AND Marca__c = :marca AND Grupo__c != null GROUP BY Grupo__c, Marca__c ORDER BY Grupo__c];
    //     }
        
    //     return lstProds;
    // }
    
    // @AuraEnabled
    // public static List<Product2> getVehiculos(String familia, String marca){
    //     List<Product2> lstProds = new List<Product2>();
    //     if(marca == 'Motorrad'){
    //         lstProds = [SELECT Modelo_De_Inter_s__c, Familia__c FROM Product2 WHERE Grupo__c = :familia AND walking_product__c = true AND Marca__c IN ('Motorrad','Kawasaki','Polaris','Indian') ORDER BY Orden_Walking__c];
    //     }else{
    //         lstProds = [SELECT Modelo_De_Inter_s__c, Familia__c FROM Product2 WHERE Grupo__c = :familia AND walking_product__c = true AND Marca__c = :marca ORDER BY Orden_Walking__c];
    //     }                

    //     return lstProds;
    // }

    @AuraEnabled
    public static List<AggregateResult> getFamilia(String marca) {
        return walkingCommunityControllerBase.getFamilia(marca);
    }

    @AuraEnabled
    public static List<Product2> getVehiculos(String familia, String marca) {
        return walkingCommunityControllerBase.getVehiculos(familia, marca);
    }

    @AuraEnabled
    public static List<String> getCedula(String cedula){
        List<String> cedulaCliente = new List<String>();
        List<String> cedulaInfo = new List<String>();

        List<Account> lstAccount = [Select Id,FirstName,LastName,PersonEmail,Phone From Account Where Cedula__c =:cedula ];
        if(lstAccount.size()>0){
            String textCompleto = lstAccount[0].FirstName+';'+lstAccount[0].LastName+';'+';'+lstAccount[0].PersonEmail+';'+lstAccount[0].Phone+';';
            cedulaInfo.add(textCompleto);
            cedulaInfo.add('existe');
        }else{
            cedulaCliente.add(cedula);        
            cedulaInfo = ApiCreditWS.getInfoCliente( cedulaCliente);
            cedulaInfo.add('nuevo');
        }
        
        return cedulaInfo;
    }

    // @AuraEnabled
    // public static Map<String, String> getImagenes(String familia, String marca){
    //     List<Product2> lstProds = new List<Product2>();
    //     if(marca == 'Motorrad'){
    //         lstProds = [SELECT Modelo_De_Inter_s__c FROM Product2 WHERE Grupo__c = :familia AND walking_product__c = true AND Marca__c IN ('Motorrad','Kawasaki','Polaris','Indian')];
    //     }else{
    //         lstProds = [SELECT Modelo_De_Inter_s__c FROM Product2 WHERE Grupo__c = :familia AND walking_product__c = true AND Marca__c = :marca];
    //     } 
        
        

    //     List<String> listLeadMDI = new List<String>();
    //     List<Document> listDoc = new List<Document>();
    //     Map<String, String> lstIds = new Map<String, String>();
        
    //     for(Product2 prod : lstProds){            
    //         listLeadMDI.add(prod.Modelo_De_Inter_s__c.substringBefore(' ').trim());
    //     }

    //     if(!listLeadMDI.isEmpty() && listLeadMDI.size() > 0){
    //         listDoc = [SELECT Name, Id, DeveloperName FROM Document WHERE Type = 'png'];
    //         System.debug(' ** LISTA FT ** ' + listDoc);
    //         if(!listDoc.isEmpty() && listDoc.size() > 0){
    //             for(String str : listLeadMDI){
    //                 for(Document d : listDoc){
    //                     if(d.DeveloperName.contains(str) || d.Name.contains(str)){
    //                         lstIds.put(str, d.Id);
    //                     }                                      
    //                 }
    //             }
    //         }
    //     }

    //     return lstIds;
    // }

    @AuraEnabled
    public static Map<String, String> getImagenes(String familia, String marca) {
        List<Product2> lstProds = [SELECT Modelo_De_Inter_s__c 
                                FROM Product2 
                                WHERE Grupo__c = :familia 
                                AND walking_product__c = true 
                                AND Marca__c = :marca]; // Filtro único por marca
        
        List<String> listLeadMDI = new List<String>();
        Map<String, String> lstIds = new Map<String, String>();
        
        // Procesar modelos de interés
        for(Product2 prod : lstProds) {            
            if(String.isNotBlank(prod.Modelo_De_Inter_s__c)) {
                listLeadMDI.add(prod.Modelo_De_Inter_s__c.substringBefore(' ').trim());
            }
        }

        // Buscar documentos relacionados
        if(!listLeadMDI.isEmpty()) {
            List<Document> listDoc = [SELECT Name, Id, DeveloperName 
                                    FROM Document 
                                    WHERE Type = 'png'];
            
            for(Document d : listDoc) {
                for(String str : listLeadMDI) {
                    if(d.DeveloperName.contains(str) || d.Name.contains(str)) {
                        lstIds.put(str, d.Id);
                        break; // Salir del loop interno al encontrar coincidencia
                    }                                      
                }
            }
        }

        return lstIds;
    }

    @AuraEnabled
    public static void createTraficoUsados(String nombre, String apellido, String correo, String telefono, String tiempoAprox, String cedula, String sucursal, String otroMedio, String tipoVehiculo) {        
        String traficoId = null;
        String oppId = null;
        String idClienteJuridico = '';
        String idOpportunity = '';
    
        idClienteJuridico = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Autos Usados').getRecordTypeId();    
        idOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Autos usados').getRecordTypeId();   
    
        Date today = Date.today();
        Date sixMonthsBefore = today.addMonths(-6);
        Date twoMonthsBefore = today.addMonths(-2);
    
        // 1. Buscar oportunidades por cédula
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<Lead> lstLeads = new List<Lead> ();
        lstOpp = [SELECT Id, CreatedDate FROM Opportunity WHERE Cedula_formula__c = :cedula AND StageName != 'Cerrada Ganada' AND StageName != 'Cerrada Perdida' AND recordTypeId = :idOpportunity order by CreatedDate desc];
        lstLeads = [SELECT id, CreatedDate FROM Lead WHERE FirstName = :nombre AND LastName = :apellido AND Email = :correo AND recordTypeId = :idClienteJuridico AND Convertido_custom__c = false];


        // 2. Buscar leads por cédula (posible tráfico existente)
    
        // Revisar si hay oportunidades
        if (!lstOpp.isEmpty()) {
            Opportunity opp = lstOpp[0]; // Tomamos la primera oportunidad si existe
            
            if (opp.CreatedDate >= twoMonthsBefore) {
                // Oportunidad reciente (menos de 2 meses) - Solo agregar actividad de walking
                addWalkingActivity(opp.Id, null);
                oppId = opp.Id;
            } else if (opp.CreatedDate < sixMonthsBefore) {
                // Oportunidad vieja (más de 6 meses) - Crear tráfico y agregar actividad de walking
                traficoId = crearActualizarTraficoUsados(nombre, apellido, correo, telefono, tiempoAprox, cedula, sucursal, otroMedio, tipoVehiculo, idClienteJuridico);
                addWalkingActivity(opp.Id, null); // Agregar actividad de walking a la oportunidad
                oppId = opp.Id;
            } else {
                // Oportunidad entre 2 y 6 meses - No agregar actividad de walking
                // Pero se debe manejar el tráfico si es necesario
                if (traficoId == null && lstLeads.isEmpty()) {
                    traficoId = crearActualizarTraficoUsados(nombre, apellido, correo, telefono, tiempoAprox, cedula, sucursal, otroMedio, tipoVehiculo, idClienteJuridico);
                } else {
                    Lead lead = lstLeads[0];
                    if (lead.CreatedDate < sixMonthsBefore) {
                        traficoId = crearActualizarTraficoUsados(nombre, apellido, correo, telefono, tiempoAprox, cedula, sucursal, otroMedio, tipoVehiculo, idClienteJuridico);
                    }else{
                        traficoId = lead.Id;
                        traficoId = crearActualizarTraficoUsados(nombre, apellido, correo, telefono, tiempoAprox, cedula, sucursal, otroMedio, tipoVehiculo, idClienteJuridico);
                    }
                }
            }
        } else {
            // Regla 4: Sin oportunidad y sin tráfico - Crear tráfico nuevo
            if (lstLeads.isEmpty()) {
                traficoId = crearActualizarTraficoUsados(nombre, apellido, correo, telefono, tiempoAprox, cedula, sucursal, otroMedio, tipoVehiculo, idClienteJuridico);
            } else {
                // Regla 5: Con tráfico y sin oportunidad
                Lead lead = lstLeads[0];
                if (lead.CreatedDate < sixMonthsBefore) {
                    // Tráfico mayor a 6 meses - Crear tráfico nuevo
                    traficoId = crearActualizarTraficoUsados(nombre, apellido, correo, telefono, tiempoAprox, cedula, sucursal, otroMedio, tipoVehiculo, idClienteJuridico);
                } else {
                    // Tráfico menor a 6 meses - Actualizar tráfico
                    traficoId = lead.Id;
                }
            }
        }
        List<User> lstUser = [Select Id From User Where Name like '%Login%' OR Name like '%Admin%'];
        //familia, modelo, marca
        // Crear registro walk-in
        Registro_WalkIn__c nuevoRegistro = new Registro_WalkIn__c();
        nuevoRegistro.Nombre__c = nombre + ' ' + apellido;
        nuevoRegistro.Correo__c = correo;

        nuevoRegistro.peticion__c = 
        'nombre: ' + nombre + '\n' +
        'apellido: ' + apellido + '\n' +
        'correo: ' + correo + '\n' +
        'telefono: ' + telefono + '\n' +
        'tiempoAprox: ' + tiempoAprox + '\n' +
        'cedula: ' + cedula + '\n' +
        'sucursal: ' + sucursal + '\n' +
        'otroMedio: ' + otroMedio + '\n' +
        'tipoVehiculo: ' + tipoVehiculo + '\n' +
        'idClienteJuridico: ' + idClienteJuridico;

        nuevoRegistro.Descripcion__c = '';        
        nuevoRegistro.OwnerId = lstUser[0].id;
        nuevoRegistro.Modelo_Walking__c = tipoVehiculo;
        nuevoRegistro.Trafico__c = traficoId;
        nuevoRegistro.Opportunity__c = oppId;
    
        if(traficoId == null){
            traficoId = [SELECT id FROM Lead WHERE FirstName = :nombre AND LastName = :apellido AND Email = :correo AND recordTypeId =:idClienteJuridico LIMIT 1].id;
            if(traficoId != null){
                nuevoRegistro.Trafico__c = traficoId;
            }
        }

        insert nuevoRegistro;
        System.debug('Registro WalkIn creado exitosamente: ' + nuevoRegistro.Id);
        System.debug('=== FINALIZANDO createTraficoUsados EXITOSAMENTE ===');
    }

    private static String crearActualizarTraficoUsados(String nombre, String apellido, String correo, String telefono, String tiempoAprox, String cedula, String sucursal, String otroMedio, String tipoVehiculo, String recordTypeId) {
        // Buscar tráfico existente (Lead) usando la cédula y la marca IN ('Motorrad','Kawasaki','Polaris','Indian')
        System.debug('=== INICIANDO crearActualizarTraficoUsados ===');
        System.debug('Parámetros: nombre=' + nombre + ', apellido=' + apellido + ', cedula=' + cedula + ', tipoVehiculo=' + tipoVehiculo);

        List<Lead> existingTraffic = new  List<Lead>();
        String idClienteJuridico = '';

        existingTraffic = [SELECT Id, CreatedDate FROM Lead WHERE (Numero_de_Identificacion_del__c = :cedula OR Email =: correo ) AND Tipo_Vehiculo_Usados__c = :tipoVehiculo ORDER BY CreatedDate DESC LIMIT 1];

        Lead traffic;
        if(otroMedio == 'si'){
            otroMedio = 'Online';
        }else{
            otroMedio = 'Orgánico';
        }
        
        // Si existe un tráfico y es reciente (menos de 6 meses), lo actualizamos
        if (!existingTraffic.isEmpty() && existingTraffic[0].CreatedDate >= Date.today().addMonths(-6)) {
            traffic = existingTraffic[0]; // Usamos el tráfico existente
            traffic.FirstName = nombre;
            traffic.Action__c = otroMedio;
            traffic.LastName = apellido;
            traffic.Email = correo;
            traffic.MobilePhone = telefono;
            traffic.Phone = telefono;
            traffic.FechaPosibleCompra__c = tiempoAprox;
            traffic.Tipo_Vehiculo_Usados__c = tipoVehiculo;
            traffic.Sucursal__c = 'Uruca';
            update traffic; // Actualizamos el tráfico existente
            System.debug('Tráfico actualizado exitosamente: ' + traffic.Id);
        } else {
            // Si no existe tráfico o es más antiguo de 6 meses, creamos uno nuevo
            traffic = new Lead();

            traffic.RecordTypeId = recordTypeId;

            traffic.FirstName = nombre;
            traffic.LastName = apellido;
            traffic.Email = correo;
            traffic.Action__c = otroMedio;
            traffic.LeadSource = 'Walking Usados';
            traffic.MobilePhone = telefono;
            traffic.Phone = telefono;
            traffic.Campana__c = '7010P0000010QZCQA2';
            // traffic.Campana__c = '701O800002U0ybSIAR';
            traffic.FechaPosibleCompra__c = tiempoAprox;            
            traffic.Origen_1__c = 'Walking Usados';
            traffic.Tipo_de_Identificaci_n__c = '01';
            traffic.Numero_de_Identificacion_del__c = cedula;
            traffic.Sucursal__c = 'Uruca'; 
            traffic.Tipo_Vehiculo_Usados__c = tipoVehiculo;

            insert traffic; // Insertamos el nuevo tráfico
            System.debug('Nuevo tráfico creado exitosamente: ' + traffic.Id);

        }
        System.debug('=== FINALIZANDO crearActualizarTraficoUsados ===');
        return traffic.Id; // Retornamos el Id del tráfico creado o actualizado
    }

    @AuraEnabled
    public static void createTrafico(String nombre, String apellido, String correo, String telefono, String tiempoAprox, String familia, String modelo, String marca, String cedula, String sucursal, String otroMedio) {        
         System.debug('=== Entrando a  createTrafico ===');
        String traficoId = null;
        String oppId = null;
        String idClienteJuridico = '';
        String idClienteJuridicoKa = '';
        String idClienteJuridicoPo = '';
        String idClienteJuridicoIn = '';
        String idOpportunity = '';
        String idOpportunityKa = '';
        String idOpportunityPo = '';
        String idOpportunityIn = '';

        System.debug('=== marca ===');
        System.debug(marca);
    
        // Establecer el RecordType basado en la marca ('Motorrad','Kawasaki','Polaris','Indian')
        if(marca == 'BMW'){
            idClienteJuridico = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BMW').getRecordTypeId();    
            idOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();    
        } else if(marca == 'MINI'){
            idClienteJuridico = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('MINI').getRecordTypeId();
            idOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MINI').getRecordTypeId();    
        } else if(marca == 'Motorrad' || marca == 'Kawasaki' || marca == 'Polaris' || marca == 'Indian'){
            idClienteJuridico = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Motorrad').getRecordTypeId();
            idOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Motorrad').getRecordTypeId();

            idClienteJuridicoKa = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Kawasaki').getRecordTypeId();
            idOpportunityKa = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Kawasaki').getRecordTypeId();

            idClienteJuridicoPo = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Polaris').getRecordTypeId();   
            idOpportunityPo = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Polaris').getRecordTypeId();

            idClienteJuridicoIn = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Indian').getRecordTypeId();
            idOpportunityIn = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Indian').getRecordTypeId(); 
        }
    
        System.debug('=== idOpportunity ===');
        System.debug(idOpportunity);

        System.debug('=== idClienteJuridico ===');
        System.debug(idClienteJuridico);
        

        Date today = Date.today();
        Date sixMonthsBefore = today.addMonths(-6);
        Date twoMonthsBefore = today.addMonths(-2);
        System.debug('=== Datos ===');
        System.debug(nombre);
        System.debug(apellido);
        System.debug(correo);
        System.debug(idClienteJuridico);
        System.debug(cedula);        
        System.debug(idOpportunity);
        
        // 1. Buscar oportunidades por cédula
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<Lead> lstLeads = new List<Lead> ();
        if(marca == 'Motorrad' || marca == 'Kawasaki' || marca == 'Polaris' || marca == 'Indian'){
            lstOpp = [SELECT Id, CreatedDate FROM Opportunity WHERE Cedula_formula__c = :cedula AND StageName != 'Cerrada Ganada' AND StageName != 'Cerrada Perdida' AND (recordTypeId = :idOpportunity Or recordTypeId = :idOpportunityKa Or recordTypeId = :idOpportunityPo Or recordTypeId = :idOpportunityIn ) order by CreatedDate desc];
            lstLeads = [SELECT id, CreatedDate FROM Lead WHERE FirstName = :nombre AND LastName = :apellido AND Email = :correo AND (recordTypeId = :idClienteJuridico Or recordTypeId = :idClienteJuridicoKa Or recordTypeId = :idClienteJuridicoPo Or recordTypeId = :idClienteJuridicoIn ) AND Convertido_custom__c = false ];
        }else{
            lstOpp = [SELECT Id, CreatedDate FROM Opportunity WHERE Cedula_formula__c = :cedula AND StageName != 'Cerrada Ganada' AND StageName != 'Cerrada Perdida' AND recordTypeId = :idOpportunity order by CreatedDate desc];
            lstLeads = [SELECT id, CreatedDate FROM Lead WHERE FirstName = :nombre AND LastName = :apellido AND Email = :correo AND recordTypeId = :idClienteJuridico AND Convertido_custom__c = false];
        }

        System.debug('=== lstOpp ===');
        System.debug(lstOpp);
        System.debug('=== lstLeads ===');
        System.debug(lstLeads);
        // 2. Buscar leads por cédula (posible tráfico existente)
        
    
        // Revisar si hay oportunidades
        if (!lstOpp.isEmpty()) {
            Opportunity opp = lstOpp[0]; // Tomamos la primera oportunidad si existe
            
            if (opp.CreatedDate >= twoMonthsBefore) {
                // Oportunidad reciente (menos de 2 meses) - Solo agregar actividad de walking
                addWalkingActivity(opp.Id, null);
                oppId = opp.Id;
            } else if (opp.CreatedDate < sixMonthsBefore) {
                // Oportunidad vieja (más de 6 meses) - Crear tráfico y agregar actividad de walking
                traficoId = createOrUpdateTraffic(nombre, apellido, correo, telefono, tiempoAprox, familia, modelo, marca, cedula, sucursal, otroMedio, idClienteJuridico);
                addWalkingActivity(opp.Id, null); // Agregar actividad de walking a la oportunidad
                oppId = opp.Id;
            } else {
                // Oportunidad entre 2 y 6 meses - No agregar actividad de walking
                // Pero se debe manejar el tráfico si es necesario
                if (traficoId == null && lstLeads.isEmpty()) {
                    traficoId = createOrUpdateTraffic(nombre, apellido, correo, telefono, tiempoAprox, familia, modelo, marca, cedula, sucursal, otroMedio, idClienteJuridico);
                } else {
                    Lead lead = lstLeads[0];
                    if (lead.CreatedDate < sixMonthsBefore) {
                        traficoId = createOrUpdateTraffic(nombre, apellido, correo, telefono, tiempoAprox, familia, modelo, marca, cedula, sucursal, otroMedio, idClienteJuridico);
                    }else{
                        traficoId = lead.Id;
                        traficoId = createOrUpdateTraffic(nombre, apellido, correo, telefono, tiempoAprox, familia, modelo, marca, cedula, sucursal, otroMedio, idClienteJuridico);
                    }
                }
            }
        } else {
            // Regla 4: Sin oportunidad y sin tráfico - Crear tráfico nuevo
            if (lstLeads.isEmpty()) {
                traficoId = createOrUpdateTraffic(nombre, apellido, correo, telefono, tiempoAprox, familia, modelo, marca, cedula, sucursal, otroMedio, idClienteJuridico);
            } else {
                // Regla 5: Con tráfico y sin oportunidad
                Lead lead = lstLeads[0];
                if (lead.CreatedDate < sixMonthsBefore) {
                    // Tráfico mayor a 6 meses - Crear tráfico nuevo
                    traficoId = createOrUpdateTraffic(nombre, apellido, correo, telefono, tiempoAprox, familia, modelo, marca, cedula, sucursal, otroMedio, idClienteJuridico);
                } else {
                    // Tráfico menor a 6 meses - Actualizar tráfico
                    traficoId = lead.Id;
                }
            }
        }
        System.debug('=== datos finales ===');
        System.debug(traficoId);
        System.debug(oppId);
        List<User> lstUser = [Select Id From User Where Name like '%Login%'];
        //familia, modelo, marca
        // Crear registro walk-in
        Registro_WalkIn__c nuevoRegistro = new Registro_WalkIn__c();
        nuevoRegistro.Descripcion__c = '';
        nuevoRegistro.Nombre__c = nombre + ' ' + apellido;

        nuevoRegistro.peticion__c = 
        'nombre: ' + nombre + '\n' +
        'apellido: ' + apellido + '\n' +
        'correo: ' + correo + '\n' +
        'telefono: ' + telefono + '\n' +
        'tiempoAprox: ' + tiempoAprox + '\n' +
        'cedula: ' + cedula + '\n' +
        'sucursal: ' + sucursal + '\n' +
        'otroMedio: ' + otroMedio + '\n' +
        'modelo: ' + modelo + '\n' +
        'marca: ' + marca + '\n' +
        'idClienteJuridico: ' + idClienteJuridico;

        nuevoRegistro.Correo__c = correo;
        nuevoRegistro.Trafico__c = traficoId;
        nuevoRegistro.OwnerId = lstUser[0].id;
        nuevoRegistro.Modelo_Walking__c = modelo;
        nuevoRegistro.Marca_Walking__c = marca;
        nuevoRegistro.Familia_Walking__c = familia;
        //nuevoRegistro.CreatedById = lstUser[0].id;
        nuevoRegistro.Opportunity__c = oppId;
        insert nuevoRegistro;
        System.debug(nuevoRegistro.id);
    }
    
    @AuraEnabled
    public static void createOportunidad(String leadId) {
        walkingCommunityControllerBase.createOportunidad(leadId);
    }

    // Método auxiliar para obtener el LeadStatus de conversión
    private static String getConvertedStatus() {
        LeadStatus convertedStatus = [
            SELECT MasterLabel 
            FROM LeadStatus 
            WHERE IsConverted = true 
            LIMIT 1
        ];
        return convertedStatus.MasterLabel;
    }
    
    // Método para crear o actualizar tráfico
    private static String createOrUpdateTraffic(String nombre, String apellido, String correo, String telefono, String tiempoAprox, String familia, String modelo, String marca, String cedula, String sucursal, String otroMedio, String recordTypeId) {
        // Buscar tráfico existente (Lead) usando la cédula y la marca IN ('Motorrad','Kawasaki','Polaris','Indian')
        List<Lead> existingTraffic = new  List<Lead>();
        String idClienteJuridico = '';
        String idClienteJuridicoKa = '';
        String idClienteJuridicoPo = '';
        String idClienteJuridicoIn = '';
        if(marca == 'Motorrad'){            
            idClienteJuridico = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Motorrad').getRecordTypeId();                                
            existingTraffic = [SELECT Id, CreatedDate FROM Lead WHERE (Numero_de_Identificacion_del__c = :cedula OR Email =: correo ) AND Marca__c IN ('Motorrad','Kawasaki','Polaris','Indian') ORDER BY CreatedDate DESC LIMIT 1];
        }else if(marca == 'Kawasaki'){
            idClienteJuridicoKa = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Kawasaki').getRecordTypeId();
            existingTraffic = [SELECT Id, CreatedDate FROM Lead WHERE (Numero_de_Identificacion_del__c = :cedula OR Email =: correo ) AND Marca__c IN ('Motorrad','Kawasaki','Polaris','Indian') ORDER BY CreatedDate DESC LIMIT 1];
        }else if(marca == 'Polaris'){
            idClienteJuridicoPo = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Polaris').getRecordTypeId();   
            existingTraffic = [SELECT Id, CreatedDate FROM Lead WHERE (Numero_de_Identificacion_del__c = :cedula OR Email =: correo ) AND Marca__c IN ('Motorrad','Kawasaki','Polaris','Indian') ORDER BY CreatedDate DESC LIMIT 1];         
        }else if(marca == 'Indian'){
            idClienteJuridicoIn = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Indian').getRecordTypeId();
            existingTraffic = [SELECT Id, CreatedDate FROM Lead WHERE (Numero_de_Identificacion_del__c = :cedula OR Email =: correo ) AND Marca__c IN ('Motorrad','Kawasaki','Polaris','Indian') ORDER BY CreatedDate DESC LIMIT 1];                                                        
        }else{
            existingTraffic = [SELECT Id, CreatedDate FROM Lead WHERE (Numero_de_Identificacion_del__c = :cedula OR Email =: correo ) AND Marca__c = :marca ORDER BY CreatedDate DESC LIMIT 1];
        }


        
        
        Lead traffic;
        if(otroMedio == 'si'){
            otroMedio = 'Online';
        }else{
            otroMedio = 'Orgánico';
        }
        
        // Si existe un tráfico y es reciente (menos de 6 meses), lo actualizamos
        if (!existingTraffic.isEmpty() && existingTraffic[0].CreatedDate >= Date.today().addMonths(-6)) {
            traffic = existingTraffic[0]; // Usamos el tráfico existente
            traffic.FirstName = nombre;
            traffic.Action__c = otroMedio;
            traffic.LastName = apellido;
            traffic.Email = correo;
            traffic.MobilePhone = telefono;
            traffic.Phone = telefono;
            traffic.FechaPosibleCompra__c = tiempoAprox;
            traffic.Familia1__c = familia;
            traffic.Modelo_De_Inter_s1__c = modelo;
            if (sucursal != null && sucursal != '' && sucursal != 'undefined') {
                traffic.Sucursal__c = sucursal;
            }
            update traffic; // Actualizamos el tráfico existente
        } else {
            // Si no existe tráfico o es más antiguo de 6 meses, creamos uno nuevo
            traffic = new Lead();

            traffic.RecordTypeId = recordTypeId;
            traffic.Marca__c = marca;

            traffic.FirstName = nombre;
            traffic.LastName = apellido;
            traffic.Email = correo;
            traffic.Action__c = otroMedio;
            traffic.LeadSource = 'Walking';
            traffic.MobilePhone = telefono;
            traffic.Phone = telefono;
            traffic.Ano1__c = '2024';
            traffic.Campana__c = '7010P0000010QZCQA2';
            traffic.FechaPosibleCompra__c = tiempoAprox;            
            traffic.Familia1__c = familia;            
            traffic.Modelo_De_Inter_s1__c = modelo;
            traffic.Origen_1__c = 'Walking';
            traffic.Tipo_de_Identificaci_n__c = '01';
            traffic.Numero_de_Identificacion_del__c = cedula;
            if (sucursal != null && sucursal != '' && sucursal != 'undefined') {
                traffic.Sucursal__c = sucursal;
            }

            if(marca == 'Motorrad'){            
                traffic.RecordTypeId = idClienteJuridico;
                
            }else if(marca == 'Kawasaki'){
                 traffic.RecordTypeId = idClienteJuridicoKa;
                
            }else if(marca == 'Polaris'){
                traffic.RecordTypeId = idClienteJuridicoPo;
                
            }else if(marca == 'Indian'){
                traffic.RecordTypeId = idClienteJuridicoIn;
            }


            try {
                insert traffic; // Insertamos el nuevo tráfico
            } catch (Exception e) {              
                 System.debug(e);                       
            }
            
        }
        
        return traffic.Id; // Retornamos el Id del tráfico creado o actualizado
    }
    
    // Método para agregar actividad de walking
    private static void addWalkingActivity(Id oppId, Id whoId) {

        

        List<User> lstUser = [Select Id From User Where Name like '%Login%'];

        Task nuevaTarea = new Task();
        nuevaTarea.Subject = 'Walking';
        nuevaTarea.ActivityDate = Date.today();
        nuevaTarea.Priority = 'Normal';
        nuevaTarea.Status = 'Open';
        nuevaTarea.WhatId = oppId;
        nuevaTarea.OwnerId = lstUser[0].id;
        nuevaTarea.WhoId = whoId;
        insert nuevaTarea;
    }
    

    public class MyPickListInfo {
         public String validFor;
    }

    @AuraEnabled
    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField){
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for(Schema.PicklistEntry currControllingValue : controllingValues){
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }

        for(Schema.PicklistEntry currDependentValue : dependentValues){
            String jsonString = JSON.serialize(currDependentValue);
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;
            for(Integer curr : hexString.getChars()){
                Integer val = 0;
                if(curr >= 65) val = curr - 65 + 10;
                else val = curr - 48;
                if((val & 8) == 8) controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                if((val & 4) == 4) controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());
                if((val & 2) == 2) controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());
                if((val & 1) == 1) controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());
                baseCount += 4;
            }
        }

        return controllingInfo;
    }



    @AuraEnabled
    public static List<Cita_trafico_online__c> buscarCitaPorCedula(String cedula) {
        return walkingCommunityControllerBase.buscarCitaPorCedula(cedula);
    }

    @AuraEnabled
    public static void marcarAsistenciaCita(String citaId) {
        Cita_trafico_online__c citaSel = [
            SELECT Id, Name, Status__c,OwnerId
            FROM Cita_trafico_online__c
            WHERE Id = :citaId
            LIMIT 1
        ];
        
        citaSel.Status__c = 'Asistió';
        update citaSel;
        
        List<Lead> lstLeadOriginal = [
            SELECT Id
            FROM Lead 
            WHERE Cita_trafico_online__c = :citaSel.Id
        ];

        if (!lstLeadOriginal.isEmpty()) {
            walkingCommunityController.createOportunidad(
                lstLeadOriginal[0].Id                
            );
        }
       
    }


}
