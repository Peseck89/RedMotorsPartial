@isTest
public class TrabajoQuoteControllerTest {

    @isTest
    static void testTrabajoQuoteController() {
        // ====== SETUP BÁSICO ======
        Pricebook2 pb = new Pricebook2(Name='Test PB', IsActive=true);
        insert pb;

        Product2 manoObra = new Product2(Name='MO Test', Family='Servicios', tipoProducto__c='Mano de Obra', IsActive=true, Codigo_de_Producto__c='MO29');
        Product2 manoObra2 = new Product2(Name='MO Test 2', Family='Servicios', tipoProducto__c='Mano de Obra', IsActive=true, Codigo_de_Producto__c='MO30');
        insert new List<Product2>{ manoObra, manoObra2 };

        PricebookEntry pbe  = new PricebookEntry(Product2Id=manoObra.Id,  Pricebook2Id=pb.Id, UnitPrice=100, IsActive=true);
        PricebookEntry pbe2 = new PricebookEntry(Product2Id=manoObra2.Id, Pricebook2Id=pb.Id, UnitPrice=150, IsActive=true);
        insert new List<PricebookEntry>{ pbe, pbe2 };

        tiposDeTrabajo__c tipoTrabajo  = new tiposDeTrabajo__c(Name='TT-1', ManoDeObra__c=manoObra.Id,  UTS__c=12);
        tiposDeTrabajo__c tipoTrabajo2 = new tiposDeTrabajo__c(Name='TT-2', ManoDeObra__c=manoObra2.Id, UTS__c=12);
        insert new List<tiposDeTrabajo__c>{ tipoTrabajo, tipoTrabajo2 };

        Opportunity opp = new Opportunity(Name='OppTest', StageName='Prospecting', CloseDate=Date.today());
        insert opp;

        Quote q = new Quote(Name='QuoteTest', OpportunityId=opp.Id, Pricebook2Id=pb.Id);
        insert q;

        // ====== QLIs para diferentes escenarios ======
        // Par padre-hijo para deleteSubtrabajo (mismo TrabajoARealizar/SubTrabajoARealizar)
        QuoteLineItem qliPadre = new QuoteLineItem(
            QuoteId=q.Id, PricebookEntryId=pbe.Id, Product2Id=manoObra.Id, UnitPrice=100,
            Quantity=2, UTS__c=24, Hora__c=2,
            TrabajoARealizar__c=tipoTrabajo.Id, SubTrabajoARealizar__c=tipoTrabajo.Id, Tarea__c=tipoTrabajo.Id,
            SubTrabajoAlias__c='padre'
        );
        QuoteLineItem qliHijo = new QuoteLineItem(
            QuoteId=q.Id, PricebookEntryId=pbe.Id, Product2Id=manoObra.Id, UnitPrice=100,
            Quantity=1, UTS__c=12, HoraSubtrabajo__c=1,
            TrabajoARealizar__c=tipoTrabajo.Id, SubTrabajoARealizar__c=tipoTrabajo.Id, Tarea__c=tipoTrabajo.Id,
            SubTrabajoAlias__c='hijo'
        );
        insert new List<QuoteLineItem>{ qliPadre, qliHijo };

        // Grupo extra para deleteTrabajo (mismo TrabajoARealizar__c)
        QuoteLineItem qliTrabajoGrupo2_A = new QuoteLineItem(
            QuoteId=q.Id, PricebookEntryId=pbe2.Id, Product2Id=manoObra2.Id, UnitPrice=150,
            Quantity=1,
            TrabajoARealizar__c=tipoTrabajo2.Id, SubTrabajoARealizar__c=tipoTrabajo2.Id, Tarea__c=tipoTrabajo2.Id,
            SubTrabajoAlias__c='g2-A'
        );
        QuoteLineItem qliTrabajoGrupo2_B = new QuoteLineItem(
            QuoteId=q.Id, PricebookEntryId=pbe2.Id, Product2Id=manoObra2.Id, UnitPrice=150,
            Quantity=1,
            TrabajoARealizar__c=tipoTrabajo2.Id, SubTrabajoARealizar__c=tipoTrabajo2.Id, Tarea__c=tipoTrabajo2.Id,
            SubTrabajoAlias__c='g2-B'
        );
        insert new List<QuoteLineItem>{ qliTrabajoGrupo2_A, qliTrabajoGrupo2_B };

        Test.startTest();

        // ====== updateTareaPrioridad ======
        Id tareaUpdate = TrabajoQuoteController.updateTareaPrioridad(q.Id, tipoTrabajo.Id, 'Necesario');

        // ====== getTrabajos (para tarea tipoTrabajo.Id) ======
        List<TrabajoQuoteController.TrabajoWrapper> trabajos =
            TrabajoQuoteController.getTrabajos(q.Id, tipoTrabajo.Id);

        // ====== saveTrabajo (crea/actualiza un trabajo) ======
        TrabajoQuoteController.TrabajoWrapper wrapper = new TrabajoQuoteController.TrabajoWrapper();
        wrapper.id = null;
        wrapper.tipoTrabajo = tipoTrabajo.Id;
        wrapper.alias = 'Alias test';
        wrapper.uts = 2;
        wrapper.tipoCargo = 'Cliente';
        wrapper.aprobador = 'Asesor';
        wrapper.prioridad = 'Necesario';
        Id qliCreadoId = TrabajoQuoteController.saveTrabajo(wrapper, q.Id);

        // ====== getUTSTipoTrabajo ======
        Decimal uts = TrabajoQuoteController.getUTSTipoTrabajo(tipoTrabajo.Id);

        // ====== saveSubtrabajos (agrega sub al trabajo creado) ======
        TrabajoQuoteController.SubtrabajoWrapper st = new TrabajoQuoteController.SubtrabajoWrapper();
        st.id = null;
        st.tipoTrabajo = tipoTrabajo.Id; // usa TT-1 (tiene ManoDeObra y PBE válido)
        st.alias = 'ST Alias';
        st.uts = 2;
        List<TrabajoQuoteController.SubtrabajoWrapper> subs = new List<TrabajoQuoteController.SubtrabajoWrapper>{ st };
        TrabajoQuoteController.saveSubtrabajos(tipoTrabajo.Id, qliCreadoId, tipoTrabajo.Id, subs, q.Id, 'Necesario', 'Cliente');

        // ====== deleteSubtrabajo (sobre el hijo del primer grupo) ======
        TrabajoQuoteController.deleteSubtrabajo(qliHijo.Id, q.Id);

        // ====== deleteTrabajo (borra el A y, si aplica, sus "subtrabajos" del grupo 2) ======
        TrabajoQuoteController.deleteTrabajo(qliTrabajoGrupo2_A.Id, q.Id);

        // ====== archivarTarea (con flag de recordatorio) ======
        Id tareaArchivada = TrabajoQuoteController.archivarTarea(q.Id, tipoTrabajo.Id, true);

        Test.stopTest();
    }
}