public with sharing class obtenerClienteJSON {
    public static DeserializeRespuesta resultresult { get; set; }

    public static string obtenerCliente(String identificacion)
    {
        JSONGenerator gen = JSON.createGenerator(false);
    
        gen.writeStartObject();
        gen.writeStringField('identificacion', identificacion);
        
        String body = gen.getAsString();
        System.Debug(JSON.serializePretty(body));
		return body;
    }

    public static string updateCliente(String jsonRes, Oportunidad_de_Financiamiento__c oportunidadFinanciamiento) {
		string respuesta = '';
		Try {
			System.Debug(jsonRes);
			resultresult = DeserializeRespuesta.parse(jsonRes);
			if (resultresult.errorMessage == null) {
				oportunidadFinanciamiento.comportamiento__c = Decimal.valueOf(resultresult.Comportamiento);
				oportunidadFinanciamiento.tipoDeProducto__c = Decimal.valueOf(resultresult.Tipo_Producto);
				oportunidadFinanciamiento.tipoMontoFrecuenciaTransacciones__c = Decimal.valueOf(resultresult.Tipo_Monto);
				if(resultresult.Tipo_Cliente=='0')
				{
					oportunidadFinanciamiento.tipoCliente__c = 'Ocasional';
				} else if(resultresult.Tipo_Cliente=='1')
				{
					oportunidadFinanciamiento.tipoCliente__c = 'Habitual';
				}
                update oportunidadFinanciamiento;
                
                respuesta = 'Actualización completa';
			} else {
				respuesta = resultresult.errorMessage;
			}
		} Catch(Exception e) {
			System.Debug(e);
        }
        
		return respuesta;
	}
}