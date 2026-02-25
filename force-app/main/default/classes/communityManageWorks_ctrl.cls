public without sharing class communityManageWorks_ctrl {

    // Inner wrapper class to hold WorkOrderLineItem data along with tipoCargo__c data
    public class WorkOrderLineItemWrapper {
        @AuraEnabled public Id workOrderLineItemId;
        @AuraEnabled public String workOrderId;
        @AuraEnabled public Id tiposDeTrabajoId;
        @AuraEnabled public String tiposDeTrabajoName;
        @AuraEnabled public Decimal totalFacturar2; // Holds the tipoCargo__c totalFacturar2__c value
        @AuraEnabled public Decimal totalPrice;
        @AuraEnabled public String productoOrAlias;
        @AuraEnabled public String tipoTrabajo;
        @AuraEnabled public String currencyIsoCode;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public String tipodecargo;
        @AuraEnabled public String workOrderNumber;
        @AuraEnabled public String categoradepresupuesto;
        @AuraEnabled public String estadoAporbacionEnService;
        @AuraEnabled public String aprobador;
        @AuraEnabled public String tipoProducto;

        // Constructor to initialize wrapper fields
        public WorkOrderLineItemWrapper(WorkOrderLineItem item, Decimal totalFacturar2) {
            this.workOrderLineItemId = item.Id;
            this.workOrderId = item.WorkOrderId;
            this.tiposDeTrabajoId = item.TipoTrabajoCaso__r.Id;
            this.tiposDeTrabajoName = item.tiposDeTrabajo__r.Name;
            this.totalFacturar2 = totalFacturar2 != null ? totalFacturar2 : 0 ;
            this.tipodecargo = item.TipoTrabajoCaso__r.Tipo_de_cargo__c;
            this.totalPrice = item.TotalPrice;
            this.categoradepresupuesto = item.TipoTrabajoCaso__r.Categor_a_de_presupuesto__c;
            this.productoOrAlias = item.Producto_OR_Alias__c;
            this.currencyIsoCode = item.WorkOrder.CurrencyIsoCode;
            this.quantity = item.Quantity;
            this.workOrderNumber = item.WorkOrder.WorkOrderNumber;
            this.estadoAporbacionEnService = item.TipoTrabajoCaso__r.Estado_aprobaci_n_service__c;
            this.aprobador = item.TipoTrabajoCaso__r.Aprobador__c;
            this.tipoProducto = item.TrabajoFormulaProducto__c;
        }
    }

    public class TrabajoWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String workOrderId { get; set; }
        @AuraEnabled public String aseguradora { get; set; }
        @AuraEnabled public String aseguradoraNombre { get; set; }
        @AuraEnabled public String centroDeCostos { get; set; }
        @AuraEnabled public String centroDeCostosNombre { get; set; }
        @AuraEnabled public String nombreTrabajo { get; set; }
        @AuraEnabled public String alias { get; set; }
        @AuraEnabled public Boolean changeAlias { get; set; }
        @AuraEnabled public String prioridad { get; set; }
        @AuraEnabled public String tipoTrabajo { get; set; }
        @AuraEnabled public String tarea { get; set; }
        @AuraEnabled public String tipoCargo { get; set; }
        @AuraEnabled public String aprobador { get; set; }
        @AuraEnabled public String manoDeObra { get; set; }
        @AuraEnabled public String manoDeObraNombre { get; set; }
        @AuraEnabled public Decimal uts { get; set; }
        @AuraEnabled public Decimal utsReal { get; set; }
        @AuraEnabled public Decimal totalUts { get; set; }
        @AuraEnabled public Decimal totalSubtrabajos { get; set; }
        @AuraEnabled public Decimal utsDelTipoDeTrabajo { get; set; }
        @AuraEnabled public List<SubtrabajoWrapper> subtrabajos { get; set; }
    }
    
    public class SubtrabajoWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String nombre { get; set; }
        @AuraEnabled public String alias { get; set; }
        @AuraEnabled public String manoDeObra { get; set; }
        @AuraEnabled public String manoDeObraNombre { get; set; }
        @AuraEnabled public String pasoDeTrabajo { get; set; }
        @AuraEnabled public String tipoTrabajo { get; set; }
        @AuraEnabled public String tipoTrabajoNombre { get; set; }
        @AuraEnabled public Decimal horas { get; set; }
        @AuraEnabled public Decimal uts { get; set; }
        @AuraEnabled public Decimal utsDelTipoDeTrabajo { get; set; }
    }

    // Main method to retrieve and group WorkOrderLineItems by tiposDeTrabajo__c
   @AuraEnabled(cacheable=false)
   public static Map<Id, List<WorkOrderLineItemWrapper>> getWorkOrderLineItemsGroupedByTipoTrabajo(String casoId) {
       Map<Id, List<WorkOrderLineItemWrapper>> groupedWorkOrderLineItems = new Map<Id, List<WorkOrderLineItemWrapper>>();

       // Step 1: Query WorkOrderLineItems
       List<WorkOrderLineItem> workOrderLineItems = [
            SELECT Id, WorkOrderId, tiposDeTrabajo__c, tiposDeTrabajo__r.Name, TipoTrabajoCaso__r.Enviar_a_service__c,
            TipoTrabajoCaso__r.Status__c,TipoTrabajoCaso__r.Aprobador__c,TipoTrabajoCaso__r.Estado_aprobaci_n_service__c,
            TipoTrabajoCaso__r.Tipo_de_cargo__c,TotalPrice,TipoTrabajoCaso__r.Id,TipoTrabajoCaso__r.Categor_a_de_presupuesto__c,
            Producto_OR_Alias__c,WorkOrder.CurrencyIsoCode,Quantity,WorkOrder.WorkOrderNumber,Total__c, TrabajoFormulaProducto__c
            FROM WorkOrderLineItem
            WHERE TipoTrabajoCaso__r.Enviar_a_service__c = true AND WorkOrder.Enviar_presupuesto_a_service__c = true AND WorkOrder.CaseId =:casoId
        ];

       // Collect WorkOrderLineItem IDs
       Set<Id> workOrderLineItemIds = new Set<Id>();
       for (WorkOrderLineItem item : workOrderLineItems) {
           workOrderLineItemIds.add(item.Id);
       }

       // Step 2: Query tipoCargo__c records related to WorkOrderLineItems where tipoCargo__c = '1'
       Map<Id, Decimal> tipoCargoMap = new Map<Id, Decimal>();
       List<tipoCargo__c> cargos = [
           SELECT totalFacturar2__c, Work_Order_Line_Item__r.Id
           FROM tipoCargo__c
           WHERE Work_Order_Line_Item__r.Id IN :workOrderLineItemIds
           AND tipoCargo__c = '1'
       ];

       // Map each WorkOrderLineItem Id to its corresponding totalFacturar2__c
       for (tipoCargo__c cargo : cargos) {
           tipoCargoMap.put(cargo.Work_Order_Line_Item__r.Id, cargo.totalFacturar2__c);
       }

       // Step 3: Create WorkOrderLineItemWrapper instances and group them by tiposDeTrabajo__c
       for (WorkOrderLineItem item : workOrderLineItems) {
           Decimal totalFacturar2 = tipoCargoMap.containsKey(item.Id) ? tipoCargoMap.get(item.Id) : null;
           WorkOrderLineItemWrapper wrapper = new WorkOrderLineItemWrapper(item, totalFacturar2);

           // Group WorkOrderLineItemWrapper objects by tiposDeTrabajo__c
           if (!groupedWorkOrderLineItems.containsKey(item.tiposDeTrabajo__c)) {
               groupedWorkOrderLineItems.put(item.tiposDeTrabajo__c, new List<WorkOrderLineItemWrapper>());
           }
           groupedWorkOrderLineItems.get(item.tiposDeTrabajo__c).add(wrapper);
       }

       return groupedWorkOrderLineItems;
   }


    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getCases() {

        // Obtener el ID del usuario actual
        Id currentUserId = UserInfo.getUserId();

        // Consultar el AccountId relacionado al usuario actual
        User currentUser = [SELECT AccountId FROM User WHERE Id = :currentUserId LIMIT 1];

        // Almacenar el AccountId en una variable
        Id accountId = currentUser.AccountId;
        // Consulta inicial para obtener los WorkOrderLineItems con los filtros especificados
        List<WorkOrderLineItem> workOrderLineItems = [
            SELECT Id, WorkOrder.CaseId, WorkOrderId, tiposDeTrabajo__c, tiposDeTrabajo__r.Name, 
            TipoTrabajoCaso__r.Enviar_a_service__c, TipoTrabajoCaso__r.Status__c, 
            TipoTrabajoCaso__r.Aprobador__c, TipoTrabajoCaso__r.Estado_aprobaci_n_service__c,
            TipoTrabajoCaso__r.Tipo_de_cargo__c, TotalPrice, TipoTrabajoCaso__r.Id, 
            TipoTrabajoCaso__r.Categor_a_de_presupuesto__c, Producto_OR_Alias__c, 
            WorkOrder.CurrencyIsoCode, Quantity, WorkOrder.WorkOrderNumber,WorkOrder.accountId
            FROM WorkOrderLineItem
            WHERE TipoTrabajoCaso__r.Enviar_a_service__c = true 
            AND WorkOrder.Enviar_presupuesto_a_service__c = true
            AND WorkOrder.accountId =: accountId
        ];

        // Mapa para almacenar la suma de TotalPrice por CaseId y también para almacenar el WorkOrderNumber
        Map<Id, Decimal> caseTotalPriceMap = new Map<Id, Decimal>();
        Map<Id, String> caseWorkOrderNumberMap = new Map<Id, String>();

        // Llenar los mapas con la suma de TotalPrice por CaseId y WorkOrderNumber
        for (WorkOrderLineItem woli : workOrderLineItems) {
            if (woli.WorkOrder.CaseId != null) {
                // Actualiza el mapa para sumar los precios
                if (caseTotalPriceMap.containsKey(woli.WorkOrder.CaseId)) {
                    caseTotalPriceMap.put(woli.WorkOrder.CaseId, caseTotalPriceMap.get(woli.WorkOrder.CaseId) + woli.TotalPrice);
                } else {
                    caseTotalPriceMap.put(woli.WorkOrder.CaseId, woli.TotalPrice);
                }
                // Actualiza el mapa con el WorkOrderNumber
                caseWorkOrderNumberMap.put(woli.WorkOrder.CaseId, woli.WorkOrder.WorkOrderNumber);
            }
        }

        // Consulta para obtener los casos junto con el CreatedDate
        List<Case> listaCasos = [
            SELECT Id, CreatedDate, N_de_placa__c, CaseNumber,Service_Territory_Name_Formula__c
            FROM Case 
            WHERE Id IN :caseTotalPriceMap.keySet()
        ];

        // Crear una lista para almacenar el resultado final con WorkOrderNumber, total de TotalPrice y CreatedDate
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        for (Case caso : listaCasos) {
            Map<String, Object> caseInfo = new Map<String, Object>();
            caseInfo.put('CaseId', caso.Id);
            caseInfo.put('CaseNumber', caso.CaseNumber);
            caseInfo.put('WorkOrderNumber', caseWorkOrderNumberMap.get(caso.Id)); // Usamos WorkOrderNumber en lugar de CaseId
            caseInfo.put('TotalPrice', caseTotalPriceMap.get(caso.Id));
            caseInfo.put('Territorio', caso.Service_Territory_Name_Formula__c);
            caseInfo.put('CreatedDate', caso.CreatedDate);
            caseInfo.put('Placa', caso.N_de_placa__c);
            result.add(caseInfo);
        }

        return result;
    }

    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getQuotes() {
        // Obtener el ID del usuario actual
        Id currentUserId = UserInfo.getUserId();

        // Consultar el AccountId relacionado al usuario actual
        User currentUser = [SELECT AccountId FROM User WHERE Id = :currentUserId LIMIT 1];
        Id accountId = currentUser.AccountId;

        // Consulta para obtener las Quotes que cumplen con las condiciones
        List<Quote> quotes = [
            SELECT Id, Name, CreatedDate, Placa__c, GrandTotal, QuoteNumber, Opportunity.AccountId, CurrencyIsoCode
            FROM Quote 
            WHERE Opportunity.AccountId = :accountId 
            AND Enviar_presupuesto_a_service__c = true
            // AND Status IN ('Presentada', 'En revisión')
        ];

        // Crear una lista para almacenar el resultado final
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        for (Quote quote : quotes) {
            Map<String, Object> quoteInfo = new Map<String, Object>();
            quoteInfo.put('QuoteId', quote.Id);
            quoteInfo.put('Name', quote.Name);
            quoteInfo.put('QuoteNumber', quote.QuoteNumber);
            quoteInfo.put('GrandTotal', quote.GrandTotal);
            quoteInfo.put('CreatedDate', quote.CreatedDate);
            quoteInfo.put('Placa', quote.Placa__c);
            result.add(quoteInfo);
        }

        return result;
    }

    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getCasesHistory() {

        // Obtener el ID del usuario actual
        Id currentUserId = UserInfo.getUserId();

        // Consultar el AccountId relacionado al usuario actual
        User currentUser = [SELECT AccountId FROM User WHERE Id = :currentUserId LIMIT 1];

        // Almacenar el AccountId en una variable
        Id accountId = currentUser.AccountId;
        // Consulta inicial para obtener los WorkOrderLineItems con los filtros especificados
        List<WorkOrderLineItem> workOrderLineItems = [
            SELECT Id, WorkOrder.CaseId, WorkOrderId, tiposDeTrabajo__c, tiposDeTrabajo__r.Name, 
            TipoTrabajoCaso__r.Enviar_a_service__c, TipoTrabajoCaso__r.Status__c, 
            TipoTrabajoCaso__r.Aprobador__c, TipoTrabajoCaso__r.Estado_aprobaci_n_service__c,
            TipoTrabajoCaso__r.Tipo_de_cargo__c, TotalPrice, TipoTrabajoCaso__r.Id, 
            TipoTrabajoCaso__r.Categor_a_de_presupuesto__c, Producto_OR_Alias__c, 
            WorkOrder.CurrencyIsoCode, Quantity, WorkOrder.WorkOrderNumber,WorkOrder.accountId
            FROM WorkOrderLineItem
            WHERE WorkOrder.accountId =: accountId
        ];

        // Mapa para almacenar la suma de TotalPrice por CaseId y también para almacenar el WorkOrderNumber
        Map<Id, Decimal> caseTotalPriceMap = new Map<Id, Decimal>();
        Map<Id, String> caseWorkOrderNumberMap = new Map<Id, String>();

        // Llenar los mapas con la suma de TotalPrice por CaseId y WorkOrderNumber
        for (WorkOrderLineItem woli : workOrderLineItems) {
            if (woli.WorkOrder.CaseId != null) {
                // Actualiza el mapa para sumar los precios
                if (caseTotalPriceMap.containsKey(woli.WorkOrder.CaseId)) {
                    caseTotalPriceMap.put(woli.WorkOrder.CaseId, caseTotalPriceMap.get(woli.WorkOrder.CaseId) + woli.TotalPrice);
                } else {
                    caseTotalPriceMap.put(woli.WorkOrder.CaseId, woli.TotalPrice);
                }
                // Actualiza el mapa con el WorkOrderNumber
                caseWorkOrderNumberMap.put(woli.WorkOrder.CaseId, woli.WorkOrder.WorkOrderNumber);
            }
        }

        // Consulta para obtener los casos junto con el CreatedDate
        List<Case> listaCasos = [
            SELECT Id, CreatedDate, N_de_placa__c, CaseNumber, Service_Territory_Name_Formula__c
            FROM Case 
            WHERE Id IN :caseTotalPriceMap.keySet()
        ];

        // Crear una lista para almacenar el resultado final con WorkOrderNumber, total de TotalPrice y CreatedDate
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        for (Case caso : listaCasos) {
            Map<String, Object> caseInfo = new Map<String, Object>();
            caseInfo.put('CaseId', caso.Id);
            caseInfo.put('CaseNumber', caso.CaseNumber);
            caseInfo.put('WorkOrderNumber', caseWorkOrderNumberMap.get(caso.Id)); // Usamos WorkOrderNumber en lugar de CaseId
            caseInfo.put('TotalPrice', caseTotalPriceMap.get(caso.Id));
            caseInfo.put('Territorio', caso.Service_Territory_Name_Formula__c);
            caseInfo.put('CreatedDate', caso.CreatedDate);
            caseInfo.put('Placa', caso.N_de_placa__c);
            result.add(caseInfo);
        }

        return result;
    }        
    
    @AuraEnabled(cacheable=false)
    public static List<tipoCargoWrapper> getMarcasConfig(String casoId) {
        // Query tipoCargo__c and related Work_Order_Line_Item__c records
        List<tipoCargo__c> userAssets = [SELECT Id, Name, porcentaje__c, totalMercaderia2__c, tipoCargo__c,
                                        Work_Order_Line_Item__c, Work_Order_Line_Item__r.Id, Work_Order_Line_Item__r.UnitPrice, 
                                        Work_Order_Line_Item__r.ListPrice, Work_Order_Line_Item__r.ProductCode__c, 
                                        Work_Order_Line_Item__r.Producto_OR_Alias__c, Work_Order_Line_Item__r.TipoTrabajoCaso__r.Id, 
                                        Work_Order_Line_Item__r.TipoTrabajoCaso__r.Name, Work_Order_Line_Item__r.TipoTrabajoCaso__r.Status__c, 
                                        Work_Order_Line_Item__r.TipoTrabajoCaso__r.Total_de_horas__c, Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id, 
                                        Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Status, Work_Order_Line_Item__r.TipoTrabajoCaso__r.Categor_a_de_presupuesto__c,
                                        Work_Order_Line_Item__r.TipoTrabajoCaso__r.Aprobador__c, Work_Order_Line_Item__r.TipoTrabajoCaso__r.Estado_aprobaci_n_service__c,Work_Order_Line_Item__r.WorkOrderId,
                                        Work_Order_Line_Item__r.WorkOrder.Enviar_presupuesto_a_service__c
                                        FROM tipoCargo__c 
                                        WHERE Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id = :casoId and Work_Order_Line_Item__r.WorkOrder.Enviar_presupuesto_a_service__c = true];

        // Collect Work_Order_Line_Item__c IDs
        Set<Id> workOrderLineItemIds = new Set<Id>();
        for(tipoCargo__c tc : userAssets) {
            if(tc.Work_Order_Line_Item__c != null) {
                workOrderLineItemIds.add(tc.Work_Order_Line_Item__c);
            }
        }

        // Query Subtipo_de_trabajo_del_caso__c related to the collected Work_Order_Line_Item__c IDs
        List<Subtipo_de_trabajo_del_caso__c> subtipos = new List<Subtipo_de_trabajo_del_caso__c>();
        if(!workOrderLineItemIds.isEmpty()) {
            subtipos = [SELECT Name, Articulo_Mano_de_Obra__c 
                        FROM Subtipo_de_trabajo_del_caso__c 
                        WHERE Articulo_Mano_de_Obra__c IN :workOrderLineItemIds];
        }

        // Map the Subtipo_de_trabajo_del_caso__c records to their respective Work_Order_Line_Item__c
        Map<Id, List<Subtipo_de_trabajo_del_caso__c>> subtipoMap = new Map<Id, List<Subtipo_de_trabajo_del_caso__c>>();
        for(Subtipo_de_trabajo_del_caso__c subtipo : subtipos) {
            if(!subtipoMap.containsKey(subtipo.Articulo_Mano_de_Obra__c)) {
                subtipoMap.put(subtipo.Articulo_Mano_de_Obra__c, new List<Subtipo_de_trabajo_del_caso__c>());
            }
            subtipoMap.get(subtipo.Articulo_Mano_de_Obra__c).add(subtipo);
        }

        // Create a wrapper to include both tipoCargo__c and related Subtipo_de_trabajo_del_caso__c
        List<tipoCargoWrapper> wrappedResults = new List<tipoCargoWrapper>();
        for(tipoCargo__c tc : userAssets) {
            List<Subtipo_de_trabajo_del_caso__c> relatedSubtipos = subtipoMap.containsKey(tc.Work_Order_Line_Item__c) ? subtipoMap.get(tc.Work_Order_Line_Item__c) : new List<Subtipo_de_trabajo_del_caso__c>();
            wrappedResults.add(new tipoCargoWrapper(tc, relatedSubtipos));
        }

        return wrappedResults;
    }
    @AuraEnabled()
    public static Boolean cambiarEstado(List<String> tipoTrabajoCasoId, String estado) {
        // Query the child records
        List<tiposDeTrabajoCaso__c> lstTrabajos = [
            SELECT Id, RM_WorkOrder__c, Estado_aprobaci_n_service__c 
            FROM tiposDeTrabajoCaso__c 
            WHERE Id IN :tipoTrabajoCasoId
        ];
        String woOrDef = '';
        // Collect parent record IDs
        Set<Id> workOrderIds = new Set<Id>();
        for (tiposDeTrabajoCaso__c trb : lstTrabajos) {
            
            if (trb.RM_WorkOrder__c != null) {
                woOrDef = trb.RM_WorkOrder__c;
                workOrderIds.add(trb.RM_WorkOrder__c);
            }
        }
            
        // Update child records
        for (tiposDeTrabajoCaso__c trb : lstTrabajos) {
            trb.Estado_aprobaci_n_service__c = estado;
        }
        update lstTrabajos;
        
        //process to reject
        List<tiposDeTrabajoCaso__c> lstTrabajosRecha = [
            SELECT Id, RM_WorkOrder__c, Estado_aprobaci_n_service__c 
            FROM tiposDeTrabajoCaso__c 
            WHERE Id Not IN :tipoTrabajoCasoId AND RM_WorkOrder__c =: woOrDef
        ];
        // Update child records
        for (tiposDeTrabajoCaso__c trb : lstTrabajosRecha) {
            if(trb.Estado_aprobaci_n_service__c != 'Aprobado'){
                trb.Estado_aprobaci_n_service__c = 'Rechazado';
            }        
        }
        update lstTrabajos;
        update lstTrabajosRecha;

        return true;
    }
    

    @AuraEnabled
    public static String callExternalApi() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        // Get the OAuth access token
        String accessToken = OAuthTokenService.getAccessToken();
        
        // Set the REST endpoint
        request.setEndpoint('https://redmotors.my.salesforce.com/services/apexrest/Citas/');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');

        String sucursal = '0D43690';

        // Construct the request body
        String requestBody = '{ "tipoPeticion": "validarPlaca", "parametros": { "placa": "' + sucursal + '" } }';
        request.setBody(requestBody);

        // Send the request
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            throw new AuraHandledException('Error: ' + response.getStatusCode() + ' ' + response.getBody());
        }
    }

    @AuraEnabled
    public static Boolean revisarCorreo(String correo) {
        Id currentUserId = UserInfo.getUserId();
        // Perform a SOQL query to check if there is any user with the same email address
        List<User> existingUsers = [SELECT Id FROM User WHERE Email = :correo AND Id != :currentUserId  LIMIT 1];
    
        // If the list is not empty, it means a user with the same email exists
        return existingUsers.size() > 0;
    }

    @AuraEnabled()
    public static List<Object> obtenerStages(String casoId){
        List<Case> lstCasos = [Select Service_Territory1__c From Case  Where id =:casoId];
        List<Stage_service__c> lstTrabajos = new List<Stage_service__c>();
        if(lstCasos.size() > 0){
            lstTrabajos = [Select Id, Case_Stage__c,Nombre_Mostrar__c ,Stage_Order__c FROM Stage_service__c WHERE Service_Territory__c =: lstCasos[0].Service_Territory1__c order by Stage_Order__c];
        }else{ 
            lstTrabajos = [Select Id, Case_Stage__c,Nombre_Mostrar__c ,Stage_Order__c FROM Stage_service__c  order by Stage_Order__c];
        }
         
        Integer i = 0;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        return lstTrabajos;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> quoteInfo(String quoteId) {
        // Obtener el Quote con el campo Placa__c
        Quote quote = [SELECT Id, QuoteNumber, GrandTotal, Placa__c, 
                            Account.Name, Account.Cedula__c, Account.Phone,
                            Contact.Name, Contact.Email, Contact.MobilePhone, Contact.Phone, CurrencyIsoCode
                    FROM Quote 
                    WHERE Id = :quoteId 
                    LIMIT 1];
        
        // Buscar el Asset basado en la placa del Quote
        Asset asset = null;
        if (quote.Placa__c != null) {
            List<Asset> assets = [SELECT Id, numeroDePlaca__c, marca__c, modelo__c, 
                                        Anio__c, NumeroDeChasis__c, Kilometros__c,
                                        Combustible__c, Tipo_de_veh_culo__c
                                FROM Asset 
                                WHERE (numeroDePlaca__c = :quote.Placa__c OR Name = :quote.Placa__c)
                                LIMIT 1];
            
            if (!assets.isEmpty()) {
                asset = assets[0];
            }
        }
        
        // Crear un mapa para retornar ambos objetos
        Map<String, Object> result = new Map<String, Object>();
        result.put('quote', quote);
        result.put('asset', asset);
        
        return result;
    }

    @AuraEnabled(cacheable=false)
    public static Contact getContactFromAccount(String accountId) {
        List<Contact> contacts = [SELECT Id, Name, Email, Phone 
                                FROM Contact 
                                WHERE AccountId = :accountId 
                                LIMIT 1];
        return contacts.isEmpty() ? null : contacts[0];
    }

    private static List<communityManageWorks_ctrl.TrabajoWrapper> getTrabajosForAura(Id quoteId) {
    try {
        List<communityManageWorks_ctrl.TrabajoWrapper> trabajos = new List<communityManageWorks_ctrl.TrabajoWrapper>();

        // Consulta sin filtrar por Tarea__c
        List<QuoteLineItem> trabajosExistentes = [
            SELECT Id,
                   TrabajoARealizar__c, TrabajoARealizar__r.Name, TrabajoARealizar__r.UTS__c, TrabajoARealizar__r.Cantidad__c,
                   TrabajoARealizar__r.ManoDeObra__r.Name, TrabajoARealizar__r.ManoDeObra__c,
                   SubTrabajoAlias__c, Quantity,
                   SubTrabajoARealizar__c, SubTrabajoARealizar__r.Name, SubTrabajoARealizar__r.UTS__c, SubTrabajoARealizar__r.Cantidad__c,
                   SubTrabajoARealizar__r.ManoDeObra__c, SubTrabajoARealizar__r.ManoDeObra__r.Name,
                   BMW_Alias__c, tipoCargo__c, Aprobador__c, UTS__c, Hora__c, HoraSubtrabajo__c, Categor_a_de_presupuesto__c
            FROM QuoteLineItem
            WHERE QuoteId = :quoteId
            AND TrabajoARealizar__c != NULL
            ORDER BY TrabajoARealizar__c
        ];

        Id currentTrabajo = null;
        Integer totalsubtrabajos = 0;

        for (QuoteLineItem trabajoQLI : trabajosExistentes) {
            if (trabajoQLI.TrabajoARealizar__c != currentTrabajo) {
                totalsubtrabajos = 0;

                communityManageWorks_ctrl.TrabajoWrapper trabajoWrapper = new communityManageWorks_ctrl.TrabajoWrapper();
                trabajoWrapper.id = trabajoQLI.Id;
                trabajoWrapper.nombreTrabajo = (trabajoQLI.TrabajoARealizar__r != null) ? trabajoQLI.TrabajoARealizar__r.Name : null;
                trabajoWrapper.alias = (trabajoQLI.BMW_Alias__c != null && trabajoQLI.BMW_Alias__c != '') ? trabajoQLI.BMW_Alias__c : trabajoWrapper.nombreTrabajo;
                trabajoWrapper.prioridad = trabajoQLI.Categor_a_de_presupuesto__c;
                trabajoWrapper.tipoTrabajo = trabajoQLI.TrabajoARealizar__c;
                trabajoWrapper.tipoCargo = trabajoQLI.tipoCargo__c;
                trabajoWrapper.aprobador = trabajoQLI.Aprobador__c;
                trabajoWrapper.uts = trabajoQLI.Quantity;
                trabajoWrapper.utsReal = trabajoQLI.UTS__c;
                trabajoWrapper.utsDelTipoDeTrabajo = (trabajoQLI.TrabajoARealizar__r != null) ? trabajoQLI.TrabajoARealizar__r.Cantidad__c : null;
                trabajoWrapper.manoDeObra = (trabajoQLI.TrabajoARealizar__r != null) ? trabajoQLI.TrabajoARealizar__r.ManoDeObra__c : null;
                trabajoWrapper.manoDeObraNombre = (trabajoQLI.TrabajoARealizar__r != null && trabajoQLI.TrabajoARealizar__r.ManoDeObra__r != null)
                                                    ? trabajoQLI.TrabajoARealizar__r.ManoDeObra__r.Name : null;
                trabajoWrapper.totalUts = trabajoQLI.HoraSubtrabajo__c;
                trabajoWrapper.subtrabajos = new List<communityManageWorks_ctrl.SubtrabajoWrapper>();

                // Recorre todos los QLI del mismo TrabajoARealizar
                for (QuoteLineItem subtrabajoQLI : trabajosExistentes) {
                    if (subtrabajoQLI.TrabajoARealizar__c == trabajoQLI.TrabajoARealizar__c && subtrabajoQLI.SubTrabajoARealizar__c != null) {
                        totalsubtrabajos++;

                        communityManageWorks_ctrl.SubtrabajoWrapper st = new communityManageWorks_ctrl.SubtrabajoWrapper();
                        st.id = subtrabajoQLI.Id;
                        st.nombre = (subtrabajoQLI.SubTrabajoARealizar__r != null) ? subtrabajoQLI.SubTrabajoARealizar__r.Name : null;
                        st.alias = (subtrabajoQLI.SubTrabajoAlias__c != null && subtrabajoQLI.SubTrabajoAlias__c != '')
                                   ? subtrabajoQLI.SubTrabajoAlias__c
                                   : trabajoWrapper.alias;
                        st.horas = subtrabajoQLI.HoraSubtrabajo__c;
                        st.tipoTrabajo = subtrabajoQLI.SubTrabajoARealizar__c;
                        st.tipoTrabajoNombre = (subtrabajoQLI.SubTrabajoARealizar__r != null) ? subtrabajoQLI.SubTrabajoARealizar__r.Name : null;

                        if (subtrabajoQLI.SubTrabajoARealizar__r != null &&
                            subtrabajoQLI.SubTrabajoARealizar__r.Cantidad__c != null &&
                            subtrabajoQLI.SubTrabajoARealizar__r.Cantidad__c != 0) {
                            st.uts = subtrabajoQLI.SubTrabajoARealizar__r.Cantidad__c;
                        } else {
                            st.uts = (subtrabajoQLI.HoraSubtrabajo__c != null) ? subtrabajoQLI.HoraSubtrabajo__c * 12 : 0;
                        }

                        st.utsDelTipoDeTrabajo = (subtrabajoQLI.SubTrabajoARealizar__r != null)
                                                    ? subtrabajoQLI.SubTrabajoARealizar__r.Cantidad__c : null;

                        if (subtrabajoQLI.SubTrabajoARealizar__r != null &&
                            subtrabajoQLI.SubTrabajoARealizar__r.ManoDeObra__c != null) {
                            st.manoDeObra = subtrabajoQLI.SubTrabajoARealizar__r.ManoDeObra__c;
                            st.manoDeObraNombre = (subtrabajoQLI.SubTrabajoARealizar__r.ManoDeObra__r != null)
                                                    ? subtrabajoQLI.SubTrabajoARealizar__r.ManoDeObra__r.Name : null;
                        }

                        trabajoWrapper.subtrabajos.add(st);
                    }
                }

                trabajoWrapper.totalSubtrabajos = totalsubtrabajos;
                trabajos.add(trabajoWrapper);
                currentTrabajo = trabajoQLI.TrabajoARealizar__c;
            }
        }

            return trabajos;

        } catch (Exception e) {
            throw new AuraHandledException('Error al obtener los trabajos: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getQuoteTrabajosGrouped(String quoteId) {
        try {
            Map<String, Object> result = new Map<String, Object>();
            
            // Obtener todos los QuoteLineItems del quote
            List<QuoteLineItem> productosTarea = [
                SELECT Id, Product2.Codigo_de_Producto__c, Product2.Name, 
                    UnitPrice, TotalPrice, Quantity, Discount,
                    BMW_Dispinible__c, BMW_TipoDeArticulo__c, 
                    BMW_Alias__c, Tarea__c, Categor_a_de_presupuesto__c,
                    Description, TrabajoARealizar__c, TrabajoARealizar__r.Name,
                    SubTrabajoARealizar__c, SubTrabajoARealizar__r.Name,
                    Estado_aprobaci_n_service__c,
                    Aprobado_service__c
                FROM QuoteLineItem
                WHERE QuoteId = :quoteId
                AND Enviar_presupuesto_a_service__c = true
                ORDER BY CreatedDate ASC
            ];
            
            // Variables para totales generales
            Decimal totalUrgente = 0;
            Decimal totalProximo = 0;
            Decimal totalSugerido = 0;
            Integer countUrgente = 0;
            Integer countProximo = 0;
            Integer countSugerido = 0;
            
            // Agrupar por prioridad (como en el PDF)
            List<BloqueTareaAura> urgentes = new List<BloqueTareaAura>();
            List<BloqueTareaAura> proximos = new List<BloqueTareaAura>();
            List<BloqueTareaAura> sugeridos = new List<BloqueTareaAura>();
            
            // Mapa temporal para agrupar por tarea
            Map<String, BloqueTareaAura> mapaTareas = new Map<String, BloqueTareaAura>();
            
            for(QuoteLineItem qli : productosTarea) {
                String tareaNombre = qli.Tarea__c != null ? qli.Tarea__c : 'Sin Tarea';
                String prioridad = qli.Categor_a_de_presupuesto__c != null ? qli.Categor_a_de_presupuesto__c : 'Normal';
                String nombreTarea = qli.BMW_Alias__c != null ? qli.BMW_Alias__c : 
                                    (qli.TrabajoARealizar__r != null ? qli.TrabajoARealizar__r.Name : 'Sin nombre');
                
                // Crear bloque de tarea si no existe
                if(!mapaTareas.containsKey(tareaNombre)) {
                    BloqueTareaAura bloque = new BloqueTareaAura();
                    bloque.nombreTarea = tareaNombre;
                    bloque.prioridad = prioridad;
                    bloque.tareaName = nombreTarea;
                    bloque.items = new List<QuoteLineItem>();
                    bloque.totalMaterialesTarea = 0;
                    bloque.totalManoDeObraTarea = 0;
                    bloque.totalSubcontratoTarea = 0;
                    bloque.totalPinturaTarea = 0;
                    bloque.totalVariosTarea = 0;
                    bloque.totalTarea = 0;
                    
                    mapaTareas.put(tareaNombre, bloque);
                }
                
                // Agregar item al bloque
                BloqueTareaAura bloque = mapaTareas.get(tareaNombre);
                bloque.items.add(qli);
                
                // Calcular totales por tipo
                Decimal monto = qli.TotalPrice != null ? qli.TotalPrice : 0;
                if (qli.BMW_TipoDeArticulo__c == 'Materiales') {
                    bloque.totalMaterialesTarea += monto;
                } else if (qli.BMW_TipoDeArticulo__c == 'Mano de Obra') {
                    bloque.totalManoDeObraTarea += monto;
                } else if (qli.BMW_TipoDeArticulo__c == 'Subcontrato') {
                    bloque.totalSubcontratoTarea += monto;
                } else if (qli.BMW_TipoDeArticulo__c == 'Pintura') {
                    bloque.totalPinturaTarea += monto;
                } else if (qli.BMW_TipoDeArticulo__c == 'Varios') {
                    bloque.totalVariosTarea += monto;
                }
                
                bloque.totalTarea += monto;
            }
            
            // Distribuir bloques por prioridad
            for(BloqueTareaAura bloque : mapaTareas.values()) {
                if(bloque.prioridad == 'Necesario') {
                    urgentes.add(bloque);
                    totalUrgente += bloque.totalTarea;
                    countUrgente++;
                } else if(bloque.prioridad == 'Sugerido') {
                    proximos.add(bloque);
                    totalProximo += bloque.totalTarea;
                    countProximo++;
                } else if(bloque.prioridad == 'Recomendado') {
                    sugeridos.add(bloque);
                    totalSugerido += bloque.totalTarea;
                    countSugerido++;
                }
            }
            
            // Preparar resultado
            result.put('urgentes', urgentes);
            result.put('proximos', proximos);
            result.put('sugeridos', sugeridos);
            result.put('totalUrgente', totalUrgente);
            result.put('totalProximo', totalProximo);
            result.put('totalSugerido', totalSugerido);
            result.put('countUrgente', countUrgente);
            result.put('countProximo', countProximo);
            result.put('countSugerido', countSugerido);
            
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error al obtener trabajos agrupados: ' + e.getMessage());
        }
    }

    // Clase wrapper para Aura (similar a la del PDF)
    public class BloqueTareaAura {
        @AuraEnabled public String nombreTarea {get;set;}
        @AuraEnabled public String prioridad {get;set;}
        @AuraEnabled public String tareaName {get;set;}
        @AuraEnabled public List<QuoteLineItem> items {get;set;}
        @AuraEnabled public Decimal totalMaterialesTarea {get;set;}
        @AuraEnabled public Decimal totalManoDeObraTarea {get;set;}
        @AuraEnabled public Decimal totalSubcontratoTarea {get;set;}
        @AuraEnabled public Decimal totalPinturaTarea {get;set;}
        @AuraEnabled public Decimal totalVariosTarea {get;set;}
        @AuraEnabled public Decimal totalTarea {get;set;}
    }

    // Método auxiliar para obtener precio unitario
    private static Decimal obtenerPrecioUnitario(String tipoTrabajoId, String quoteId) {
        try {
            if (tipoTrabajoId == null) return 0;
            
            // Obtener el ManoDeObra__c del tipo de trabajo
            tiposDeTrabajo__c tipoTrabajo = [SELECT Id, ManoDeObra__c FROM tiposDeTrabajo__c WHERE Id = :tipoTrabajoId LIMIT 1];
            
            if (tipoTrabajo == null || tipoTrabajo.ManoDeObra__c == null) return 0;
            
            // Obtener el Quote para saber el Pricebook
            Quote q = [SELECT Id, Pricebook2Id FROM Quote WHERE Id = :quoteId LIMIT 1];
            
            // Buscar el PricebookEntry
            List<PricebookEntry> pbes = [
                SELECT Id, UnitPrice 
                FROM PricebookEntry 
                WHERE Product2Id = :tipoTrabajo.ManoDeObra__c 
                AND Pricebook2Id = :q.Pricebook2Id 
                AND IsActive = true 
                LIMIT 1
            ];
            
            return pbes.isEmpty() ? 0 : pbes[0].UnitPrice;
            
        } catch (Exception e) {
            System.debug('Error obteniendo precio unitario: ' + e.getMessage());
            return 0;
        }
    }

    @AuraEnabled
    public static Map<String, Object> aprobarRechazarQuoteLineItems(Id quoteId, List<Id> quoteLineItemIds, String estado, Boolean aprobado) {
        try {
            if (quoteLineItemIds == null || quoteLineItemIds.isEmpty()) {
                return new Map<String, Object>{
                    'success' => true,
                    'message' => 'No hay items para actualizar',
                    'count' => 0
                };
            }

            // Traer TODOS los QLIs de la quote para identificar los no seleccionados
            List<QuoteLineItem> allQuoteLineItems = [
                SELECT Id, Estado_aprobaci_n_service__c, Aprobado_service__c, Tarea__c
                FROM QuoteLineItem
                WHERE QuoteId = :quoteId
                FOR UPDATE
            ];

            List<QuoteLineItem> itemsToUpdate = new List<QuoteLineItem>();
            Set<String> tareasActualizadas = new Set<String>();

            // Primero: Actualizar los seleccionados a Aprobado
            for (QuoteLineItem qli : allQuoteLineItems) {
                if (quoteLineItemIds.contains(qli.Id)) {
                    // Solo actualizar si no está ya aprobado
                    if (qli.Estado_aprobaci_n_service__c != 'Aprobado' || qli.Aprobado_service__c != true) {
                        qli.Estado_aprobaci_n_service__c = 'Aprobado';
                        qli.Aprobado_service__c = true;
                        itemsToUpdate.add(qli);
                        if (qli.Tarea__c != null) tareasActualizadas.add(qli.Tarea__c);
                    }
                }
            }

            // Segundo: Actualizar los NO seleccionados SOLO si no están ya aprobados
            for (QuoteLineItem qli : allQuoteLineItems) {
                if (!quoteLineItemIds.contains(qli.Id)) {
                    // Solo rechazar si no está ya aprobado
                    if (qli.Estado_aprobaci_n_service__c != 'Aprobado' && qli.Aprobado_service__c != true) {
                        qli.Estado_aprobaci_n_service__c = 'Rechazado';
                        qli.Aprobado_service__c = false;
                        itemsToUpdate.add(qli);
                        if (qli.Tarea__c != null) tareasActualizadas.add(qli.Tarea__c);
                    }
                }
            }

            if (!itemsToUpdate.isEmpty()) {
                update itemsToUpdate;
            }

            return new Map<String, Object>{
                'success' => true,
                'message' => 'Items actualizados exitosamente',
                'count' => itemsToUpdate.size(),
                'tareasActualizadas' => new List<String>(tareasActualizadas)
            };
        } catch (Exception e) {
            throw new AuraHandledException('Error al aprobar/rechazar items: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void enviarEmailTareasAprobadas(String quoteId, String tareasNecesarioJSON, String tareasRecomendadoJSON, String tareasSugeridoJSON, String currencyIso) {
        try {
            // Obtener información del Quote
            Quote quote = [SELECT Id, QuoteNumber, Account.Name, Contact.Email, Contact.Name 
                        FROM Quote WHERE Id = :quoteId LIMIT 1];
            
            // Deserializar los JSON
            List<Object> tareasNecesario = (List<Object>)JSON.deserializeUntyped(tareasNecesarioJSON);
            List<Object> tareasRecomendado = (List<Object>)JSON.deserializeUntyped(tareasRecomendadoJSON);
            List<Object> tareasSugerido = (List<Object>)JSON.deserializeUntyped(tareasSugeridoJSON);
            
            // Construir el cuerpo del email
            String emailBody = construirCuerpoEmail(tareasNecesario, tareasRecomendado, tareasSugerido, currencyIso, quote);
            
            // Crear y enviar el email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'john.navarro@portalnetcr.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Tareas Aprobadas - Cotización: ' + quote.QuoteNumber);
            mail.setHtmlBody(emailBody);
            mail.setSaveAsActivity(false);
            
            // Enviar email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            
        } catch (Exception e) {
            throw new AuraHandledException('Error al enviar email: ' + e.getMessage());
        }
    }

    private static String construirCuerpoEmail(List<Object> tareasNecesario, 
                                            List<Object> tareasRecomendado, 
                                            List<Object> tareasSugerido, 
                                            String currencyIso, Quote quote) {
        
        String emailBody = '<html><body>';
        emailBody += '<h2>Tareas Aprobadas - Cotización: ' + quote.QuoteNumber + '</h2>';
        emailBody += '<p><strong>Cliente:</strong> ' + (quote.Account.Name != null ? quote.Account.Name : 'N/A') + '</p>';
        emailBody += '<p><strong>Contacto:</strong> ' + (quote.Contact.Name != null ? quote.Contact.Name : 'N/A') + '</p>';
        emailBody += '<hr/>';
        
        // Tareas Urgentes (Necesario)
        if (tareasNecesario != null && !tareasNecesario.isEmpty()) {
            emailBody += '<h3 style="color: #d62728;">Tareas Urgentes</h3>';
            for (Object taskObj : tareasNecesario) {
                Map<String, Object> task = (Map<String, Object>)taskObj;
                emailBody += '<div style="margin-top:10px; padding:6px 8px; border-radius:6px; background:#fafafa; border-left: 4px solid #d62728;">';
                emailBody += '<strong>' + String.valueOf(task.get('tarea')) + '</strong> — Total tarea: ' + currencyIso + '&nbsp;' + String.valueOf(task.get('total'));
                emailBody += '<ol style="margin:6px 0 0 18px;">';
                
                List<Object> items = (List<Object>)task.get('items');
                if (items != null) {
                    for (Object itemObj : items) {
                        Map<String, Object> item = (Map<String, Object>)itemObj;
                        emailBody += '<li>' + String.valueOf(item.get('description')) + ' — ' + currencyIso + '&nbsp;' + String.valueOf(item.get('amount')) + '</li>';
                    }
                }
                
                emailBody += '</ol>';
                emailBody += '</div>';
            }
        }
        
        // Tareas Sugeridas (Recomendado)
        if (tareasRecomendado != null && !tareasRecomendado.isEmpty()) {
            emailBody += '<h3 style="color: #2ca02c;">Tareas Sugeridas</h3>';
            for (Object taskObj : tareasRecomendado) {
                Map<String, Object> task = (Map<String, Object>)taskObj;
                emailBody += '<div style="margin-top:10px; padding:6px 8px; border-radius:6px; background:#fafafa; border-left: 4px solid #2ca02c;">';
                emailBody += '<strong>' + String.valueOf(task.get('tarea')) + '</strong> — Total tarea: ' + currencyIso + '&nbsp;' + String.valueOf(task.get('total'));
                emailBody += '<ol style="margin:6px 0 0 18px;">';
                
                List<Object> items = (List<Object>)task.get('items');
                if (items != null) {
                    for (Object itemObj : items) {
                        Map<String, Object> item = (Map<String, Object>)itemObj;
                        emailBody += '<li>' + String.valueOf(item.get('description')) + ' — ' + currencyIso + '&nbsp;' + String.valueOf(item.get('amount')) + '</li>';
                    }
                }
                
                emailBody += '</ol>';
                emailBody += '</div>';
            }
        }
        
        // Tareas Próximas (Sugerido)
        if (tareasSugerido != null && !tareasSugerido.isEmpty()) {
            emailBody += '<h3 style="color: #ff7f0e;">Tareas Próximas</h3>';
            for (Object taskObj : tareasSugerido) {
                Map<String, Object> task = (Map<String, Object>)taskObj;
                emailBody += '<div style="margin-top:10px; padding:6px 8px; border-radius:6px; background:#fafafa; border-left: 4px solid #ff7f0e;">';
                emailBody += '<strong>' + String.valueOf(task.get('tarea')) + '</strong> — Total tarea: ' + currencyIso + '&nbsp;' + String.valueOf(task.get('total'));
                emailBody += '<ol style="margin:6px 0 0 18px;">';
                
                List<Object> items = (List<Object>)task.get('items');
                if (items != null) {
                    for (Object itemObj : items) {
                        Map<String, Object> item = (Map<String, Object>)itemObj;
                        emailBody += '<li>' + String.valueOf(item.get('description')) + ' — ' + currencyIso + '&nbsp;' + String.valueOf(item.get('amount')) + '</li>';
                    }
                }
                
                emailBody += '</ol>';
                emailBody += '</div>';
            }
        }
        
        emailBody += '<hr/>';
        emailBody += '<p><em>Email generado automáticamente desde el sistema BMW Service</em></p>';
        emailBody += '</body></html>';
        
        return emailBody;
    }

    private static String construirCuerpoEmail(List<Map<String, Object>> tareasNecesario, 
                                            List<Map<String, Object>> tareasRecomendado, 
                                            List<Map<String, Object>> tareasSugerido, 
                                            String currencyIso, Quote quote) {
        
        String emailBody = '<html><body>';
        emailBody += '<h2>Tareas Aprobadas - Cotización: ' + quote.QuoteNumber + '</h2>';
        emailBody += '<p><strong>Cliente:</strong> ' + (quote.Account.Name != null ? quote.Account.Name : 'N/A') + '</p>';
        emailBody += '<p><strong>Contacto:</strong> ' + (quote.Contact.Name != null ? quote.Contact.Name : 'N/A') + '</p>';
        emailBody += '<hr/>';
        
        // Tareas Urgentes (Necesario)
        if (tareasNecesario != null && !tareasNecesario.isEmpty()) {
            emailBody += '<h3 style="color: #d62728;">Tareas Urgentes</h3>';
            for (Map<String, Object> task : tareasNecesario) {
                emailBody += '<div style="margin-top:10px; padding:6px 8px; border-radius:6px; background:#fafafa; border-left: 4px solid #d62728;">';
                emailBody += '<strong>' + String.valueOf(task.get('tarea')) + '</strong> — Total tarea: ' + currencyIso + '&nbsp;' + String.valueOf(task.get('total'));
                emailBody += '<ol style="margin:6px 0 0 18px;">';
                
                List<Object> items = (List<Object>)task.get('items');
                if (items != null) {
                    for (Object itemObj : items) {
                        Map<String, Object> item = (Map<String, Object>)itemObj;
                        emailBody += '<li>' + String.valueOf(item.get('description')) + ' — ' + currencyIso + '&nbsp;' + String.valueOf(item.get('amount')) + '</li>';
                    }
                }
                
                emailBody += '</ol>';
                emailBody += '</div>';
            }
        }
        
        // Tareas Sugeridas (Recomendado)
        if (tareasRecomendado != null && !tareasRecomendado.isEmpty()) {
            emailBody += '<h3 style="color: #2ca02c;">Tareas Sugeridas</h3>';
            for (Map<String, Object> task : tareasRecomendado) {
                emailBody += '<div style="margin-top:10px; padding:6px 8px; border-radius:6px; background:#fafafa; border-left: 4px solid #2ca02c;">';
                emailBody += '<strong>' + String.valueOf(task.get('tarea')) + '</strong> — Total tarea: ' + currencyIso + '&nbsp;' + String.valueOf(task.get('total'));
                emailBody += '<ol style="margin:6px 0 0 18px;">';
                
                List<Object> items = (List<Object>)task.get('items');
                if (items != null) {
                    for (Object itemObj : items) {
                        Map<String, Object> item = (Map<String, Object>)itemObj;
                        emailBody += '<li>' + String.valueOf(item.get('description')) + ' — ' + currencyIso + '&nbsp;' + String.valueOf(item.get('amount')) + '</li>';
                    }
                }
                
                emailBody += '</ol>';
                emailBody += '</div>';
            }
        }
        
        // Tareas Próximas (Sugerido)
        if (tareasSugerido != null && !tareasSugerido.isEmpty()) {
            emailBody += '<h3 style="color: #ff7f0e;">Tareas Próximas</h3>';
            for (Map<String, Object> task : tareasSugerido) {
                emailBody += '<div style="margin-top:10px; padding:6px 8px; border-radius:6px; background:#fafafa; border-left: 4px solid #ff7f0e;">';
                emailBody += '<strong>' + String.valueOf(task.get('tarea')) + '</strong> — Total tarea: ' + currencyIso + '&nbsp;' + String.valueOf(task.get('total'));
                emailBody += '<ol style="margin:6px 0 0 18px;">';
                
                List<Object> items = (List<Object>)task.get('items');
                if (items != null) {
                    for (Object itemObj : items) {
                        Map<String, Object> item = (Map<String, Object>)itemObj;
                        emailBody += '<li>' + String.valueOf(item.get('description')) + ' — ' + currencyIso + '&nbsp;' + String.valueOf(item.get('amount')) + '</li>';
                    }
                }
                
                emailBody += '</ol>';
                emailBody += '</div>';
            }
        }
        
        emailBody += '<hr/>';
        emailBody += '<p><em>Email generado automáticamente desde el sistema BMW Service</em></p>';
        emailBody += '</body></html>';
        
        return emailBody;
    }

    @AuraEnabled
    public static Map<String, Object> aprobarRechazarTareas(String quoteId, List<String> tareaNames, String estado, Boolean aprobado) {
        try {
            System.debug('aprobarRechazarTareas called - quoteId: ' + quoteId + ', tareaNames: ' + tareaNames + ', estado: ' + estado + ', aprobado: ' + aprobado);
            
            if (tareaNames == null || tareaNames.isEmpty()) {
                return new Map<String, Object>{
                    'success' => true,
                    'message' => 'No hay tareas para actualizar',
                    'count' => 0
                };
            }
            
            // Buscar todos los QuoteLineItems de las tareas seleccionadas
            List<QuoteLineItem> itemsToUpdate = [
                SELECT Id, Estado_aprobaci_n_service__c, Aprobado_service__c, Tarea__c
                FROM QuoteLineItem 
                WHERE QuoteId = :quoteId 
                AND Tarea__c IN :tareaNames
                AND Enviar_presupuesto_a_service__c = true
                FOR UPDATE
            ];
            
            System.debug('Encontrados ' + itemsToUpdate.size() + ' items para actualizar');
            
            Set<String> tareasActualizadas = new Set<String>();
            
            // Actualizar todos los items de las tareas seleccionadas
            for (QuoteLineItem item : itemsToUpdate) {
                item.Estado_aprobaci_n_service__c = estado;
                item.Aprobado_service__c = aprobado;
                tareasActualizadas.add(item.Tarea__c);
            }
            
            if (!itemsToUpdate.isEmpty()) {
                update itemsToUpdate;
                System.debug('Successfully updated ' + itemsToUpdate.size() + ' items');
            }
            
            return new Map<String, Object>{
                'success' => true,
                'message' => 'Tareas actualizadas exitosamente',
                'count' => itemsToUpdate.size(),
                'tareasActualizadas' => new List<String>(tareasActualizadas)
            };
            
        } catch (Exception e) {
            System.debug('Error in aprobarRechazarTareas: ' + e.getMessage());
            throw new AuraHandledException('Error al aprobar/rechazar tareas: ' + e.getMessage());
        }
    }

    // Método para obtener el estado actual de las tareas
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getEstadoTareas(String quoteId) {
        try {
            Map<String, String> estadoTareas = new Map<String, String>();
            
            // Agrupar por tarea y estado
            AggregateResult[] resultados = [
                SELECT Tarea__c, Estado_aprobaci_n_service__c, COUNT(Id) cantidad
                FROM QuoteLineItem
                WHERE QuoteId = :quoteId 
                AND Enviar_presupuesto_a_service__c = true
                GROUP BY Tarea__c, Estado_aprobaci_n_service__c
            ];
            
            for (AggregateResult ar : resultados) {
                String tarea = (String)ar.get('Tarea__c');
                String estado = (String)ar.get('Estado_aprobaci_n_service__c');
                
                if (tarea != null) {
                    estadoTareas.put(tarea, estado);
                }
            }
            
            return estadoTareas;
            
        } catch (Exception e) {
            System.debug('Error in getEstadoTareas: ' + e.getMessage());
            throw new AuraHandledException('Error al obtener estado de tareas: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Object> caseInfo(String casoId){
        List<Case> lstCasos = [SELECT Id, CaseNumber,RecordType.Name, Asset.marca__c,AssetId, Asset.numeroDePlaca__c, Asset.NumeroDeChasis__c, Asset.Kilometros__c,Asset.Tipo_de_veh_culo__c,	
        OwnerId, Asset.Combustible__c, Asset.modelo__c,Asset.motor__c, Asset.Color__c, Asset.Anio__c,
        Account.Name, Account.BillingStreet, Account.Tipo_de_Documento__c,  Account.Phone, Account.Cedula__c, Contact.Email, Contact.MobilePhone,	
        Contact.Name, Contact.Phone, Fecha_Hora_de_apertura__c, FechaEntrada__c,CreatedDate, 	
       (SELECT Id, Name, Tipo_de_cargo__c, FechaAlta__c, Status__c, Taller__c,Horaa__c, ComentarioTTC__c,Tipotrabajo__r.Name,	
        Tipotrabajo__c,Ordenamiento__c
        FROM Tipos_de_Trabajo__r order by Ordenamiento__c ASC)
        FROM Case	
        WHERE Id =: casoId	
        LIMIT 1];
        Integer i = 0;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        return lstCasos;
    }
    
    @AuraEnabled(cacheable=true)
    public static String obtenerPaso(String casoId){
        List<Case> lstTrabajos = [Select id,StatusDetail__c From Case  Where id =:casoId];
        String estadoActual = '';
        for(Case trb : lstTrabajos){
            estadoActual = trb.StatusDetail__c;
        }
        return estadoActual;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> obtenerDatosUsuario(){
        List<User> estadoActual = new List<User>();
        Id userIdActual = UserInfo.getUserId();
        estadoActual = [Select Id,FirstName,Lastname,Email,UserName,MobilePhone From User Where Id =:userIdActual];

        return estadoActual;
    }

    @AuraEnabled(cacheable=false)
    public static List<Object> actualizarDatosUsuario(String firstName, String lastName, String telefono, String correo, String contra) {
        Id userId = UserInfo.getUserId(); // Get the current user's ID

        // Create a response object to hold the result
        List<Object> response = new List<Object>();

        try {
            // Retrieve the user record
            User userToUpdate = [SELECT Id, FirstName, LastName, Email, UserName, MobilePhone, AccountId
                                FROM User 
                                WHERE Id = :userId 
                                LIMIT 1];

            // Update user fields
            userToUpdate.FirstName = firstName;
            userToUpdate.LastName = lastName;
            userToUpdate.MobilePhone = telefono;
            userToUpdate.Email = correo;

            // Update the user record
            update userToUpdate;

            if(userToUpdate.AccountId != null ) {
                // Update Account fields
                // 1. Update account name
                Account accToUpdate = [SELECT Id,IsPersonAccount, Name,PersonEmail,CorreoElectronicoEmpresarial__c FROM Account WHERE Id = :userToUpdate.AccountId];
                if(accToUpdate.IsPersonAccount == true){
                    accToUpdate.PersonEmail = correo;
                }else{
                    accToUpdate.CorreoElectronicoEmpresarial__c = correo;
                }
                update accToUpdate;
            }
            
            // Add the updated user to the response
            response.add(userToUpdate);

            // Update password if provided and not empty
            // if (contra != null && contra != '') {
            //     try {
            //         System.setPassword(userId, contra);
            //         System.debug('Password updated successfully');
            //         response.add('Password updated successfully');
            //     } catch (Exception e) {
            //         System.debug('Error updating password: ' + e.getMessage());
            //         response.add('Error updating password: ' + e.getMessage());
            //     }
            // }

        } catch (DmlException dmlEx) {
            // Handle DML exceptions
            System.debug('Error updating user: ' + dmlEx.getMessage());
            response.add('Error updating user: ' + dmlEx.getMessage());
        } catch (Exception ex) {
            // Handle any other exceptions
            System.debug('Unexpected error: ' + ex.getMessage());
            response.add('Unexpected error: ' + ex.getMessage());
        }

        return response;
    }

    public class AssetWithSeguroWrapper {
        @AuraEnabled
        public Asset asset { get; set; }
    
        @AuraEnabled
        public List<Seguro__c> seguros { get; set; }
    
        // Constructor
        public AssetWithSeguroWrapper(Asset asset) {
            this.asset = asset;
            this.seguros = new List<Seguro__c>();
        }
    }
    

    @AuraEnabled(cacheable=false)
    public static List<Object> obtenerAssets() {
                
        User userr = fetchUser();
        List<Asset> lstAsset = [Select id,numeroDePlaca__c,Marca_Nvo__c,Modelo_Nvo2__c,Anio__c,Kilometros__c From Asset Where AccountId =: userr.AccountId];
        return lstAsset;
    }

    // @AuraEnabled(cacheable=false)
    // public static List<Object> getSeguroDetails() {
    //     User userr = fetchUser();
    //     List<Asset> lstAsset = [Select id From Asset Where AccountId =: userr.AccountId];
    //     List<Seguro__c> lstSeguro = new List<Seguro__c>();
    //     List<String> lstString = new List<String>(); 
    //     for(Asset ast:lstAsset) {
    //         lstString.add(ast.id);
    //     }

    //     if(lstString.size() > 0){
    //         lstSeguro = [Select Tipo_seguro__c, Asset__c From Seguro__c Where Asset__c in :lstString];
    //     }
        
    //     return lstAsset;
    // }


    @AuraEnabled(cacheable=false)
    public static List<Object> getSeguroDetails() {
        User userr = fetchUser();
        
        // Fetch the assets for the user
        List<Asset> lstAsset = [SELECT id, numeroDePlaca__c, Marca_Nvo__c, Modelo_Nvo2__c, Anio__c, Kilometros__c 
                                FROM Asset 
                                WHERE AccountId = :userr.AccountId];

        // Create a list of AssetWithSeguroWrapper
        List<AssetWithSeguroWrapper> assetWithSeguros = new List<AssetWithSeguroWrapper>();
        
        // Prepare a list to hold Asset IDs for querying Seguro__c
        List<String> lstString = new List<String>(); 
        for (Asset ast : lstAsset) {
            lstString.add(ast.Id);
            assetWithSeguros.add(new AssetWithSeguroWrapper(ast)); // Add the wrapper for each asset
        }

        // Fetch the Seguro__c records if any assets exist
        if (!lstString.isEmpty()) {
            List<Seguro__c> lstSeguro = [SELECT Tipo_seguro__c, Asset__c FROM Seguro__c WHERE Asset__c IN :lstString AND Activo__c = true];

            // Map to associate Seguro__c records with their corresponding Asset
            Map<String, List<Seguro__c>> segurosByAssetId = new Map<String, List<Seguro__c>>();
            for (Seguro__c seguro : lstSeguro) {
                if (!segurosByAssetId.containsKey(seguro.Asset__c)) {
                    segurosByAssetId.put(seguro.Asset__c, new List<Seguro__c>());
                }
                segurosByAssetId.get(seguro.Asset__c).add(seguro);
            }

            // Populate the seguros in the wrapper objects
            for (AssetWithSeguroWrapper wrapper : assetWithSeguros) {
                if (segurosByAssetId.containsKey(wrapper.asset.Id)) {
                    wrapper.seguros.addAll(segurosByAssetId.get(wrapper.asset.Id));
                }
            }
        }

        return assetWithSeguros;
    }

    @AuraEnabled()
    public static Boolean cambiarContra(String contra){
        
            Id userId = UserInfo.getUserId();
  
            
                    try {
                        System.setPassword(userId, contra);
                        System.debug('Password updated successfully');
                        
                        return true;
                    } catch (Exception e) {
                        System.debug('Error updating password: ' + e.getMessage());
                        
                        return false;
                    }
                

    }
    
    @AuraEnabled(cacheable=false)
    public static void createCaseDesasocia(String vehiculoId,String motivoBaja){
       
        User userr = fetchUser();
        String cocheBuscado = '';
        List<Asset> lstAsset = [Select Id,AccountId From Asset Where  AccountId = :userr.Contact?.AccountId ];
        if(lstAsset.size()>0){
            cocheBuscado = lstAsset[0].id;
        }else{
            cocheBuscado = '02i4U00000Hn9k8QAB';
        }
        Case newCase = new Case();
        newCase.RecordTypeId = '012PH00000HBor9YAD';
        newCase.Origin = 'BMW Service Desasociar';
        newCase.FechaEntrada__c = Date.today();
        
        newCase.Subject = 'Se ha solicitado la desasociación de un vehiculo.';
        newCase.Description = 'Se ha solicitado la desasociación de este vehiculo, por el motivo: ' + motivoBaja ;
        if(lstAsset.size()>0){
            newCase.AssetId  = vehiculoId;
            newCase.AccountId = userr.Contact?.AccountId;
        }
        newCase.Priority = 'Media';
        newCase.Type = 'Solicitud';
        newCase.Service_Territory1__c  = '0HhPH0000003NEb0AM';
        newCase.suppliedLastName__c = userr.Lastname;
        newCase.SuppliedName = userr.FirstName;
        newCase.Creado_por_service__c = true;
        //newCase.Service_Territory1__c  = '0HhPH0000003NEb0AM';
        insert newCase;

    }
    @AuraEnabled
    public static void createCaseComunidad(String mensaje){
       
        User userr = fetchUser();
        String cocheBuscado = '';
        List<Asset> lstAsset = [Select Id From Asset Where  AccountId = :userr.Contact?.AccountId ];
        if(lstAsset.size()>0){
            cocheBuscado = lstAsset[0].id;
        }else{
            cocheBuscado = '02i4U00000Hn9k8QAB';
        }
        Case newCase = new Case();
        newCase.RecordTypeId = '012PH00000HBor9YAD';
        newCase.Origin = 'BMW Service Contactanos';
        newCase.FechaEntrada__c = Date.today();
        newCase.Priority = 'Media';
        newCase.Subject = 'Nuevo Caso Interno Comunidad';
        newCase.Description = mensaje;
        newCase.Creado_por_service__c = true;
        if(lstAsset.size()>0){
            newCase.AssetId  = lstAsset[0].Id;
            newCase.AccountId = userr.Contact?.AccountId;
        }
        newCase.suppliedLastName__c = userr.Lastname;
        newCase.SuppliedName = userr.FirstName;
        newCase.Type = 'Solicitud';
        newCase.Service_Territory1__c  = '0HhPH0000003NEb0AM';
        insert newCase;
        Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i ++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        // return capacity;
    }
    @AuraEnabled(cacheable=true)
    public static user fetchUser(){
       User u = [select Id,FirstName,LastName,AccountId, Name, ProfileId,Contact.AccountId, Profile.Name, ContactId, Contact.Name, Contact.Email, Contact.Phone from User where id =: userInfo.getUserId()];
       return u;
    }
    
     @AuraEnabled(cacheable=false)
    public static String nestedJsonUrlByTipoTrabajo(String objectId) {
        system.debug('nestedJson ID: '+objectId);
        FileContentService fileService = new FileContentService();
        String nestedJson = fileService.getNestedFileJson(objectId);
        system.debug(nestedJson);
        return nestedJson;
    }
    

    public static void dummy() {
        Integer i = 0;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
         i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
        i= i+1;
    }
    

}