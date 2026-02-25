/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 19-10-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class MovimientosRequest {
    Integer tipoIdentificacion;
    String numeroIdentificacion;
    String nombreCompleto;
    Integer tipoProducto;
    Integer subProducto;
    String numeroReferencia;
    String tipoMovimiento;
    Integer oficina;
    Integer canal;
    String descripcionCanal;
    Integer moneda;
    Integer monedaProducto;
    String naturalezaTransaccion;
    String origenTransaccion;
    Decimal tipoCambio;
    Decimal montoDebitos;
    Decimal montoCreditos;
    Integer usuarioRegistro;
    String idOriginario;
    String nombreOriginario;
    String idBeneficiario;
    String nombreBeneficiario;
    String numeroCuentaOrigen;
    String numeroCuentaDestino;
    Integer paisOrigen;
    Integer paisDestino;
    Integer bancoOrigen;
    Integer bancoDestino;
    DateTime fechaRegistro;
    DateTime fechaMovimiento;

    public MovimientosRequest(Movimiento__c actualMovimiento) 
    {
        this.tipoIdentificacion = Integer.valueOf(actualMovimiento.tipoIdentificacion__c);
        this.numeroIdentificacion = actualMovimiento.numeroIdentificacion__c;
        this.nombreCompleto = actualMovimiento.nombreCompleto__c;
        this.tipoProducto = Integer.valueOf(actualMovimiento.tipoProducto__c);
        this.subProducto = Integer.valueOf(actualMovimiento.subProducto__c);
        this.numeroReferencia = actualMovimiento.numeroReferencia__c;
        this.tipoMovimiento = actualMovimiento.tipoMovimiento__c;
        this.oficina = Integer.valueOf(actualMovimiento.oficina__c);
        this.canal = Integer.valueOf(actualMovimiento.canal__c);
        //this.descripcionCanal = actualMovimiento.descripcionCanal__c;
        this.moneda = Integer.valueOf(actualMovimiento.moneda__c);
        this.monedaProducto = Integer.valueOf(actualMovimiento.monedaProducto__c);
        this.naturalezaTransaccion = actualMovimiento.naturalezaTransaccion__c;
        this.origenTransaccion = actualMovimiento.origenTransaccion__c;
        this.tipoCambio = actualMovimiento.tipoCambio__c;
        this.montoDebitos = actualMovimiento.montoDebitos__c;
        this.montoCreditos = actualMovimiento.montoCreditos__c;
        this.usuarioRegistro = Integer.valueOf(actualMovimiento.usuarioRegistro__c);
        this.idOriginario = actualMovimiento.idOriginario__c;
        this.nombreOriginario = actualMovimiento.nombreOriginario__c;
        this.idBeneficiario = actualMovimiento.idBeneficiario__c;
        this.nombreBeneficiario = actualMovimiento.nombreBeneficiario__c;
        this.numeroCuentaOrigen = actualMovimiento.numeroCuentaOrigen__c;
        this.numeroCuentaDestino = actualMovimiento.numeroCuentaDestino__c;
        this.paisOrigen = Integer.valueOf(actualMovimiento.paisOrigen__c);
        this.paisDestino = Integer.valueOf(actualMovimiento.paisDestino__c);
        this.bancoOrigen = Integer.valueOf(actualMovimiento.bancoOrigen__c);
        this.bancoDestino = Integer.valueOf(actualMovimiento.bancoDestino__c);
        this.fechaRegistro = actualMovimiento.fechaRegistro__c;
        this.fechaMovimiento = actualMovimiento.LastModifiedDate;
    }

    public String getJSONResponseMovimiento()
    {
        String payload = JSON.serialize(this);
        return payload;
    }
}