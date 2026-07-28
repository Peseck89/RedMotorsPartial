public class BatchGetSubtipoDocumentoSoftland implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.SUBTIPO_DOCUMENTO).execute(context);
    }
}