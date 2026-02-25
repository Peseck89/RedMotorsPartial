public with sharing class cT_AssetTrigger_handler {

    public static  void handleTrigger(List<Asset> TriggerNew,System.TriggerOperation triggerEvent){

        List<Asset> coches = new List<Asset>();
        Integer actualiza = 0;
        for(Asset coche : TriggerNew){
            Asset cochenvo = new Asset(Id = coche.Id);
            if(coche.Marca_Nvo__c != '' && coche.Marca_Nvo__c != null ){
                if (coche.Marca_Nvo__c == 'BMW Motos' ) {
                    coche.marca__c = 'Moto BMW';  
                    actualiza = 1;  
                }else if(coche.Marca_Nvo__c == 'Kawasaki Motos' || coche.Marca_Nvo__c == 'Kawasaki Mula' || coche.Marca_Nvo__c == 'Kawasaki Cuadraciclo' ){
                    coche.marca__c = 'Moto Kawa';  
                    actualiza = 1;
                }else if(coche.Marca_Nvo__c == 'Polaris Moto' || coche.Marca_Nvo__c == 'Polaris Mula' ){
                    coche.marca__c = 'Vehículo Polaris';  
                    actualiza = 1;
                }else {
                    if (coche.Marca_Nvo__c == 'BMW Automovil' ) {
                        coche.marca__c = 'BMW'; 
                    }else if(coche.Marca_Nvo__c == 'MINI') {
                        coche.marca__c = 'MINI'; 
                    }
                }
                if(coche.Modelo_Nvo2__c != '' && coche.Modelo_Nvo2__c != null && coche.Modelo_Nvo2__c != 'Otro'  ){
                    coche.modelo__c = coche.Modelo_Nvo2__c; 
                }else {
                    
                }

            }
                    
        }

        //Revisa si existe un Asset con el mismo codigo Vin y evita su creacion en caso de existir
        if(triggerEvent != System.TriggerOperation.BEFORE_UPDATE){
            System.debug('=======================triggerEvent=====================');
        System.debug(triggerEvent);
           //Revisa si existe un Asset con el mismo codigo Vin y evita su creacion en caso de existir
            try {
                List<String> newVins = new List<String>();
                List<Id> listIds = new List<Id>();

                for (Asset currentAsset : TriggerNew) {
                    newVins.add(currentAsset.NumeroDeChasis__c);
                    listIds.add(currentAsset.Id);
                }
                system.debug('newVins: ' + newVins);
                
                List<Asset> assetsAlreadyUseVin = [SELECT Id, NumeroDeChasis__c FROM Asset WHERE NumeroDeChasis__c =: newVins AND Id NOT IN: listIds LIMIT 2000];

                if (assetsAlreadyUseVin.size() > 0 ) TriggerNew[0].addError('Error: El numero vin ya esta relacionado a otro vehiculo.');
                
            }catch(Exception e){
                System.debug('Error: El numero vin ya esta relacionado a otro vehiculo.');

            }
 
        }


        
    }
}