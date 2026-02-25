public with sharing class cT_improductivoRecurrenteHandler {
    private static boolean run = true;
    public static boolean runOnce(){
      if(run){
       run=false;
       return true;
      }else{
        return run;
      }
    }
}