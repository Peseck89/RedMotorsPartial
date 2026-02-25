/**
 * @description       : 
 * @author            : David Evangelista david@incompany.cr
 * @group             : 
 * @last modified on  : 06-22-2022
 * @last modified by  : David Evangelista david@incompany.cr
**/
public with sharing class SaldosRequest {
    Integer tipoIdentificacion; 
    String numeroIdentificacion; 
    String nombreCompleto; 
    Integer tipoProducto; 
    Integer subProducto; 
    datetime fechaCorteSaldo; 
    Integer moneda; 
    Integer monedaProducto; 
    Integer montoSaldo; 
    Integer limiteAprobado; 
    datetime fechaApertura; 
    Integer montoApertura; 
    Integer coutaAprobada; 
    datetime fechaCancelacion; 
    Integer sucursalCompra; 
    Integer sucursalApertura; 
    Integer sucursalCancelacion; 
    datetime fechaRegistro; 
    public SaldosRequest(enviodeSaldos__c saldo) {
        this.tipoIdentificacion = Integer.valueOf(saldo.tipoIdentificacion__c);
        this.numeroIdentificacion = saldo.numeroIdentificacion__c;
        this.nombreCompleto = saldo.nombreCompleto__c;
        this.tipoProducto = Integer.valueOf(saldo.tipoProducto__c);
        this.fechaCorteSaldo = saldo.fechaCorteSaldo__c;
        this.subProducto = Integer.valueOf(saldo.subProducto__c);
        this.moneda = Integer.valueOf(saldo.moneda__c);
        this.monedaProducto = Integer.valueOf(saldo.monedaProducto__c);
        this.montoSaldo = Integer.valueOf(saldo.montoSaldo__c);
        this.limiteAprobado = Integer.valueOf(saldo.limiteAprobado__c);
        this.fechaApertura = saldo.fechaApertura__c;
        this.montoApertura = Integer.valueOf(saldo.montoApertura__c);
        this.coutaAprobada = Integer.valueOf(saldo.cuotaAprobada__c);	
        this.fechaCancelacion = saldo.fechaCancelacion__c;
        this.sucursalCompra = Integer.valueOf(saldo.sucursalCompra__c);
        this.sucursalApertura = Integer.valueOf(saldo.sucursalApertura__c);
        this.sucursalCancelacion = Integer.valueOf(saldo.sucursalCancelacion__c);
        this.fechaRegistro = saldo.fechaRegistro__c;
    }
    public String getJSONResponseSaldo()
    {
        String payload = JSON.serialize(this);
        return payload;
    }
}