/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 17-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class ClienteParser {
    public List<Cliente> clientes;
    public class Cliente
    {
        public String tipoIdentificacion;
        public String numeroIdentificacion;
        public String nombreCliente;
        public String segundoNombreCliente;
        public String primerApellido;
        public String segundoApellido;
        public String sconocidoComo;
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
        public String codigoOficina;
        public String usuarioRegistro;
        public String administFondosTercero;
        public String estructuraLegal;
        public String profesion;
        public String actividadEconomica;
        public String sectorPublico;
        public String institucionLabora;
        public String cantidadAnosLaborar;
        public String monedaIngresoMensual;
        public String montoIngresoMensual;
        public String esEmpleado;
        public String esPep;
        public String tipoPep;
        public String Articulo15;
        public String origenFondos;
        public String inversionInicial;
        public String residente;
        public String fechaCargaCliente;
        public String usuario;
        public String fechaValor;
        public String fechaRegistro;
        public String descripcionObservaciones;
        public String esApnfd;
        public String tipoApnfd;
        public String fechaRegistroApnfd;
        public String entidadSupervisora;
        public String esCpe;
        public String pagaImpuestos;
        public String clientesNacionalidades;
        public String clientesUbicaciones;
        public String clientesFATCA;
        public String clientesIngresos;
        public String clientesFondosTerceros;
        public String clientesPatrimonio;
        public String clientesFuncionesPEP;
        public String clientesTransacciones;
        public String clientesPolizas;
        public String clientesOtrosAtributos;
        public String clientesSocios;
        public String clientesRelaciones;
        public String clientesRepresentantes;
    }

    public static ClienteParser parse(String json) {
        return(ClienteParser) System.JSON.deserialize(json, ClienteParser.class);
    }
}