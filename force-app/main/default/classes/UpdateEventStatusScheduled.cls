global class UpdateEventStatusScheduled implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Llama al batch
        UpdateEventStatusBatch batch = new UpdateEventStatusBatch();
        Database.executeBatch(batch, 200);
    }
}