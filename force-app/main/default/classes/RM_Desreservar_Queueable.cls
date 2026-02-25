public class RM_Desreservar_Queueable implements System.Queueable, Database.AllowsCallouts {
    //declare variables
    private final Id oppId;
    private final Id productId;

    public RM_Desreservar_Queueable(Id oppId,Id productId) {
        this.oppId = oppId;
        this.productId = productId;
    }

    public void execute(System.QueueableContext context) {
        QuitarReservaController.makeEliminarReserva(this.oppId,this.productId);
    }

}