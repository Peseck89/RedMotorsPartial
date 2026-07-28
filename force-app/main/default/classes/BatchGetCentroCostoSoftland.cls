public class BatchGetCentroCostoSoftland implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.CENTRO_COSTO).execute(context);
    }
}