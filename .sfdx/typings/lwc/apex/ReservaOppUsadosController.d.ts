declare module "@salesforce/apex/ReservaOppUsadosController.getCurrentOpp" {
  export default function getCurrentOpp(param: {OppId: any}): Promise<any>;
}
declare module "@salesforce/apex/ReservaOppUsadosController.getModelosUsados" {
  export default function getModelosUsados(param: {OppId: any}): Promise<any>;
}
declare module "@salesforce/apex/ReservaOppUsadosController.getProduct" {
  export default function getProduct(param: {ProdId: any}): Promise<any>;
}
declare module "@salesforce/apex/ReservaOppUsadosController.getAnticipo" {
  export default function getAnticipo(param: {OppId: any, ProdId: any}): Promise<any>;
}
declare module "@salesforce/apex/ReservaOppUsadosController.makeReserva" {
  export default function makeReserva(param: {OppId: any, ProdId: any}): Promise<any>;
}
