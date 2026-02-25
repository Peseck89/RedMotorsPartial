public class WoliGridWrapper {
    @AuraEnabled public String wolId;// ID wrapper
    @AuraEnabled public Boolean isUpdate;
    //Product Query --> Service Territory
    @AuraEnabled  public String ID;// ID wrapper 
    @AuraEnabled public String ProductXBodegaID;
    @AuraEnabled  public Id productId;// Product ID
    @AuraEnabled  public String ProductCode;// Product code
    @AuraEnabled  public String Name;// Product Name
    @AuraEnabled  public decimal precio;// Product Unit price 
    @AuraEnabled public String productType;//tipoProducto__c
    @AuraEnabled public String despachoEmail;
    //Service territory
    @AuraEnabled  public String Bodega;//Bodega del NameTest ServiceTerritory
    @AuraEnabled  public String bodegaID;
    @AuraEnabled  public String idExtBodega; //bodega__c
    @AuraEnabled  public decimal cantidadDisponible;// Cantidad disponible (productoxbodega**)
    //WorkOrderLineItem insert
    @AuraEnabled  public String alias;// validado
    @AuraEnabled public Boolean aprobado;// cambiar boolean check
    @AuraEnabled public double cantidad;// double
    @AuraEnabled public String tipotrabajo;// lookup validado//deprecated
    @AuraEnabled public String trabajo;// picklist validado/deprecated
    @AuraEnabled public decimal discount;
    @AuraEnabled public String tax;// picklist validado Impuesto__c No se ve insert 13%
    @AuraEnabled public String priceBookEntry;
    @AuraEnabled public String currencyCode;
    //Flag to insert in ProductosPorBodega Field (WorkOrderLineItem)
    //Flag servicio softland
    @AuraEnabled public Boolean validated;
    @AuraEnabled public Boolean available;
    @AuraEnabled public double softlandQuantity;
    @AuraEnabled public String location;
    @AuraEnabled public List<String> locations;
    @AuraEnabled public List<double> softlandQuantities;
    @AuraEnabled public Map<String,Double> quantityByLocation;
    @AuraEnabled public decimal unitPrice;
    @AuraEnabled public boolean isClosed;
    @AuraEnabled public boolean esKit;
    @AuraEnabled public String estadoReserva;
    @AuraEnabled public String estadoEntrega;
    @AuraEnabled public String estadoSolicitudCompra;
    @AuraEnabled public String solicitudCompraID;
    @AuraEnabled public decimal cantidadSC;
    @AuraEnabled public String estadoSoftland;
    @AuraEnabled public decimal cantidadDevolucion;
    ///porcentajeDescuento__c porcentajeDescuento__c
    @AuraEnabled public List<Bodegas> bodegas;
    @AuraEnabled public Boolean canEditSalesPrice;
    @AuraEnabled public decimal lineSortNumber;
    @AuraEnabled public String estado;
    //AddTiposDeTrabajoLogic
    @AuraEnabled public String tiposDeTrabajo;
    @AuraEnabled public String TipoTrabajoCaso;
    @AuraEnabled public String aprobadoService;
    //New property in service consultarDisponibilidad
    @AuraEnabled public String existenciasOtrasBodegas;
    @AuraEnabled public String otherInventoryText;
    
    
    
    public WoliGridWrapper(Id ID, Id productId, String ProductCode, String Name, decimal precio, String Bodega, Decimal cantidadDisponible,String productType,
                   String alias, String tipotrabajo, String priceBookEntry, String currencyCode, String bodegaID, String idExtBodega, String ProductXBodegaID/*,String trabajo*/)
    {
        this.wolId=null;
        this.ID=ID;
        this.productId=productId;
        this.ProductCode=ProductCode;
        this.Name=Name;
        this.precio=precio;
        this.Bodega=Bodega;//Work Order WorkOrder.Owner.Name
        this.idExtBodega=idExtBodega; //bodega__c
        this.cantidadDisponible=cantidadDisponible;//WorkOrder.WorkOrderNumber
        this.productType=productType;
        this.alias=alias;
        this.aprobado=true;
        this.cantidad=1.0000;
        this.tipotrabajo=tipotrabajo;
        this.discount=0;
        this.esKit=esKit;
        this.priceBookEntry=priceBookEntry;
        this.currencyCode=currencyCode;
        this.bodegaID=bodegaID;
        this.validated=false;
        this.available=null;
        this.softlandQuantity=this.cantidadDisponible;
        this.location=null;
        if(this.productType=='Mano de Obra'){
            this.softlandQuantity=1000;
        }
        this.locations=new List<String>();
        this.softlandQuantities= new List <double>();
        this.quantityByLocation = new Map<String,Double>();
        this.ProductXBodegaID= ProductXBodegaID;
        this.unitPrice=this.precio;
        this.isClosed= false;
    }

    public void setWolId(ID woli){
        this.ID=woli+this.ID;
        this.wolId=woli;
    }
    
    public class Bodegas{
        @AuraEnabled  public String Id;
        @AuraEnabled  public String name;
        @AuraEnabled  public Decimal cantidadDisponible;
        @AuraEnabled  public Boolean isPrincipal;
    }
}