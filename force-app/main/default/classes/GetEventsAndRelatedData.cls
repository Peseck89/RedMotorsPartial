public with sharing class GetEventsAndRelatedData {
    @InvocableMethod
    public static List<List<Campa_a_t_cnica_temp__c>> getEventsAndCampaigns(List<Id> userIds) {
        // Asumimos que solo se pasará un ID de usuario en la lista
        if (userIds.isEmpty()) {
            return new List<List<Campa_a_t_cnica_temp__c>>();
        }

        Id userId = userIds[0];
        List<List<Campa_a_t_cnica_temp__c>> results = new List<List<Campa_a_t_cnica_temp__c>>();
        List<Campa_a_t_cnica_temp__c> results1 = new List<Campa_a_t_cnica_temp__c>();
        
        Date today = Date.today();
        Date fifteenDaysFromNow = today.addDays(15);

        // Obtener todos los eventos para el ID de usuario dado
        List<Event> events = [SELECT Id, Subject, StartDateTime, BMW_Cuenta__c, Activo__r.Id, Activo__r.Name 
                              FROM Event 
                              WHERE Asesor__c = :userId 
                              AND BMW_NuevaCita__c = true
                              AND StartDateTime >= :today 
                              AND StartDateTime <= :fifteenDaysFromNow];
        
        System.debug('events: ' + events);

        // Obtener los IDs de los activos relacionados
        Set<Id> assetIds = new Set<Id>();
        for (Event event : events) {
            System.debug('Assets creados: ' + event.Activo__c);
            if (event.Activo__c != null) {
                assetIds.add(event.Activo__c);
            }
        }
		System.debug('Assets: ' + assetIds);
        
        
        List<Campa_a_t_cnica__c> test = [SELECT Asset__c, Categoria__c, Descripcion__c,  Confirmaci_n_de_lectura__c
                                      FROM Campa_a_t_cnica__c 
                                      WHERE Asset__c IN :assetIds AND Confirmaci_n_de_lectura__c = FALSE];
        
        System.debug('Campa_a_t_cnica__c: ' + test);

        // Obtener todas las campañas relacionadas con los activos obtenidos
        Map<Id, List<Campa_a_t_cnica__c>> assetToCampaignsMap = new Map<Id, List<Campa_a_t_cnica__c>>();
        if (!assetIds.isEmpty()) {
            for (Campa_a_t_cnica__c campaign : [SELECT Asset__c, Categoria__c, Descripcion__c,  Confirmaci_n_de_lectura__c
                                      FROM Campa_a_t_cnica__c 
                                      WHERE Asset__c IN :assetIds AND Confirmaci_n_de_lectura__c = FALSE]) {
                if (!assetToCampaignsMap.containsKey(campaign.Asset__c)) {
                    assetToCampaignsMap.put(campaign.Asset__c, new List<Campa_a_t_cnica__c>());
                }
                assetToCampaignsMap.get(campaign.Asset__c).add(campaign);
            }
        }

        
        for (Event event : events) {
            List<Campa_a_t_cnica__c> relatedCampaigns = assetToCampaignsMap.get(event.Activo__r.Id);
            if (relatedCampaigns != null) {
                for (Campa_a_t_cnica__c campaign : relatedCampaigns) {
                    Campa_a_t_cnica_temp__c info = new Campa_a_t_cnica_temp__c();
                    info.Subject_Event__c = event.Subject;
                    info.Startdate_Event__c= event.StartDateTime;
                    info.Nombre_Cuenta__c= event.BMW_Cuenta__c;
                    info.Placa_veh_culo__c= event.Activo__r.Name;
                    info.Categoria__c = campaign.Categoria__c;
                    info.Descripci_n__c= campaign.Descripcion__c;
                    info.IDCampa_a__c = campaign.Id;
                    //info.eventSubject = event.Subject;
                    

                    results1.add(info);
                }
            } else {
            }
        }

        // Salesforce Flow espera una lista de listas para las variables de salida
        return new List<List<Campa_a_t_cnica_temp__c>> { results1 };
    }
}