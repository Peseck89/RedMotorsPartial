global class ScheduleGetCategoriaClienteSoftland implements Schedulable{
    global void execute(SchedulableContext SC) {
        System.enqueueJob(new BatchGetCategoriaClienteSoftland('RMBAVARIAN'));
        System.enqueueJob(new BatchGetCategoriaClienteSoftland('RMPEKING'));
    }
}