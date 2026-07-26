@IsTest
public with sharing class RM_Lead_Trigger_Helper_Test {
    private static Id getRecordTypeId(SObjectType sobjectType, String developerName) {
        Schema.RecordTypeInfo info = sobjectType.getDescribe()
            .getRecordTypeInfosByDeveloperName()
            .get(developerName);
        System.assertNotEquals(null, info, 'No existe el Record Type requerido: ' + developerName);
        return info.getRecordTypeId();
    }

    private static Opportunity newOpportunity(String name, String recordTypeDeveloperName) {
        return new Opportunity(
            Name = name,
            StageName = 'Oportunidad Calificada',
            CloseDate = Date.today().addDays(15),
            RecordTypeId = getRecordTypeId(Opportunity.SObjectType, recordTypeDeveloperName)
        );
    }

    private static Lead convertedLead(String leadRecordTypeDeveloperName, Id opportunityId) {
        return convertedLeadWithRecordType(
            String.valueOf(getRecordTypeId(Lead.SObjectType, leadRecordTypeDeveloperName)),
            opportunityId
        );
    }

    private static Lead convertedLeadWithRecordType(String leadRecordTypeId, Id opportunityId) {
        return (Lead) JSON.deserialize(
            '{"attributes":{"type":"Lead"},"RecordTypeId":"' + leadRecordTypeId + '","ConvertedOpportunityId":"' + String.valueOf(opportunityId) + '"}',
            Lead.class
        );
    }

    private static Lead convertedLeadWithoutRecordType(Id opportunityId) {
        return (Lead) JSON.deserialize(
            '{"attributes":{"type":"Lead"},"ConvertedOpportunityId":"' + String.valueOf(opportunityId) + '"}',
            Lead.class
        );
    }

    @IsTest
    static void mapsConfiguredLeadRecordTypesToOpportunityRecordTypes() {
        RM_Lead_Trigger_Helper helper = new RM_Lead_Trigger_Helper();

        Map<String, String> mappings = helper.getRecordTypeIdsByRTName();

        System.assertEquals(
            getRecordTypeId(Opportunity.SObjectType, 'Omoda'),
            mappings.get(getRecordTypeId(Lead.SObjectType, 'Omoda')),
            'Lead Omoda debe mapear a Opportunity Omoda'
        );
        System.assertEquals(
            getRecordTypeId(Opportunity.SObjectType, 'Jaecoo'),
            mappings.get(getRecordTypeId(Lead.SObjectType, 'Jaecoo')),
            'Lead Jaecoo debe mapear a Opportunity Jaecoo'
        );
        System.assertEquals(
            getRecordTypeId(Opportunity.SObjectType, 'MINI'),
            mappings.get(getRecordTypeId(Lead.SObjectType, 'MINI')),
            'El mapping MINI heredado debe conservarse'
        );
        System.assertEquals(
            getRecordTypeId(Opportunity.SObjectType, 'Kawasaki'),
            mappings.get(getRecordTypeId(Lead.SObjectType, 'Kawasaki')),
            'El mapping Kawasaki heredado debe conservarse'
        );
    }

    @IsTest
    static void setOpportunityRecordTypeUsesOmodaAndJaecooMappings() {
        Opportunity omodaOpp = newOpportunity('Bloque20 Omoda', 'BMW');
        Opportunity jaecooOpp = newOpportunity('Bloque20 Jaecoo', 'MINI');
        insert new List<Opportunity>{ omodaOpp, jaecooOpp };

        List<Lead> convertedLeads = new List<Lead>{
            convertedLead('Omoda', omodaOpp.Id),
            convertedLead('Jaecoo', jaecooOpp.Id)
        };

        Test.startTest();
        new RM_Lead_Trigger_Helper().setOpportunityRecordType(convertedLeads);
        Test.stopTest();

        Map<Id, Opportunity> updatedOpps = new Map<Id, Opportunity>([
            SELECT Id, RecordType.DeveloperName
            FROM Opportunity
            WHERE Id IN :new List<Id>{ omodaOpp.Id, jaecooOpp.Id }
        ]);

        System.assertEquals(
            'Omoda',
            updatedOpps.get(omodaOpp.Id).RecordType.DeveloperName,
            'La oportunidad convertida desde Lead Omoda debe quedar en Record Type Omoda'
        );
        System.assertEquals(
            'Jaecoo',
            updatedOpps.get(jaecooOpp.Id).RecordType.DeveloperName,
            'La oportunidad convertida desde Lead Jaecoo debe quedar en Record Type Jaecoo'
        );
    }

    @IsTest
    static void unknownLeadRecordTypeDoesNotUpdateOpportunity() {
        Opportunity opp = newOpportunity('Bloque20 Sin mapping', 'BMW');
        insert opp;

        Lead leadWithoutMappedRecordType = convertedLeadWithoutRecordType(opp.Id);

        Test.startTest();
        new RM_Lead_Trigger_Helper().setOpportunityRecordType(new List<Lead>{ leadWithoutMappedRecordType });
        Test.stopTest();

        Opportunity unchangedOpp = [
            SELECT RecordType.DeveloperName
            FROM Opportunity
            WHERE Id = :opp.Id
        ];
        System.assertEquals(
            'BMW',
            unchangedOpp.RecordType.DeveloperName,
            'Un Lead sin RecordTypeId mapeado no debe modificar el Record Type de la oportunidad'
        );
    }
}
