/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 13-10-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class MovimientoParser {
    public List<Movimiento> movimientos;
    public class Movimiento
    {
        public String cod_tipo_identificacion;
        public String num_identificacion;
        public String nom_completo;
        public String cod_tipo_producto;
        public String cod_subproducto;
        public String num_referencia;
        public String fec_movimiento;
        public String cod_tipo_movimiento;
        public String cod_oficina;
        public String cod_canal;
        public String des_canal;
        public String cod_moneda;
        public String cod_moneda_producto;
        public String ind_naturaleza_transaccion;
        public String ind_origen_transaccion;
        public String mon_tipo_cambio;
        public String mon_debitos;
        public String mon_creditos;
        public String cod_usuario_registo;
        public String num_identificacion_originario;
        public String des_nombre_originario;
        public String num_identificacion_beneficiario;
        public String des_nombre_beneficiario;
        public String num_cuenta_origen;
        public String num_cuenta_destino;
        public String cod_pais_origen;
        public String cod_pais_destino;
        public String cod_banco_origen;
        public String cod_banco_destino;
        public String fec_registro;
    }
    
    public static MovimientoParser parse(String json) {
        return(MovimientoParser) System.JSON.deserialize(json, MovimientoParser.class);
    }
}