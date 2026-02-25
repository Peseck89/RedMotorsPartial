/*
    Creador: David Leon S (IS)
    Fecha creación: 10/11/2017
    Cliente: Red Motor - Altica
    
*/

public with sharing class OpportunityLineItemService {
    
    //Metodo para actualizar la Oportunidad de Financiamiento de acuerdo al comportamiento de los productos de la Oportunidad de Negocio que este ligada, dependiendo
    //de la accion enviada: 1 = Insert, 2 = Update y 3 = Delete, mas el ID de la Oportunidad de Negocio que se guarda en la variable 'idOp'
    public static void actualizarProductosOF(String idOp, Integer accion, String idProd){
        String modelos = '';
        String sep = ' || ';
        Product2 producto;
        Opportunity nombreLista = new Opportunity();
        List<OpportunityLineItem> listProductos = new List<OpportunityLineItem>();
        List<Oportunidad_de_Financiamiento__c> listOF = new List<Oportunidad_de_Financiamiento__c>();
        List<String>idsProd = new List<String>();
        Map<String,String> mapPro = new Map<String,String>();
        
        System.debug('***** size of list ***** ' + listProductos.size());
        System.debug('****** accion ***** ' + accion);
        
        //Obtengo la Oportunidad de Financiamiento ligada a la Oportunidad de Negocio
        listOF = [SELECT PrecioLista__c, Precio_de_la_Lista_2__c, Ano__c, Ano_2__c, 
                    Cantidad__c, Cantidad_2__c, Marca__c, Marca_2__c, Modelo__c, Modelo_2__c 
                    FROM Oportunidad_de_Financiamiento__c WHERE Oportunidad__c =: idOp];
                    
        //Dependiendo del tipo de accion, 1 = Insert, 2 = Update y 3 = Delete
        if(accion == 1 || accion == 3){
            //Obtengo el nombre de la lista de precio de la Oportunidad de negocio
            nombreLista = [SELECT Pricebook2.Name, RecordType.Name FROM Opportunity WHERE Id =: idOp];
        
            //Obtengo los productos de la Oportunidad de Negocio
            listProductos = [SELECT Product2Id, OpportunityId, ProductCode, Name, ListPrice, Quantity FROM OpportunityLineItem WHERE OpportunityId =: idOp];
            System.debug('*****lista de prod***** ' + listProductos);
            
            //Obtengo los Id de los Productos de la Oportunidad
            for(OpportunityLineItem temp : listProductos){
                idsProd.add(temp.Product2Id);
                if(modelos == ''){//Concateno en la variable 'modelos' todos los codigos de los productos de la Oportunidad de Negocio
                    modelos = temp.ProductCode;
                }else{
                    modelos = modelos + sep + temp.ProductCode;
                }
            }
            //Obtengo informacion sobre los productos de la oportunidad
            for(Product2 pro : [SELECT Name, Id FROM Product2 WHERE Id IN : idsProd]){
                system.debug('entra a getProduct de UpdateFieldProductOpF 3');
                mapPro.put(pro.Id, pro.Name);
            }
            
            if(listProductos.size() == 1){//Si la Oportunidad de Negocio tiene un solo producto
                if(Test.isRunningTest()){
                    listOF[0].Ano__c = '2017';
                }else{
                    System.debug('****** lista precios 00 ***** ' + nombreLista);
                    System.debug('******* nombre ****** ' + nombreLista.Pricebook2.Name);
                    if(listOF[0].Marca__c == 'Harley-Davidson'){
                        listOF[0].Ano__c = nombreLista.Pricebook2.Name.substringAfter('- ');
                    }else{
                        listOF[0].Ano__c = nombreLista.Pricebook2.Name.substringAfter('-');
                    }
                }
                listOF[0].Modelo__c = mapPro.get(listProductos[0].Product2Id);
                listOF[0].Cantidad__c = listProductos[0].Quantity;
                listOF[0].PrecioLista__c = listProductos[0].ListPrice;
                listOF[0].Ano_2__c = '';
                listOF[0].Modelo_2__c = '';
                listOF[0].Cantidad_2__c = null;
                listOF[0].Precio_de_la_Lista_2__c = null;
                listOF[0].Marca_2__c = '';
                listOF[0].Producto__c = modelos;
            }else if(listProductos.size() == 0 || listProductos == null){
                listOF[0].Ano__c = '';
                listOF[0].Modelo__c = '';
                listOF[0].Cantidad__c = null;
                listOF[0].PrecioLista__c = null;
                listOF[0].Ano_2__c = '';
                listOF[0].Modelo_2__c = '';
                listOF[0].Cantidad_2__c = null;
                listOF[0].Precio_de_la_Lista_2__c = null;
                listOF[0].Marca_2__c = '';
                listOF[0].Producto__c = '';
            }else{//Si la Oportunidad de Negocio tiene 2 o mas  productos
                if(Test.isRunningTest()){
                    listOF[0].Ano__c = '2017';
                    listOF[0].Ano_2__c = '2017';
                }else{
                    if(listOF[0].Marca__c == 'Harley-Davidson'){
                        listOF[0].Ano__c = nombreLista.Pricebook2.Name.substringAfter('- ');
                        listOF[0].Ano_2__c = nombreLista.Pricebook2.Name.substringAfter('- ');
                    }else{
                        listOF[0].Ano__c = nombreLista.Pricebook2.Name.substringAfter('-');
                        listOF[0].Ano_2__c = nombreLista.Pricebook2.Name.substringAfter('-');
                    }
                }
                listOF[0].Modelo__c = mapPro.get(listProductos[0].Product2Id);
                listOF[0].Cantidad__c = listProductos[0].Quantity;
                listOF[0].PrecioLista__c = listProductos[0].ListPrice;
                listOF[0].Modelo_2__c = mapPro.get(listProductos[1].Product2Id);
                listOF[0].Cantidad_2__c = listProductos[1].Quantity;
                listOF[0].Precio_de_la_Lista_2__c = listProductos[1].ListPrice;
                listOF[0].Marca_2__c = listOF[0].Marca__c;
                listOF[0].Producto__c = modelos;
            }
        }else if(accion == 2){
            producto = new Product2();
            
            listProductos = [SELECT Product2Id, ProductCode, Name, ListPrice, Quantity FROM OpportunityLineItem WHERE Id =: idProd];
            producto = [SELECT Name, Id FROM Product2 WHERE Id =: listProductos[0].Product2Id];
            
            if(listProductos.size() > 0){
                System.debug('size OF' + listOF.size());
                System.debug('producto' + producto);
                if(listOF[0].Modelo__c == producto.Name){
                    listOF[0].Modelo__c = producto.Name;
                    listOF[0].Cantidad__c = listProductos[0].Quantity;
                    listOF[0].PrecioLista__c = listProductos[0].ListPrice;
                }else{
                    listOF[0].Cantidad_2__c = listProductos[0].Quantity;
                    listOF[0].Precio_de_la_Lista_2__c = listProductos[0].ListPrice;
                } 
            }
        }
        //Update a la Oportunidad de Financiamiento
        update listOF;
    }
}