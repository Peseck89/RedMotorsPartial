@isTest()
public class cT_eventoHistorico_test {
    @testSetup
    static void setupTestData() {
        Horarios_Historicos__c nuevoHistorial = new Horarios_Historicos__c();
        nuevoHistorial.Evento_Origen__c = '00UPH000004LAms2AG';
        datetime myDate = datetime.now();
        
        nuevoHistorial.Hora_Original__c  = myDate;
        nuevoHistorial.Horario_Modificado__c  = myDate.addMinutes(30);
        insert nuevoHistorial;
    }
	@isTest
    static void testGetHistorico() {
	    cT_eventoHistorico_ctrl.getHistorico('00UPH000004LAms2AG');
    }
}