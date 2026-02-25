declare module "@salesforce/apex/QLIGridController.findTrabajos" {
  export default function findTrabajos(param: {searchKeyTrabajo: any}): Promise<any>;
}
declare module "@salesforce/apex/QLIGridController.searchProducts" {
  export default function searchProducts(param: {productType: any, queryValue: any, quote: any}): Promise<any>;
}
declare module "@salesforce/apex/QLIGridController.getTiposTrabajoPorMO" {
  export default function getTiposTrabajoPorMO(param: {product2Ids: any}): Promise<any>;
}
declare module "@salesforce/apex/QLIGridController.getQlis" {
  export default function getQlis(param: {listTosave: any, quote: any}): Promise<any>;
}
declare module "@salesforce/apex/QLIGridController.saveQlis" {
  export default function saveQlis(param: {jsonString: any, quote: any}): Promise<any>;
}
declare module "@salesforce/apex/QLIGridController.saveQuantities" {
  export default function saveQuantities(param: {jsonString: any, quote: any}): Promise<any>;
}
declare module "@salesforce/apex/QLIGridController.deleteQlis" {
  export default function deleteQlis(param: {quoteIds: any}): Promise<any>;
}
declare module "@salesforce/apex/QLIGridController.setPublicFileWO" {
  export default function setPublicFileWO(param: {contentIds: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QLIGridController.setPublicFile" {
  export default function setPublicFile(param: {contentIds: any, quoteId: any}): Promise<any>;
}
