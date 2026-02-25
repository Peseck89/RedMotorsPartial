/**
  @Autor: David Leon Sanchez
  @Fecha creacion: 08/01/2019
  @Proyecto: Red Motors
  @Proposito: Controlador para el componente llamado plantillaCotizacionTrafico
 **/

public with sharing class controllerPlantillaCotizacionTrafico {
    
    public Id idTrafico{get;set;}
    public Id idPropietario{get;set;}
	public Lead l{get;set;}
	//public Boolean showMINI{get;set;}
    
    public controllerPlantillaCotizacionTrafico(){
		
    }   
    
    public List<datosProductos> productos {
        get {
            if(productos == null) {
                productos = this.getListDataProducts();
            }
            return productos;
        }
        set;
    } 
    
    public User user {
        get {
            if(user == null) {
                user = new User();
                for (User t:[SELECT Id, Email, Name, MobilePhone FROM User WHERE ID = :idPropietario]) {
                    user = t;
                }
				System.debug(' ** user ** ' + user);                
            }
            return user;
        }
        set;
    }  
	
	public datosLogoMarca imagenLogo{
		get{
			if(imagenLogo == null){
				imagenLogo = new datosLogoMarca();
				if(l.RecordType.Name == 'Kawasaki'){
					//Sandbox Pruebas
					//imagenLogo.source = 'https://c.cs95.content.force.com/servlet/servlet.ImageServer?id=0150P000004zrE9&oid=00D1g0000008euk&lastMod=1489604115000';
					//Sandbox Produccion
					imagenLogo.source = 'https://c.na37.content.force.com/servlet/servlet.ImageServer?id=0150P000004zrE9&oid=00D0P000000Dvkz&lastMod=1489604115000';
					imagenLogo.height = 100;
					imagenLogo.width = 600;
				}else if(l.RecordType.Name == 'Motorrad'){
					//Sandbox Pruebas
					//imagenLogo.source = 'https://c.cs95.content.force.com/servlet/servlet.ImageServer?id=0150P000004zrEE&oid=00D1g0000008euk&lastMod=1489604116000';
					//Sandbox Produccion
					imagenLogo.source = 'https://c.na37.content.force.com/servlet/servlet.ImageServer?id=0150P000004zrEE&oid=00D0P000000Dvkz&lastMod=1489604116000';
					imagenLogo.height = 200;
					imagenLogo.width = 200;
				}else if(l.RecordType.Name == 'Polaris'){
					//Sandbox Pruebas
					//imagenLogo.source = 'https://c.cs95.content.force.com/servlet/servlet.ImageServer?id=0150P000004zrEC&oid=00D1g0000008euk&lastMod=1489604115000';
					//Sandbox Produccion
					imagenLogo.source = 'https://c.na37.content.force.com/servlet/servlet.ImageServer?id=0150P000004zrEC&oid=00D0P000000Dvkz&lastMod=1489604115000';
					imagenLogo.height = 90;
					imagenLogo.width = 600;
				}else if(l.RecordType.Name == 'Harley_Davidson'){
					//Sandbox Pruebas
					//imagenLogo.source = 'https://c.cs95.content.force.com/servlet/servlet.ImageServer?id=0151g0000000oLV&oid=00D1g0000008euk&lastMod=1515777570000';
					//Sandbox Produccion
					imagenLogo.source = 'https://c.na37.content.force.com/servlet/servlet.ImageServer?id=0150P000006aAfz&oid=00D0P000000Dvkz&lastMod=1512768476000';
					imagenLogo.height = 90;
					imagenLogo.width = 200;
				}
			}
			return imagenLogo;
		}
		set;
	} 

    public List<datosProductos> getListDataProducts(){
        List<datosProductos> infoFinal = new List<datosProductos>();
        
		System.debug(' ** id lead plantilla ** ' + idTrafico);
        if (idTrafico!=null) {
            l = [SELECT RecordType.Name, Name, Marca__c, Marca2__c, Marca3__c, Marca4__c, Modelo_De_Inter_s1__c, Modelo_De_Inter_s2__c, Modelo_De_Inter_s3__c, 
            		Modelo_De_Inter_s4__c, Ano1__c, Ano2__c, Ano3__c, Ano4__c, Precio1__c, Precio2__c, Precio3__c, Precio4__c, Cotizacion_1__c, Cotizacion_2__c, 
            		Cotizacion_3__c, Cotizacion_4__c FROM Lead WHERE id =: idTrafico];
			System.debug(' ** lead encontrado ** ' + l);
			if(l.Cotizacion_1__c == true || l.Cotizacion_2__c == true || l.Cotizacion_3__c == true || l.Cotizacion_4__c == true){
				System.debug(' ** metodo uno ** ');
				if(l.Marca__c != null && l.Cotizacion_1__c == true){
					datosProductos temp = new datosProductos();
					List<String> args = new String[]{'0', 'number', '000,000.00'};
					String s = String.format(l.Precio1__c.format(), args);

					temp.Marca = l.Marca__c;
					temp.Modelo = getModelString(l.Modelo_De_Inter_s1__c);
					temp.precioLista = s;
					//temp.precioLista = l.Precio1__c;
					temp.Anno = l.Ano1__c;
					infoFinal.add(temp);
				}
				if(l.Marca2__c != null && l.Cotizacion_2__c == true){
					datosProductos temp2 = new datosProductos();
					List<String> args2 = new String[]{'0', 'number', '000,000.00'};
					String s2 = String.format(l.Precio2__c.format(), args2);

					temp2.Marca = l.Marca2__c;
					temp2.Modelo = getModelString(l.Modelo_De_Inter_s2__c);
					temp2.precioLista = s2;
					//temp2.precioLista = l.Precio2__c;
					temp2.Anno = l.Ano2__c;
					infoFinal.add(temp2);
				}
				if(l.Marca3__c != null && l.Cotizacion_3__c == true){
					datosProductos temp3 = new datosProductos();
					List<String> args3 = new String[]{'0', 'number', '000,000.00'};
					String s3 = String.format(l.Precio3__c.format(), args3);

					temp3.Marca = l.Marca3__c;
					temp3.Modelo = getModelString(l.Modelo_De_Inter_s3__c);
					temp3.precioLista = s3;
					//temp3.precioLista = l.Precio3__c;
					temp3.Anno = l.Ano3__c;
					infoFinal.add(temp3);
				}
				if(l.Marca4__c != null && l.Cotizacion_4__c == true){
					datosProductos temp4 = new datosProductos();
					List<String> args4 = new String[]{'0', 'number', '000,000.00'};
					String s4 = String.format(l.Precio4__c.format(), args4);

					temp4.Marca = l.Marca4__c;
					temp4.Modelo = getModelString(l.Modelo_De_Inter_s4__c);
					temp4.precioLista = s4;
					//temp4.precioLista = l.Precio4__c;
					temp4.Anno = l.Ano4__c;
					infoFinal.add(temp4);
				}
			}else{
				System.debug(' ** metodo dos ** ');
				if(l.Marca__c != null){
					datosProductos temp = new datosProductos();
                    List<String> args = new String[]{'0', 'number', '000,000.00'};
					String s = String.format(l.Precio1__c.format(), args);
                    
					temp.Marca = l.Marca__c;
					temp.Modelo = getModelString(l.Modelo_De_Inter_s1__c);
					temp.precioLista = s;
                    //temp.precioLista = l.Precio1__c;
					temp.Anno = l.Ano1__c;
					infoFinal.add(temp);
				}
				if(l.Marca2__c != null){
					datosProductos temp2 = new datosProductos();
                    List<String> args2 = new String[]{'0', 'number', '000,000.00'};
					String s2 = String.format(l.Precio2__c.format(), args2);
                    
					temp2.Marca = l.Marca2__c;
					temp2.Modelo = getModelString(l.Modelo_De_Inter_s2__c);
                    temp2.precioLista = s2;
					//temp2.precioLista = l.Precio2__c;
					temp2.Anno = l.Ano2__c;
					infoFinal.add(temp2);
				}
				if(l.Marca3__c != null){
					datosProductos temp3 = new datosProductos();
                    List<String> args3 = new String[]{'0', 'number', '000,000.00'};
					String s3 = String.format(l.Precio3__c.format(), args3);
                    
					temp3.Marca = l.Marca3__c;
					temp3.Modelo = getModelString(l.Modelo_De_Inter_s3__c);
                    temp3.precioLista = s3;
					//temp3.precioLista = l.Precio3__c;
					temp3.Anno = l.Ano3__c;
					infoFinal.add(temp3);
				}
				if(l.Marca4__c != null){
					datosProductos temp4 = new datosProductos();
                    List<String> args4 = new String[]{'0', 'number', '000,000.00'};
					String s4 = String.format(l.Precio4__c.format(), args4);
                    
					temp4.Marca = l.Marca4__c;
					temp4.Modelo = getModelString(l.Modelo_De_Inter_s4__c);
                    temp4.precioLista = s4;
					//temp4.precioLista = l.Precio4__c;
					temp4.Anno = l.Ano4__c;
					infoFinal.add(temp4);
				}
			}
        }
        return infoFinal;
        
    }
    
    public string getModelString(string modelo){
        string modelString = modelo.substringAfter(' ').trim();
        if (modelString.indexOf('-', 0) == 0) modelString = modelString.substringAfter('-').trim();
        return modelString;
    }
    
    public class datosProductos{
        public String Marca{get;set;}
        public String Modelo{get;set;}
        public String precioLista{get;set;}
        public String Anno{get;set;}
    }

	public class datosLogoMarca{
		public String source{get;set;}
		public Integer height{get;set;}
		public Integer width{get;set;}
	}
}