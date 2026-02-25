public with sharing class controllerConsentInfoPersonaJuridica  {
	public Account act{get;set;}
	public String idCuenta{get;set;}
	public String consentInfo1{get;set;}
	public String consentInfo2{get;set;}
	public String consentInfo3{get;set;}
	public String consentInfo4{get;set;}
	public String consentInfo5{get;set;}
	public String consentInfo6{get;set;}
	public String consentInfo7{get;set;}
	public String consentInfo8{get;set;}
	public String consentInfo9{get;set;}

	public controllerConsentInfoPersonaJuridica(){
		act = new Account();
		idCuenta = Apexpages.currentPage().getParameters().get('id');
		consentInfo1 = System.Label.ConInfoJuridica1;
		consentInfo2 = System.Label.ConInfoJuridica2;
		consentInfo3 = System.Label.ConInfoJuridica3;
		consentInfo4 = System.Label.ConInfoJuridica4;
		consentInfo5 = System.Label.ConInfoJuridica5;
		consentInfo6 = System.Label.ConInfoJuridica6;
		consentInfo7 = System.Label.ConInfoJuridica7;
		consentInfo8 = System.Label.ConInfoJuridica8;
		consentInfo9 = System.Label.ConInfoJuridica9;

		System.debug('*** id cuenta *** ' + idCuenta);
		if(idCuenta != null){
			System.debug('**** entro **** ');
			act = [SELECT Name, Nombre_Representante_Legal__c, Cedula__c, Numero_Cedula_Representante_Legal__c, CorreoElectronicoEmpresarial__c, Phone
					FROM Account WHERE Id =: idCuenta LIMIT 1];
		}
	}
}