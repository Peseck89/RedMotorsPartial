/*
	Creado por: David Leon Sanche IS
	Fecha: 13/03/2018
	Descripcion: Clase para la funcionalidad del objeto Account
*/

public without sharing class AccountServices  {
	
	public static Boolean buscarClientes(String cedula){
		String idClienteFisico, idClienteJuridico, idClienteMutuo;

		System.debug(' ** cedula a buscar **  ' + cedula);
		idClienteFisico = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Físico').getRecordTypeId();
		idClienteJuridico = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Jurídico').getRecordTypeId();	
		idClienteMutuo = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RedMotors-Altica').getRecordTypeId();
		Account[] act = [SELECT Name 
							FROM Account 
							WHERE Cedula__c =: cedula AND (RecordTypeId =: idClienteFisico OR RecordTypeId =: idClienteJuridico OR RecordTypeId =: idClienteMutuo) LIMIT 1];
		System.debug(' ** cuentas encontradas ** ' + act);
		if(act.size() > 0){
			return true;
		}
		return false;
	}	
}