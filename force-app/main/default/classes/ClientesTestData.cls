/**
 * @description       : 
 * @author            : alexander@incompany.cr
 * @group             : 
 * @last modified on  : 09-12-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class ClientesTestData {
    public Account generateMovimiento(Boolean isInsert)
    {
        Account clienteActual = new Account();
        /*clienteActual.tipoIdentificacion__c = 1;
        clienteActual.cedula__c = '702100613';
        clienteActual.nombreCompleto__c = 'Esteban Segura Benavides';
        clienteActual.tipoProducto__c = 1;
        clienteActual.subProducto__c = 1;
        clienteActual.numeroReferencia__c = 'Referencia';
        clienteActual.tipoMovimiento__c = 'Contado';
        clienteActual.oficina__c = 1;
        clienteActual.canal__c = 1;
        clienteActual.descripcionCanal__c = 'Descripcion';
        clienteActual.moneda__c = '1';
        clienteActual.monedaProducto__c = 1;
        clienteActual.naturalezaTransaccion__c = 'L';
        clienteActual.origenTransaccion__c = 'E';
        clienteActual.tipoCambio__c = 3242;
        clienteActual.montoDebitos__c = 3242;
        clienteActual.montoCreditos__c = 3242;
        clienteActual.usuarioRegistro__c = 2342;
        clienteActual.idOriginario__c = '702100613';
        clienteActual.nombreOriginario__c = 'Esteban Segura Benavides';
        clienteActual.idBeneficiario__c ='324234324';
        clienteActual.nombreBeneficiario__c = 'Esteban Segura Benavides';
        clienteActual.numeroCuentaOrigen__c = '21313';
        clienteActual.numeroCuentaDestino__c = '213213';
        clienteActual.paisOrigen__c = '188';
        clienteActual.paisDestino__c = '188';
        clienteActual.bancoOrigen__c = '1';
        clienteActual.bancoDestino__c = '1';
        clienteActual.fechaRegistro__c = Date.today();*/
        if(isInsert)
        {
            insert clienteActual;
        }
        return clienteActual;
    }

    public static String getClientesJSON()
    {
        String jsonStr = 
        '{'+
            '"clientes": ['+
                '{'+
                    '"tipoIdentificacion": "3",'+
                    '"numeroIdentificacion": "000000564867",'+
                    '"nombreCliente": "Rodrigo",'+
                    '"segundoNombreCliente": "",'+
                    '"primerApellido": "Blanco",'+
                    '"segundoApellido": "Rojas",'+
                    '"sconocidoComo": "",'+
                    '"razonSocial": "",'+
                    '"nombreComercial": "",'+
                    '"descripcionCuenta": "Rodrigo Blanco Rojas",'+
                    '"numeroIdentificacionEntidad": "000000564867",'+
                    '"fechaVencimientoIdentificacion": "2020-10-30",'+
                    '"lugarExpedicionIdentificacion": "",'+
                    '"fechaUltimaActualizacion": null,'+
                    '"genero": "M",'+
                    '"fechaNacimiento": null,'+
                    '"estadoCivil": "C",'+
                    '"paisOrigen": "188",'+
                    '"fechaIngreso": "2020-10-30",'+
                    '"fechaSalida": "2020-10-30",'+
                    '"fechaInactividad": "2020-10-30",'+
                    '"fechaVinculacion": "2020-10-30",'+
                    '"estado": "C",'+
                    '"ejecutivo": "ELP",'+
                    '"estadoXML": "G",'+
                    '"tipoCuenta": "0",'+
                    '"codigoOficina": "1",'+
                    '"usuarioRegistro": "hartavia",'+
                    '"administFondosTercero": "N",'+
                    '"estructuraLegal": "2",'+
                    '"profesion": "0",'+
                    '"actividadEconomica": "268",'+
                    '"sectorPublico": "N",'+
                    '"institucionLabora": "0",'+
                    '"cantidadAnosLaborar": "0",'+
                    '"monedaIngresoMensual": "1",'+
                    '"montoIngresoMensual": "1.00",'+
                    '"esEmpleado": "N",'+
                    '"esPep": "N",'+
                    '"tipoPep": "N",'+
                    '"Articulo15": "N",'+
                    '"origenFondos": "18",'+
                    '"inversionInicial": "0",'+
                    '"residente": "S",'+
                    '"fechaCargaCliente": "2022-11-18",'+
                    '"usuario": "1",'+
                    '"fechaValor": "2022-11-17",'+
                    '"fechaRegistro": "2022-11-18",'+
                    '"descripcionObservaciones": "",'+
                    '"esApnfd": "N",'+
                    '"tipoApnfd": "0",'+
                    '"fechaRegistroApnfd": "1900-01-01",'+
                    '"entidadSupervisora": "0",'+
                    '"esCpe": "N",'+
                    '"pagaImpuestos": "N",'+
                    '"clientesNacionalidades": "188",'+
                    '"clientesUbicaciones": "188",'+
                    '"clientesFATCA": "",'+
                    '"clientesIngresos": "",'+
                    '"clientesFondosTerceros": "",'+
                    '"clientesPatrimonio": "",'+
                    '"clientesFuncionesPEP": "",'+
                    '"clientesTransacciones": "",'+
                    '"clientesPolizas": "",'+
                    '"clientesOtrosAtributos": "",'+
                    '"clientesSocios": "",'+
                    '"clientesRelaciones": "",'+
                    '"clientesRepresentantes": ""'+
                '},'+
                '{'+
                    '"tipoIdentificacion": "1",'+
                    '"numeroIdentificacion": "103730248",'+
                    '"nombreCliente": "Gabriela",'+
                    '"segundoNombreCliente": "",'+
                    '"primerApellido": "Cruz",'+
                    '"segundoApellido": "Guevara",'+
                    '"sconocidoComo": "",'+
                    '"razonSocial": "",'+
                    '"nombreComercial": "",'+
                    '"descripcionCuenta": "Gabriela Cruz Guevara",'+
                    '"numeroIdentificacionEntidad": "103730248",'+
                    '"fechaVencimientoIdentificacion": "2020-09-05",'+
                    '"lugarExpedicionIdentificacion": "",'+
                    '"fechaUltimaActualizacion": null,'+
                    '"genero": "F",'+
                    '"fechaNacimiento": null,'+
                    '"estadoCivil": "C",'+
                    '"paisOrigen": "188",'+
                    '"fechaIngreso": "2017-05-02",'+
                    '"fechaSalida": "1900-01-01",'+
                    '"fechaInactividad": "1900-01-01",'+
                    '"fechaVinculacion": "2017-05-02",'+
                    '"estado": "A",'+
                    '"ejecutivo": "ELP",'+
                    '"estadoXML": "G",'+
                    '"tipoCuenta": "0",'+
                    '"codigoOficina": "1",'+
                    '"usuarioRegistro": "hartavia",'+
                    '"administFondosTercero": "N",'+
                    '"estructuraLegal": "2",'+
                    '"profesion": "0",'+
                    '"actividadEconomica": "179",'+
                    '"sectorPublico": "N",'+
                    '"institucionLabora": "0",'+
                    '"cantidadAnosLaborar": "0",'+
                    '"monedaIngresoMensual": "2",'+
                    '"montoIngresoMensual": "2068.97",'+
                    '"esEmpleado": "N",'+
                    '"esPep": "N",'+
                    '"tipoPep": "N",'+
                    '"Articulo15": "N",'+
                    '"origenFondos": "18",'+
                    '"inversionInicial": "0",'+
                    '"residente": "S",'+
                    '"fechaCargaCliente": "2022-11-18",'+
                    '"usuario": "1",'+
                    '"fechaValor": "2022-11-17",'+
                    '"fechaRegistro": "2022-11-18",'+
                    '"descripcionObservaciones": "",'+
                    '"esApnfd": "N",'+
                    '"tipoApnfd": "0",'+
                    '"fechaRegistroApnfd": "1900-01-01",'+
                    '"entidadSupervisora": "0",'+
                    '"esCpe": "N",'+
                    '"pagaImpuestos": "N",'+
                    '"clientesNacionalidades": "188",'+
                    '"clientesUbicaciones": "188",'+
                    '"clientesFATCA": "",'+
                    '"clientesIngresos": "",'+
                    '"clientesFondosTerceros": "",'+
                    '"clientesPatrimonio": "",'+
                    '"clientesFuncionesPEP": "",'+
                    '"clientesTransacciones": "",'+
                    '"clientesPolizas": "",'+
                    '"clientesOtrosAtributos": "",'+
                    '"clientesSocios": "",'+
                    '"clientesRelaciones": "",'+
                    '"clientesRepresentantes": ""'+
                '}'+
            ']'+    
        '}';

        return jsonStr;
    }

}