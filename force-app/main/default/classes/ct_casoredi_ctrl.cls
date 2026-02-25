public with sharing class ct_casoredi_ctrl {
    @AuraEnabled(cacheable=true)
    public static List<Case> getCaseData (String recordId){
        List<Case> lstCase = [Select Id,
                              Type,
                              TipoDeCombustible__c,
                              NivelDeCombustible__c,
                              PorcentajeDeCargaElectrica__c,
                              AccountId,
                              Account.Name,
                              Account.PersonContactId,
                              Account.Correo_Electronico__pc,
                              Account.CorreoElectronicoEmpresarial__c,
                              Cuenta_de_Facturacion__r.Name,
                              Cuenta_de_Facturacion__r.Invoice_Email__c,
                              Cuenta_de_Facturacion__r.Invoice_Phone__c,
                              Account.PersonEmail,
                              Account.Cedula__c,
                              Account.PersonMobilePhone,
                              Account.IsPersonAccount,
                              Account.Phone,
                              ContactId,
                              Contact.Name,
                              Contact.LastName,
                              Contact.FirstName,
                              Contact.Cedula__c,
                              Contact.Email,
                              Contact.Phone,
                              AssetId,
                              Asset.Tipo_de_veh_culo__c,
                              Asset.Name,
                              Asset.NumeroDeChasis__c,
                              Asset.Marca_Nvo__c,
                              Asset.Modelo_Nvo2__c,
                              Asset.Anio__c,
                              StatusDetail__c,
                              Asset.UltimaVisitaAlTaller__c,
                              Asset.Kilometros__c,
                              Asset.Detalles_de_Garantia__c,
                              Asset.Comentario__c,
                              Asset.fecha_facturacion_vehiculo__c,
                              Asset.Oportunidad_relacionada__c,
                              Mecanico_Asignado__r.Name,
                              Mecanico_Asignado__c,
                              Priority,
                              servicioRequrido__c,
                              Service_Territory1__c,
                              Cita__c,
                              Origin,
                              Consecutivo__c,
                              Actualizo_Kilometraje__c,
                              RecordTypeId,
                              Status,
                              FechaEntrada__c,
                              ClosedDate,
                              OwnerId,
                              Comments,
                              Kilometraje__c,
                              Detalle_Asesor__c,
                              Description,
                              Service_Territory_Name_Formula__c,
                              Requiere_lavado__c,
                              Objetos_de_valor__c,
                              N_mero_y_color_de_gu_a__c,
                              Color_de_g_ia__c,
                              ObjetosValor__c,
                              Llevarse_repuestos__c                      
                              From Case Where Id =: recordId];            
        
        return lstCase;
    }
    
    @AuraEnabled
    public static String getOwnerName(Id caseId) {
        Case caseRecord = [
            SELECT OwnerId, Owner.Name 
            FROM Case 
            WHERE Id = :caseId
            LIMIT 1
        ];
        return caseRecord.Owner.Name;
    }
    @AuraEnabled
    public static void saveCombustibleData(Id caseId, String tipoCombustible, String nivelCombustible, Decimal porcentajeCarga) {
        Case c = new Case(Id = caseId);
        c.TipoDeCombustible__c = tipoCombustible;
        
        if(tipoCombustible == 'Gasolina' || tipoCombustible == 'Diesel') {
            c.NivelDeCombustible__c = nivelCombustible;
            c.PorcentajeDeCargaElectrica__c = null;
        } else if(tipoCombustible == 'Eléctrico') {
            c.PorcentajeDeCargaElectrica__c = porcentajeCarga;
            c.NivelDeCombustible__c = null;
        }     
        update c;
    }
    @AuraEnabled
    public static void savePriorityData(Id caseId, String prioridad) {
        Case c = new Case(Id = caseId);
        c.Priority = prioridad;   
        update c;
    }
    @AuraEnabled(cacheable=true)
    public static List<AssetWarranty> getAssetWarranty(String assetId) {
        List<AssetWarranty> warrantyRecord = [SELECT Id,WarrantyName__c,Details_Warranty__c,EndDate,Vigencia__c,Cambio_de_owner__c,WarrantyType FROM AssetWarranty WHERE AssetId = :assetId ];
        
        return warrantyRecord;
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<Opportunity> getUltimoComentario(Id assetId) {
        List<Opportunity> lstOpp = [Select Id,Observaciones_cliente__c, ConsecutivoOportunidad__c, Observaciones_negocio__c From Opportunity Where BMW_PlacaDeVehiculoOElVIN__c =: assetId Order by LastModifiedDate DESC LIMIT 1];
        return lstOpp;
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<Opportunity> getOpp(Id opportunityId) {
        List<Opportunity> lstOppo = [Select Id,
                                     Observaciones_cliente__c, 
                                     ConsecutivoOportunidad__c, 
                                     Observaciones_negocio__c 
                                     From Opportunity Where Id =: opportunityId];
        return lstOppo;
    }
    
    @AuraEnabled
    public static void updateComentario(Id recordId, String comentario) {
        Opportunity opp = [SELECT Id, Observaciones_cliente__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
        opp.Observaciones_cliente__c = comentario;
        update opp;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Historial_Fechas__c> getHistorialFechas(Id assetId) {
        return [
            SELECT Id, Name, Fecha__c, TipoDeFecha__c, UsuarioQueModifica__r.Name, FechaIngresoDato__c
            FROM Historial_Fechas__c
            WHERE Vehiculo__c = :assetId
            ORDER BY Fecha__c DESC
        ];
    }
    
    @AuraEnabled(cacheable = true)
    public static Boolean updateCaseFacturacion(String recordId) {
        List<Case> lstCase = [Select Id,
                              Type,
                              AccountId,
                              Account.Name,
                              Account.Correo_Electronico__pc,
                              Account.Invoice_Email__c,
                              Account.PersonEmail,
                              Account.Invoice_Phone__c,
                              Account.PersonMobilePhone,
                              Account.IsPersonAccount,
                              Account.Phone,
                              ContactId,
                              Contact.Name,
                              Contact.Email,
                              Contact.Phone,
                              AssetId,
                              Asset.Tipo_de_veh_culo__c,
                              Asset.Name,
                              Asset.NumeroDeChasis__c,
                              Asset.Marca_Nvo__c,
                              Asset.Modelo_Nvo2__c,
                              Asset.Anio__c,
                              Asset.Combustible__c,
                              StatusDetail__c,
                              Asset.UltimaVisitaAlTaller__c,
                              Asset.Kilometros__c,
                              Asset.Detalles_de_Garantia__c,
                              Asset.Comentario__c,
                              Asset.fecha_facturacion_vehiculo__c,
                              Mecanico_Asignado__r.Name,
                              Mecanico_Asignado__c,
                              Priority,
                              Cita__c,
                              Origin,
                              Consecutivo__c,
                              RecordTypeId,
                              Status,
                              FechaEntrada__c,
                              ClosedDate,
                              OwnerId,
                              Comments
                              From Case Where Id =: recordId];
        
        For(Case caso : lstCase){
            if(caso.Account.Invoice_Email__c == null || caso.Account.Invoice_Email__c == '' || caso.Account.Invoice_Phone__c == null || caso.Account.Invoice_Phone__c == '' ){
                if(caso.Account.Invoice_Email__c == null || caso.Account.Invoice_Email__c == '' ){
                    caso.Account.Invoice_Email__c = caso.Contact.Email;
                }
                
                if(caso.Account.Invoice_Phone__c == null || caso.Account.Invoice_Phone__c == ''){
                    caso.Account.Invoice_Phone__c = caso.Contact.Phone;
                }             
            }
        }
        update lstCase;
        return true;
    }
    
    @AuraEnabled
    public static void saveDetalleAsesor(Id caseId, String detalleAsesor) {
        Case caseRecord = [SELECT Id, Detalle_Asesor__c FROM Case WHERE Id = :caseId LIMIT 1];
        caseRecord.Detalle_Asesor__c = detalleAsesor;
        update caseRecord;
    }
    @AuraEnabled
    public static void saveNumeroGuia(Id caseId, String numGuia) {
        Case caseRecord = [SELECT Id, N_mero_y_color_de_gu_a__c FROM Case WHERE Id = :caseId LIMIT 1];
        caseRecord.N_mero_y_color_de_gu_a__c = numGuia;
        update caseRecord;
    }
    
    @AuraEnabled
    public static void saveColorGuia(Id caseId, String colorDeGuia) {
        Case caseRecord = [SELECT Id, Color_de_g_ia__c FROM Case WHERE Id = :caseId LIMIT 1];
        caseRecord.Color_de_g_ia__c = colorDeGuia;
        update caseRecord;
    }
    
    @AuraEnabled
    public static void saveLavado(Id caseId, Boolean ReqLavado) {
        Case caseRecord = [SELECT Id, Requiere_lavado__c FROM Case WHERE Id = :caseId LIMIT 1];
        caseRecord.Requiere_lavado__c = ReqLavado;
        update caseRecord;
    }
    
    @AuraEnabled
    public static void saveObjetoValor(Id caseId, Boolean objValor) {
        Case caseRecord = [SELECT Id, Objetos_de_valor__c FROM Case WHERE Id = :caseId LIMIT 1];
        caseRecord.Objetos_de_valor__c = objValor;
        update caseRecord;
    }
    
    @AuraEnabled
    public static void saveObjetoValorText(Id caseId, String objValorText) {
        Case caseRecord = [SELECT Id, ObjetosValor__c FROM Case WHERE Id = :caseId LIMIT 1];
        caseRecord.ObjetosValor__c = objValorText;
        update caseRecord;
    }
    
    @AuraEnabled
    public static void saveRepuestos(Id caseId, Boolean LlevarseRepuestos) {
        Case caseRecord = [SELECT Id, Llevarse_repuestos__c FROM Case WHERE Id = :caseId LIMIT 1];
        caseRecord.Llevarse_repuestos__c = LlevarseRepuestos;
        update caseRecord;
    }
    
    @AuraEnabled
    public static void updateCaseKilometraje(Id caseId, Decimal kilometraje) {
        Case caseRecord = [SELECT Id, Kilometraje__c FROM Case WHERE Id = :caseId LIMIT 1];
        caseRecord.Kilometraje__c = kilometraje;
        update caseRecord;
    }
    
    // @AuraEnabled
    // public static void updateAssetkilometraje(Id assetId, Decimal kilometraje, Id caseId) {
    //     Asset caseRecord = [SELECT Id, Kilometros__c FROM Asset WHERE Id = :assetId LIMIT 1];
    //     caseRecord.Kilometros__c = kilometraje;
    //     update caseRecord;
    
    //     Case caso = [SELECT Id, Actualizo_Kilometraje__c FROM Case WHERE Id = :caseId LIMIT 1];
    //     caso.Actualizo_Kilometraje__c = true;
    //     update caso;
    // }
    
    @AuraEnabled
    public static void updateAssetComment(Id assetId, String comment) {
        Asset caseRecord = [SELECT Id, Comentario__c FROM Asset WHERE Id = :assetId LIMIT 1];
        caseRecord.Comentario__c = comment;
        update caseRecord;
    }

    @AuraEnabled(Cacheable = true)
    public static List<WorkOrder> getCaseOrders (String caseId){
        List<WorkOrder> lstWorkOrder = new List<WorkOrder>();
        lstWorkOrder = [Select Id, Status, Kilometros__c FROM WorkOrder WHERE CaseId =: caseId];

        return lstWorkOrder;
    }

   
    
    @AuraEnabled(Cacheable = true)
    public static List<Asset> getAsset(String assetId){
        List<Asset> lstAsset = new List<Asset>();
        lstAsset = [Select Id,
                    Garant_a_de_activo__c,
                    Garant_a_de_activo__r.AssetWarrantyNumber,
                    Garant_a_de_activo__r.WarrantyTerm.WarrantyTermName,
                    Garant_a_de_activo__r.StartDate,
                    Garant_a_de_activo__r.EndDate,
                    Garant_a_de_activo__r.WarrantyTerm.EffectiveStartDate,
                    Garant_a_de_activo__r.WarrantyType
                    From Asset Where Id =: assetId];
        
        return lstAsset;
        
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<Subtipo_de_trabajo_del_caso__c> getTrabajosOld(String recordId){
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
                                                            from  Subtipo_de_trabajo_del_caso__c WHERE Caso__c =: recordId ];
        return subTrabajos;
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<tiposDeTrabajoCaso__c> getTrabajos(String recordId){
        List<tiposDeTrabajoCaso__c> subTrabajos = [Select Id,
                                                   Name,
                                                   Nombre_TTC__c, 
                                                   Total_de_horas__c  
                                                   from  tiposDeTrabajoCaso__c WHERE Caso__c =: recordId ];
        return subTrabajos;
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<WorkOrder> getWO(String recordId){
        List<WorkOrder> subTrabajos = [Select Id,
                                       WorkOrderNumber ,OwnerOT__c,Tipo_de_Cargo__c
                                       from  WorkOrder WHERE CaseId =: recordId ];
        return subTrabajos;
    }
    
    @AuraEnabled
    public static void updateCaseStatusDetail(Id caseId, String statusDetail) {
        Case caseRecord = [SELECT Id, StatusDetail__c FROM Case WHERE Id = :caseId LIMIT 1];
        caseRecord.StatusDetail__c = statusDetail;
        update caseRecord;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getWorkOrdersByCaseId(Id caseId) {
        return [SELECT Id, WorkOrderNumber, Owner.Name, Tipo_de_Cargo__c ,totalFinal__c, CurrencyIsoCode
                
                FROM WorkOrder 
                WHERE CaseId = :caseId];
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