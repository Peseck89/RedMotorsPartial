/*
	Creador: David Leon IS.
    Fecha: 07/01/2019
    Descripcion: controlador para la funcionalidad del visualforce vfInfoCuentaRM
*/

public without sharing class controllerVFInfoCuentaRM  {
	
	public Account act{get;set;}
	public Account actUpdate{get;set;}
	public Boolean mostrarCampos{get;set;}
	
	public controllerVFInfoCuentaRM(){
		act = new Account();
		actUpdate = new Account();
		mostrarCampos = false;

		System.debug(' ** cedula ** ' + act.Cedula__c);
	}

	public void buscarUsuario(){
		List<Account> listAct = new List<Account>();
		String idCuentaPersonal, idCuentaCompartida;
        
        idCuentaPersonal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        idCuentaCompartida = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RedMotors-Altica').getRecordTypeId();
        
		System.debug(' ** cedula 2 ** ' + act.PersonEmail);
		if(act.PersonEmail == null){
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Debe ingresar el correo electrónico');
			ApexPages.addMessage(msg);
		}else{
			listAct = [SELECT Id, Name, Vendedorasignado__c, Sexo__c, Profesiones__c, Provincia__c, Tiene_Hijos__c, Cantidad_de_hijos__c, 
						Le_gusta_vacacionar__c, Frecuencia_de_viaje__c, Tipo_de_viaje__c, Destino_favorito__c, PorGeneralSaleVacacionar__c, frecuenciaCine__c, 
						tipoPeliculasGusta__c, PracticaDeporte__c, tipoDeporte__c, EquipoFutbolFavorito__c, TipoMusicaPrefiere__c, TieneGustosPreferencias__c, 
						Gustospreferencias__c, IsPersonAccount, Cedula__c, Completo_Informacion_Personal__c, Marca__c, Extensi_n__c, Estilo__c, Version__c, Anno__c
						FROM Account 
						WHERE PersonEmail =: act.PersonEmail AND (RecordTypeId =: idCuentaPersonal OR RecordTypeId =: idCuentaCompartida) LIMIT 1];
			System.debug(' ** cliente update ** ' + listAct);
			if(!listAct.isEmpty() && listAct.size() > 0){
				if(listAct[0].Completo_Informacion_Personal__c == true){
					ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Cliente ya actualizó la información.');
					ApexPages.addMessage(msg);
				}else{
					mostrarCampos = true;
					actUpdate = listAct[0];
					System.debug(' ** cliente update 2 ** ' + actUpdate);
					System.debug(' ** mostar campos ** ' + mostrarCampos);
				}
			}else{
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Correo Electrónico Invalido.');
				ApexPages.addMessage(msg);
			}
		}
	}

	public void guardarInfo(){
		System.debug(' ** cuenta a guardar ** ' + actUpdate);
		try{
			actUpdate.Completo_Informacion_Personal__c = true;
            actUpdate.Sexo__c = act.Sexo__c;
            actUpdate.Profesiones__c = act.Profesiones__c;
            actUpdate.Tiene_Hijos__c = act.Tiene_Hijos__c;
            actUpdate.Cantidad_de_hijos__c = act.Cantidad_de_hijos__c;
            actUpdate.Le_gusta_vacacionar__c = act.Le_gusta_vacacionar__c;
            actUpdate.Frecuencia_de_viaje__c = act.Frecuencia_de_viaje__c;
            actUpdate.Tipo_de_viaje__c = act.Tipo_de_viaje__c;
            actUpdate.Destino_favorito__c = act.Destino_favorito__c;
            actUpdate.PorGeneralSaleVacacionar__c = act.PorGeneralSaleVacacionar__c;
            actUpdate.frecuenciaCine__c = act.frecuenciaCine__c;
            actUpdate.tipoPeliculasGusta__c = act.tipoPeliculasGusta__c;
            actUpdate.PracticaDeporte__c = act.PracticaDeporte__c;
            actUpdate.tipoDeporte__c = act.tipoDeporte__c;
            actUpdate.EquipoFutbolFavorito__c = act.EquipoFutbolFavorito__c;
            actUpdate.TipoMusicaPrefiere__c = act.TipoMusicaPrefiere__c;
            actUpdate.Gustospreferencias__c = act.Gustospreferencias__c;
            actUpdate.TieneGustosPreferencias__c = act.TieneGustosPreferencias__c;
			update actUpdate;
			mostrarCampos = false;
			act.PersonEmail = '';
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Cliente actualizado satisfactoriamente');
			ApexPages.addMessage(msg);
		}catch(DmlException ex){
			System.debug(' ** error al actualizar cliente ** ' + ex.getMessage());
		}
	}
}