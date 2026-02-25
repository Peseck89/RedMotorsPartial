/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 02-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public with sharing class SaldosTestData {
    public SaldosTestData() {}

    public enviodeSaldos__c generateSaldo(Boolean isInsert)
    {
        Account acc = new Account();
        acc.Name = 'Esteban Segura Benavides';

        enviodeSaldos__c actualSaldo = new enviodeSaldos__c();
        actualSaldo.tipoIdentificacion__c = '1';
        actualSaldo.nombreCompleto__c = 'Esteban Segura Benavides';
        actualSaldo.tipoProducto__c = 1;
        actualSaldo.fechaCorteSaldo__c = System.today();
        actualSaldo.subProducto__c = 1;
        actualSaldo.moneda__c = '1';
        actualSaldo.monedaProducto__c = '1';
        actualSaldo.montoSaldo__c = 1;
        actualSaldo.fechaApertura__c = System.today();
        actualSaldo.montoApertura__c = 1;
        actualSaldo.cuotaAprobada__c = 1;	
        actualSaldo.fechaCancelacion__c = System.today();
        actualSaldo.sucursalCompra__c = 1;
        actualSaldo.sucursalCancelacion__c = 1;
        actualSaldo.fechaRegistro__c = System.today();
        
        if(isInsert)
        {
            insert acc;
            actualSaldo.Cuenta__c = acc.Id;
            insert actualSaldo;
        }
        return actualSaldo;
    }

    public static String getSaldosJSON()
    {
        String jsonStr = 
        '{'+
            '"saldos": ['+
                '{'+
                    '"NumeroOperacion": "AF-20170502-98",'+
                    '"tipoIdentificacion": "1",'+
                    '"numeroIdentificacion": "103730248",'+
                    '"nombreCompleto": "Gabriela Cruz Guevara",'+
                    '"fechaCorteSaldo": "2022-11-01 05:00:43",'+
                    '"tipoProducto": "2",'+
                    '"subProducto": "132",'+
                    '"moneda": "2",'+
                    '"monedaProducto": "2",'+
                    '"montoSaldo": "15697.25",'+
                    '"limiteAprobado": "27805.80",'+
                    '"fechaApertura": "2020-09-05 00:00:00",'+
                    '"montoApertura": "27805.80",'+
                    '"cuotaAprobada": "282.46",'+
                    '"fechaCancelacion": "1900-01-01 00:00:00",'+
                    '"sucursalCompra": "1",'+
                    '"sucursalApertura": "1",'+
                    '"sucursalCancelacion": null,'+
                    '"fechaRegistro": "2022-11-02 05:00:43"'+
                '},'+
                '{'+
                    '"NumeroOperacion": "AF-20201127-1452",'+
                    '"tipoIdentificacion": "1",'+
                    '"numeroIdentificacion": "104120879",'+
                    '"nombreCompleto": "Virginia Ines Gutierrez Moya",'+
                    '"fechaCorteSaldo": "2022-11-01 05:00:43",'+
                    '"tipoProducto": "2",'+
                    '"subProducto": "132",'+
                    '"moneda": "2",'+
                    '"monedaProducto": "2",'+
                    '"montoSaldo": "19104.71",'+
                    '"limiteAprobado": "23027.00",'+
                    '"fechaApertura": "2020-12-02 00:00:00",'+
                    '"montoApertura": "23027.00",'+
                    '"cuotaAprobada": "379.48",'+
                    '"fechaCancelacion": "1900-01-01 00:00:00",'+
                    '"sucursalCompra": "1",'+
                    '"sucursalApertura": "1",'+
                    '"sucursalCancelacion": null,'+
                    '"fechaRegistro": "2022-11-02 05:00:43"'+
                '}'+
            ']'+
        '}';

        return jsonStr;
    }
}