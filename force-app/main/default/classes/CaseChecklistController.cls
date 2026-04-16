public class CaseChecklistController	
{	
    
    public String caseId {get;set;}	
    public Case cs {get;set;}	
    public DateTime apertura {get;set;}	
    public String fechaEntrada {get;set;}	
    public String fechaPrevistaEntrega {get;set;}	
    public String fechaVehiculo {get;set;}	
    public List<Subtipo_de_trabajo_del_caso__c> subtipos {get;set;}	
    public List<tiposDeTrabajoCaso__c> listTipos {get; set;}
    public List<WorkOrder> ordenesTrabajo {get;set;}	
    public decimal kilometros {get;set;}	
    public String workOrderNumber {get;set;}	
    public String assetDinam {get;set;}	
    public List<WorkOrder> Ubi {get; set;}
    public List<tiposDeTrabajoCaso__c> trabajosarealizar {get; set;}
    public String tipoDeVehiculo {get;set;}	
    public Boolean hayDibujo {get;set;}	
    public String dibujoImagen {get;set;}	
    public Quote quoteRelacionado { get; set; }
    public String quoteNumber {get;set;}
    public Boolean infoInComplete {get;set;}
 	public Firma__c firma { get; private set; }
    public Boolean firmaEncontrada { get; private set; }
    public String firmaImagen { get; private set; }
    public String visualforceName { get; private set; }
    public Cambio_de_Propietario__c cambioPropietario {get; set;}

    public CaseChecklistController(ApexPages.StandardController controller) {
        caseId = controller.getId();
        Map<String, String> mapTipoVehiculoVisualforce = new Map<String, String>{
    	'Automóvil' => 'CaseChecklistPDFBeta',
    	'Motocicleta' => 'ChecklistMotosPDFBeta',
    	'Mula' => 'ChecklistMulaPDF',
    	'Cuadraciclo' => 'ChecklistCuadraPDF'
		};
        Case caso = [SELECT Id, Marca__c, AssetId, Asset.Tipo_de_veh_culo__c FROM Case WHERE Id =: caseId];
        if (caso.Asset.Tipo_de_veh_culo__c != null) {
                visualforceName = mapTipoVehiculoVisualforce.get(caso.Asset.Tipo_de_veh_culo__c);
            }
        List<Firma__c> firmas = [
            SELECT Id, Nombre__c, (SELECT ContentDocumentId FROM ContentDocumentLinks LIMIT 1)
            FROM Firma__c
            WHERE Case__c = :caseId
            AND Visualforce__c = :visualforceName
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (!firmas.isEmpty()) {firma = firmas[0]; firmaEncontrada = true;
            // Obtener la imagen de la firma
            if (firma.ContentDocumentLinks.isEmpty()) { firmaImagen = null;
            } else { ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :firma.ContentDocumentLinks[0].ContentDocumentId ORDER BY CreatedDate DESC LIMIT 1]; firmaImagen = '/sfc/servlet.shepherd/version/download/' + cv.Id;
            }
        } else {
            firmaEncontrada = false;
        }
        tipoDeVehiculo = 'Automóvil';
        hayDibujo = false;
        infoInComplete = true;
        cs = [SELECT Id, ContactId, Kilometraje__c,Cuenta_de_Facturacion__c, Marca__c, CaseNumber,RecordType.Name, Asset.marca__c,AssetId, Asset.numeroDePlaca__c, Asset.NumeroDeChasis__c, Asset.Kilometros__c,	
              OwnerId, Asset.Combustible__c, Asset.modelo__c,Asset.motor__c, Asset.Color__c, Asset.anio__c, Asset.Tipo_de_veh_culo__c,	
              Account.Name, Account.BillingStreet, Account.Tipo_de_Documento__c,  Account.Phone, Account.Cedula__c, Contact.Email, Contact.MobilePhone,	
              Contact.Name, Contact.Phone, Fecha_Hora_de_apertura__c, FechaEntrada__c,CreatedDate,Requiere_lavado__c,Objetos_de_valor__c,N_mero_y_color_de_gu_a__c,
              Color_de_g_ia__c,Llevarse_repuestos__c,ObjetosValor__c,Detalle_Asesor__c,
             (SELECT Id, Name, Tipo_de_cargo__c, FechaAlta__c, Status__c, Taller__c,Horaa__c, ComentarioTTC__c,Tipotrabajo__r.Name,	
              Tipotrabajo__c,Ordenamiento__c,Alias_Articulo__c
              FROM Tipos_de_Trabajo__r 
              //Where Tipotrabajo__r.Name != '-Control final' And Tipotrabajo__r.Name!= 'CONTROL FINAL'  And Tipotrabajo__r.Name!= 'Control final'  And Tipotrabajo__r.Name!= 'Lavado Red Motos' 
              order by Ordenamiento__c ASC)
              FROM Case	
              WHERE Id =: caseId	
              LIMIT 1];	
        if (cs.ContactId != null && cs.Kilometraje__c != null && cs.OwnerId != null && cs.Cuenta_de_Facturacion__c != null) {
            infoInComplete = false;
        }
        if(cs.Asset.Tipo_de_veh_culo__c != null){ tipoDeVehiculo = cs.Asset.Tipo_de_veh_culo__c;
        }
        Map<String, String> mapaVehiculo = new Map<String, String>{
            'Automóvil' => 'Auto',
            'Motocicleta' => 'Moto',
            'Mula' => 'Mula',
            'Cuadraciclo' => 'Cuadra'
        };
        tipoDeVehiculo = mapaVehiculo.get(tipoDeVehiculo);
        try{
             List<DibujoVehiculo__c> dibujos = [SELECT Id, (SELECT ContentDocumentId FROM ContentDocumentLinks LIMIT 1) 
                                      FROM DibujoVehiculo__c 
                                      WHERE Case__c =: cs.Id AND TipoDeVehiculo__c =: tipoDeVehiculo 
                                      ORDER BY CreatedDate DESC LIMIT 1];
            if(dibujos.size()>0){
                DibujoVehiculo__c dibujo = dibujos[0];
                if(!dibujo.ContentDocumentLinks.isEmpty()){ ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :dibujo.ContentDocumentLinks[0].ContentDocumentId ORDER BY CreatedDate DESC LIMIT 1];   dibujoImagen = '/sfc/servlet.shepherd/version/download/' + cv.Id; hayDibujo = true;
                }
                
            }
        } catch(Exception e) {
        }
        fechaEntrada = cs.FechaEntrada__c != null ? cs.FechaEntrada__c.format() : '';	
        
         trabajosarealizar = [SELECT Id, Name, Tipo_de_cargo__c, FechaAlta__c, Status__c, Taller__c,Horaa__c, ComentarioTTC__c,Tipotrabajo__r.Name,
              Tipotrabajo__c,Ordenamiento__c,Alias_Articulo__c, NombreDeTrabajo__c 
              FROM tiposDeTrabajoCaso__c Where caso__c =: caseId order by Ordenamiento__c ASC];
        
        List<Cambio_de_Propietario__c> cambios = [SELECT Id, Asset__c, Case__c, Cuenta_Anterior__c, Cuenta_Nueva__c, Estado__c
            FROM Cambio_de_Propietario__c WHERE (Case__c = :caseId OR Asset__c = :cs.AssetId) AND Estado__c ='Pendiente' ];
            if (!cambios.isEmpty()) {
               cambioPropietario = cambios[0];
             }
        
        List<WorkOrder> OT = new List<WorkOrder>();
        List<Opportunity> Opp = new List<Opportunity>();
        List<Quote> quote = new List<Quote>();
        OT = [SELECT Id, AssetId, Kilometros__c, Fecha_prevista_de_entrega__c, Asset.Anio__c FROM WorkOrder WHERE AssetId =: cs.AssetId AND CaseId =: caseId ORDER BY CreatedDate DESC];
        if (OT.size() > 0) {
            Opp = [SELECT Id, Name, StageName, Amount FROM Opportunity WHERE WorkOrder__c = :OT[0].Id LIMIT 1];
            if (Opp.size() > 0) {
                quote = [SELECT Id, Name, QuoteNumber FROM Quote WHERE OpportunityId = :Opp[0].Id LIMIT 1];
                if (quote.size() > 0) {
                    quoteRelacionado = quote[0];
                    quoteNumber = quote[0].QuoteNumber;
                }
            }
        }	
        	
            	
        if(OT.size() > 0){	
            if(OT[0].Kilometros__c != null && OT[0].Kilometros__c != 0){kilometros= OT[0].Kilometros__c;	
            }else{	
                kilometros=cs.Asset.Kilometros__c;	
            }	
        }else{	kilometros=cs.Asset.Kilometros__c;	
        }	
        listTipos = [Select Id,Estado_aprobaci_n_service__c, Name, Tipo_de_cargo__c, FechaAlta__c, Status__c, Taller__c,Horaa__c, ComentarioTTC__c,Tipotrabajo__r.Name,	
              Tipotrabajo__c,Ordenamiento__c,Alias_Articulo__c From tiposDeTrabajoCaso__c Where Caso__c =:caseId 
                   //  And Tipotrabajo__r.Name != '-Control final' And Tipotrabajo__r.Name!= 'CONTROL FINAL'  And Tipotrabajo__r.Name!= 'Control final'  And Tipotrabajo__r.Name!= 'Lavado Red Motos' 
                     Order by Ordenamiento__c ASC];	
        ordenesTrabajo = [SELECT Id, Fecha_de_Apertura__c, Fecha_prevista_de_entrega__c, Asset.Anio__c, WorkOrderNumber FROM WorkOrder WHERE CaseId =: caseId];
        if (ordenesTrabajo.size() > 0) {	
            apertura = ordenesTrabajo[0].Fecha_de_Apertura__c;	
            workOrderNumber = ordenesTrabajo[0].WorkOrderNumber;	
            //fechaEntrada = ordenesTrabajo[0].Fecha_de_Entrada__c != null ? ordenesTrabajo[0].Fecha_de_Entrada__c.format() : '';	
            fechaPrevistaEntrega = ordenesTrabajo[0].Fecha_prevista_de_entrega__c != null ? ordenesTrabajo[0].Fecha_prevista_de_entrega__c.format() : '';	
            fechaVehiculo = ordenesTrabajo[0].Asset != null ? ordenesTrabajo[0].Asset.Anio__c: '';	
        }else{	apertura = cs.CreatedDate;	
        }	
        if(listTipos.size()>0){	subtipos = [SELECT Id, Name, Cantidad_de_horas__c,Alias__c, Tipo_de_trabajo_del_caso__r.Name,Tipo_de_trabajo_del_caso__r.Alias_Articulo__c FROM Subtipo_de_trabajo_del_caso__c Where Tipo_de_trabajo_del_caso__c IN: listTipos 
                                           // AND TipoDeTrabajo__r.Name != '-Control final' And TipoDeTrabajo__r.Name!= 'CONTROL FINAL'  And TipoDeTrabajo__r.Name!= 'Control final'  And TipoDeTrabajo__r.Name!= 'Lavado Red Motos'
                                           ];	
        }      	
        	
        Ubi = [SELECT Id, ServiceTerritoryId, CaseId FROM WorkOrder WHERE CaseId =: caseId LIMIT 1];
    }	
    	
}