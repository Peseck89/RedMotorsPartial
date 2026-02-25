declare module "@salesforce/apex/savePDFfile.getRelatedFile" {
  export default function getRelatedFile(param: {recordId: any, fromButton: any}): Promise<any>;
}
declare module "@salesforce/apex/savePDFfile.attachPDFinCase" {
  export default function attachPDFinCase(param: {caseId: any, fromButton: any, vfNamePage: any}): Promise<any>;
}
declare module "@salesforce/apex/savePDFfile.attachPDFinWO" {
  export default function attachPDFinWO(param: {woId: any, fromButton: any, vfNamePage: any, save: any, enviarEmail: any, recipientEmail: any}): Promise<any>;
}
declare module "@salesforce/apex/savePDFfile.attachPDFinQuote" {
  export default function attachPDFinQuote(param: {quoteId: any, fromButton: any, vfNamePage: any, save: any, enviarEmail: any, recipientEmail: any}): Promise<any>;
}
declare module "@salesforce/apex/savePDFfile.attachPDFinOpportunity" {
  export default function attachPDFinOpportunity(param: {oppId: any, fromButton: any, vfNamePage: any, save: any, enviarEmail: any, recipientEmail: any}): Promise<any>;
}
declare module "@salesforce/apex/savePDFfile.getURL" {
  export default function getURL(): Promise<any>;
}
declare module "@salesforce/apex/savePDFfile.getEnvioFormalizacion" {
  export default function getEnvioFormalizacion(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/savePDFfile.getVehiculoReservado" {
  export default function getVehiculoReservado(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/savePDFfile.getHasContact" {
  export default function getHasContact(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/savePDFfile.getDescuentoAprobado" {
  export default function getDescuentoAprobado(param: {oppId: any}): Promise<any>;
}
