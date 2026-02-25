/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 23-10-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class SaldosParser {
    public List<Saldo> saldos;

    public class Saldo
    {
        public String NumeroOperacion;
        public String tipoIdentificacion;
        public String numeroIdentificacion;
        public String nombreCompleto;
        public String fechaCorteSaldo;
        public String tipoProducto;
        public String subProducto;
        public String moneda;
        public String monedaProducto;
        public String montoSaldo;
        public String limiteAprobado;
        public String fechaApertura;
        public String montoApertura;
        public String cuotaAprobada;
        public String fechaCancelacion;
        public String sucursalCompra;
        public String sucursalApertura;
        public String sucursalCancelacion;
        public String fechaRegistro;
    }

    public static SaldosParser parse(String json) {
        return(SaldosParser) System.JSON.deserialize(json, SaldosParser.class);
    }
}