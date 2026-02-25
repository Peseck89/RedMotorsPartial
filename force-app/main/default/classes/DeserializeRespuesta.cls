/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 03-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class DeserializeRespuesta {
    public String Identificacion;
    public String Comportamiento;
    public String Tipo_Producto;
    public String Tipo_Monto;
    public String Tipo_Cliente;
    public String errorMessage;

    public static DeserializeRespuesta parse(String json) {
        System.debug('JSON Recibido: '+json);
        return(DeserializeRespuesta) System.JSON.deserialize(json, DeserializeRespuesta.class);
    }
}