@isTest
public class cT_improductivoRecurrenteTest {
    private static testmethod void getFilteredDateTest(){        
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        insert acc;
        Contact con = new Contact();
        con.LastName = 'testContact';
        con.FirstName = 'Luis';
        con.AccountId = acc.Id;
        insert con;
        tiposDeTrabajo__c  tipoTrabajo = new tiposDeTrabajo__c();
        tipoTrabajo.Name = 'Trabajo test';
        insert tipoTrabajo;
        Date fecha1 = date.today();
        Date fecha2 = fecha1.addDays(18);
        Date fecha3 = fecha1.addDays(60);
        Time myTime = Time.newInstance(1, 2, 3, 0);
        Time myTime2 = Time.newInstance(2, 4, 6, 0);
		Horas_improductivas_por_mec_nico__c objAgregar = new Horas_improductivas_por_mec_nico__c();
		objAgregar.Inicio__c = fecha1;
       	objAgregar.Fin__c = fecha2;
        objAgregar.Hora_inicio__c = myTime;
        objAgregar.Hora_fin__c = myTime2;
		objAgregar.Observaciones__c = 'Test';
        Datetime tiempoInicial = Date.today();
        objAgregar.Inicio_de_tiempo_Improductivo__c = tiempoInicial;
        objAgregar.Fin_de_tiempo_Improductivo__c = tiempoInicial.addHours(3);
        objAgregar.Mecanico__c = con.Id;
        objAgregar.Se_repite__c = 'Semanalmente';
        objAgregar.Tipo_de_Trabajo__c = tipoTrabajo.Id;
        objAgregar.L__c = true;
        objAgregar.K__c = true;
        objAgregar.M__c = true;
        objAgregar.J__c = true;
        objAgregar.V__c = true;


        test.startTest();
			insert objAgregar;
        test.stopTest();
    }
    
    private static testmethod void getFilteredDateTest2(){        
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        insert acc;
        Contact con = new Contact();
        con.LastName = 'testContact';
        con.AccountId = acc.Id;
        insert con;
        tiposDeTrabajo__c  tipoTrabajo = new tiposDeTrabajo__c();
        tipoTrabajo.Name = 'Trabajo test';
        insert tipoTrabajo;
        Date fecha1 = date.today();
        Date fecha2 = fecha1.addDays(18);
        Date fecha3 = fecha1.addDays(4);
        Time myTime = Time.newInstance(1, 2, 3, 0);
        Time myTime2 = Time.newInstance(2, 4, 6, 0);
        Horas_improductivas_por_mec_nico__c objAgregar2 = new Horas_improductivas_por_mec_nico__c();
		objAgregar2.Inicio__c = fecha1;
       	objAgregar2.Fin__c = fecha3;
        objAgregar2.Hora_inicio__c = myTime;
        objAgregar2.Hora_fin__c = myTime2;
		objAgregar2.Observaciones__c = 'Test';
        objAgregar2.Mecanico__c = con.Id;
        objAgregar2.Se_repite__c = 'Mensualmente';
        objAgregar2.Tipo_de_Trabajo__c = tipoTrabajo.Id;
        objAgregar2.L__c = false;
        objAgregar2.K__c = false;
        objAgregar2.M__c = false;
        objAgregar2.J__c = false;
        objAgregar2.V__c = false;
        Datetime tiempoInicial = Date.today();
        objAgregar2.Inicio_de_tiempo_Improductivo__c = tiempoInicial;
        objAgregar2.Fin_de_tiempo_Improductivo__c = tiempoInicial.addHours(3);
        objAgregar2.Numero_de_meses__c = 3;
        test.startTest();
			insert objAgregar2;
        test.stopTest();
    }
}