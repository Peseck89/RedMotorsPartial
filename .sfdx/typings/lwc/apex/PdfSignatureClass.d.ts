declare module "@salesforce/apex/PdfSignatureClass.getLastContentDocumentId" {
  export default function getLastContentDocumentId(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/PdfSignatureClass.sendSignedPDFEmail" {
  export default function sendSignedPDFEmail(param: {recordId: any, contentDocumentId: any}): Promise<any>;
}
declare module "@salesforce/apex/PdfSignatureClass.SaveSignature" {
  export default function SaveSignature(param: {nombre: any, recordId: any, visualforce: any, visualforceFirmado: any, fromButton: any, signatureBase64: any}): Promise<any>;
}
declare module "@salesforce/apex/PdfSignatureClass.getContactInfo" {
  export default function getContactInfo(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/PdfSignatureClass.GeneratePDF" {
  export default function GeneratePDF(param: {recordId: any, fromButton: any, visualforceFirmado: any}): Promise<any>;
}
declare module "@salesforce/apex/PdfSignatureClass.getValidacionCase" {
  export default function getValidacionCase(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/PdfSignatureClass.getImageFromAsset" {
  export default function getImageFromAsset(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/PdfSignatureClass.SaveDibujo" {
  export default function SaveDibujo(param: {recordId: any, dibujoBase64: any, tipoVehiculo: any}): Promise<any>;
}
