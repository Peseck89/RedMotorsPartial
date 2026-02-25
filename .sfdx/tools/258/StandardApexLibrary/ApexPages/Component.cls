Id oppId = '006Nq00000QmDtdIAF';
List<Quote> qs = [SELECT Id, Name, OpportunityId FROM Quote WHERE OpportunityId = :oppId];
System.debug('QUOTES => ' + qs);
