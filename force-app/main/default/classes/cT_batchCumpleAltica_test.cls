@isTest(SeeAllData=true)
public class cT_batchCumpleAltica_test {

	private static testmethod void getFilteredDateTest(){   
        String fechaHoy =  DateTime.now().format('yyyy-MM-dd');
        Integer anio = date.today().year();
        Integer mes = date.today().month();
        Integer dia = date.today().day();
        Date myDate = date.newinstance(anio, mes, dia);
        system.debug(myDate);
        List<RecordType> recordAltica = [SELECT Id FROM RecordType WHERE Name = 'Cliente Físico' LIMIT 1];
        RecordType tiporegistro = recordAltica[0];
        
        Account Acc = new Account(Name='Testersa Acc');
        Acc.Name='Testersa account';
        Acc.Sexo__c = 'Hombre';
        Acc.recordType = tiporegistro;
        Acc.Cedula__c='1816543210';
        Acc.Fecha_Nacimiento__c = mydate;       
        Acc.Tipo_de_Documento__c='02';
        Acc.codigoSoftland__c = '1234';        
        insert Acc;
        System.debug(Acc.id);
		System.debug(Acc.Fecha_Nacimiento__c);
        Oportunidad_de_Financiamiento__c Opp = new Oportunidad_de_Financiamiento__c();
        Opp.Ano__c = '2022';
        Opp.Categoria__c = 'Moto';
        Opp.Distribuidor__c = 'Red Motors';
        Opp.TipoProducto__c = 'Leasing Financiero';
        Opp.Email__c = 'antonio.dorantesperez@outlook.com';
        Opp.Estado__c = 'Aprobada';
        Opp.Subcategoria__c = 'Nuevo';
        Opp.Etapa__c = 'Cliente formalizado.';
        Opp.Fecha_Formalizacion__c = myDate;
        Opp.Nombre_Cliente_Altica__c = Acc.id;
        Opp.ModenaIngreso__c = 'Dólares';
        insert Opp;
        System.debug(Opp.id);
        Test.startTest();
     
        cT_batchCumpleAltica obj = new cT_batchCumpleAltica();
       	id jobid = DataBase.executeBatch(obj); 
        List<Account> lstAcc = [Select Id,Sexo__c,Fecha_Nacimiento__c,PersonEmail From Account WHERE RecordTypeId IN (SELECT Id FROM RecordType WHERE Name = 'Cliente Físico' OR Name = 'Cuenta Personal' OR Name = 'RedMotors-Altica')  AND Id IN (SELECT Nombre_Cliente_Altica__c FROM Oportunidad_de_Financiamiento__c WHERE Estado__c = 'Aprobada' AND Etapa__c = 'Cliente formalizado.') LIMIT 200];
	    obj.execute(null,lstAcc);
        System.debug(jobid);
        Test.stopTest();

    }
    
}