declare module "@salesforce/apex/ProductSearcherController.getProducts" {
  export default function getProducts(param: {productType: any, productName: any, productCode: any, bodegaId: any, year: any, vin: any, brand: any, family: any, intColor: any, extColor: any, model: any, recordId: any, vehiculoTransito: any, pageNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductSearcherController.getProductDataFromOLI" {
  export default function getProductDataFromOLI(param: {oppProdInteresId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductSearcherController.getProductByQuoteId" {
  export default function getProductByQuoteId(param: {quoteId: any}): Promise<any>;
}
