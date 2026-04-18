public class WebServiceAutomationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts  {
    private List<String> oppIds{get;set;}
    public static void runBatch (String contentDocId) {
        ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocId];
        String file = cv.VersionData.toString();
        List<List<String>> csvDataList = parseCSV(file, false);
        List<String> oppIds = new List<String>();
        for(List<String> row : csvDataList) {
            if (row.size() > 1 && row.get(1).startsWith(Oportunidad_de_Financiamiento__c.sobjecttype.getDescribe().getKeyPrefix())) {
                oppIds.add(row.get(1).replace('\n','').replace('\r',''));
            }
        }
        System.debug('oppIds :: ' + oppIds);
        WebServiceAutomationBatch batch = new WebServiceAutomationBatch(oppIds);
        Database.executeBatch(batch, 1);
    }
    
    public WebServiceAutomationBatch(List<String> oppIds) {
        this.oppIds = oppIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Nombre_Cliente_Altica__r.Cedula__c,comportamiento__c,tipoDeProducto__c,tipoMontoFrecuenciaTransacciones__c FROM Oportunidad_de_Financiamiento__c WHERE Id IN :oppIds';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        if (scope.size() > 0) {
            processOpportunity(scope.get(0).Id);
        }
    }
    public void finish(Database.BatchableContext BC) {
    }

    private static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        List<List<String>> allFields = new List<List<String>>();

        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for (String line : lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) continue;

            List<String> fields = line.split(',');
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for (String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    if(makeCompositeField) {
                        compositeField += ',' + field.substring(0, field.length()-1);
                        cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                        makeCompositeField = false;
                    } else {
                        cleanFields.add(field.replaceAll('DBLQT','"'));
                    }
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field.substring(1, field.length());
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field.substring(0, field.length()-1);
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }

            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;
    }
    
    public static void processOpportunity(String oppRecId){
        Oportunidad_de_Financiamiento__c opp = [
            SELECT Nombre_Cliente_Altica__r.Cedula__c,comportamiento__c,tipoDeProducto__c,tipoMontoFrecuenciaTransacciones__c 
            FROM Oportunidad_de_Financiamiento__c WHERE Id= :oppRecId
        ];

        opp = [SELECT Id, Nombre_Cliente_Altica__c,formConozcaSuCliente__c, formularioConozcaSuCliente__c,origenRecursos__c,
                                                estructuraPropiedad__c,comportamiento__c,tipoDeProducto__c,tipoMontoFrecuenciaTransacciones__c,Tipo__c,
                                                Nombre_Cliente_Altica__r.RecordType.Name
                                                FROM Oportunidad_de_Financiamiento__c WHERE Id =:oppRecId LIMIT 1];

        if(opp != null){
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            if(opp.Nombre_Cliente_Altica__r.RecordType.Name == 'Cuenta Empresarial' || opp.Nombre_Cliente_Altica__r.RecordType.Name == 'Cliente Jurídico'){
                formulaDeInfoJuridicoController forDeJuridicoCntrl = new formulaDeInfoJuridicoController(sc);
                forDeJuridicoCntrl.createBuro();
                forDeJuridicoCntrl.save();
            }else {
                formulaDeInfoFisicoController forDeFisicoCntrl = new formulaDeInfoFisicoController(sc);
                forDeFisicoCntrl.redirectForJuridico();
                forDeFisicoCntrl.save();
            }
        }
       	
        CalculateRiskFactorController calRiskFactCntrl = new CalculateRiskFactorController();
        calRiskFactCntrl.oppId = opp.Id;
        calRiskFactCntrl.calculateRiskFactor();
    }
}