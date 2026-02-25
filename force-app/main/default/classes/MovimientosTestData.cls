/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 02-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class MovimientosTestData {
    public MovimientosTestData(){}
    
    public Movimiento__c generateMovimiento(Boolean isInsert)
    {
        Movimiento__c actualMovimiento = new Movimiento__c();
        actualMovimiento.tipoIdentificacion__c = 1;
        actualMovimiento.numeroIdentificacion__c = '702100613';
        actualMovimiento.nombreCompleto__c = 'Esteban Segura Benavides';
        actualMovimiento.tipoProducto__c = 1;
        actualMovimiento.subProducto__c = 1;
        actualMovimiento.numeroReferencia__c = 'Referencia';
        actualMovimiento.tipoMovimiento__c = 'Contado';
        actualMovimiento.oficina__c = 1;
        actualMovimiento.canal__c = 1;
        actualMovimiento.descripcionCanal__c = 'Descripcion';
        actualMovimiento.moneda__c = '1';
        actualMovimiento.monedaProducto__c = 1;
        actualMovimiento.naturalezaTransaccion__c = 'L';
        actualMovimiento.origenTransaccion__c = 'E';
        actualMovimiento.tipoCambio__c = 3242;
        actualMovimiento.montoDebitos__c = 3242;
        actualMovimiento.montoCreditos__c = 3242;
        actualMovimiento.usuarioRegistro__c = 2342;
        actualMovimiento.idOriginario__c = '702100613';
        actualMovimiento.nombreOriginario__c = 'Esteban Segura Benavides';
        actualMovimiento.idBeneficiario__c ='324234324';
        actualMovimiento.nombreBeneficiario__c = 'Esteban Segura Benavides';
        actualMovimiento.numeroCuentaOrigen__c = '21313';
        actualMovimiento.numeroCuentaDestino__c = '213213';
        actualMovimiento.paisOrigen__c = '188';
        actualMovimiento.paisDestino__c = '188';
        actualMovimiento.bancoOrigen__c = '1';
        actualMovimiento.bancoDestino__c = '1';
        actualMovimiento.fechaRegistro__c = Date.today();
        if(isInsert)
        {
            insert actualMovimiento;
        }
        return actualMovimiento;
    }

    public static String getMovimientosJSON()
    {
        String jsonStr = 
        '{'+
            '"movimientos": ['+
                '{'+
                    '"cod_tipo_identificacion": "1",'+
                    '"num_identificacion": "114360451",'+
                    '"nom_completo": null,'+
                    '"cod_tipo_producto": "11",'+
                    '"cod_subproducto": "11",'+
                    '"num_referencia": "AF-20170904-279",'+
                    '"fec_movimiento": "2022-10-28 00:00:00",'+
                    '"cod_tipo_movimiento": "38",'+
                    '"cod_oficina": "1",'+
                    '"cod_canal": "2",'+
                    '"des_canal": "Transferencia manual",'+
                    '"cod_moneda": "2",'+
                    '"cod_moneda_producto": null,'+
                    '"ind_naturaleza_transaccion": "L",'+
                    '"ind_origen_transaccion": "T",'+
                    '"mon_tipo_cambio": "625.03000000",'+
                    '"mon_debitos": "333.0200",'+
                    '"mon_creditos": "0.00",'+
                    '"cod_usuario_registo": "1",'+
                    '"num_identificacion_originario": "",'+
                    '"des_nombre_originario": "",'+
                    '"num_identificacion_beneficiario": "114360451",'+
                    '"des_nombre_beneficiario": "Esteban Alberto Herrera Alvarez",'+
                    '"num_cuenta_origen": "0",'+
                    '"num_cuenta_destino": "0",'+
                    '"cod_pais_origen": "0",'+
                    '"cod_pais_destino": "0",'+
                    '"cod_banco_origen": "0",'+
                    '"cod_banco_destino": "0",'+
                    '"fec_registro": "2022-11-02 00:00:00"'+
                '},'+
                '{'+
                    '"cod_tipo_identificacion": "1",'+
                    '"num_identificacion": "111350897",'+
                    '"nom_completo": null,'+
                    '"cod_tipo_producto": "73",'+
                    '"cod_subproducto": "73",'+
                    '"num_referencia": "AF-20171103-361",'+
                    '"fec_movimiento": "2022-10-28 00:00:00",'+
                    '"cod_tipo_movimiento": "38",'+
                    '"cod_oficina": "1",'+
                    '"cod_canal": "2",'+
                    '"des_canal": "Transferencia manual",'+
                    '"cod_moneda": "2",'+
                    '"cod_moneda_producto": null,'+
                    '"ind_naturaleza_transaccion": "L",'+
                    '"ind_origen_transaccion": "T",'+
                    '"mon_tipo_cambio": "625.03000000",'+
                    '"mon_debitos": "186.0000",'+
                    '"mon_creditos": "0.00",'+
                    '"cod_usuario_registo": "1",'+
                    '"num_identificacion_originario": "",'+
                    '"des_nombre_originario": "",'+
                    '"num_identificacion_beneficiario": "111350897",'+
                    '"des_nombre_beneficiario": "Laura Priscilla Contreras Ortega",'+
                    '"num_cuenta_origen": "0",'+
                    '"num_cuenta_destino": "CR53010200009301417838",'+
                    '"cod_pais_origen": "0",'+
                    '"cod_pais_destino": "188",'+
                    '"cod_banco_origen": "0",'+
                    '"cod_banco_destino": "4",'+
                    '"fec_registro": "2022-11-02 00:00:00"'+
                '}'+
            ']'+    
        '}';

        return jsonStr;
    }
}