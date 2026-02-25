@isTest
public class TestDataFactory {
    
    public static Map<String,RecordType> MapRecordType = new  Map<String,RecordType>();
    public static Map<String,String> MapEtapasIds = new  Map<String,String>();
    public static Map<Integer, PricebookEntry> MapPriceEntries;
    public static Map<Integer, Product2> MapProducts;
    public static Map<Integer, Product2> MapProductsAltica;
    public static Map<Integer, Account> MapCuentas;
    public static Map<Integer, Account> MapCuentasAltica;
    public static Map<Integer, Opportunity> MapOportunidades;
    public static Map<Integer, OpportunityLineItem> MapOpItems;
    public static Map<Integer, ReciboUsado__c> MapReciboUsados;
    public static Map <Integer, Oportunidad_de_Financiamiento__c> MapOpF;
    public static Sucursal__c sucursal;
    public static Campaign campanna;
    public static Campaign campannaAltica;
    public static Cotizacion__c cotizacion;
    public static Distribucion__c distribucion;
    public static Distribucion__c distribucion2;
    public static Cargo__c cargo;
    public static Cargo__c cargo2;
    public static Cargo__c cargo3;
    public static Cargos_Financiamiento__c cargoF;
    public static Tabla_Pagos__c tablaPagos; 
    public static Tabla_Pagos__c tablaPagos2;
    public static Map<Integer, ReciboUsado__c> MapReciboUsadosMoto;
    public static Map<Integer, ReciboUsado__c> MapReciboUsadosMotoKTM;
    public static Map<Integer, ReciboUsado__c> MapReciboUsadosMotoPolaris;
    public static Map<Integer, ReciboUsado__c> MapReciboUsadosMotoKawasaki;
    public static Map<Integer, ReciboUsado__c> MapReciboUsadosMotoOtras; 
    public static Configuracion_Recibo_Usados_Motos__c confMarcas; 
    
    
    public static void datosGenerales() { 
        //Seleccionar tipos de registros.
        for (RecordType r: [Select Id,DeveloperName,SObjectType From RecordType]) {
            if (!MapRecordType.containsKey(r.SObjectType+'-'+r.DeveloperName)) {MapRecordType.put(r.SObjectType+'-'+r.DeveloperName,r);}            
        }
        
        //Seleccionar etapas.
        for (OpportunityStage s:[Select o.MasterLabel,o.Id From OpportunityStage o Where IsActive = true order by o.SortOrder]) {
            if (!MapEtapasIds.containsKey(s.MasterLabel)) {MapEtapasIds.put(s.MasterLabel,s.Id);}
        }
        
        //Crear sucursales.
        sucursal = new Sucursal__c(
            Name='Escazú', 
            DirectordeVentasMotorrad__c=UserInfo.getUserId(),
            DirectordeVentasMini__c=UserInfo.getUserId(),
            DirectordeVentasKTM__c=UserInfo.getUserId(),
            DirectordeVentasKawasaki__c=UserInfo.getUserId(),
            DirectordeVentasBMW__c=UserInfo.getUserId(),
            DirectordeVentasPolaris__c=UserInfo.getUserId(),
            Gerente_de_SucursalMotorrad__c=UserInfo.getUserId(),
            GerentedeSucursalMini__c=UserInfo.getUserId(),
            GerentedeSucursalKTM__c=UserInfo.getUserId(),
            GerentedeSucursalKawasaki__c=UserInfo.getUserId(),
            GerentedeSucursalBMW__c=UserInfo.getUserId(),
            GerentedeSucursalPolaris__c=UserInfo.getUserId(),
            JefedeSucursalMotorrad__c=UserInfo.getUserId(),
            JefesdeSucursalMini__c=UserInfo.getUserId(),
            JefesdeSucursalKTM__c=UserInfo.getUserId(),
            JefesdeSucursalKawasaki__c=UserInfo.getUserId(),
            JefeseSucursalBMW__c=UserInfo.getUserId(),
            JefesdeSucursalPolaris__c=UserInfo.getUserId()
        );
        
        insert sucursal;        
        
        //Crear campaña.
        campanna = new Campaign
        (
            Name='Campaign',
            RecordTypeId = MapRecordType.get('Campaign-Campana_Red_Motors').Id
        );
        insert campanna;

        //Crear campana Altica
        campannaAltica = new Campaign(
            Name = 'Campaign',
            RecordTypeId = MapRecordType.get('Campaign-Campana_Altica').Id
        );
        insert campannaAltica;

        Provincia__c prov = new Provincia__c(
            Name = 'GUANACASTE',
            CodigoProvincia__c = '7'
        );
        insert prov;

        Canton__c cant = new Canton__c(
            Name = 'ABANGARES',
            CodigoCanton__c = '1',
            Provincia__c = prov.Id        
        );
        insert cant;
    }
    
    //Crear Productos Nuevos Red Motors
    public static void createProducts(Integer iTotReg){
        
        List<Product2> listProductos = new List<Product2>();
        MapProducts = new Map<Integer,Product2>();   
        // Obtener valor válido para Categor_a_veh_culo__c
List<Schema.PicklistEntry> picklistValues = Product2.Categor_a_veh_culo__c.getDescribe().getPicklistValues();
String valorValido = picklistValues.isEmpty() ? null : picklistValues[0].getValue();
        
        for (Integer x=0;x<iTotReg;x++) {
            Product2 prod = new Product2(
                Name = 'prod '+x,
                Codigo_de_Producto__c = x.format(),
                ProductCode = 'prod '+x,
                Marca__c = 'BMW',
                Grupo__c = 'BMW i',
                Categor_a_veh_culo__c = 'Eléctrico',
                Familia__c = 'i4',
                IsActive = true,
                Color__c = 'rojo',
                modelo__c = 'prod '+x,
                vin__c = 'prod '+x,
                Anno__c = '2002 ',
                esVehiculo__c = true
            );
            
            listProductos.add(prod);
            MapProducts.put(x,prod);
        }
        
        if(listProductos.size()>0){insert listProductos;}
        
    }

    //Crear Productos Nuevos Altica
    public static void createProductsAltica(Integer iTotReg){
        
        List<Product2> listProductosAltica = new List<Product2>();
        MapProductsAltica = new Map<Integer,Product2>();   
        
        for (Integer x=0;x<iTotReg;x++) {
            Product2 prod = new Product2(
                name = 'prod '+x,
                RecordTypeId = MapRecordType.get('Product2-Producto_Altica').Id,
                Codigo_de_Producto__c = x.format(),
                IsActive = true
            );
            
            listProductosAltica.add(prod);
            MapProductsAltica.put(x,prod);
        }
        
        if(listProductosAltica.size()>0){insert listProductosAltica;}
        
    }
    
    //Crear Registros en lista de precios standard
    public static void createPriceBookEntries(Integer iTotReg, Id standardPricebookId){
        
        MapPriceEntries = new Map<Integer, PricebookEntry>();
        List<PricebookEntry> listPreciosProductos = new List<PricebookEntry>();
        
        if (MapPriceEntries.isEmpty()) {           
        
            for (Integer x=0;x<iTotReg;x++) {
                PricebookEntry standardPrice2 = new PricebookEntry(
                                Pricebook2Id = standardPricebookId, 
                                Product2Id = MapProducts.get(x).Id,
                                CurrencyIsoCode = 'USD',
                                UnitPrice = 59900, 
                                IsActive = true,
                                Vendedor__c = 2, Jefe__c = 7,
                                Gerente__c = 8
                );
                MapPriceEntries.put(x,standardPrice2);
                listPreciosProductos.add(standardPrice2);            
            }
            
            if(listPreciosProductos.size()>0){//insert listPreciosProductos;
            } 
        }
    }
    
    public static void crearCuentas(Integer iTotReg) {
        list<Account> listAccs = new list<Account>();
        MapCuentas = new Map<Integer, Account>();
        
        for (Integer x=0;x<iTotReg;x++){
            
            Account a = new Account
            (
                RecordTypeId = MapRecordType.get('Account-PersonAccount').Id,
                FirstName = 'Test' + x,
                LastName    =   'test',
                PersonEmail = 'correo'+x+'@email.com',
                Tipo_de_Documento__c = 'Cedula',
                Cedula__c = '222222222',
                PersonMobilePhone = '+50687878787'
            );
            
            listAccs.add(a);
            MapCuentas.put(x, a);
        }
        
        if(MapCuentas.size()>0) insert MapCuentas.values();
    }

    public static void crearCuentasAltica(Integer iTotReg) {//Cuenta Altica
        list<Account> listAccsAltica = new list<Account>();
        MapCuentasAltica = new Map<Integer, Account>();
        
        for (Integer x=0;x<iTotReg;x++){
            
            Account a = new Account
            (
                RecordTypeId = MapRecordType.get('Account-Cuenta_Altica').Id,
                FirstName = 'Test' + x,
                LastName    =   'test',
                PersonEmail = 'correo'+x+'@email.com',
                Tipo_de_Documento__c = 'Cedula',
                Cedula__c = '222222222',
                PersonMobilePhone = '+50683838383',
                Monedas_Iden__c = 'USD',
                Monto_Ingreso__c = 2500,
                Vendedorasignado__c = UserInfo.getUserId()
            );
            
            listAccsAltica.add(a);
            MapCuentasAltica.put(x, a);
        }
        
        if(MapCuentasAltica.size()>0) insert MapCuentasAltica.values();
    }
    
    public static void crearOportunidades(Integer iTotReg, String stageName) {
        list<Opportunity> listOps = new list<Opportunity>();
        MapOportunidades = new Map<Integer, Opportunity>();
        
        for (Integer x=0;x<iTotReg;x++){
            Opportunity op = new Opportunity(
                AccountId = MapCuentas.get(x).Id,
                CloseDate = System.today().AddMonths(3),
                StageName = MapEtapasIds.get(stageName),
                Campana__c = campanna.Id,
                Sucursal__c = sucursal.Name,
                //MonedaIngreso__c = 'Colones',
                IngresoAproximado__c = 1500,
                RT_Lead__c = 'BMW'
            );
            
            listOps.add(op);
            MapOportunidades.put(x, op);
        }
        
        if(MapOportunidades.size()>0) insert MapOportunidades.values();
    }
    

    public static void crearProductosOP(Integer iTotReg){
        list<OpportunityLineItem> listOpItems = new list<OpportunityLineItem>();
        MapOpItems = new Map<Integer, OpportunityLineItem>();
        for (Integer x=0;x<iTotReg;x++){
            OpportunityLineItem item = new OpportunityLineItem(
                PriceBookEntryId = MapPriceEntries.get(x).Id,
                OpportunityId=MapOportunidades.get(x).Id,
                Quantity = 1,
                TotalPrice = MapPriceEntries.get(x).UnitPrice
            );

            
            listOpItems.add(item);
            MapOpItems.put(x, item);
        }
        
        //if(MapOpItems.size()>0) insert MapOpItems.values();
    }
    
    public static void crearReciboUsado(Integer iTotReg){
        list<ReciboUsado__c> listReciboUsados = new list<ReciboUsado__c>();
        MapReciboUsados = new Map<Integer, ReciboUsado__c>();
        for (Integer x=0;x<iTotReg;x++){
            ReciboUsado__c r = new ReciboUsado__c(
                Oportunidad__c          =   MapOportunidades.get(x).Id,
                Ano__c                  =   '2017',
                Marca__c                =   'BMW',
                Modelo__c               =   '2017',
                Placa__c                =   x.format(),
                Serecibevehiculo__c     =   true,
                Color__c                =   'AZUL',
                Combustible__c          =   'GASOLINA',
                EstiloUsado__c          =   'TODO TERRENO',
                Trasmision__c           =   'AUTOMATICA',
                Kilometraje__c          =   2000,
                Traccion__c             =   '4x4',
                N_puertas__c            =   4,                
                Revendedor__c           =   true,
                ValorReciboCliente__c   =   60000.00,
                ReciboJefeUsados__c     =   40000.00,
                Valor_final__c          =   50000.00,
                Valor_inicial__c        =   70000.00,
                Fecha_de_recibo__c      =   Date.today() 
            );
            
            listReciboUsados.add(r);
            MapReciboUsados.put(x,r);
        }
        if(MapReciboUsados.size()>0) insert MapReciboUsados.values();
    }

    public static void crearOpFAltica(Integer iToReg){
        List<Oportunidad_de_Financiamiento__c> listOpF = new List<Oportunidad_de_Financiamiento__c>();
        MapOpF = new Map<Integer, Oportunidad_de_Financiamiento__c>();

        for(Integer x = 0; x < iToReg; x++){
            Oportunidad_de_Financiamiento__c opF = new Oportunidad_de_Financiamiento__c(
                Campana_Altica__c = campannaAltica.Id,
                FechaInicioOF__c = System.now(),
                Nombre_Cliente_Altica__c = MapCuentasAltica.get(x).Id
            );
            listOpF.add(opF);
            MapOpF.put(x, opF);
        }
        if(MapOpF.size() > 0){
            Insert MapOpF.values();
        }
    }

    public static void crearCotizacionAltica(){
        cotizacion = new Cotizacion__c();

        cotizacion.Ano__c = '2020';
        cotizacion.Nombre_Cliente__c = 'Prueba';
        cotizacion.Apellidos_Cliente__c = 'Prueba Prueba';
        cotizacion.Correo_Electronico__c = 'prueba@prueba.com';
        cotizacion.Telefono__c = '99999999';
        cotizacion.Profesion__c = 'Consultor';
        cotizacion.Compania__c = 'Altica';
        cotizacion.Activo__c = 'Auto';
        cotizacion.Condicion_Activo__c = 'Nuevo';
        cotizacion.Producto__c = 'Leasing Operativo';
        cotizacion.Precio__c = 50000;
        cotizacion.Moneda__c = 'USD';
        cotizacion.Seguro_Fijo__c = 5000;
        cotizacion.Monto_Real__c = 60000;
        cotizacion.Campana__c = 'Prueba';
        cotizacion.Plazo__c = 64;
        cotizacion.Prima__c = 10;
        cotizacion.Monto_Seguro__c = 10000;
        cotizacion.Valor_Residual__c = 5000;

        insert cotizacion;
    }
    
    public static void crearDistribucionAltica(){
        distribucion = new Distribucion__c();
        distribucion2 = new Distribucion__c();

        distribucion.Mes_Inicial__c = 1;
        distribucion.Mes_Final__c = 24;
        distribucion.Descripcion_Tasa_Base__c = 'Tasa_Vehiculos';
        distribucion.Cuota__c = 500;
        distribucion.Porcentaje_Tasa_Base__c = 10;
        distribucion.Spread__c = 0;
        distribucion.Cotizacion__c = cotizacion.Id;
        distribucion.Variable_Tasa_Base__c = 0;

        distribucion2.Mes_Inicial__c = 25;
        distribucion2.Mes_Final__c = 96;
        distribucion2.Descripcion_Tasa_Base__c = 'Tasa_variable Vehiculos';
        distribucion2.Cuota__c = 500;
        distribucion2.Porcentaje_Tasa_Base__c = 10;
        distribucion2.Spread__c = 13;
        distribucion2.Cotizacion__c = cotizacion.Id;
        distribucion2.Variable_Tasa_Base__c = 1;

        insert distribucion;
        insert distribucion2;
    }

    public static void crearCargosAltica(){
        cargo = new Cargo__c();
        cargo2 = new Cargo__c();
        cargo3 = new Cargo__c();
        cargoF = new Cargos_Financiamiento__c();

        cargo.Descripcion_Cargo__c = 'Administrativo';
        cargo.Impuesto__c = 13;
        cargo.Monto__c = 0;
        cargo.Descripcion_Tipo_Pago__c = 'Prueba';
        cargo.Cotizacion__c = cotizacion.Id;
        cargo.Porcentaje_Credito__c = 0;

        cargo2.Descripcion_Cargo__c = 'GPS';
        cargo2.Impuesto__c = 0;
        cargo2.Monto__c = 400;
        cargo2.Descripcion_Tipo_Pago__c = 'Prueba';
        cargo2.Cotizacion__c = cotizacion.Id;
        cargo2.Porcentaje_Credito__c = 0;

        cargo3.Descripcion_Cargo__c = 'Comisión_Sin_IVA';
        cargo3.Impuesto__c = 0;
        cargo3.Monto__c = 1000;
        cargo3.Descripcion_Tipo_Pago__c = 'Prueba';
        cargo3.Cotizacion__c = cotizacion.Id;
        cargo3.Porcentaje_Credito__c = 4;

        insert cargo;
        insert cargo2;
        insert cargo3;

        cargoF.Cargo__c = cargo.Id;
        cargoF.Mes_Inicial__c = 1;
        cargoF.Mes_Final__c = 96;
        cargoF.Porcentaje__c = 5;
        cargoF.Intereses__c = 0;
        cargoF.Monto_Fijo__c = 0;

        insert cargoF;
    }

    public static void crearTablaPagosAltica(){
        tablaPagos = new Tabla_Pagos__c();
        tablaPagos2 = new Tabla_Pagos__c();

        tablaPagos.Cotizacion__c = cotizacion.Id;
        tablaPagos.Saldo__c = 30000;
        tablaPagos.Index__c = 1;
        tablaPagos.Monto__c = 500;
        tablaPagos.Intereses__c = 260;
        tablaPagos.Principal__c = 200;
        tablaPagos.Impuestos__c = 15;
        tablaPagos.Monto_Total__c = 700;
        tablaPagos.Administrativo__c = 115;
        tablaPagos.Seguro_Monto_Fijo__c = 0;

        tablaPagos2.Cotizacion__c = cotizacion.Id;
        tablaPagos2.Saldo__c = 30000;
        tablaPagos2.Index__c = 25;
        tablaPagos2.Monto__c = 500;
        tablaPagos2.Intereses__c = 260;
        tablaPagos2.Principal__c = 200;
        tablaPagos2.Impuestos__c = 15;
        tablaPagos2.Monto_Total__c = 700;
        tablaPagos2.Administrativo__c = 115;
        tablaPagos2.Seguro_Monto_Fijo__c = 100;

        insert tablaPagos;
        insert tablaPagos2;
    }

    public static void crearConfigReciboUsadosMotos(String marca){
        confMarcas = new Configuracion_Recibo_Usados_Motos__c();

        confMarcas.Name = marca;
        confMarcas.Antiguedad__c = -0.200708;
        confMarcas.Cilindrada__c = 0.003559;
        confMarcas.Gama__c = -3.309902;
        confMarcas.Intercepto__c = 2.988381;
        confMarcas.Segmento__c = -0.101711;
        confMarcas.Valor_Recibo__c = -0.000137;
        confMarcas.Modelo__c = -1.362995;
            confMarcas.Mes__c = 0.091227;

        insert confMarcas;
    }

    public static void crearReciboUsadoMotos(Integer iTotReg){
        list<ReciboUsado__c> listReciboUsadosMoto = new list<ReciboUsado__c>();
        MapReciboUsadosMoto = new Map<Integer, ReciboUsado__c>();
        for (Integer x=0;x<iTotReg;x++){
            ReciboUsado__c r = new ReciboUsado__c(
                Oportunidad__c          =   MapOportunidades.get(x).Id,
                RecordTypeId      =  Schema.SObjectType.ReciboUsado__c.getRecordTypeInfosByName().get('Motocicleta').getRecordTypeId(),
                Ano__c                  =   '2015',
                Marca__c        =   'BMW',
        //Marca_Usados__c      =  'BMW',
                Placa__c                =   x.format() + 1,
                Color__c        =   'AZUL',
                Kilometraje__c      =   2000, 
                ValorReciboCliente__c  =  60000.00,
                ReciboJefeUsados__c    =  40000.00,
                Valor_final__c          =   50000.00,
                Valor_inicial__c        =   70000.00,
                Fecha_de_recibo__c    =  Date.today().addYears(-2),
                Cilindraje__c      =  650,
                Segmento__c        =  'Adventure',
                Gama__c          =  'Alta',
                Modelo__c        =  'C650'
            );
            
            listReciboUsadosMoto.add(r);
            MapReciboUsadosMoto.put(x,r);
        }
        if(MapReciboUsadosMoto.size()>0) insert MapReciboUsadosMoto.values();
    }

    public static void crearReciboUsadoMotosOtras(Integer iTotReg){
        list<ReciboUsado__c> listReciboUsadosMotoOtras = new list<ReciboUsado__c>();
        MapReciboUsadosMotoOtras = new Map<Integer, ReciboUsado__c>();
        for (Integer x=0;x<iTotReg;x++){
            ReciboUsado__c r = new ReciboUsado__c(
                Oportunidad__c          =   MapOportunidades.get(x).Id,
                RecordTypeId      =  Schema.SObjectType.ReciboUsado__c.getRecordTypeInfosByName().get('Motocicleta').getRecordTypeId(),
                Ano__c                  =   '2015',
                Marca__c        =   'APRILIA',
                Placa__c                =   x.format() + 2,
                Color__c        =   'AZUL',
                Kilometraje__c      =   2000, 
                ValorReciboCliente__c  =  60000.00,
                ReciboJefeUsados__c    =  40000.00,
                Valor_final__c          =   50000.00,
                Valor_inicial__c        =   70000.00,
                Fecha_de_recibo__c    =  Date.today(),
                Cilindraje__c      =  650,
                Segmento__c        =  'Side by Side',
                Gama__c          =  'Baja',
                Mes__c          =  5
            );
            
            listReciboUsadosMotoOtras.add(r);
            MapReciboUsadosMotoOtras.put(x,r);
        }
        if(MapReciboUsadosMotoOtras.size()>0) insert MapReciboUsadosMotoOtras.values();
    }
    
    public static void crearReciboUsadoMotosKTM(Integer iTotReg){
        list<ReciboUsado__c> listReciboUsadosMotoKTM = new list<ReciboUsado__c>();
        MapReciboUsadosMotoKTM = new Map<Integer, ReciboUsado__c>();
        for (Integer x=0;x<iTotReg;x++){
            ReciboUsado__c r = new ReciboUsado__c(
                Oportunidad__c          =   MapOportunidades.get(x).Id,
                RecordTypeId      =  Schema.SObjectType.ReciboUsado__c.getRecordTypeInfosByName().get('Motocicleta').getRecordTypeId(),
                Ano__c                  =   '2015',
                Marca__c        =   'KTM',
                Placa__c                =   x.format() + 3,
                Color__c        =   'AZUL',
                Kilometraje__c      =   2000, 
                ValorReciboCliente__c  =  60000.00,
                ReciboJefeUsados__c    =  40000.00,
                Valor_final__c          =   50000.00,
                Valor_inicial__c        =   70000.00,
                Fecha_de_recibo__c    =  Date.today(),
                Cilindraje__c      =  650,
                Segmento__c        =  'Adventure',
                Gama__c          =  'Alta' 
            );
            
            listReciboUsadosMotoKTM.add(r);
            MapReciboUsadosMotoKTM.put(x,r);
        }
        if(MapReciboUsadosMotoKTM.size()>0) insert MapReciboUsadosMotoKTM.values();
    }

    public static void crearReciboUsadoMotosPolaris(Integer iTotReg){
        list<ReciboUsado__c> listReciboUsadosMotoPolaris = new list<ReciboUsado__c>();
        MapReciboUsadosMotoPolaris = new Map<Integer, ReciboUsado__c>();
        for (Integer x=0;x<iTotReg;x++){
            ReciboUsado__c r = new ReciboUsado__c(
                Oportunidad__c          =   MapOportunidades.get(x).Id,
                RecordTypeId      =  Schema.SObjectType.ReciboUsado__c.getRecordTypeInfosByName().get('Motocicleta').getRecordTypeId(),
                Ano__c                  =   '2015',
                Marca__c        =   'POLARIS',
                Placa__c                =   x.format() + 4,
                Color__c        =   'AZUL',
                Kilometraje__c      =   2000, 
                ValorReciboCliente__c  =  60000.00,
                ReciboJefeUsados__c    =  40000.00,
                Valor_final__c          =   50000.00,
                Valor_inicial__c        =   70000.00,
                Fecha_de_recibo__c    =  Date.today(),
                Cilindraje__c      =  650,
                Segmento__c        =  'Adventure',
                Gama__c          =  'Alta' 
            );
            
            listReciboUsadosMotoPolaris.add(r);
            MapReciboUsadosMotoPolaris.put(x,r);
        }
        if(MapReciboUsadosMotoPolaris.size()>0) insert MapReciboUsadosMotoPolaris.values();
    }

    public static void crearReciboUsadoMotosKawasaki(Integer iTotReg){
        list<ReciboUsado__c> listReciboUsadosMotoKawasaki = new list<ReciboUsado__c>();
        MapReciboUsadosMotoKawasaki = new Map<Integer, ReciboUsado__c>();
        for (Integer x=0;x<iTotReg;x++){
            ReciboUsado__c r = new ReciboUsado__c(
                Oportunidad__c          =   MapOportunidades.get(x).Id,
                RecordTypeId      =  Schema.SObjectType.ReciboUsado__c.getRecordTypeInfosByName().get('Motocicleta').getRecordTypeId(),
                Ano__c                  =   '2015',
                Marca__c        =   'KAWASAKI',
                Modelo__c        =  'KX',
                Placa__c                =   x.format() + 5,
                Color__c        =   'AZUL',
                Kilometraje__c      =   2000, 
                ValorReciboCliente__c  =  60000.00,
                ReciboJefeUsados__c    =  40000.00,
                Valor_final__c          =   50000.00,
                Valor_inicial__c        =   70000.00,
                Fecha_de_recibo__c    =  Date.today(),
                Cilindraje__c      =  650,
                Segmento__c        =  'Adventure',
                Gama__c          =  'Alta' 
            );
            
            listReciboUsadosMotoKawasaki.add(r);
            MapReciboUsadosMotoKawasaki.put(x,r);
        }
        if(MapReciboUsadosMotoKawasaki.size()>0) insert MapReciboUsadosMotoKawasaki.values();
    }

	public static OperatingHours createOperatingHour(String name,String timeZone, Boolean doInsert) {
		OperatingHours newRecord = new OperatingHours(
            Name = name,
            TimeZone = timeZone == null ? 'America/Costa_Rica' : ''
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	}
    
	public static ServiceTerritory createServiceTerritory(String name,Boolean isActive,OperatingHours operatingHour, Boolean doInsert) {
		ServiceTerritory newRecord = new ServiceTerritory(
            Name = name,
            IsActive = isActive == null ? true : isActive,
            OperatingHoursId = operatingHour.Id 
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	}

	public static User createUser(String firstName,String lastName,String alias,String email,String userName,Profile profile,String emailEncodingKey,String languageLocaleKey,String localeSidKey,String timeZoneSidKey, Boolean doInsert) {      
		User newRecord = new User(
            FirstName = firstName,
            LastName = lastName,
            Alias = alias,
            Email = email,
            IsActive = true,
            UserName = userName,
            EmailEncodingKey = emailEncodingKey == null ? 'UTF-8' : emailEncodingKey,
            LanguageLocaleKey = languageLocaleKey == null ? 'en_US' : languageLocaleKey,
            LocaleSidKey = localeSidKey == null ? 'en_US' : localeSidKey,
            TimeZoneSidKey = timeZoneSidKey == null ? 'America/New_York' : timeZoneSidKey,
            ProfileId = profile.Id
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	}    
    
	public static FSL__User_Territory__c createUserTerritory(String userId,String territoryServiceId, Boolean doInsert) {
		FSL__User_Territory__c newRecord = new FSL__User_Territory__c(
            FSL__User__c = userId,
            FSL__ServiceTerritory__c = territoryServiceId
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	}

	public static Account createAccount(String name, Boolean doInsert) {
		Account newRecord = new Account(
            Name = name,
            Tipo_de_Documento__c ='01',
            Cedula__c = '123456789'
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	}
    
	public static WorkOrder createWorkOrder(Account account,Case serviceCase,Asset vehicle,User serviceAdviser, ServiceTerritory serviceTerritory, Boolean doInsert) {
		WorkOrder newRecord = new WorkOrder(        
            AccountId = account.Id,
            CaseId = serviceCase.Id,
            AssetId = vehicle.Id,
            Asesor_de_la_orden__c = serviceAdviser.Id,
            ServiceTerritoryId = serviceTerritory.Id,
            Kilometros__c = 10000,
            Etapa_de_flujo_de_trabajo__c = 'Nuevo',
            Priority = 'Bajo',
            Tipo_de_servicio__c = 'Mecánica Rápida',
            Duration = 2,
            Fecha_de_Entrada__c = System.today(),
            empresaFactura__c = 'RMOTOBAI',
            tipoDeGasto__c =  'Cliente',            
            CurrencyIsoCode = 'CRC'            
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	}

	public static Case createCase(String type,String status,Asset asset,Account account,String recordTypeName, Boolean doInsert) {        
		Case newRecord = new Case(
            AccountId = account.Id,
            Type = type,
            Status = status,
            AssetId = asset.Id,
            RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId()
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	}  
    
	public static Asset createVehicle(String name,String placa,String chasis,Account account, Boolean doInsert) {
		Asset newRecord = new Asset(
            Name = name,
            AccountId = account.Id,
            numeroDePlaca__c = placa,
            NumeroDeChasis__c = chasis
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	}     
      
    public static Contact createContact(String firstName,String lastName,Account account,String recordTypeName, Boolean doInsert) {
		Contact newRecord = new Contact(
            FirstName = firstName,
            LastName = lastName,
            AccountId = account?.Id,
            RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Contacto de Taller').getRecordTypeId()
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	}
    
    public static tiposDeTrabajo__c createTipoTrabajo(String name,Boolean doInsert) {
		tiposDeTrabajo__c newRecord = new tiposDeTrabajo__c(
            Name = name
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	} 

    public static tiposDeTrabajoCaso__c createTipoTrabajoCaso(Case caso,tiposDeTrabajo__c tipoTrabajo, Boolean doInsert) {
		tiposDeTrabajoCaso__c newRecord = new tiposDeTrabajoCaso__c(
            Caso__c = caso.Id,
            Tipotrabajo__c = tipoTrabajo.Id,
            Status__c = 'Abierta',
            Tipo_de_cargo__c = 'Cliente',
            Horaa__c = 4
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	} 
    
    public static Bodega__c createBodega(String name, Boolean doInsert) {
		Bodega__c newRecord = new Bodega__c(
            Name = name,
            ID_EXTERNO_BODEGA__c = name
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	}

    public static ProductoXBodega__c createProductoXBodega(Bodega__c bodega,Product2 producto, Boolean doInsert) {
		ProductoXBodega__c newRecord = new ProductoXBodega__c(
            Bodega__c = bodega.Id,
            Disponible__c = 1,
            Identificador__c = bodega.Id + '- '+ producto.Id,
            Name = bodega.Id + '- '+ producto.Id,
            Producto__c = producto.Id
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	} 

    public static Subtipo_de_trabajo_del_caso__c createSubtipoTrabajoCaso(String name,Case caso,tiposDeTrabajoCaso__c tipoTrabajoCaso,WorkOrder workOrder, Boolean doInsert) {
		Subtipo_de_trabajo_del_caso__c newRecord = new Subtipo_de_trabajo_del_caso__c(
            Caso__c = caso.Id,
            Tipo_de_trabajo_del_caso__c = tipoTrabajoCaso.Id,
            Orden_de_trabajo__c = workOrder.Id,
            Cantidad_de_horas__c = 1,
            CurrencyIsoCode = 'CRC',
            Name = name
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	} 
    
    public static WorkOrderLineItem createWorkOrderLineItem(WorkOrder workOrder,Product2 product,PriceBookEntry priceBookEntry, tiposDeTrabajo__c tipoTrabajo, Boolean doInsert) {
		WorkOrderLineItem newRecord = new WorkOrderLineItem(
            WorkOrderId = workOrder.Id,
            Product__c = product.Id,
            // PricebookEntryId = priceBookEntry.Id,
            aprobado__c = true,
            UT__c = 100,
            Alias_Articulo__c = 'Product',
            // Quantity = 1,
            porcentajeDescuento__c = 0,
            especificacionesTaller__c = 'Recomendado',
            tiposDeTrabajo__c = tipoTrabajo.Id,
            Trabajo__c = 'Mano de Obra'
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	}

    public static Horas_improductivas_por_mec_nico__c createTiempoImproductivoMecanico(Case caso,Contact contacto,tiposDeTrabajo__c tipoTrabajo, Boolean doInsert) {
		Horas_improductivas_por_mec_nico__c newRecord = new Horas_improductivas_por_mec_nico__c(
            Caso__c = caso.Id,
            Mecanico__c = contacto.Id,
            Tipo_de_Trabajo__c = tipoTrabajo.Id,
            Inicio__c = System.today(),
            Hora_inicio__c = System.now().time(),
            Fin__c = System.today(),
            Hora_fin__c = System.now().time()
            );
		if(doInsert) {
			insert newRecord;
		}
		return newRecord;
	}    


    /**
    * @description Prepara un entorno con registros relacionados a la consola
    * @author marcohernandezhp@gmail.com | 12-27-2022 
    **/
    public static void prepareConsoleRecords() {
        OperatingHours operatingHour = TestDataFactory.createOperatingHour('Monday',null,true);
        List<ServiceTerritory> serviceTerritoryList = new List<ServiceTerritory>();
        serviceTerritoryList.add(TestDataFactory.createServiceTerritory('Uruca Test',null,operatingHour,false));
        serviceTerritoryList.add(TestDataFactory.createServiceTerritory('other territory',null,operatingHour,false));
        insert serviceTerritoryList;

        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema' LIMIT 1];
        User testUser = TestDataFactory.createUser('Marcotest', 'Hernandeztest', 'mahp', 'test_console_user@test.test', 'test_console_user@test.test',profile, null, null, null, null, true);
        
        List<FSL__User_Territory__c> newUserTerritoryList = new List<FSL__User_Territory__c>();
        for (ServiceTerritory st : serviceTerritoryList) {
            newUserTerritoryList.add(TestDataFactory.createUserTerritory(UserInfo.getUserId(),st.Id,false));
        }        
        insert newUserTerritoryList;
        
        Account newAccount = TestDataFactory.createAccount('Marco Hernandez', true);

        Asset newVehicle = TestDataFactory.createVehicle('ABCTEST01','ABCTEST01','12345678912345678',newAccount, true);                  
        
        Case newCase = TestDataFactory.createCase('Mecánica Rápida','Creado',newVehicle,newAccount,'Autos', true);
        
        Contact mecanico = TestDataFactory.createContact('Juan','Perez',newAccount,'Contacto_de_Taller',true);

        List<WorkOrder> workOrderList = new List<WorkOrder>();
        for (ServiceTerritory st : serviceTerritoryList) {
            if (st.Name == 'Uruca Test') {
                workOrderList.add(TestDataFactory.createWorkOrder(newAccount,newCase,newVehicle,testUser,serviceTerritoryList[0], false));                
            }        
        }
        insert workOrderList;
        
        tiposDeTrabajo__c mecanicaRapida = TestDataFactory.createTipoTrabajo('Mecanica Rapida',true);

        tiposDeTrabajoCaso__c mecanicaRapidaTTC = TestDataFactory.createTipoTrabajoCaso(newCase,mecanicaRapida, true);

        List<Subtipo_de_trabajo_del_caso__c> subtipoTrabajoCasoList = new List<Subtipo_de_trabajo_del_caso__c>();
        subtipoTrabajoCasoList.add(TestDataFactory.createSubtipoTrabajoCaso('Cambio Aceite',newCase,mecanicaRapidaTTC,workOrderList[0], false));
        subtipoTrabajoCasoList.add(TestDataFactory.createSubtipoTrabajoCaso('Cambio Filtro de Aire',newCase,mecanicaRapidaTTC,workOrderList[0], false));
        insert subtipoTrabajoCasoList;  

        createTiempoImproductivoMecanico(newCase,mecanico,mecanicaRapida,true);        
    }
    

   public static Product2 createProduct(
    String name,String vin, String tipo, String grupo, String marca, String familia, 
    String modelo,String anio,String color,String colorExterior,
    String productType,Boolean isVehicle, Boolean doInsert
){
    // Obtener valor válido del picklist
    List<String> valoresPermitidos = new List<String>();
    for (Schema.PicklistEntry entry : Product2.Categor_a_veh_culo__c.getDescribe().getPicklistValues()) {
        valoresPermitidos.add(entry.getValue());
    }
    String valorCategoria = valoresPermitidos.isEmpty() ? null : valoresPermitidos[0];

    Product2 newRecord = new Product2(
        Name = name,
        Codigo_de_Producto__c = name,
        ProductCode = name,
        marcaVehiculo__c = marca,   // Softland
        VN_familia__c = familia,
        IsActive = true,
        Color__c = colorExterior,
        Color_Externo__c = color,
        tipoProducto__c = productType,
        vin__c = name,
        Anno__c = anio,             // Rebeca
        Ano__c = anio != null ? Integer.valueOf(anio) : null, // Softland
        Empresa__c = 'RMBAVARIAN',
        Categor_a_veh_culo__c = valorCategoria  // 👈 siempre asignar aquí
    );

    if (productType == 'Vehiculo' && isVehicle) {
        newRecord.RecordTypeId = getRecordTypeId('Product2', 'Vehiculos');
        newRecord.modelo__c = modelo;
        newRecord.esVehiculo__c = true;
    } else if(productType == 'Vehiculo' && !isVehicle){
        newRecord.RecordTypeId = getRecordTypeId('Product2', 'Producto_Red_Motors');
        newRecord.esVehiculo__c = false;
        newRecord.Familia__c = familia;
        newRecord.Grupo__c = grupo;
        newRecord.Marca__c = marca;
        newRecord.Modelo_De_Inter_s__c = modelo;
    } else {
        newRecord.RecordTypeId = getRecordTypeId('Product2', 'Producto_Red_Motors');
    }

    if(doInsert){
        insert newRecord;
    }
    return newRecord;
}


    public static Marca__c createBrand(String name, Boolean doInsert){            
        Marca__c newRecord = new Marca__c(
            Name = name,
            Activo__c = true,
            External_Id__c = name
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static Modelo__c createModel(String name,Marca__c brand, Boolean doInsert){            
        Modelo__c newRecord = new Modelo__c(
            Name = name,
            Marca__c = brand.Id,
            Activo__c = true
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    } 
    
    public static Compatibilidad__c createCompatibilidad(Marca__c brand,Modelo__c model,Product2 product, Boolean doInsert){            
        Compatibilidad__c newRecord = new Compatibilidad__c(
            Marca__c = brand.Id,
            Modelo__c = model.Id,
            Producto__c = product.Id
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }    

    public static Opportunity createOpportunity(Account acc, string stageName, Campaign campanna, String pricebookId, Boolean doInsert){            
        Opportunity newRecord = new Opportunity(
            AccountId = acc.Id,
            CloseDate = System.today().AddMonths(3),
            StageName = stageName,
            Campana__c = campanna.Id,
            Sucursal__c = 'Escazú',
            //MonedaIngreso__c = 'Colones',
            IngresoAproximado__c = 1500,
            RT_Lead__c = 'BMW',
            // CurrencyIsoCode = 'USD',
            Pricebook2Id = pricebookId,
            RecordTypeId = getRecordTypeId('Opportunity', 'BMW')
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static Sucursal__c createSurcursal(string name, Boolean doInsert){            
        Sucursal__c newRecord = new Sucursal__c(
            Name = name
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static Campaign createCampanna(string name, string rtypeId, Boolean doInsert){            
        Campaign newRecord = new Campaign(
            Name = name,
            RecordTypeId = rtypeId
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static Quote createQuote(Opportunity opp,Boolean doInsert){            
        Quote newRecord = new Quote(
            Name = 'PT-2023 Test',
            OpportunityId = opp.Id,
            CurrencyIsoCode = 'USD'
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static Quote createQuote(Opportunity opp, String vigencia,Boolean doInsert){            
        Quote newRecord = new Quote(
            Name = 'PT-2023 Test',
            Vegencia_del_presupuesto__c = vigencia,
            OpportunityId = opp.Id,
            CurrencyIsoCode = 'USD'
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }    

    public static QuoteLineItem createQLI(Quote quote, String pricebookId, Product2 product, String qliId, Decimal UnitPrice, Boolean esExtra, Boolean esRegalia, Boolean esManoObra, Boolean doInsert){            
        QuoteLineItem newRecord = new QuoteLineItem(
            QuoteId = quote.Id,
            Quantity = 1,
            UnitPrice = UnitPrice,
            PricebookEntryId = pricebookId,
            Product2Id = product.Id,
            // esVehiculo__c = esVehiculo,
            esExtra__c = esExtra,
            esRegalia__c = esRegalia,
            // esManoObra__c = esManoObra,
            Quote_Line_Item__c = qliId
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static Oportunidad_Producto_Interes__c createOportunidadProductoInteres(String marca,String modeloInteres,String familia,String anio,Opportunity opp, Boolean doInsert){            
        Oportunidad_Producto_Interes__c newRecord = new Oportunidad_Producto_Interes__c(
            Marca__c = marca,
            Modelo_Interes__c = modeloInteres,
            Familia__c = familia,
            Anio__c = anio,
            Oportunidad__c = opp.Id,
            Precio_Unitario__c = 99000,
            Costo_Fijo__c = 10000
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static void createQuoteWithItems() {

        List<String> pickListValuesList= new List<String>();
        String picklistValue;
		Schema.DescribeFieldResult fieldResult = Product2.Modelo_De_Inter_s__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
            picklistValue = pickListVal.getValue();
		}

        // String grupo = 'BMW i';
        // String brand = 'BMW';
        // String year = '2023';
        // String model = 'BMW-IX1-20-VR-XLINE';
        // String family = 'iX1';
        // String tipo = 'Eléctrinco';
        // String model2 = 'BMW-IX1-20-VR-XLINE-PLUS';

        List<Product2> productList = new List<Product2>();        
        productList.add(TestDataFactory.createProduct('BM166 - X1 sDrive18d', 'BMW-X1','Eléctrico','BMW i', 'BMW', 'iX1', picklistValue, '2021', 'Rojo','Negro','Vehiculo',true, false));

        List<Product2> productExtraList = new List<Product2>();
        productExtraList.add(TestDataFactory.createProduct('Rack BMW X1 2021', 'Rack BMW X1 2021',null,null, 'BMW', null, null, '2021', 'Rojo','Negro','Materiales',false, false));        
        productExtraList.add(TestDataFactory.createProduct('Rack BMW X3 2023', 'Rack BMW X3 2023',null,null, 'BMW', null, null, '2023', 'Rojo','Negro','Materiales',false, false));

        //Mano de obra         
        productExtraList.add(TestDataFactory.createProduct('Mano de obra', 'Mano de obra',null, null,'BMW', null, null, '2022', 'Rojo','Negro','Mano de Obra',false, false));
        productExtraList.add(TestDataFactory.createProduct('Mano de obra', 'Mano de obra',null, null,'BMW', null, null, '2023', 'Rojo','Negro','Mano de Obra',false, false));
        productList.addAll(productExtraList);
        
        insert productList; 
        
        Bodega__c bodegaUruca = TestDataFactory.createBodega('Uruca',true);       
        
        Id pricebookId = Test.getStandardPricebookId();
  
        List<Id> prodIds = new List<Id>();
        for(Product2 p : productList){
            prodIds.add(p.Id);
        }
        
        productList = [ SELECT Id, (SELECT Id, Name, Product2Id, Pricebook2Id, pricebookEntryId__c, CurrencyIsoCode FROM PricebookEntries WHERE CurrencyIsoCode = 'USD' ), esVehiculo__c, esExtra__c, tipoProducto__c FROM Product2 WHERE Id =:prodIds];        

        
        List<ProductoXBodega__c> prodXBodList = new List<ProductoXBodega__c>();
        for (Product2 product : productList) {
            if (product.tipoProducto__c != null && product.tipoProducto__c != 'Mano de Obra') {
                prodXBodList.add(TestDataFactory.createProductoXBodega(bodegaUruca,product, false));
            }
        }
        insert prodXBodList;  

        Marca__c brand = TestDataFactory.createBrand('BMW',true);

        Modelo__c model = TestDataFactory.createModel('BM166 - X1 sDrive18d',brand,true);

        List<Compatibilidad__c> compList = new List<Compatibilidad__c>();
        for (Product2 prod : productExtraList) {
            compList.add(TestDataFactory.createCompatibilidad(brand,model,prod,false));                
        }        
        insert compList;        

        Account acc = TestDataFactory.createAccount('Account Test Juan C.', true);

        List<RecordType> rtype = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Campana_Red_Motors'];
        String rtId = getRecordTypeId('Campaign','Campana_Red_Motors');
        Campaign campanna = TestDataFactory.createCampanna('Campaign JC',rtId, true);        
        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Oportunidad Calificada', campanna, pricebookId, true);

        Quote newQuote = TestDataFactory.createQuote(opp, false);
        newQuote.Pricebook2Id = pricebookId;
        insert newQuote;

        List<QuoteLineItem> newQLIList = new List<QuoteLineItem>();        
        for(Product2 p  : productList){
            for(PricebookEntry priceBE  : p.PricebookEntries){
                if(p.Id == priceBE.Product2Id && p.esVehiculo__c == true){
                    newQLIList.add(TestDataFactory.createQLI(newQuote, priceBE.Id, p, null,  1, false, false, false, false));
                }
            }
        }        
        insert newQLIList;

        List<QuoteLineItem> qliList = new List<QuoteLineItem>();

        for(Product2 p  : productList){
            for(PricebookEntry priceBE  : p.PricebookEntries){
                if(p.Id == priceBE.Product2Id && p.esVehiculo__c == false){          
                    Boolean esExtra = false;
                    Boolean esRegalia = false;
                    Boolean esManoObra = false;

                    System.debug('p2==> ' + p);
                    System.debug('priceBE2 ===> ' + priceBE);
                    if(p.tipoProducto__c == 'Mano de Obra'){
                        esManoObra = true;
                    }

                    if(p.tipoProducto__c == 'Materiales'){
                        esExtra = true;
                    }

                    qliList.add(TestDataFactory.createQLI(newQuote, priceBE.Id, p, newQLIList[0].Id, 1, esExtra, esRegalia, esManoObra, false));
                }
            }
        }
        insert qliList;
    }

    public static String getRecordTypeId(String objectName,String recordTypeDeveloperName) {
        String rtId;
        List<RecordType> rtypeList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = :objectName AND DeveloperName = :recordTypeDeveloperName AND IsActive = TRUE LIMIT 1];
        if (rtypeList.size() > 0) {
            rtId = rtypeList[0].Id;
        }
        return rtId;
    }

    public static Anticipo__c createAnticipo(Opportunity opp, Boolean doInsert){            
        Anticipo__c newRecord = new Anticipo__c(
            Identificador__c = '000000000000019',
            Monto__c = 100,
            Oportunidad__c = opp.Id,
            Estatus__c = 'Abierto'
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }


    public static Pricebook2 createPriceBook(String Name, Boolean doInsert){            
        Pricebook2 newRecord = new Pricebook2(
            Name = Name,
            IsActive = true
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }


    public static PricebookEntry createPriceBookEntry(Pricebook2 priceBook,Product2 product,Decimal unitPrice, Boolean doInsert){            
        PricebookEntry newRecord = new PricebookEntry(
            Pricebook2Id = priceBook.Id,
            Product2Id = product.Id,
            UnitPrice = unitPrice,
            Costo_Fijo__c = unitPrice,
            IsActive = true,
            CurrencyIsoCode = 'USD'
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static Configuracion_de_ventas__c createConfiVentas(String name,String currentPriceBook,String brand,Pricebook2 softlandPB, Boolean doInsert){            
        Configuracion_de_ventas__c newRecord = new Configuracion_de_ventas__c(
            Name = name,
            Listas_de_Precios_Vigente__c = currentPriceBook,
            Marca__c = brand,
            RM_ListaPrecioSoftland__c = softlandPB.Id,
            CurrencyIsoCode = 'USD'
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    //create plan de mantenimiento
    public static Plan_de_mantenimiento__c createPlanMantenimiento(String name,Opportunity opp,OpportunityLineItem oppLineItem, Boolean doInsert){            
        Plan_de_mantenimiento__c newRecord = new Plan_de_mantenimiento__c(
            Fecha_de_inicio__c = Date.today(),
            Fecha_de_fin__c = Date.today().addYears(1),
            Opportunity__c = opp.Id,
            Opportunity_Product__c = oppLineItem.Id,
            Plan_de_mantenimiento__c = 'BSI Fabrica Autos'
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    //create OpportunityLineItem
    public static OpportunityLineItem createOpportunityLineItem(Opportunity opp,Product2 product,PricebookEntry priceBookEntry, Boolean doInsert){            
        OpportunityLineItem newRecord = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = product.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 1,
            UnitPrice = 100
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    //create Trigger_control__c
    public static Trigger_control__c createTriggerControl(String name, Boolean doInsert){            
        Trigger_control__c newRecord = new Trigger_control__c(
            Name = name,
            Turned_off__c = true
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    public static Detalle_Costo_Producto__c crearDetalleCosto(Product2 product, Boolean doInsert){            
        Detalle_Costo_Producto__c newRecord = new Detalle_Costo_Producto__c(
            id_linea_gasto__c = '1',
            Product__c = product.Id,
            Monto_Dolar__c = 31577.48,
            Monto_local__c = 17186990.8144,
            Rubro__c = 'TRANSPORTE TERRESTRE'
        );
    
        if(doInsert){
            insert newRecord;
        }
        return newRecord;
    }

    

    // //create WarrantyTerm
    // public static WarrantyTerm createWarrantyTerm(String name,Boolean doInsert){            
    //     WarrantyTerm newRecord = new WarrantyTerm(
    //         Name = name,
    //         Code = 'WarrantyTermCode',
    //         IsActive = true,
    //         WarrantyType = 'BSI BMW'
    //     );
    
    //     if(doInsert){
    //         insert newRecord;
    //     }
    //     return newRecord;
    // }
        // ...otros métodos
public static Product2 createProduct(
    String name,
    String productCode,
    String marca,
    String modelo,
    String codigoProducto,
    String anno,
    String colorInt,
    String colorExt,
    String familia,
    Boolean esUsado,
    Boolean reservado
){
    Product2 p = new Product2();
    p.Name = name;
    p.ProductCode = productCode;
    p.Codigo_de_Producto__c = codigoProducto;
    p.Marca__c = marca;
    p.Grupo__c = marca;
    p.modelo__c = modelo;
    p.Color__c = colorInt;
    p.Color_Externo__c = colorExt;
    p.Familia__c = familia;
    p.IsActive = true;
    p.vin__c = 'VIN-' + String.valueOf(DateTime.now().getTime());

    // Año (por si es Number en tu org)
    try { p.Anno__c = Integer.valueOf(anno); } catch (Exception e) {}

    // Picklist categoría (toma un valor válido)
    List<Schema.PicklistEntry> vals = Product2.Categoria_veh_culo__c.getDescribe().getPicklistValues();
    if (!vals.isEmpty()) p.Categoria_veh_culo__c = vals[0].getValue();

    // Flags
    p.esVehiculo__c = true;
    p.es_Vehiculo_usado__c = esUsado;
    p.Producto_Reservado__c = reservado;

    return p;
}

} // <- esta es la última llave de la clase