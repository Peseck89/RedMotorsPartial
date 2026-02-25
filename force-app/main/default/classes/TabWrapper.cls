public with sharing class TabWrapper {
    public String plantillaName {get; private set;}
    public String plantillaId {get; private set;}
    public String opFinanciamientoId {get; private set;}

    public TabWrapper(String plantillaName, String plantillaId, String opFinanciamientoId) {
        this.plantillaName = plantillaName;
        this.plantillaId = plantillaId;
        this.opFinanciamientoId = opFinanciamientoId;
    }
}