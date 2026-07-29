public class BatchGetCentroCostoSoftland implements Queueable, Database.AllowsCallouts {
    public String company;

    public BatchGetCentroCostoSoftland() {
    }

    public BatchGetCentroCostoSoftland(String company) {
        this.company = company;
    }

    public void execute(QueueableContext context) {
        new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.CENTRO_COSTO, company).execute(context);
    }
}