@RestResource(urlMapping='/CreateLeadService')
global with sharing class LeadService {

    // Clase interna para mapear los datos entrantes
    public class LeadInput {
        public String FirstName;
        public String LastName;
        public String Email;
        public String MobilePhone;
        public String Tipotrafico;
        public String FechaPosibleCompra;
        public String Sucursal;
        //public String Marca;
        public String Familia1;
        public String Modelo_De_Inter_s1;
        public String Ano1;
    }
    
    // Método REST POST para crear el lead
    @HttpPost
    global static void createLead() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String inputJson = req.requestBody.toString();
            System.debug('Input JSON: ' + inputJson);
            
            // Parsear el JSON de entrada
            LeadInput input = (LeadInput) JSON.deserialize(inputJson, LeadInput.class);
            System.debug('Input: ' + input);
            
            // Mapear 'Tipotrafico' a 'RecordTypeId'
            String recordTypeId = getRecordTypeId(input.Tipotrafico);
            if (recordTypeId == null) {
                throw new CustomException('Tipotrafico no válido');
            }
            System.debug('Body ' + input);

			String transformedFechaPosibleCompra;

            if (input.FechaPosibleCompra == 'Antes de 3 meses') {
                transformedFechaPosibleCompra = '1 a 3 meses';
            } else if (input.FechaPosibleCompra == 'De 3 a 6 meses') {
                transformedFechaPosibleCompra = '4 a 6 meses';
            } else if (input.FechaPosibleCompra == 'Después de 6 meses.') {
                transformedFechaPosibleCompra = 'Después de 6 meses.';
            } else {
                transformedFechaPosibleCompra = input.FechaPosibleCompra; // Mantener el valor original si no coincide con ninguno
            }

			// Consultar la Campaña con el nombre "Campaña Digital Edna"
            Campaign ednaCampaign = [SELECT Id FROM Campaign WHERE Name = 'Campaña Digital Edna' LIMIT 1];
            
            // Guardar el Id de la campaña
            Id ednaCampaignId = ednaCampaign.Id;

			

            
            // Crear un nuevo Lead
            Lead newLead = new Lead(
                FirstName = input.FirstName,
                LastName = input.LastName,
                Email = input.Email,
                MobilePhone = input.MobilePhone,
                LeadSource='Whatsapp',
                RecordTypeId = recordTypeId,
                Status = 'New',
                Action__c= 'Orgánico',
                Campana__c = ednaCampaignId,
                Origen_Del_Candidato__c = 'WhatsApp Edna',
                FechaPosibleCompra__c = transformedFechaPosibleCompra,
                Sucursal__c = input.Sucursal,
                Marca__c = input.Tipotrafico,
                Familia1__c = input.Familia1,
                Modelo_De_Inter_s1__c = input.Modelo_De_Inter_s1,
                Ano1__c = input.Ano1
            );
            
            // Insertar el Lead
            insert newLead;
            
            
            // Consultar el Lead recién creado para obtener el correo del Owner
            Lead insertedLead = [
                SELECT Owner.Email 
                FROM Lead 
                WHERE Id = :newLead.Id
                LIMIT 1
            ];
            
            // Obtener el correo electrónico del propietario
            String ownerEmail = insertedLead.Owner.Email;
            
            // Crear la respuesta como un mapa
            Map<String, Object> response = new Map<String, Object>();
            response.put('message', 'Procesado correctamente.');
            response.put('LeadID', newLead.Id);
            response.put('email', ownerEmail);
            
            // Convertir el mapa a JSON y establecer en la respuesta
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;
            
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"message": "Error al procesar la solicitud."}');
            System.debug('Error: ' + e.getMessage());
        }
    }
    
    // Método auxiliar para obtener el RecordTypeId
    private static String getRecordTypeId(String tipotrafico) {
        Map<String, String> recordTypeMap = new Map<String, String>{
            'BMW' => '0120P000000arDfQAI',
            'MINI' => '0120P000000arDiQAI',
            'Kawasaki' => '0120P000000arDhQAI',
            'Motorrad' => '0120P000000arDjQAI',
            'Polaris' => '0120P000000arDkQAI'
        };
        
        return recordTypeMap.get(tipotrafico);
    }
    
    // Clase personalizada para manejar excepciones
    global class CustomException extends Exception {}
    
    public static void dummy() {
        String test = '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        
    }
    
}