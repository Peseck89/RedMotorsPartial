public with sharing class cT_newFacturaProforma {
    public static List<String> currencyFormat = new String[]{'0','number','###,###,##0.00'};
	
    public Opportunity op{set;get;}

	public List<datosProductos> productLine {get;set;}
	public Product2 prod {get;set;}
	public OpportunityLineItem prodLitem {get;set;}

    public cT_newFacturaProforma(Apexpages.StandardController controller) {
		String recordId = controller.getId();

		getData(recordId);
    }

	public void getData(String recordId) {
		list<Opportunity> lstOpp = [SELECT Id,vehiculoProForma__c FROM Opportunity WHERE id =: recordId ];
		if(lstOpp.size()>0){
			List<Product2> lstProd = [SELECT Id,marcaVehiculo__c,modelo__c,Anno__c,Color_Externo__c,combustible__c,Numero_Motor__c 
			,vin__c,cubicaje__c,Cantidad_Cilindros__c,pasajeros__c,Carroceria__c,Peso__c,traccion__c
			,BL__c,Valor_exonerado__c,transmision__c,Familia__c,Marca__c FROM Product2 WHERE Id =: lstOpp[0].vehiculoProForma__c ];

			prodLitem = [SELECT Id,UnitPrice FROM OpportunityLineItem WHERE Product2Id =: lstOpp[0].vehiculoProForma__c AND OpportunityId =: lstOpp[0].id LIMIT 1 ];


			prod = [SELECT Id,marcaVehiculo__c,modelo__c,Anno__c,Color_Externo__c,combustible__c,Numero_Motor__c 
			,vin__c,cubicaje__c,Cantidad_Cilindros__c,pasajeros__c,Carroceria__c,Peso__c,traccion__c
			,BL__c,Valor_exonerado__c,transmision__c,Familia__c,Marca__c FROM Product2 WHERE Id =: lstOpp[0].vehiculoProForma__c ];

			List<datosProductos> listaNueva = new List<datosProductos> ();
			for (Product2 item1 : lstProd) {
                datosProductos nuevoItem = new datosProductos();
				nuevoItem.marca = item1.Marca__c != null & item1.Marca__c != '' ? item1.Marca__c  : 'Por definir';
				nuevoItem.modelo = item1.Familia__c  != null & item1.Familia__c != '' ? item1.Familia__c  : 'Por definir';
				nuevoItem.anio = item1.Anno__c != null & item1.Anno__c != '' ? item1.Anno__c  : 'Por definir';
				nuevoItem.color = item1.Color_Externo__c != null & item1.Color_Externo__c != '' ? item1.Color_Externo__c  : 'Por definir';
				nuevoItem.combustible = item1.combustible__c != null & item1.combustible__c != '' ? item1.combustible__c  : 'Por definir';
				nuevoItem.numMotor = item1.Numero_Motor__c != null & item1.Numero_Motor__c != '' ? item1.Numero_Motor__c  : 'Por definir';
				nuevoItem.numChasis = item1.vin__c != null & item1.vin__c != '' ? item1.vin__c  : 'Por definir';
				nuevoItem.cubicaje = item1.cubicaje__c != null & item1.cubicaje__c != '' ? item1.cubicaje__c  : 'Por definir';
				nuevoItem.cilindros = String.valueOf(item1.Cantidad_Cilindros__c) != null & String.valueOf(item1.Cantidad_Cilindros__c) != '' ? String.valueOf(item1.Cantidad_Cilindros__c) : 'Por definir';
				nuevoItem.capacidad = String.valueOf(item1.pasajeros__c) != null & String.valueOf(item1.pasajeros__c) != '' ? String.valueOf(item1.pasajeros__c) : 'Por definir';
				nuevoItem.carroceria = item1.Carroceria__c != null & item1.Carroceria__c != '' ? item1.Carroceria__c  : 'Por definir';
				nuevoItem.peso = item1.Peso__c != null & item1.Peso__c != '' ? item1.Peso__c  : 'Por definir';
				nuevoItem.traccion = item1.traccion__c != null & item1.traccion__c != '' ? item1.traccion__c  : 'Por definir';
				nuevoItem.transmision = item1.transmision__c != null & item1.transmision__c != '' ? item1.transmision__c  : 'Por definir';
				nuevoItem.bl = item1.BL__c != null & item1.BL__c != '' ? item1.BL__c  : 'Por definir';
				nuevoItem.valorVenta = String.valueOf(item1.Valor_exonerado__c) != null &  String.valueOf(item1.Valor_exonerado__c)!= '' ?  String.valueOf(item1.Valor_exonerado__c)  : 'Por definir';
				
                listaNueva.add(nuevoItem);
            }
			productLine = listaNueva;
		}
		
	}




    public class datosProductos{
		public String marca{get;set;}
		public String modelo{get;set;}
		public String anio{get;set;}
		public String color{get;set;}
		public String combustible{get;set;}
		public String numMotor{get;set;}
		public String numChasis{get;set;}
		public String cubicaje{get;set;}
		public String cilindros{get;set;}
		public String capacidad{get;set;}
		public String carroceria{get;set;}
		public String peso{get;set;}
		public String traccion{get;set;}
		public String transmision{get;set;}
		public String bl{get;set;}
		public String valorVenta{get;set;}

	}	

}