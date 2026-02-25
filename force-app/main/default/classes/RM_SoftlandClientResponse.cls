/** 
 * @className RM_SoftlandClientResponse
 * @description Clase que representa la respuesta de un cliente de Softland
 * {"operationResult":{"code":"02","description":"El codigo del articulo no es valido."}}
 */
public class RM_SoftlandClientResponse {
    public RM_SoftlandClientOperationResult operationResult;
    public RM_SoftlandClientResponse(){
        this.operationResult = new RM_SoftlandClientOperationResult();
    }
}