public class BatchGetCondicionPagoSoftland implements Queueable, Database.AllowsCallouts {
    public String company;

    public BatchGetCondicionPagoSoftland() {
    }

    public BatchGetCondicionPagoSoftland(String company) {
        this.company = company;
    }

    public void execute(QueueableContext context) {
        new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.CONDICION_PAGO, company).execute(context);
    }
}