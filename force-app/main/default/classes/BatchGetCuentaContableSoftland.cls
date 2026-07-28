public class BatchGetCuentaContableSoftland implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.CUENTA_CONTABLE).execute(context);
    }
}