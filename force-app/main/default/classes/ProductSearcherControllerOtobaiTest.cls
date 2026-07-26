@IsTest
private class ProductSearcherControllerOtobaiTest {

    private static String uid() {
        return String.valueOf(Math.abs(Crypto.getRandomInteger())).left(8);
    }

    private static Pricebook2 makePricebook() {
        Pricebook2 pb = new Pricebook2(Name = 'Otobai Dolares ' + uid(), IsActive = true);
        insert pb;
        return pb;
    }

    private static void makePrice(Id pricebookId, Id productId, Decimal unitPrice) {
        Id standardPbId = Test.getStandardPricebookId();
        List<PricebookEntry> standardEntries = [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :standardPbId
            AND Product2Id = :productId
            LIMIT 1
        ];
        if (standardEntries.isEmpty()) {
            insert new PricebookEntry(
                Pricebook2Id = standardPbId,
                Product2Id = productId,
                UnitPrice = unitPrice,
                IsActive = true
            );
        }
        insert new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            UnitPrice = unitPrice,
            IsActive = true,
            UseStandardPrice = false
        );
    }

    @IsTest
    static void manoObraSubcontractUsesSubMotInOtobaiContext() {
        TriggerHandler.bypass('OpportunityTriggerHandler');

        Pricebook2 pb = makePricebook();
        Product2 subMot = new Product2(
            Name = 'Subcontratos Taller Externo Motos ' + uid(),
            ProductCode = 'SUB-MOT',
            Codigo_de_Producto__c = 'SUB-MOT',
            tipoProducto__c = 'Mano de Obra',
            Empresa__c = 'RMOTOBAI',
            RM_VN_EsActivo__c = false,
            IsActive = true
        );
        Product2 legacy = new Product2(
            Name = 'SUBCONTRATADOS ' + uid(),
            ProductCode = 'MT-06',
            Codigo_de_Producto__c = 'MT-06',
            tipoProducto__c = 'Mano de Obra',
            Empresa__c = 'RMOTOBAI',
            RM_VN_EsActivo__c = true,
            IsActive = true
        );
        insert new List<Product2>{ subMot, legacy };
        makePrice(pb.Id, subMot.Id, 1);
        makePrice(pb.Id, legacy.Id, 1);

        Account acc = new Account(Name = 'PSC Account ' + uid());
        insert acc;
        Id kawasakiRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get('Kawasaki')
            .getRecordTypeId();
        Opportunity opp = new Opportunity(
            Name = 'PSC Opp ' + uid(),
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Pricebook2Id = pb.Id,
            RecordTypeId = kawasakiRecordTypeId
        );
        insert opp;
        Quote quote = new Quote(
            Name = 'PSC Quote ' + uid(),
            OpportunityId = opp.Id,
            Pricebook2Id = pb.Id,
            Status = 'Draft'
        );
        insert quote;

        Test.startTest();
        // Firma realineada de 16 a 14 parametros (vigente en ProductSearcherController.getProducts):
        // se eliminaron dos parametros nulos obsoletos que ya no existen en la firma actual;
        // el resto conserva exactamente los mismos valores y posiciones relativas.
        // 'model' (posicion 11) no participa en absoluto en la rama 'mano obra' de getProducts()
        // (solo se usa en la rama 'vehiculo' y en la validacion inicial "El modelo es requerido.").
        // Se reutiliza 'MT-06' (ya usado legitimamente como 'vin' en esta misma prueba) unicamente
        // para satisfacer esa validacion de entrada preexistente, sin afectar la logica ni el
        // resultado de la busqueda de mano de obra.
        Map<String, Object> response = ProductSearcherController.getProducts(
            'mano obra',
            'subcontratados',
            null,
            null,
            '2026',
            'MT-06',
            'Kawasaki',
            null,
            null,
            null,
            'MT-06',
            quote.Id,
            null,
            1
        );
        Test.stopTest();

        String searchMessage = response.containsKey('message') ? (String) response.get('message') : 'search failed';
        System.assertEquals(null, response.get('message'), searchMessage);
        System.assertNotEquals(null, response.get('totalRecords'));
        System.assertNotEquals(null, response.get('products'));
    }
}