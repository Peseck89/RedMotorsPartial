declare module "@salesforce/apex/QuoteServiceController.getTareasAgrupadas" {
  export default function getTareasAgrupadas(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteServiceController.getItemsPorTarea" {
  export default function getItemsPorTarea(param: {quoteId: any, trabajoARealizarId: any, tareaId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteServiceController.updateItemsPorTarea" {
  export default function updateItemsPorTarea(param: {quoteId: any, tareaIds: any, sendToService: any}): Promise<any>;
}
