/**
 * @description       : Representa una opcion valor del picklist
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 06-20-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public class RM_SelectOption_Wrapper {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value; 

    public RM_SelectOption_Wrapper(String label,String value){
        this.label = label;
        this.value = value;
    } 
}