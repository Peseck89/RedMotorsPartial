/*
	Creado por: David Leon Sanchez IS
	fecha: 07/03/2018
	Descripcion: clase para imprimir el consentimiento informativo, se llama desde un bonton en al objeto cuenta
*/

public with sharing class controllerConsentInfoPersonaFisica  {
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

	public controllerConsentInfoPersonaFisica(){
		act = new Account();

		idCuenta = Apexpages.currentPage().getParameters().get('id');
		consentInfo1 = System.Label.ConInfoFisica1;
		consentInfo2 = System.Label.ConInfoFisica2;
		consentInfo3 = System.Label.ConInfoFisica3;
		consentInfo4 = System.Label.ConInfoFisica4;
		consentInfo5 = System.Label.ConInfoFisica5;
		consentInfo6 = System.Label.ConInfoFisica6;
		consentInfo7 = System.Label.ConInfoFisica7;
		consentInfo8 = System.Label.ConInfoFisica8;

		System.debug('*** id cuenta *** ' + idCuenta);
		if(idCuenta != null){
			System.debug('**** entro **** ');
			act = [SELECT Name, EstadoCivilTipos__c, Cedula__c, Profesiones__c, Empresas__c, Direccion_Residencial__c, Phone, Monto_Ingreso__c,
				PersonEmail FROM Account WHERE Id =: idCuenta LIMIT 1];
		}
	}
}