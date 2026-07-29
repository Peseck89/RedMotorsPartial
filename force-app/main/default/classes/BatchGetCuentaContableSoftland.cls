public class BatchGetCuentaContableSoftland implements Queueable, Database.AllowsCallouts {
    public String company;

    public BatchGetCuentaContableSoftland() {
    }

    public BatchGetCuentaContableSoftland(String company) {
        this.company = company;
    }

    public void execute(QueueableContext context) {
        new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.CUENTA_CONTABLE, company).execute(context);
    }
}