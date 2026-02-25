@RestResource(urlMapping='/Financiamiento/*')
global class ServicioFinanciamiento {
    
    // Define las clases internas para mapear la estructura del JSON
    public class InputData {
        public Integer id;
        public Integer calculationId;
        public String tipoIdentificacion;
        public Result selectedResults;
        public Boolean syncedWithSalesForce;
        public String createdAt;
        public String updatedAt;
        public Boolean active;
        public Client[] client;
        public vendedor[] vendedor;
        public Calculation calculation;
    }

    public class Result {
        public String name;
        public Decimal deposit;
        public Decimal plazo;
        public Decimal primeraCuota;
        public Period[] periods;
        public Decimal tirUsura;
        public String typeCredit;
        public Decimal tirBussines;
        public Integer idCalculator;
    }
    
    public class Period {
        public Integer end_1;
        public Integer begin_1;
        public Integer period;
        public Decimal taxRate;
        public Decimal paymentAmount;
    }
    
    public class Client {
        public Integer id;
        public String personalID;
        public String name;
        public String lastName;
        public String email;
        public String phone;
        public Integer idOportunity;
    }
    
    public class vendedor {
        public Integer id;
        public String name;
        public String lastName;
        public String email;
        public String phone;
    }

    public class Calculation {
        public Brand brand;
        public Integer initialAmount;
        public Parameter[] parameters;
    }

    public class Brand {
        public String name;
        public String modelo;
        public String subcategoria;
        public String distribuidor;
    }

    public class Parameter {
        public String value;
        public Integer idParameter;
    }

    @HttpPost
    global static String procesarJSON() {
        // Deserializa el JSON de entrada
        RestRequest req = RestContext.request;
        InputData data = (InputData) JSON.deserialize(req.requestBody.toString(), InputData.class);
        
        Account cuentaCreadaBuscada;
        
        
        
        List<Account> CuentaBuscada = [SELECT Id FROM Account WHERE Cedula__c = :data.client[0].personalID OR cedulaIdentificacionIntellect__c  = :data.client[0].personalID LIMIT 1];
        if (CuentaBuscada.size() > 0) {
            CuentaBuscada[0].Cedula__c = data.client[0].personalID;
            CuentaBuscada[0].FirstName = data.client[0].name;
            CuentaBuscada[0].LastName = data.client[0].lastName;
            CuentaBuscada[0].PersonEmail = data.client[0].email;
            //cuenta.CorreoElectronicoEmpresarial__c = data.client[0].email;
            //String phoneO = data.client[0].phone;
            //CuentaBuscada[0].Phone =  phoneO.substring(4,11);
            CuentaBuscada[0].Phone =  data.client[0].phone;
            update CuentaBuscada[0];
            cuentaCreadaBuscada =CuentaBuscada[0];
            System.debug('Cuenta encontrada');
            
        }else{
            Account cuenta = new Account();
            cuenta.Cedula__c = data.client[0].personalID;
            cuenta.FirstName = data.client[0].name;
            cuenta.LastName = data.client[0].lastName;
            cuenta.PersonEmail = data.client[0].email;
            //cuenta.CorreoElectronicoEmpresarial__c = data.client[0].email;
            //cuenta.Phone = data.client[0].phone;
            //
            //String phoneO = data.client[0].phone;
            //cuenta.Phone =  phoneO.substring(4,11);
            //
            if (data.tipoIdentificacion   == 'Cédula Juridica'){
                
                cuenta.Tipo_de_Documento__c = 'Cédula Juridica';
                
            }else {
                cuenta.Tipo_de_Documento__c = 'Cédula Fisica';
                
                
            }
            cuenta.Phone = data.client[0].phone;
            insert cuenta;
            cuentaCreadaBuscada =cuenta;
            System.debug('Cuenta creada nueva');
        }
        

        

        
        
        // Crea la oportunidad de financiamiento
        Oportunidad_de_Financiamiento__c oportunidad = new Oportunidad_de_Financiamiento__c();
        
        /*
        List<Marca__c> marcas = [SELEC T Id FROM Marca__c WHERE Name = :data.calculation.brand.name LIMIT 1];
        if (marcas.size() > 0) {
            oportunidad.Marca__c = marcas[0].Id;
        }
        */
        
        string nombre_vendedor = data.vendedor[0].name + ' ' + data.vendedor[0].lastname;
        

        
        oportunidad.Creado_cotizador__c = True;
        
        oportunidad.Email__c = data.client[0].email;
        oportunidad.Numero_de_Identificacion_Altica__c = data.client[0].personalID;
        
        if (!Test.isRunningTest()) {
            oportunidad.Campana_Altica__c = '701PH000001qEEVYA2';
        }
        
        
        String phoneO = data.client[0].phone;
        oportunidad.Movil_Altica__c = phoneO.substring(3,11);
        
        oportunidad.Etapa__c = 'Pendiente documentación';
        
        oportunidad.Marca_Altica__c = data.calculation.brand.name;
        oportunidad.Modelo_Altica__c = data.calculation.brand.modelo;
        
        if (data.calculation.brand.subcategoria != null) {
            oportunidad.Subcategoria__c = data.calculation.brand.subcategoria;
        }
        
        
        oportunidad.Distribuidor__c = data.calculation.brand.distribuidor;
        //oportunidad.Marca_Modelo__c = data.calculation.brand.name;
       
        oportunidad.Nombre_Cliente_Altica__c = cuentaCreadaBuscada.Id;  // Asigna la cuenta a la oportunidad de financiamiento

        for (ServicioFinanciamiento.Parameter parameter : data.calculation.parameters) {
            if (parameter.idParameter == 39) {
                //oportunidad.Estado__c = parameter.value;
            } else if (parameter.idParameter == 38) {
                oportunidad.Combustible__c = parameter.value;
            } else if (parameter.idParameter == 20) {
                //oportunidad.TipoVehiculo__c = parameter.value;
            }
        }
        DateTime now = DateTime.now();
		String dateOnly = now.format('dd/MM/yyyy');
        System.debug(dateOnly);
        
        oportunidad.Name = data.client[0].name + ' ' + data.client[0].lastName + '-' + data.calculation.brand.name + '-' + dateOnly;
        oportunidad.Prima_Altica__c = data.selectedResults.deposit;
        oportunidad.PlazoOF__c = data.selectedResults.plazo;
        oportunidad.CuotaTotal__c = data.selectedResults.primeraCuota;
        oportunidad.TipoProducto__c = data.selectedResults.typeCredit;
        oportunidad.Valor_Altica__c = data.calculation.initialAmount;
        //Valor_Altica__c
        insert oportunidad;
        
        Map<String, Object> response = new Map<String, Object>();
        response.put('message', 'Procesado correctamente.');
        response.put('oportunidad_id', oportunidad.Id);
        response.put('oportunidad_name', oportunidad.Name);
        
         String jsonResponse = JSON.serialize(response);

        // Debug para imprimir el JSON de respuesta
        System.debug(jsonResponse);

        // Devuelve un mensaje de éxito
        return JSON.serialize(response);
    }

}