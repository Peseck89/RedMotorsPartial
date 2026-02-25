/** 
 * @className RM_SoftlandClientOperationResult
 * @description Clase que representa la respuesta de un cliente de Softland en este caso el resultado de la operacion operationResult
 * {"operationResult":{"code":"02","description":"El codigo del articulo no es valido."}}
 */
public with sharing class RM_SoftlandClientOperationResult {
    public String code;
    public String description;
    public RM_SoftlandClientOperationResult(){
        this.code = '';
        this.description = '';
    }
}