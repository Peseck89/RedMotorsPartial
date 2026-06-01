@IsTest
private class VN_RQ106_OppAnticipoSyncTest {
    private static Opportunity createOpportunity(String name) {
        Account account = new Account(Name = 'Cliente ' + name);
        insert account;

        Opportunity opportunity = new Opportunity(
            Name = name,
            AccountId = account.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            CurrencyIsoCode = 'USD',
            Estado_Anticipo__c = 'Pendiente'
        );
        insert opportunity;
        return opportunity;
    }

    private static Anticipo__c buildAnticipo(Id opportunityId, String status, Decimal amount) {
        return new Anticipo__c(
            Oportunidad__c = opportunityId,
            Tipo_Ingreso__c = 'Abono',
            Medio_Pago__c = 'Transferencia',
            Fecha_Ingreso__c = Date.today(),
            Referencia_Comprobante__c = 'SYNC-' + String.valueOf(amount),
            Depositante__c = 'Cliente Sync',
            Monto__c = amount,
            CurrencyIsoCode = 'USD',
            Estatus__c = status
        );
    }

    @IsTest
    static void afterDeleteClearsStateWhenNoAnticiposRemain() {
        Opportunity opportunity = createOpportunity('VN-RQ106 Sync Sin Anticipos');
        Anticipo__c anticipo = buildAnticipo(opportunity.Id, 'Borrador', 100);
        insert anticipo;

        Opportunity pendingOpportunity = [
            SELECT Estado_Anticipo__c
            FROM Opportunity
            WHERE Id = :opportunity.Id
        ];
        System.assertEquals('Pendiente', pendingOpportunity.Estado_Anticipo__c);

        delete anticipo;

        Opportunity clearedOpportunity = [
            SELECT Estado_Anticipo__c
            FROM Opportunity
            WHERE Id = :opportunity.Id
        ];
        System.assertEquals(null, clearedOpportunity.Estado_Anticipo__c);
    }

    @IsTest
    static void pendingStatusesSetOpportunityPending() {
        Opportunity opportunity = createOpportunity('VN-RQ106 Sync Pendiente');

        insert new List<Anticipo__c>{
            buildAnticipo(opportunity.Id, 'Borrador', 100),
            buildAnticipo(opportunity.Id, 'En validación de Tesorería', 200),
            buildAnticipo(opportunity.Id, 'Corrección requerida por Tesorería', 300),
            buildAnticipo(opportunity.Id, 'Confirmada por Tesorería', 400),
            buildAnticipo(opportunity.Id, 'Anticipo creado', 500),
            buildAnticipo(opportunity.Id, 'Error de integración', 600)
        };

        Opportunity updatedOpportunity = [
            SELECT Estado_Anticipo__c
            FROM Opportunity
            WHERE Id = :opportunity.Id
        ];
        System.assertEquals('Pendiente', updatedOpportunity.Estado_Anticipo__c);
    }

    @IsTest
    static void cancelledStatusesSetOpportunityCancelledAndUndeleteResyncs() {
        Opportunity opportunity = createOpportunity('VN-RQ106 Sync Cancelado');

        List<Anticipo__c> anticipos = new List<Anticipo__c>{
            buildAnticipo(opportunity.Id, 'Rechazada por Tesorería', 100),
            buildAnticipo(opportunity.Id, 'Reserva rechazada', 200),
            buildAnticipo(opportunity.Id, 'Cancelado', 300)
        };
        insert anticipos;

        Opportunity cancelledOpportunity = [
            SELECT Estado_Anticipo__c
            FROM Opportunity
            WHERE Id = :opportunity.Id
        ];
        System.assertEquals('Cancelado', cancelledOpportunity.Estado_Anticipo__c);

        delete anticipos;

        Opportunity clearedOpportunity = [
            SELECT Estado_Anticipo__c
            FROM Opportunity
            WHERE Id = :opportunity.Id
        ];
        System.assertEquals(null, clearedOpportunity.Estado_Anticipo__c);

        undelete anticipos[0];

        Opportunity restoredOpportunity = [
            SELECT Estado_Anticipo__c
            FROM Opportunity
            WHERE Id = :opportunity.Id
        ];
        System.assertEquals('Cancelado', restoredOpportunity.Estado_Anticipo__c);
    }

    @IsTest
    static void appliedAndReservedStatusesSetOpportunityReceived() {
        Opportunity appliedOpportunity = createOpportunity('VN-RQ106 Sync Aplicado');
        Opportunity reservedOpportunity = createOpportunity('VN-RQ106 Sync Reservado');

        insert new List<Anticipo__c>{
            buildAnticipo(appliedOpportunity.Id, 'Aplicado', 100),
            buildAnticipo(reservedOpportunity.Id, 'Vehículo reservado', 200)
        };

        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([
            SELECT Estado_Anticipo__c
            FROM Opportunity
            WHERE Id IN :new Set<Id>{ appliedOpportunity.Id, reservedOpportunity.Id }
        ]);

        System.assertEquals('Recibido', opportunities.get(appliedOpportunity.Id).Estado_Anticipo__c);
        System.assertEquals('Recibido', opportunities.get(reservedOpportunity.Id).Estado_Anticipo__c);
    }

    @IsTest
    static void receivedStatusWinsOverCancelledAndBulkUpdatesAffectedOpportunities() {
        Opportunity firstOpportunity = createOpportunity('VN-RQ106 Sync Prioridad 1');
        Opportunity secondOpportunity = createOpportunity('VN-RQ106 Sync Prioridad 2');

        Anticipo__c receivedAnticipo = buildAnticipo(firstOpportunity.Id, 'Aplicado', 100);
        Anticipo__c cancelledAnticipo = buildAnticipo(firstOpportunity.Id, 'Rechazada por Tesorería', 200);
        Anticipo__c pendingAnticipo = buildAnticipo(secondOpportunity.Id, 'Borrador', 300);
        insert new List<Anticipo__c>{ receivedAnticipo, cancelledAnticipo, pendingAnticipo };

        Map<Id, Opportunity> initialStates = new Map<Id, Opportunity>([
            SELECT Estado_Anticipo__c
            FROM Opportunity
            WHERE Id IN :new Set<Id>{ firstOpportunity.Id, secondOpportunity.Id }
        ]);
        System.assertEquals('Recibido', initialStates.get(firstOpportunity.Id).Estado_Anticipo__c);
        System.assertEquals('Pendiente', initialStates.get(secondOpportunity.Id).Estado_Anticipo__c);

        receivedAnticipo.Estatus__c = 'Reserva rechazada';
        pendingAnticipo.Estatus__c = 'Vehículo reservado';
        update new List<Anticipo__c>{ receivedAnticipo, pendingAnticipo };

        Map<Id, Opportunity> updatedStates = new Map<Id, Opportunity>([
            SELECT Estado_Anticipo__c
            FROM Opportunity
            WHERE Id IN :new Set<Id>{ firstOpportunity.Id, secondOpportunity.Id }
        ]);
        System.assertEquals('Cancelado', updatedStates.get(firstOpportunity.Id).Estado_Anticipo__c);
        System.assertEquals('Recibido', updatedStates.get(secondOpportunity.Id).Estado_Anticipo__c);
    }
}
