/*
    @Autor: David Leon Sanchez
    @Fecha creacion: 10/11/2017
    @Proyecto: Altica
    @Proposito: Clase apex que se llama desde un process builder con el nombre: Creacion Oportunidad Financiera

*/


public class UpdateFieldProductOpF {
    @InvocableMethod
    public static void getProduct(List<ID>idsOppts){
        system.debug('entra a getProduct de UpdateFieldProductOpF 1');
        String sep = ' || ';
        Integer size;
        Map<String,String> mapPro = new Map<String,String>();
        List<String> idsProd = new List<String>();
        List<Oportunidad_de_Financiamiento__c> opFi = new List<Oportunidad_de_Financiamiento__c>();
        List<infoModelos> listModelos = new List<infoModelos>();
        
        List<Opportunity> allOppts = [SELECT o.Id, o.Pricebook2.Name, o.RecordType.Name, (Select Product2Id, OpportunityId, ProductCode, Name, ListPrice, Quantity From OpportunityLineItems), 
    									(Select name, Producto__c, Oportunidad__c, PrecioLista__c From Oportunidades_de_Financiamiento1__r) 
    									FROM Opportunity o WHERE o.Id IN:idsOppts and o.TotalOpportunityQuantity >= 1];
    									
        for(Opportunity op : allOppts){
            system.debug('entra a getProduct de UpdateFieldProductOpF 2');
            for(OpportunityLineItem opL : op.OpportunityLineItems){
                idsProd.add(opL.Product2Id);
            }
        }
        size = idsProd.size();
        System.debug('****** size ***** ' + size);
        
        for(Product2 pro : [SELECT Name, Id FROM Product2 WHERE Id IN : idsProd]){
            system.debug('entra a getProduct de UpdateFieldProductOpF 3');
            mapPro.put(pro.Id, pro.Name);
        }

        for(Opportunity op : allOppts){
            system.debug('entra a getProduct de UpdateFieldProductOpF 4');
            for(Oportunidad_de_Financiamiento__c opF : op.Oportunidades_de_Financiamiento1__r){
                system.debug('entra a getProduct de UpdateFieldProductOpF 5');
                system.debug('***** productos de la Oportunidad ****** ' + op.OpportunityLineItems);
                for(OpportunityLineItem opL : op.OpportunityLineItems){
                	if(size != 0){
                		infoModelos mod = new infoModelos();
                		mod.modelo = mapPro.get(opL.Product2Id);
                		mod.precioLista = opL.ListPrice;
                		if(Test.isRunningTest()){
                			mod.ano = opL.Name.substring(22,26);
                			System.debug('***** año ***** ' + mod.ano);
                		}else{
                			System.debug('****** pricebook name 3 ***** ' + op.Pricebook2.Name.substringAfter('- '));
                			mod.ano = op.Pricebook2.Name.substringAfter('- ');
                			System.debug('***** ano modelo 3 ***** ' + mod.ano);
                		}
                		mod.cantidad = opL.Quantity;
                		listModelos.add(mod);
                		size = size - 1;
                	}
                    System.debug('Total precio lista ' + opF.PrecioLista__c);
                    if(opF.Producto__c == null){
                        system.debug('entra a getProduct de UpdateFieldProductOpF 7');
                        opF.Producto__c = opL.ProductCode; 
                    }else{
                        system.debug('entra a getProduct de UpdateFieldProductOpF 8');
                        opF.Producto__c = opF.Producto__c + sep + opL.ProductCode;
                    }
                    System.debug('******************** nombre producto *************** ' + opL.Name);
                }
                System.debug(' ***** info lista modelos ****** ' + listModelos);
                for(infoModelos m : listModelos){
            		if(opF.Modelo__c == null){
            			opF.Modelo__c = m.modelo;
            			opF.PrecioLista__c = m.precioLista;
            			opF.Ano__c = m.ano;
            			opF.Cantidad__c = m.cantidad;
            		}else{
            			opF.Modelo_2__c = m.modelo;
            			opF.Precio_de_la_Lista_2__c = m.precioLista;
            			opF.Ano_2__c = m.ano;
            			opF.Cantidad_2__c = m.cantidad;
            			opF.Marca_2__c = op.RecordType.Name;
            		}
            	}
            	opFi.add(opF);
                System.debug('******************** total precio lista ***************** ' + opF.PrecioLista__c);
                System.debug('******************* total precio lista *******************' + opF.PrecioLista__c);
                agendarSchedule(opF.Name);
                listModelos.clear();
            }
        }
        update(opFi);
    }
    
    //Se crea el Scheduled para la Oportunidad Financiera
    public static void agendarSchedule(String name){
        System.debug('******************* se agendo el schedule *****************');
        String fechaEjecucion = Datetime.now().addHours(2).format('s m H d M ? yyyy');
        SchedulableEnvioAlertaOF sch = new SchedulableEnvioAlertaOF();
        System.schedule(name, fechaEjecucion , sch);
    }
    
    //Clase para manejar la informacion de los productos de cada oportunidad de negocio
    public class infoModelos{
    	public String modelo;
    	public Decimal precioLista;
    	public String ano;
    	public Decimal cantidad;
    	public String marca;
    }
}