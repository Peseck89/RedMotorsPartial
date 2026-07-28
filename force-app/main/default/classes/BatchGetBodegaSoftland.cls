public class BatchGetBodegaSoftland implements Queueable, Database.AllowsCallouts {
    public String company;

    public BatchGetBodegaSoftland(String company) {
        this.company = company;
    }

    public void execute(QueueableContext context) {
        new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.BODEGA, company).execute(context);
    }
}