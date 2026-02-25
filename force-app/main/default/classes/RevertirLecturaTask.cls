global class RevertirLecturaTask implements Schedulable {
    Set<Id> taskIds;

    public RevertirLecturaTask(Set<Id> ids){
        this.taskIds = ids;
    }

    global void execute(SchedulableContext sc){
        List<Task> tasks = [
            SELECT Id, Confirmacion_de_lectura__c
            FROM Task
            WHERE Id IN :taskIds
                  AND Confirmacion_de_lectura__c = TRUE
        ];

        for(Task t : tasks){
            t.Confirmacion_de_lectura__c = false;
        }

        if(!tasks.isEmpty())
            update tasks;
    }
}