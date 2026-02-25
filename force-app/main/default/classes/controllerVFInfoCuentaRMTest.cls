@isTest 
private class controllerVFInfoCuentaRMTest {

	@isTest
	private static void test1() {
		List<Account> act = new List<Account>();

		TestDataFactory.datosGenerales();
		TestDataFactory.crearCuentas(1);
		act = TestDataFactory.MapCuentas.values();
		PageReference page = Page.vfInfoCuentaRM;
		Test.setCurrentPage(page);

		controllerVFInfoCuentaRM cont = new controllerVFInfoCuentaRM();
		cont.act.PersonEmail = act[0].PersonEmail;

		Test.startTest();
			cont.buscarUsuario();
            cont.act.Sexo__c = 'Hombre';
            cont.act.Profesiones__c = 'Developer';
            cont.act.Tiene_Hijos__c = 'No';
            cont.act.Cantidad_de_hijos__c = 0;
            cont.act.Le_gusta_vacacionar__c = 'SI';
            cont.act.Frecuencia_de_viaje__c = '1 vez al año';
            cont.act.Tipo_de_viaje__c = 'Viaje nacional';
            cont.act.Destino_favorito__c = 'Playa';
            cont.act.PorGeneralSaleVacacionar__c = 'Amigos';
            cont.act.frecuenciaCine__c = '1 vez al mes';
            cont.act.tipoPeliculasGusta__c = 'Acción';
            cont.act.PracticaDeporte__c = 'Si';
            cont.act.tipoDeporte__c = 'Futbol';
            cont.act.EquipoFutbolFavorito__c = 'Deportivo Saprissa';
            cont.act.TipoMusicaPrefiere__c = 'Bachata';
            cont.act.Gustospreferencias__c = 'Si';
            cont.act.TieneGustosPreferencias__c = 'Arte moda';
			cont.guardarInfo();
		Test.stopTest();

	}
}