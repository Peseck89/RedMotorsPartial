public class ProveedorJSON {
public static String createProveedor(String jsonStr) 
    {
        JSONGenerator gen = JSON.createGenerator(False);

        proveedorRequestJSON wrapProductJSON = proveedorRequestJSON.parsePropuesta(jsonStr);
        String Name = wrapProductJSON.Name;
        String SoftlandCode = wrapProductJSON.SoftlandCode;
        Boolean activo = false;
        
        if(wrapProductJSON.activo=='true')
            {
                activo=true;
            }
        
        
        try
        {  
            List<Proveedor__c> prov;
            prov =      	[
                                SELECT Id
                                FROM Proveedor__c
                                WHERE SoftlandCode__c = :SoftlandCode
                            ];
            if(prov.size()==0)
            {
                Proveedor__c newProveedor = new Proveedor__c();
                newProveedor.Name = Name;
                newProveedor.SoftlandCode__c = SoftlandCode;
                newProveedor.activo__c = activo;
                
                insert newProveedor;
                
                String withErrors = 'false';
                String descripcionError = '';

                gen.writeStartObject();
                gen.writeFieldName('Solicitud');
                gen.writeStartObject();
                gen.writeStringField('CODIGO', '800');
               
                
                if(withErrors=='false')
                {
                    gen.writeStringField('RESULT', 'La solicitud fue procesada exitosamente');
                    
                } /*else {
                    gen.writeStringField('RESULT', 'Ocurrio un error');
                    gen.writeStringField('ERROR', descripcionError);
                }*/
                gen.writeEndObject();
                gen.writeEndObject();
            } else {
                Proveedor__c actualProveedor = prov[0];
                actualProveedor.Name = Name;
                actualProveedor.SoftlandCode__c = SoftlandCode;
                actualProveedor.activo__c = activo;           
                update actualProveedor;

                String withErrors = 'false';
                String descripcionError = '';

                gen.writeStartObject();
                gen.writeFieldName('Solicitud');
                gen.writeStartObject();
                gen.writeStringField('CODIGO', '801');
                if(withErrors=='false')
                {
                    gen.writeStringField('RESULT', 'La solicitud fue procesada exitosamente');
                    
                } else {
                    gen.writeStringField('RESULT', 'Ocurrio un error');
                    gen.writeStringField('ERROR', descripcionError);
                }
                gen.writeEndObject();
                gen.writeEndObject();
            }
        } catch(Exception ex)
        {
            gen = JSON.createGenerator(False);
            gen.writeStartObject();
            gen.writeFieldName('Solicitud');
            gen.writeStartObject();
            gen.writeStringField('CODIGO', '800');
            gen.writeStringField('RESULT', ex.getMessage()+' - '+ex.getLineNumber());
            gen.writeEndObject();
            gen.writeEndObject();
        }

        return gen.getAsString();
    }

    //Deserializador para las nuevas solicitudes
    public class proveedorRequestJSON {
        //Identificador del formulario
        public String Name;
        public String SoftlandCode;
        public String activo;
    }

    public static proveedorRequestJSON parsePropuesta(String json) {
        return(proveedorRequestJSON) System.JSON.deserialize(json, proveedorRequestJSON.class);
    }
}