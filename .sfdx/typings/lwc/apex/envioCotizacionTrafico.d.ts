declare module "@salesforce/apex/envioCotizacionTrafico.envioCotizacion" {
  export default function envioCotizacion(param: {idTrafico: any, idPropietario: any}): Promise<any>;
}
declare module "@salesforce/apex/envioCotizacionTrafico.envioCotizacionMultimarca" {
  export default function envioCotizacionMultimarca(param: {idTrafico: any, idPropietario: any}): Promise<any>;
}
declare module "@salesforce/apex/envioCotizacionTrafico.getLead" {
  export default function getLead(param: {leadId: any}): Promise<any>;
}
