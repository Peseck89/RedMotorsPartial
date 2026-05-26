/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 08-12-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class ClientesRequest {
    public String tipoIdentificacion;
    public String numeroIdentificacion;
    public String nombreCliente;
    public String segundoNombreCliente;
    public String primerApellido;
    public String segundoApellido;
    public String conocidoComo;
    public String razonSocial;
    public String nombreComercial;
    public String descripcionCuenta;
    public String numeroIdentificacionEntidad;
    public String fechaVencimientoIdentificacion;
    public String lugarExpedicionIdentificacion;
    public String fechaUltimaActualizacion;
    public String genero;
    public String fechaNacimiento;
    public String estadoCivil;
    public String paisOrigen;
    public String fechaIngreso;
    public String fechaSalida;
    public String fechaInactividad;
    public String fechaVinculacion;
    public String estado;
    public String ejecutivo;
    public String estadoXML;
    public String tipoCuenta;
    public Integer codigoOficina;
    public String usuarioRegistro;
    public String administFondosTercero;
    public Integer estructuraLegal;
    public Integer profesion;
    public Integer actividadEconomica;
    public String sectorPublico;
    public String institucionLabora;
    public Integer cantidadAnosLaborar;
    public Integer monedaIngresoMensual;
    public Double montoIngresoMensual;
    public String esEmpleado;
    public String esPep;
    public String tipoPep;
    public String articulo15;
    public Integer origenFondos;
    public Double inversionInicial;
    public String residente;
    public String fechaCargaCliente;
    public Integer usuario;
    public String fechaValor;
    public String fechaRegistro;
    public String descripcionObservaciones;
    public String esApnfd;
    public String tipoApnfd;
    public String fechaRegistroApnfd;
    public Integer entidadSupervisora;
    public String esCpe;
    public String pagaImpuestos;
    public clientesNacionalidades[] clientesNacionalidades;
    public clientesUbicaciones[] clientesUbicaciones;
    public clientesFATCA[] clientesFATCA;
    public clientesIngresos[] clientesIngresos;
    public clientesFondosTerceros[] clientesFondosTerceros;
    public clientesPatrimonio[] clientesPatrimonio;
    public clientesFuncionesPEP[] clientesFuncionesPEP;
    public clientesTransacciones[] clientesTransacciones;
    public clientesPolizas[] clientesPolizas;
    public clientesOtrosAtributos[] clientesOtrosAtributos;
    public clientesSocios[] clientesSocios;
    public clientesRelaciones[] clientesRelaciones;
    public clientesRepresentantes[] clientesRepresentantes;
    class ClientesNacionalidades {
        public Integer nacionalidad;
    }
    class ClientesUbicaciones {
        public Integer tipoUbicacion;
        public Integer divisionTerritorial;
        public String descripcionUbicacion;
    }
    class ClientesFATCA {
        public String poseeGreenCard;
        public String poseeEIN;
        public String numeroEIN;
        public String contribuyenteUSA;
        public String numeroTIN;
        public String domicilioExtranjero;
        public Integer paisDomicilio;
        public String detalleDomicilio;
        public String poseeTelefonoExtranjero;
        public String telefonoExtranjero;
        public String poseeProductos;
        public String detalleProductos;
    }
    class ClientesIngresos {
        public String nombreEmpresa;
        public String cargo;
        public Integer actividadEconomica;
        public String telefonoCentral;
        public String telefonoDirecto;
        public String direccion;
        public Integer divisionTerritorial;
        public Integer origenRecursos;
        public String justificacionOrigenRecursos;
        public String detalle;
        public String sustentoOtraPersonas;
        public String detalleSustento;
        public Double monto;
        public Integer moneda;
    }
    class ClientesFondosTerceros {
        public Integer tipoIdentificacionTercero;
        public String numeroIdentificacionTercero;
        public String nombreTercero;
        public Integer paisOrigen;
        public Integer actividadEconomica;
        public Integer origenRecursos;
        public Double monto;
        public Integer moneda;
    }
    class ClientesPatrimonio {
        public String descripcionPatrimonio;
        public Integer tipoBien;
        public Integer moneda;
        public Double montoValor;
        public String fechaRegistro;
    }
    class ClientesFuncionesPEP {
        public String cargo;
        public String esVigente;
        public String fechaInicio;
        public String fechaFinalizacion;
        public String entidad;
        public Integer pais;
    }
    class ClientesTransacciones {
        public String inversionInicial;
        public String detalleInversionInicial;
        public Double monto;
        public Integer cantidadIngresoMensuales;
        public Double montoIngresoMensual;
        public Integer cantidadEgresoMensuales;
        public Double montoEgresoMensual;
        public String finalidad;
        public String motivo;
        public String frecuencia;
    }
    class ClientesPolizas {
        public String numeroPoliza;
        public String descripcionPoliza;
        public String fechaInicio;
        public String fechaFinalizacion;
        public Integer moneda;
        public Double prima;
        public Double montoAsegurado;
        public String tipoPrima;
        public String estado;
        public String tipoPoliza;
        public Integer tipoProducto;
    }
    class ClientesOtrosAtributos {
        public Integer atributo;
        public String descripcionAtributo;
    }
    class ClientesSocios {
        public Integer tipoIdentificacionSocio;
        public String numeroIdentificacionSocio;
        public String nombre;
        public String segundoNombre;
        public String primerApellido;
        public String segundoApellido;
        public String conocidoComo;
        public String genero;
        public String fechaNacimiento;
        public String estadoCivil;
        public Integer paisOrigen;
        public Integer profesion;
        public Integer actividadEconomica;
        public String esPep;
        public String tipoPep;
        public String descripcionPep;
        public String articulo15;
        public Double participacion;
    }
    class ClientesRelaciones {
        public Integer tipoRelacion;
        public Integer tipoIdentificacionRelacion;
        public String numeroIdentificacionRelacion;
        public String nombre;
        public String segundoNombre;
        public String primerApellido;
        public String segundoApellido;
        public String conocidoComo;
        public String genero;
        public String fechaNacimiento;
        public String estadoCivil;
        public Integer paisOrigen;
        public Integer profesion;
        public Integer actividadEconomica;
        public String esPep;
        public String tipoPep;
        public String articulo15;
        public String beneficiario;
        public String titular;
        public String tipoTitularidad;
        public Integer participacion;
        public String fechaVencimientoIdentificacion;
        public String cargo;
        public String descripcionPep;
        public String fechaInscripcionCargo;
        public String fechaFinalizacionCargo;
        public clientesRelacionesNacionalidades[] clientesRelacionesNacionalidades;
        public clientesRelacionesUbicaciones[] clientesRelacionesUbicaciones;
    }
    class ClientesRelacionesNacionalidades {
        public Integer nacionalidad;
    }
    class ClientesRelacionesUbicaciones {
        public Integer tipoUbicacion;
        public Integer divisionTerritorial;
        public String descripcionUbicacion;
    }
    class ClientesRepresentantes {
        public Integer tipoIdentificacionRepresentante;
        public String numeroIdentificacionRepresentante;
        public String nombre;
        public String segundoNombre;
        public String primerApellido;
        public String segundoApellido;
        public String conocidoComo;
        public String genero;
        public String fechaNacimiento;
        public String estadoCivil;
        public Integer paisOrigen;
        public Integer profesion;
        public Integer actividadEconomica;
        public String esPep;
        public String tipoPep;
        public String descripcionPep;
        public String articulo15;
        public String cargo;
        public String fechaVencimiento;
        public clientesRepresentantesNacionalidades[] clientesRepresentantesNacionalidades;
        public clientesRepresentantesUbicaciones[] clientesRepresentantesUbicaciones;
    }
    class ClientesRepresentantesNacionalidades {
        public Integer nacionalidad;
    }
    class ClientesRepresentantesUbicaciones {
        public Integer tipoUbicacion;
        public Integer divisionTerritorial;
        public String descripcionUbicacion;
    }
    public ClientesRequest (Account clienteActual){
        this.tipoIdentificacion = clienteActual.Tipo_de_Documento__c;
        this.numeroIdentificacion = clienteActual.Cedula__c;
        this.nombreCliente = clienteActual.nombreCliente__c;
        this.segundoNombreCliente = clienteActual.segundoNombreCliente__c;
        this.primerApellido = clienteActual.primerApellido__c;
        this.segundoApellido = clienteActual.segundoApellido__c;
        this.conocidoComo = clienteActual.conocidoComo__c;
        this.razonSocial = clienteActual.razonSocial__c;
        this.nombreComercial = clienteActual.Name;
        this.descripcionCuenta = clienteActual.descripcionCuenta__c;
        this.numeroIdentificacionEntidad = clienteActual.Cedula__c;
        this.fechaVencimientoIdentificacion = String.valueOf(clienteActual.fechaVencimientoIdentificacion__c);
        this.lugarExpedicionIdentificacion = clienteActual.lugarExpedicionIdentificacion__c;
        this.fechaUltimaActualizacion = String.valueOf(clienteActual.LastModifiedDate);
        this.genero = clienteActual.genero__c;
        this.fechaNacimiento = String.valueOf(clienteActual.PersonBirthdate);
        this.estadoCivil = clienteActual.EstadoCivilTipos__c;
        this.paisOrigen = clienteActual.Pais__c;
        this.fechaIngreso = String.valueOf(clienteActual.CreatedDate);
        this.fechaSalida = String.valueOf(clienteActual.fechaSalida__c);
        this.fechaInactividad = String.valueOf(clienteActual.fechaInactividad__c);
        this.fechaVinculacion = String.valueOf(clienteActual.fechaVinculacion__c);
        this.estado = clienteActual.estado__c;
        this.ejecutivo = clienteActual.ejecutivo__c;
        this.estadoXML = clienteActual.estadoXML__c;
        this.tipoCuenta = clienteActual.tipoCuenta__c;
        this.codigoOficina = Integer.valueOf(clienteActual.codigoOficina__c);
        this.usuarioRegistro = clienteActual.usuarioRegistro__c;
        this.administFondosTercero = clienteActual.administFondosTercero__c;
        this.estructuraLegal = clienteActual.estructuraLegal__c!=null?Integer.valueOf(clienteActual.estructuraLegal__c):null;
        this.profesion = Integer.valueOf(clienteActual.profesion__c); 
        this.actividadEconomica = Integer.valueOf(clienteActual.actividadEconomica__c);
        this.sectorPublico = clienteActual.sectorPublico__c;
        this.institucionLabora = clienteActual.institucionLabora__c;
        this.cantidadAnosLaborar = Integer.valueOf(clienteActual.cantidadAnosLaborar__c);
        this.monedaIngresoMensual = clienteActual.monedaIngresoMensual__c!=null?Integer.valueOf(clienteActual.monedaIngresoMensual__c):null;
        this.montoIngresoMensual = clienteActual.montoIngresoMensual__c;
        this.esEmpleado = clienteActual.esEmpleado__c;
        //this.esPep = clienteActual.espe
        this.tipoPep = clienteActual.tipoPep__c;
        this.articulo15 = clienteActual.articulo15__c;
        this.origenFondos = clienteActual.origenFondos__c!=null?Integer.valueOf(clienteActual.origenFondos__c):null;
        this.inversionInicial = clienteActual.inversionInicial__c;
        this.residente = clienteActual.residente__c;
        this.fechaCargaCliente = String.valueOf(clienteActual.fechaCargaCliente__c);
        this.usuario = Integer.valueOf(clienteActual.usuario__c);
        this.fechaValor = String.valueOf(clienteActual.fechaValor__c);
        this.fechaRegistro = String.valueOf(clienteActual.fechaRegistro__c);
        this.descripcionObservaciones = clienteActual.descripcionObservaciones__c;
        this.esApnfd = clienteActual.esApnfd__c;
        this.tipoApnfd = clienteActual.tipoApnfd__c;
        this.fechaRegistroApnfd = String.valueOf(clienteActual.fechaRegistroApnfd__c);
        this.entidadSupervisora = Integer.valueOf(clienteActual.entidadSupervisora__c);
        this.esCpe = clienteActual.esCpe__c;
        this.pagaImpuestos = clienteActual.pagaImpuestos__c;

        
        // this.clientesNacionalidades = getClientesNacionalidades(clienteActual.Id);
        // this.clientesUbicaciones = getClientesUbicaciones(clienteActual.Id);
        // this.clientesFATCA = getClientesFATCA(clienteActual.Id);
        // this.clientesIngresos = getClientesIngresos(clienteActual.Id);
        // this.clientesFondosTerceros = getClientesFondosTerceros(clienteActual.Id);
        // this.clientesPatrimonio = getClientesPatrimonio(clienteActual.Id);
        // this.clientesFuncionesPEP = getClientesFuncionesPEP(clienteActual.Id);
        // this.clientesTransacciones = getClientesTransacciones(clienteActual.Id);
        // this.clientesPolizas = getClientesPolizas(clienteActual.Id);
        // this.clientesOtrosAtributos = getClientesOtrosAtributos(clienteActual.Id);
        // this.clientesSocios = getClientesSocios(clienteActual.Id);
        // this.clientesRelaciones = getClientesRelaciones(clienteActual.Id);
        // this.clientesRepresentantes = getClientesRepresentantes(clienteActual.Id);
    }
/*
    public static List<ClientesNacionalidades> getClientesNacionalidades(Id clienteActual)
    {
        List<clientesNacionalidades__c> clnac = [SELECT Id, cuenta__c, nacionalidad__c FROM clientesNacionalidades__c WHERE Cuenta__c =: clienteActual];
        List<ClientesNacionalidades> records = new List<ClientesNacionalidades>();
        
        for(ClientesNacionalidades__c rec : clnac){
            ClientesNacionalidades record = new ClientesNacionalidades();
            record.nacionalidad = Integer.valueOf(rec.nacionalidad__c);
            records.add(record);
        }
        return records;
    }

    public static List<ClientesUbicaciones> getClientesUbicaciones(Id clienteActual)
    {
        List<clientesUbicaciones__c> clubic = [SELECT Id, cuenta__c, descripcionUbicacion__c, divisionTerritorial__c, tipoUbicacion__c FROM clientesUbicaciones__c WHERE Cuenta__c =: clienteActual];
        List<ClientesUbicaciones> records = new List<ClientesUbicaciones>();
        
        for(ClientesUbicaciones__c rec : clubic){
            ClientesUbicaciones record = new ClientesUbicaciones();
            record.descripcionUbicacion = rec.descripcionUbicacion__c;
            record.divisionTerritorial = Integer.valueOf(rec.divisionTerritorial__c);
            record.tipoUbicacion = Integer.valueOf(rec.tipoUbicacion__c);
            records.add(record);
        }
        return records;
    }

    public static List<ClientesFATCA> getClientesFATCA(Id clienteActual)
    {
        List<clientesFATCA__c> clFATCA = [SELECT Id, cuenta__c, poseeGreenCard__c, poseeEIN__c, numeroEIN__c, contribuyenteUSA__c, numeroTIN__c, domicilioExtranjero__c, paisDomicilio__c, detalleDomicilio__c, poseeTelefonoExtranjero__c, telefonoExtranjero__c, poseeProductos__c, detalleProductos__c FROM clientesFATCA__c WHERE Cuenta__c =: clienteActual];
        List<ClientesFATCA> records = new List<ClientesFATCA>();
        
        for(ClientesFATCA__c rec : clFATCA){
            ClientesFATCA record = new ClientesFATCA();
            record.poseeGreenCard = rec.poseeGreenCard__c;
            record.poseeEIN = rec.poseeEIN__c;
            record.numeroEIN = rec.numeroEIN__c;
            record.contribuyenteUSA = rec.contribuyenteUSA__c;
            record.numeroTIN = rec.numeroTIN__c;
            record.domicilioExtranjero = rec.domicilioExtranjero__c;
            record.paisDomicilio = Integer.valueOf(rec.paisDomicilio__c);
            record.detalleDomicilio = rec.detalleDomicilio__c;
            record.poseeTelefonoExtranjero = rec.poseeTelefonoExtranjero__c;
            record.telefonoExtranjero = rec.telefonoExtranjero__c;
            record.poseeProductos = rec.poseeProductos__c;
            record.detalleProductos = rec.detalleProductos__c;
            records.add(record);
        }
        return records;
    }

    public static List<ClientesIngresos> getClientesIngresos(Id clienteActual)
    {
        List<clientesIngresos__c> clIng = [SELECT Id, cuenta__c, nombreEmpresa__c, cargo__c, actividadEconomica__c, telefonoCentral__c, telefonoDirecto__c, direccion__c, divisionTerritorial__c, origenRecursos__c, justificacionOrigenRecursos__c, detalle__c, sustentoOtraPersonas__c, detalleSustento__c, monto__c, moneda__c FROM clientesIngresos__c WHERE Cuenta__c =: clienteActual];
        List<ClientesIngresos> records = new List<ClientesIngresos>();
        
        for(ClientesIngresos__c rec : clIng){
            ClientesIngresos record = new ClientesIngresos();
            record.nombreEmpresa = rec.nombreEmpresa__c; 
            record.cargo = rec.cargo__c;
            record.actividadEconomica = Integer.valueOf(rec.actividadEconomica__c);
            record.telefonoCentral = rec.telefonoCentral__c;
            record.telefonoDirecto = rec.telefonoDirecto__c;
            record.direccion = rec.direccion__c;
            record.divisionTerritorial = Integer.valueOf(rec.divisionTerritorial__c);
            record.origenRecursos = Integer.valueOf(rec.origenRecursos__c);
            record.justificacionOrigenRecursos = rec.justificacionOrigenRecursos__c;
            record.detalle = rec.detalle__c;
            record.sustentoOtraPersonas = rec.sustentoOtraPersonas__c;
            record.detalleSustento = rec.detalleSustento__c;
            record.monto = rec.monto__c;
            record.moneda = Integer.valueOf(rec.moneda__c);
            records.add(record);
        }
        return records;
    }

    public List<ClientesFondosTerceros> getClientesFondosTerceros(Id clienteActual)
    {
        List<clientesFondosTerceros__c> clFonTer = [SELECT Id, cuenta__c, tipoIdentificacionTercero__c, numeroIdentificacionTercero__c, nombreTercero__c, paisOrigen__c, actividadEconomica__c, origenRecursos__c, monto__c, moneda__c FROM clientesFondosTerceros__c WHERE Cuenta__c =: clienteActual];
        List<ClientesFondosTerceros> records = new List<ClientesFondosTerceros>();
        
        for(ClientesFondosTerceros__c rec : clFonTer){
            ClientesFondosTerceros record = new ClientesFondosTerceros();
            record.tipoIdentificacionTercero = Integer.valueOf(rec.tipoIdentificacionTercero__c);
            record.numeroIdentificacionTercero = rec.numeroIdentificacionTercero__c;
            record.nombreTercero = rec.nombreTercero__c;
            record.paisOrigen = Integer.valueOf(rec.paisOrigen__c);
            record.actividadEconomica = Integer.valueOf(rec.actividadEconomica__c);
            record.origenRecursos = Integer.valueOf(rec.origenRecursos__c);
            record.monto = rec.monto__c;
            record.moneda = Integer.valueOf(rec.moneda__c);
            records.add(record);
        }
        return records;
    }

    public List<ClientesPatrimonio> getClientesPatrimonio(Id clienteActual)
    {
        List<Clientes_Patrimonio__c> clPat = [SELECT Id, cuenta__c, descripcionPatrimonio__c, tipoBien__c, moneda__c, montoValor__c, fechaRegistro__c FROM Clientes_Patrimonio__c WHERE Cuenta__c =: clienteActual];
        List<ClientesPatrimonio> records = new List<ClientesPatrimonio>();
        
        for(Clientes_Patrimonio__c rec : clPat){
            ClientesPatrimonio record = new ClientesPatrimonio();
            record.descripcionPatrimonio = rec.descripcionPatrimonio__c;
            record.tipoBien = Integer.valueOf(rec.tipoBien__c);
            record.moneda = Integer.valueOf(rec.moneda__c);
            record.montoValor = rec.montoValor__c;
            record.fechaRegistro = String.valueOf(rec.fechaRegistro__c);
            records.add(record);
        }
        return records;
    }

    public List<ClientesFuncionesPEP> getClientesFuncionesPEP(Id clienteActual)
    {
        List<clientesFuncionesPEP__c> clfunPEP = [SELECT Id, cuenta__c, cargo__c, esVigente__c, fechaInicio__c, fechaFinalizacion__c, entidad__c, pais__c FROM clientesFuncionesPEP__c WHERE Cuenta__c =: clienteActual];
        List<ClientesFuncionesPEP> records = new List<ClientesFuncionesPEP>();
        
        for(ClientesFuncionesPEP__c rec : clfunPEP){
            ClientesFuncionesPEP record = new ClientesFuncionesPEP();
            record.cargo = rec.cargo__c;
            record.esVigente = rec.esVigente__c;
            record.fechaInicio = String.valueOf(rec.fechaInicio__c);
            record.fechaFinalizacion = String.valueOf(rec.fechaFinalizacion__c);
            record.entidad = rec.entidad__c;
            record.pais = Integer.valueOf(rec.pais__c);
            records.add(record);
        }
        return records;
    }

    public List<ClientesTransacciones> getClientesTransacciones(Id clienteActual)
    {
        List<clientesTransacciones__c> clTran = [SELECT Id, cuenta__c, inversionInicial__c, Name, monto__c, cantidadIngresoMensuales__c, montoIngresoMensual__c, Cantidad_promedio_de_Operaciones_Egreso__c, montoEgresoMensual__c, finalidad__c, motivo__c, frecuencia__c FROM clientesTransacciones__c WHERE Cuenta__c =: clienteActual];
        List<ClientesTransacciones> records = new List<ClientesTransacciones>();
        
        for(ClientesTransacciones__c rec : clTran){
            ClientesTransacciones record = new ClientesTransacciones();
            record.inversionInicial = rec.inversionInicial__c;
            record.detalleInversionInicial = rec.Name;
            record.monto = rec.monto__c;
            record.cantidadIngresoMensuales = Integer.valueOf(rec.cantidadIngresoMensuales__c);
            record.montoIngresoMensual = rec.montoIngresoMensual__c;
            record.cantidadEgresoMensuales = Integer.valueOf(rec.Cantidad_promedio_de_Operaciones_Egreso__c);
            record.montoEgresoMensual = rec.montoEgresoMensual__c;
            record.finalidad = rec.finalidad__c;
            record.motivo = rec.motivo__c;
            record.frecuencia = rec.frecuencia__c;
            records.add(record);
        }
        return records;
    }

    public List<ClientesPolizas> getClientesPolizas(Id clienteActual)
    {
        List<clientesPolizas__c> clPol = [SELECT Id, cuenta__c, numeroPoliza__c, descripcionPoliza__c, fechaInicio__c, fechaFinalizacion__c, moneda__c, prima__c, montoAsegurado__c, tipoPrima__c, estado__c, tipoPoliza__c, tipoProducto__c FROM clientesPolizas__c WHERE Cuenta__c =: clienteActual];
        List<ClientesPolizas> records = new List<ClientesPolizas>();
        
        for(ClientesPolizas__c rec : clPol){
            ClientesPolizas record = new ClientesPolizas();
            record.numeroPoliza = rec.numeroPoliza__c;
            record.descripcionPoliza = rec.descripcionPoliza__c;
            record.fechaInicio = String.valueOf(rec.fechaInicio__c);
            record.fechaFinalizacion = String.valueOf(rec.fechaFinalizacion__c);
            record.moneda = Integer.valueOf(rec.moneda__c);
            record.prima = rec.prima__c;
            record.montoAsegurado = rec.montoAsegurado__c;
            record.tipoPrima = rec.tipoPrima__c;
            record.estado = rec.estado__c;
            record.tipoPoliza = rec.tipoPoliza__c;
            record.tipoProducto = Integer.valueOf(rec.tipoProducto__c);
            records.add(record);
        }
        return records;
    }

    public List<ClientesOtrosAtributos> getClientesOtrosAtributos(Id clienteActual)
    {
        List<clientesOtrosAtributos__c> clOtroAtt = [SELECT Id, cuenta__c, atributo__c, descripcionAtributo__c FROM clientesOtrosAtributos__c WHERE Cuenta__c =: clienteActual];
        List<ClientesOtrosAtributos> records = new List<ClientesOtrosAtributos>();
        
        for(ClientesOtrosAtributos__c rec : clOtroAtt){
            ClientesOtrosAtributos record = new ClientesOtrosAtributos();
            record.atributo = Integer.valueOf(rec.atributo__c);
            record.descripcionAtributo = rec.descripcionAtributo__c;
            records.add(record);
        }
        return records;
    }

    public static List<ClientesSocios> getClientesSocios(Id clienteActual)
    {
        List<clientesSocios__c> clSocios = [SELECT Id, cuenta__c, tipoIdentificacionSocio__c, numeroIdentificacionSocio__c, Name, segundoNombre__c, primerApellido__c, segundoApellido__c, conocidoComo__c, genero__c, fechaNacimiento__c, estadoCivil__c, paisOrigen__c, profesion__c, actividadEconomica__c, esPep__c, tipoPep__c, descripcionPep__c, articulo15__c, participacion__c FROM clientesSocios__c WHERE Cuenta__c =: clienteActual];
        List<ClientesSocios> records = new List<ClientesSocios>();
        
        for(ClientesSocios__c rec : clSocios){
            ClientesSocios record = new ClientesSocios();
            record.tipoIdentificacionSocio = Integer.valueOf(rec.tipoIdentificacionSocio__c);
            record.numeroIdentificacionSocio = rec.numeroIdentificacionSocio__c;
            record.nombre = rec.Name;
            record.segundoNombre = rec.segundoNombre__c;
            record.primerApellido = rec.primerApellido__c;
            record.segundoApellido = rec.segundoApellido__c;
            record.conocidoComo = rec.conocidoComo__c;
            record.genero = rec.genero__c;
            record.fechaNacimiento = String.valueOf(rec.fechaNacimiento__c);
            record.estadoCivil = rec.estadoCivil__c;
            record.paisOrigen = Integer.valueOf(rec.paisOrigen__c);
            record.profesion = Integer.valueOf(rec.profesion__c);
            record.actividadEconomica = Integer.valueOf(rec.actividadEconomica__c);
            record.esPep = rec.esPep__c;
            record.tipoPep = rec.tipoPep__c;
            record.descripcionPep = rec.descripcionPep__c;
            record.articulo15 = rec.articulo15__c;
            record.participacion = rec.participacion__c;
            records.add(record);
        }
        return records;
    }

    public List<ClientesRelaciones> getClientesRelaciones(Id clienteActual)
    {
        Map<Id,clientesRelaciones__c> clRel = new Map<Id,clientesRelaciones__c>([SELECT Id, cuenta__c FROM clientesRelaciones__c WHERE Cuenta__c =: clienteActual]);
        List<ClientesRelaciones> records = new List<ClientesRelaciones>();
        //List<clientesRelacionesNacionalidades__c> clRelNac = [SELECT Id, Clientes_Relaciones__c FROM clientesRelacionesNacionalidades__c WHERE Clientes_Relaciones__c IN: idclientesRelaciones];
        //List<clientesRelacionesUbicaciones__c> clRelUb = [SELECT Id, Clientes_Relaciones__c FROM clientesRelacionesUbicaciones__c WHERE Clientes_Relaciones__c IN: idclientesRelaciones];
        for(ClientesRelaciones__c rec : clRel.values()){
            ClientesRelaciones record = new ClientesRelaciones();
            records.add(record);
        }
        return records;
    }

    public List<ClientesRepresentantes> getClientesRepresentantes(Id clienteActual)
    {
        List<clientesRepresentantes__c> clRep = [SELECT Id, cuenta__c FROM clientesRepresentantes__c WHERE Cuenta__c =: clienteActual];
        List<ClientesRepresentantes> records = new List<ClientesRepresentantes>();
        
        for(ClientesRepresentantes__c rec : clRep){
            ClientesRepresentantes record = new ClientesRepresentantes();
            records.add(record);
        }
        return records;
    }     
*/
    public String getJSONClientes()
    {
        String payload = JSON.serializepretty(this);
        return payload;
    }

}
