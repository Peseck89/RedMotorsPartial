declare module "@salesforce/apex/ShowWorkStepController.getAllTerritoy" {
  export default function getAllTerritoy(): Promise<any>;
}
declare module "@salesforce/apex/ShowWorkStepController.getTipoDeServicio" {
  export default function getTipoDeServicio(): Promise<any>;
}
declare module "@salesforce/apex/ShowWorkStepController.getuserList" {
  export default function getuserList(): Promise<any>;
}
declare module "@salesforce/apex/ShowWorkStepController.getStatus" {
  export default function getStatus(): Promise<any>;
}
declare module "@salesforce/apex/ShowWorkStepController.getFilteredDate" {
  export default function getFilteredDate(param: {filter1: any, filter2: any, filter3: any, filter4fromDate: any, filter5ToDate: any, filter6status: any, pageSize: any, pageNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/ShowWorkStepController.updateNewStatus" {
  export default function updateNewStatus(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/ShowWorkStepController.updatePauseStatus" {
  export default function updatePauseStatus(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/ShowWorkStepController.updateUnPauseStatus" {
  export default function updateUnPauseStatus(param: {recId: any, dateHoraDe: any}): Promise<any>;
}
declare module "@salesforce/apex/ShowWorkStepController.updateCompleteStatus" {
  export default function updateCompleteStatus(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/ShowWorkStepController.associateCreatedContactWithWorkStep" {
  export default function associateCreatedContactWithWorkStep(param: {workStepRecordId: any, createdContactRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ShowWorkStepController.updateWorkStepOnComplete" {
  export default function updateWorkStepOnComplete(param: {recId: any, Status: any, startDate: any, endDate: any}): Promise<any>;
}
declare module "@salesforce/apex/ShowWorkStepController.updateWorkStepOnStart" {
  export default function updateWorkStepOnStart(param: {recId: any, description: any, Status: any, contactId: any, startDate: any}): Promise<any>;
}
