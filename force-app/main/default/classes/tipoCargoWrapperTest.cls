@isTest(SeeAllData=true)
public class tipoCargoWrapperTest {

    @isTest
    static void testTipoCargoWrapperWithExistingData() {
        // Fetch an existing tipoCargo__c record
        tipoCargo__c tc = [SELECT Id FROM tipoCargo__c LIMIT 1];

        // Fetch related Subtipo_de_trabajo_del_caso__c records
        List<Subtipo_de_trabajo_del_caso__c> subtipos = [
            SELECT Id, Name, Articulo_Mano_de_Obra__c
            FROM Subtipo_de_trabajo_del_caso__c
            WHERE Articulo_Mano_de_Obra__c = :tc.Id
        ];

        // Ensure there is at least one subtipo for the test
        //System.assert(subtipos.size() > 0, 'There should be at least one related Subtipo_de_trabajo_del_caso__c record.');

        // Create the wrapper instance
        tipoCargoWrapper wrapper = new tipoCargoWrapper(tc, subtipos);

        // Assert the wrapper values

    }
}