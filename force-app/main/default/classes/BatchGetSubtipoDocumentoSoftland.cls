public class BatchGetSubtipoDocumentoSoftland implements Queueable, Database.AllowsCallouts {
    public String company;

    public BatchGetSubtipoDocumentoSoftland() {
    }

    public BatchGetSubtipoDocumentoSoftland(String company) {
        this.company = company;
    }

    public void execute(QueueableContext context) {
        new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.SUBTIPO_DOCUMENTO, company).execute(context);
    }
}