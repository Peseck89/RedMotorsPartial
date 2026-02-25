declare module "@salesforce/apex/WorkStepController.getWorkSteps" {
  export default function getWorkSteps(param: {territoryId: any, serviceTypeId: any, status: any, caseNumber: any, workOrderNumber: any, plate: any, vin: any, startDate: any, endDate: any, nested: any}): Promise<any>;
}
declare module "@salesforce/apex/WorkStepController.getTasksGroupedByCase" {
  export default function getTasksGroupedByCase(param: {territoryIds: any, mechanicId: any, statuses: any, caseNumber: any, orderNumber: any, plate: any, vin: any, creationDateFrom: any, creationDateTo: any, pageNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/WorkStepController.getWorkStepsForReports" {
  export default function getWorkStepsForReports(param: {territories: any, mechanicId: any, caseNumber: any, startDate: any, endDate: any, showParentTasks: any}): Promise<any>;
}
declare module "@salesforce/apex/WorkStepController.getTerritories" {
  export default function getTerritories(): Promise<any>;
}
