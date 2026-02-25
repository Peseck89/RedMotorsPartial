public class orderSoftlandWrapper 
{
	public String compania;
    public String observaciones;
    public String comentarioCXC;
    public String total_mercaderia;
    public String monto_descuento1;
    public String monto_descuento2;
    public String porc_descuento1;
    public String porc_descuento2;
    public String total_impuesto1;
    public String total_impuesto2;
    public String total_a_facturar;
    public String moneda;
    public String condicion_pago;
    public String cod_cliente;
    public String subtipo_documento;
    public String actividad_comercial;
    public String tipo_pedido;
    public String orden_trabajo;
    public String marca;
    public String vin;
    public String linea;
    public String modelo;
    public String matricula;
    public String kilometros;
    public String num_Presupuesto;
    public String num_reclamo;
    public String cargo;
    public String recibo;
    public String asesor;
    public List<lineOrder> lineas;
    //Ajustes solicitados
    public String taller;
    public String anio;
   
    public String Descripcion_caso;
    public String Observaciones_workorder;
    public String Descripcion_workorder;
    
    
    //Ajustes cambio de moneda
    //
    public String TipoDeCambio;
    public String Moneda_destino;
    
    // Ajustes solicitados v2
    // Modificacion Diego Portalnet 2-Agosto 2022
    public String contribuyente_cuenta;
    public String tipo_id_contribuyente;
    public String telefono;
    public String movil;
    public String correo;
    public String fecha_compra;
    public String fecha_entrada;
    public String numero_caso;
    
    // Ajustes solicitados v3
    // Modificación Diego Portalnet 20 Octubre 2022***
    public string nombre_cuenta;
    public string telefono_contacto;
    public string correo_contacto;
    public string fecha_agenda_cita;
    public string fecha_cita;
    // Ajustes solicitados v4
    // Modificación MFC Portalnet 25 Enero 2023***
    public string nombres_cuenta;
    public string apellidos_cuenta;
    public string tipo_ot;
    public string u_origen_cita;
    
    public string request_id;
    
    public string realizaEntrevista;
    public string nombre_encargado;
    public string justifica_encuesta;

    public string pagador;
    public string codigo_pagador;
    public string monto_financiamiento;
    public string moneda_financiamiento;
    public string pedido_interno_esPlan;
    
    
 
    public static orderSoftlandWrapper parse(String json) 
    {
		return (orderSoftlandWrapper) System.JSON.deserialize(json, orderSoftlandWrapper.class);
	}
    
    public class lineOrder
    {
        public String cod_articulo;
        public String desc_articulo;
        public String cod_bodega;
        public String comentario;
        public String tipo_trabajo;
        public String precio_unitario;
        public String total_a_facturar;
        public String total_mercaderia;
        public String cantidad;
        public String total_descuento;
        public String monto_descuento;
        public String porc_descuento;
        public String centro_costo;
        public String cuenta_contable;
        public String cod_impuesto;
        public String total_impuesto;
        public List<tipoCargo> tipoCargos;
        //Ajustes solicitados
        public String id_linea;
        public String cod_localizacion;
    }
    
    public class tipoCargo{
        public String tipo_cargo;
       	public String cliente;
        public String porcentage;
        public String total_mercaderia;
        public String total_descuento;
        public String total_impuesto;
        public String total_a_facturar;
        public String centro_costo;
    }
}