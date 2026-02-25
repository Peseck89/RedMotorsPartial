global class WsConvertirTrafico {
	Webservice Static String convertirLead(String leadId){
		TraficoService ts = new TraficoService();
		Lead lead = [SELECT id, LeadSource FROM Lead WHERE id =: leadId];
		List<Lead> allLeads = [SELECT l.Vehiculo_Actual__c, l.Tipo_de_Identificaci_n__c, l.Sucursal__c, l.Status, l.State, l.RecordType__c, l.RecordTypeId, l.Provincia__c, l.Precio4__c, 
								l.Precio3__c, l.Precio2__c, l.Precio1__c, l.PostalCode, l.Phone, l.OwnerId, l.Observaciones__c, l.Numero_de_Identificacion_del__c, l.NumberOfEmployees, 
								l.Name, l.Moto_Actual__c, l.Modelo_De_Inter_s4__c, l.Modelo_De_Inter_s3__c, l.Modelo_De_Inter_s2__c, l.Modelo_De_Inter_s1__c, l.MobilePhone, l.MiddleName, 
								l.Marca__c, l.Marca4__c, l.Marca3__c, l.Marca2__c, l.ListadePreciosVigente__c, l.LeadSource, l.LastName, l.IsConverted, l.Id, l.FirstName, 
								l.FechaPosibleCompra__c, l.Familia4__c, l.Familia3__c, l.Familia2__c, l.Familia1__c, l.EsWeb2Lead_del__c, l.Enviar_Cotizacion__c, l.Email, l.Distrito__c, 
								l.Direccion__c, l.CreatedDate, l.CreatedById, l.Country, l.Codigo_de_producto__c, l.Codigo_de_producto4__c, l.Codigo_de_producto3__c, l.Codigo_de_producto2__c, 
								l.City, l.Canton__c, l.Campana__c, l.Ano_de_Vehiculo_Actual__c, l.Ano_de_Moto_Actual__c, l.Address, l.ConvertedOpportunityId, l.ConvertedContactId, 
								l.ConvertedAccountId FROM Lead l WHERE l.id =: lead.Id];
		if(allLeads.size() > 0){
			ts.UpdateAccountAlready(allLeads);
		}
		return '';
	}
}