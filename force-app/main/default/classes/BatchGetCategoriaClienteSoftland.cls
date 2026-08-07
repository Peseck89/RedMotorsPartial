public class BatchGetCategoriaClienteSoftland implements Queueable, Database.AllowsCallouts {
    public String company;

    public BatchGetCategoriaClienteSoftland() {
    }

    public BatchGetCategoriaClienteSoftland(String company) {
        this.company = company;
    }

    public void execute(QueueableContext context) {
        new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.CATEGORIA_CLIENTE, company).execute(context);
    }
}