/**
	@Autor: David Leon Sanchez
	@Fecha creacion: 17/08/2017 
	@Proyecto: Altica
	@Proposito: Clase Test para la clase TaskService

**/

@isTest
private class TaskTriggerHandlerTest {

	static{
		TestDataFactory.datosGenerales();
	}

	//Metodo para probar la funcionalidad del metodo llamado updateField dentro de la clase TaskService
	@isTest
	private static void test1() {
		Account acct = new Account();
		acct.FirstName = 'Prueba';
		acct.LastName = 'Prueba';
		insert acct;

		Campaign camp = new Campaign();
		camp.Name = 'Prueba';
		insert camp;

		Opportunity op = new Opportunity();
		op.Name = 'Prueba';
		op.Sucursal__c = 'Pavas';
		op.AccountId = acct.Id;
		op.CloseDate = System.today() + 5;
		op.StageName = 'Test Drive';
		op.Campana__c = TestDataFactory.campanna.Id;
		op.RT_Lead__c = 'BMW';
		insert op;

		Task t = new Task();
		t.Subject = 'Prueba';
		t.OwnerId = UserInfo.getUserId();
		t.Priority = 'Normal';
		t.Status = 'Open';
		t.WhatId = op.Id;
		insert t;

		Test.startTest();
		t.Status = 'Completed';
		update t;
		Test.stopTest();
	}
}