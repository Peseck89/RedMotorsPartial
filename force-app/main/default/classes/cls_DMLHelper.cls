public class cls_DMLHelper {
    public static Account getAccount(String accountId)
    {
        Account actualAccount = [
                                    SELECT Id,codigoSoftland__c,Name,Phone,Cedula__c,CorreoElectronicoEmpresarial__c,PersonEmail,Monedas_Iden__c,Barrio__c,
                                    Direccion__c,Telefono2__c,condicionPago__r.condicionPago__c,categoriaCliente__r.categoriaCliente__c,
                                    categoriaCliente__r.descripcion__c,impuesto__r.codigoImpuesto__c,impuesto__r.descripcion__c,Tipo_de_Documento__c,
                                    Provincia__r.Name,Canton__r.Name,Distrito__r.Name
                                    FROM Account
                                    WHERE Id=:accountId
                                ];
        return actualAccount;
    }

    public static Opportunity getOpportunity(String oppId)
    {
        /*
        List<Opportunity> actualOpp = [
                                    SELECT Contribuyente__r.Name,Contribuyente__r.Cedula__c,
                                    Contribuyente__r.Tipo_de_Documento__c,RecordTypeId,Observaciones__c,Comentario_CxC__c,
                                    ValorTotal__c,Descuento_Total_Moneda__c,Descuento_Total__c,MonedaIngreso__c,condicionPago__r.condicionPago__c,
                                    subtipoDocumento__r.subtipo__c,ActividadComercial__r.codigo__c,Pricebook2Id,empresaQueFactura__c,Marca_de_Veh_culo_Actual__c,
                                    Modelo_de_Veh_culo_Actual__c,contribuyente__c
                                    FROM Opportunity 
                                    WHERE Id = :oppId
                                ];
        if(actualOpp.size() > 0)
            return actualOpp[0];
        else*/
            return null;

    }

    public static List<OpportunityLineItem> getOpportunityLineItem(String oppId)
    {
            /*List<OpportunityLineItem> productos =   [
                                                        SELECT Id,PricebookEntry.Product2.Codigo_de_Producto__c,PricebookEntry.Product2.Description,
                                                        Bodega__r.bodega__c,Comentario__c,Quantity,Costo_Final__c,centroCosto__r.centroCosto__c,
                                                        cuentaContable__r.cuentaContable__c,impuesto__r.codigoImpuesto__c,Costo4__c,MontoDescuento__c,
                                                        DescuentoPorcentaje__c
                                                        FROM OpportunityLineItem
                                                        WHERE OpportunityId = :oppId
                                                    ];
            return productos;*/
        return null;
    }
    
     public static Order getOrder(String orderId)
    {
        Order actualOrder = [
                                SELECT Id,Work_Order__r.VinFormula__c,Work_Order__c,ordenTrabajo__c,empresaQueFactura__c,MonedaIngreso__c,Observaciones__c,Comentario_CxC__c,subtipoDocumento__r.subtipo__c,
                                ActividadComercial__r.codigo__c,ValorTotal__c,Descuento_Total_Moneda__c,Descuento_Total__c,
                                condicionPago__r.condicionPago__c,iva__c,totalDescuentos__c,porcentajeDescuento2__c,Work_Order__r.taller__c,
                                Work_Order__r.Asset.Marca_Nvo__c,Work_Order__r.Asset.Anio__c,Work_Order__r.VIN__c,Work_Order__r.Asset.modelo__c,Work_Order__r.Asset.Name,Work_Order__r.kilometros__c,
                                Work_Order__r.ServiceTerritory.Name,Work_Order__r.WorkOrderNumber,TotalAmount,CurrencyIsoCode,Total_Final__c,iva2__c,Subtotal__c,
            					isValidated__c
                                FROM Order
                                WHERE Id = :orderId
                            ];
        return actualOrder;
    }

    public static List<OrderItem> getOrderItem(String actualOrderId)
    {
        List<OrderItem> orderItems = [SELECT Id,PricebookEntry.Product2.Codigo_de_Producto__c,PricebookEntry.Product2.Description,
                                              Bodega__r.bodega__c,Comentario__c,Quantity,Costo_Final__c,centroCosto__r.centroCosto__c,
                                              cuentaContable__r.cuentaContable__c,impuesto__r.codigoImpuesto__c,UnitPrice,totalItem__c,ListPrice,
                                              descuento__c,impuesto__c,montoImpuesto__c,porcentajeDescuento__c,impuesto__r.impuesto__c,ImpuestoReal__c,Subtotal__c,
                                      		porcentajeDescuento2__c,ProductOrAlias__c
                                    FROM OrderItem
                                    WHERE OrderId = :actualOrderId];

        return orderItems;
    }
}