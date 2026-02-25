declare module "@salesforce/apex/popUpBloqueClass.isCurrentUserOwnerOf" {
  export default function isCurrentUserOwnerOf(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/popUpBloqueClass.getPendingCasesForCurrentOwner" {
  export default function getPendingCasesForCurrentOwner(): Promise<any>;
}
declare module "@salesforce/apex/popUpBloqueClass.getPendingTasksForCurrentOwner" {
  export default function getPendingTasksForCurrentOwner(): Promise<any>;
}
declare module "@salesforce/apex/popUpBloqueClass.markTasksAsRead" {
  export default function markTasksAsRead(param: {taskIds: any}): Promise<any>;
}
