public class BatchGetImpuestoSoftland implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.IMPUESTO).execute(context);
    }
}