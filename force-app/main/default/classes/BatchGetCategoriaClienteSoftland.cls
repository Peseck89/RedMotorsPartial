public class BatchGetCategoriaClienteSoftland implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.CATEGORIA_CLIENTE).execute(context);
    }
}