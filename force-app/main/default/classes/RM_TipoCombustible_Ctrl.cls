/**
 * Consulta el tipo de combustible de los vehiculos para ser mostrados en el lwc rm_vn_tipocombustibe_combobox
 * Componente usado en las pantallas para filtros
 * @author Marco Hernandez
 * @since 2024-03-01
 */
public with sharing class RM_TipoCombustible_Ctrl {
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getData()
    {
        List<Map<String,String>> response = new List<Map<String,String>>();

        //set default value
        response.add(new Map<String,String>{'label'=>'Todos', 'value'=>''});
        Schema.DescribeFieldResult fieldResult = Product2.combustible__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            if (f.isActive()) {
                response.add(new Map<String,String>{'label'=>f.getLabel(), 'value'=>f.getValue()});
            }
        }     
       return response;
    }

}