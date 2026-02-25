public class RM_Option {
    @AuraEnabled
    public String label;

    @AuraEnabled
    public String value; 

    public RM_Option(String label,String value){
        this.label = label;
        this.value = value;
    }
}