declare module "@salesforce/apex/AccountValidationController.actualizaCaso" {
  export default function actualizaCaso(param: {caseId: any, contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountValidationController.actualizaAsset" {
  export default function actualizaAsset(param: {assetId: any, modelo: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountValidationController.updateOnlyId" {
  export default function updateOnlyId(param: {cedula: any, tipoDocumento: any, cuenta: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountValidationController.getContact" {
  export default function getContact(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountValidationController.accountValidation" {
  export default function accountValidation(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountValidationController.accountValidationByOpportunity" {
  export default function accountValidationByOpportunity(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountValidationController.getSoftlandAccount" {
  export default function getSoftlandAccount(param: {AcountId: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountValidationController.updateSoftlandAccount" {
  export default function updateSoftlandAccount(param: {accountWrapper: any}): Promise<any>;
}
