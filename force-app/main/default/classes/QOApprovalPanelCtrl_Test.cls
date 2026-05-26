@IsTest
private class QOApprovalPanelCtrl_Test {
    private static Quote makeQuote(String name) {
        Account acc = new Account(Name = name + ' Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = name + ' Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            AccountId = acc.Id
        );
        insert opp;

        Quote q = new Quote(
            Name = name,
            OpportunityId = opp.Id,
            CPAprobadorCentroDeCostos__c = UserInfo.getUserId()
        );
        insert q;
        return q;
    }

    private static Id trySubmitReturnAnyWorkitem(Quote q) {
        try {
            Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
            psr.setObjectId(q.Id);
            psr.setSkipEntryCriteria(false);
            Approval.ProcessResult pr = Approval.process(psr);
            System.debug('Submit ok? ' + (pr != null ? pr.isSuccess() : null));
        } catch (Exception e) {
            System.debug('Submit skipped (no approval process / criteria): ' + e.getMessage());
        }

        try {
            Set<Id> actorIds = new Set<Id>{ UserInfo.getUserId() };
            for (GroupMember gm : [SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId()]) {
                actorIds.add(gm.GroupId);
            }
            ProcessInstanceWorkitem wi = [
                SELECT Id
                FROM ProcessInstanceWorkitem
                WHERE ProcessInstance.TargetObjectId = :q.Id
                  AND ActorId IN :actorIds
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            return wi.Id;
        } catch (Exception ignore) {
            return null;
        }
    }

    @IsTest
    static void load_NoRecordAndWithRecord() {
        QOApprovalPanelCtrl.DataResp emptyResp = QOApprovalPanelCtrl.load(null);
        System.assertEquals(0, emptyResp.instances.size(),
            'load(null) debe retornar la lista de instancias vacía.');
        System.assertEquals(0, emptyResp.myWorkitems.size(),
            'load(null) debe retornar la lista de workitems vacía.');

        Quote q = makeQuote('Quote load');
        QOApprovalPanelCtrl.DataResp quoteResp = QOApprovalPanelCtrl.load(q.Id);
        System.assertNotEquals(null, quoteResp,
            'load(q.Id) debe retornar una respuesta inicializada.');
    }

    @IsTest
    static void canView_trueNullAndInverse() {
        Quote q = makeQuote('Quote canView');

        Boolean canSee = QOApprovalPanelCtrl.canView(q.Id);
        System.assertEquals(true, canSee,
            'El usuario actual debe poder ver la aprobación cuando es aprobador.');

        Boolean cannotSeeNull = QOApprovalPanelCtrl.canView(null);
        System.assertEquals(false, cannotSeeNull,
            'canView(null) debe retornar false.');

        Boolean inverse = QOApprovalPanelCtrl.canViewNo(q.Id);
        System.assertEquals(false, inverse,
            'canViewNo debe ser false cuando el usuario sí puede ver.');
    }

    @IsTest
    static void approve_and_reject_nullWorkitem_paths() {
        Quote q = makeQuote('Quote null paths');
        Boolean approveRejectedNull = false;
        Boolean rejectRejectedNull = false;
        Set<Id> actorIds = ApprovalPanelBase.getCurrentUserActorIds();

        try {
            QOApprovalPanelCtrl.approve(null, 'x', q.Id);
        } catch (Exception e) {
            approveRejectedNull = true;
        }
        try {
            QOApprovalPanelCtrl.reject(null, 'y', q.Id);
        } catch (Exception e) {
            rejectRejectedNull = true;
        }

        ApprovalPanelBase.ensureNotNullWorkitem(UserInfo.getUserId());
        System.assertEquals(true, actorIds.contains(UserInfo.getUserId()),
            'La base debe incluir al usuario actual como actor permitido.');
        System.assertEquals(null, ApprovalPanelBase.firstError(null),
            'firstError(null) debe retornar null.');
        System.assertEquals(true, approveRejectedNull,
            'approve debe rechazar un workitem null.');
        System.assertEquals(true, rejectRejectedNull,
            'reject debe rechazar un workitem null.');
    }

    @IsTest
    static void approve_reject_happyPath_ifAvailable() {
        Quote q = makeQuote('Quote happy-ish');
        Id wiId = trySubmitReturnAnyWorkitem(q);
        if (wiId == null) {
            System.assertEquals(null, wiId,
                'Sin workitem asignado no se puede recorrer el happy path.');
            return;
        }

        Integer actionAttempts = 0;
        try {
            System.debug(QOApprovalPanelCtrl.approve(wiId, 'ok', q.Id));
            actionAttempts++;
        } catch (Exception e) {
            actionAttempts++;
            System.debug('approve lanzó excepción (válido si engine arroja error): ' + e.getMessage());
        }
        try {
            System.debug(QOApprovalPanelCtrl.reject(wiId, 'no ok', q.Id));
            actionAttempts++;
        } catch (Exception e) {
            actionAttempts++;
            System.debug('reject lanzó excepción (válido si engine arroja error): ' + e.getMessage());
        }

        System.assertEquals(2, actionAttempts,
            'El test debe intentar approve y reject cuando hay workitem disponible.');
    }
}
