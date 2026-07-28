public class BatchGetCondicionPagoSoftland implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.CONDICION_PAGO).execute(context);
    }
}