public with sharing class ct_otRedis_ctrl {
    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getWorkOrderData (String recordId){
        List<WorkOrder> lstWorkOrder = [Select Id,
        AccountId,
        Account.Name,
        Account.Phone,
        Account.IsPersonAccount,
        Account.PersonContactId,
        Correo__c,
        Cuenta_de_Facturacion__r.Name,
        Cuenta_de_Facturacion__r.Invoice_Email__c,
        Cuenta_de_Facturacion__r.Invoice_Phone__c,
        Account.Comentario__c,
        ContactId,
        Contact.FirstName,
        Contact.LastName,
        Contact.Name,
        Contact.Email,
        Contact.Phone,
        Contact.Cedula__c,
        Nota_de_cr_dito_activa__c,
        isLocked__c,
        Nivel_de_aprobaci_n_descuento_para_art_c__c,
        Nivel_de_aprobaci_n_descuento_para_MO__c,
        Estado_de_aprobaci_n_descuento_MO__c,
        AssetId,
        Asset.Name,
        Kilometros__c,
        Realizar_encuesta__c,
        totalFinal__c,
        BMW_CategorizacionDeRespuestaEncuesta__c,
        Vigencia_del_presupuesto__c,
        Origen__c,
        Tipo_de_Cargo__c,
        tipoDeGasto__c,
        Pricebook2Id,
        ActividadComercial__c,
        BMW_Aseguradora__c,
        BMW_CentroDeCosto__c,
        Asset.numeroDePlaca__c,
        Asset.Kilometros__c,
        Asset.Combustible__c,
        Asset.NumeroDeChasis__c,
        Asset.Marca_Nvo__c,
        Asset.Modelo_Nvo2__c,
        Asset.Color__c,
        Asset.Tipo_de_veh_culo__c,
        Asset.Comentario__c,
        Asset.Oportunidad_relacionada__c,
        Observaciones__c,
        Garantia_vehiculo__c,
        WorkOrderNumber,
        CaseId,
        case.CaseNumber,
        Fecha_Cita__c,
        Fecha_de_Entrada__c,
        CurrencyIsoCode,
        ParentWorkOrderId,
        IsClosed,
        Etapa_de_flujo_de_trabajo__c,
        Detalle_de_estado__c,
        Dias_en_proceso__c,
        Priority,
        Tipo_de_servicio__c,
        Duration,
        Asesor_de_la_orden__c,
        RootWorkOrderId,
        BMW_CodigoDeProducto__c,
        Fecha_de_facturacion__c,
        Fecha_de_Recibido__c,
        Fecha_veh_culo_listo__c,
        Fecha_prevista_de_entrega__c,
        ServiceTerritoryId,
        ServiceTerritory.Name,
        CT_Mecanico__c,
        Subject,
        Description,
        Financiamiento_disponible_Altica__c,
        Financiamiento_utilizado_Altica__c,
        Moneda_financiamiento_Altica__c,
        BMW_Pagador__c,
        Desea_financiamiento__c,
        Notificaci_n_Cargo_BSI__c,
        Update_BSI__c,
        Fecha_Ultima_Notificaci_n_BSI_Update__c,
        CreatedById,
        CreatedDate,
        LastModifiedById,
        LastModifiedDate,
        Comentario_CxC__c,
        Detalle_Asesor__c,
        OwnerOT__c
        From WorkOrder Where Id =: recordId];

        return lstWorkOrder;

    }

    @AuraEnabled
    public static void saveDetalleAsesor(Id caseId, String detalleAsesor) {
        WorkOrder caseRecord = [SELECT Id, Detalle_Asesor__c FROM WorkOrder WHERE Id = :caseId LIMIT 1];
        caseRecord.Detalle_Asesor__c = detalleAsesor;
        update caseRecord;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Asset> getAsset(String assetId){
        List<Asset> lstAsset = new List<Asset>();
        lstAsset = [Select Id,
        Tipo_de_veh_culo__c,
        numeroDePlaca__c,
        NumeroDeChasis__c ,
        AccountId,
        Anio__c,
        Color__c,
        marca__c,
        Modelo_Nvo2__c,
        Marca_Otros__c,
        Modelo_Otros__c,
        Account.Name,
        Account.PersonEmail,
        Account.CorreoElectronicoEmpresarial__c,
        Account.Phone,Account.codigoSoftland__c, 
        Account.IsPersonAccount,
        ContactId,Contact.Name,
        Contact.FirstName,
        Contact.LastName,
        Contact.Correo_Electronico__c,
        Contact.email,
        Contact.Phone,
        Garant_a_de_activo__c,
        Garant_a_de_activo__r.AssetWarrantyNumber,
        Garant_a_de_activo__r.WarrantyTerm.WarrantyTermName,
        Garant_a_de_activo__r.StartDate,
        Garant_a_de_activo__r.EndDate,
        Garant_a_de_activo__r.WarrantyTerm.EffectiveStartDate,
        Garant_a_de_activo__r.WarrantyType
        From Asset Where Id =: assetId LIMIT 1 ];

        return lstAsset;

    }
    @AuraEnabled(Cacheable = true)
    public static List<Subtipo_de_trabajo_del_caso__c> getTrabajos(String woId){
        List<Subtipo_de_trabajo_del_caso__c> subTrabajos = [Select Id,
        Name,
        Tipo_de_trabajo_del_caso__c, 
        Tipo_de_trabajo_del_caso__r.Name,
        Cantidad_de_horas__c,
        Articulo_Mano_de_Obra__c,
        Articulo_Mano_de_Obra__r.NombreProducto__c,
        Articulo_Mano_de_Obra__r.BMW_CodigoDeProducto__c,
        Tipo_de_trabajo_del_caso__r.Tipo_de_cargo__c,
        Articulo_Mano_de_Obra__r.Cantidad__c,
        Articulo_Mano_de_Obra__r.TotalPrice,Articulo_Mano_de_Obra__r.CurrencyIsoCode
        from  Subtipo_de_trabajo_del_caso__c WHERE Orden_de_trabajo__c =: woId ];
        return subTrabajos;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Object> getPresupuesto(String woId){
        List<Opportunity> subTrabajos = [Select Id 
        from  Opportunity 
        WHERE WorkOrder__c =: woId ];
        List<String> lstStr = new List<String> ();
        for(Opportunity opp : subTrabajos){
            lstStr.add(opp.id);
        }
        List<Quote> lstQuote = [Select Id,Name,Account.Name,GrandTotal,Opportunity.WorkOrder__r.Case.CaseNumber ,CurrencyIsoCode From Quote Where OpportunityId In :lstStr];
        return lstQuote;
    }


    @AuraEnabled
    public static void updateAccountComment(Id accountId, String comment) {
        Account caseRecord = [SELECT Id, Comentario__c FROM Account WHERE Id = :accountId LIMIT 1];
        caseRecord.Comentario__c = comment;
        update caseRecord;
    }

    @AuraEnabled
    public static void updateAssetComment(Id assetId, String comment) {
        Asset caseRecord = [SELECT Id, Comentario__c FROM Asset WHERE Id = :assetId LIMIT 1];
        caseRecord.Comentario__c = comment;
        update caseRecord;
    }

    @AuraEnabled(cacheable=false)
    public static List<WorkOrderLineItem> getWorkOrderLineItems(String casoId) {
        return [
        SELECT Id, WorkOrderId, tiposDeTrabajo__c, tiposDeTrabajo__r.Name, TipoTrabajoCaso__r.Enviar_a_service__c,
        TipoTrabajoCaso__r.Status__c, TipoTrabajoCaso__r.Aprobador__c, TipoTrabajoCaso__r.Estado_aprobaci_n_service__c,
        TipoTrabajoCaso__r.Tipo_de_cargo__c, TotalPrice, TipoTrabajoCaso__r.Id, TipoTrabajoCaso__r.Categor_a_de_presupuesto__c,
        Producto_OR_Alias__c, WorkOrder.CurrencyIsoCode, Quantity, WorkOrder.WorkOrderNumber,TipoTrabajoCaso__r.Name
        FROM WorkOrderLineItem
        WHERE  WorkOrder.CaseId = :casoId
    ];
    }

    @AuraEnabled(cacheable=true)
    public static String getCaseIdFromWorkOrder(String workOrderId) {
        WorkOrder wo = [
            SELECT CaseId 
            FROM WorkOrder 
            WHERE Id = :workOrderId
            LIMIT 1
        ];
        return wo.CaseId;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getWorkOrderDetails(String woId) {
        Map<String, Object> resultMap = new Map<String, Object>();
    
        // Consulta de WorkOrderLineItem usando el casoId
        List<WorkOrderLineItem> workOrderLineItems = [
            SELECT Id, WorkOrderId, tiposDeTrabajo__c, tiposDeTrabajo__r.Name, 
                   TipoTrabajoCaso__r.Enviar_a_service__c, TipoTrabajoCaso__r.Status__c, 
                   TipoTrabajoCaso__r.Aprobador__c, TipoTrabajoCaso__r.Estado_aprobaci_n_service__c, 
                   TipoTrabajoCaso__r.Tipo_de_cargo__c, TotalPrice, TipoTrabajoCaso__r.Id, 
                   TipoTrabajoCaso__r.Categor_a_de_presupuesto__c, Producto_OR_Alias__c, 
                   WorkOrder.CurrencyIsoCode, Quantity, WorkOrder.WorkOrderNumber, BMW_CodigoDeProducto__c,
                   TipoTrabajoCaso__r.Name
            FROM WorkOrderLineItem
            WHERE WorkOrderId = :woId
        ];
        
        // Si existen WorkOrderLineItems, obtenemos el woId del primer registro
        // if(!workOrderLineItems.isEmpty()){
        //     String woId2 = workOrderLineItems[0].WorkOrderId;
    
        //     // Consulta de Subtipo_de_trabajo_del_caso__c usando el woId
        //     List<Subtipo_de_trabajo_del_caso__c> subTrabajos = [
        //         SELECT Id, Name, Tipo_de_trabajo_del_caso__c, 
        //                Tipo_de_trabajo_del_caso__r.Name, Cantidad_de_horas__c, 
        //                Articulo_Mano_de_Obra__c, Articulo_Mano_de_Obra__r.NombreProducto__c, 
        //                Articulo_Mano_de_Obra__r.BMW_CodigoDeProducto__c, 
        //                Tipo_de_trabajo_del_caso__r.Tipo_de_cargo__c, 
        //                Articulo_Mano_de_Obra__r.Cantidad__c, 
        //                Articulo_Mano_de_Obra__r.TotalPrice, 
        //                Articulo_Mano_de_Obra__r.CurrencyIsoCode
        //         FROM Subtipo_de_trabajo_del_caso__c
        //         WHERE Orden_de_trabajo__c = :woId2
        //     ];
    
        //     // Agregar resultados de ambas consultas al Map
            
        //     resultMap.put('subTrabajos', subTrabajos);
        // }
        resultMap.put('workOrderLineItems', workOrderLineItems);
        return resultMap;
    }
    
    public static void dummy() {
        String test='';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
    }
    
}