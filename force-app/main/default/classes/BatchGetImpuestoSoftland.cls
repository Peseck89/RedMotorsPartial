public class BatchGetImpuestoSoftland implements Queueable, Database.AllowsCallouts {
    public String company;

    public BatchGetImpuestoSoftland() {
    }

    public BatchGetImpuestoSoftland(String company) {
        this.company = company;
    }

    public void execute(QueueableContext context) {
        new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.IMPUESTO, company).execute(context);
    }
}