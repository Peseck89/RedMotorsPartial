declare module "@salesforce/apex/Registrar_Anticipo_Controller.findAnticipos" {
  export default function findAnticipos(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/Registrar_Anticipo_Controller.findQuote" {
  export default function findQuote(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/Registrar_Anticipo_Controller.findPayment" {
  export default function findPayment(param: {identifier: any, oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/Registrar_Anticipo_Controller.addReceiptOportunity" {
  export default function addReceiptOportunity(param: {oppId: any, productId: any, identifier: any, monto: any}): Promise<any>;
}
declare module "@salesforce/apex/Registrar_Anticipo_Controller.getOpportunityRelatedProductsUsados" {
  export default function getOpportunityRelatedProductsUsados(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/Registrar_Anticipo_Controller.getOpportunityRelatedProducts" {
  export default function getOpportunityRelatedProducts(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/Registrar_Anticipo_Controller.getAnticipos" {
  export default function getAnticipos(param: {oppId: any}): Promise<any>;
}
