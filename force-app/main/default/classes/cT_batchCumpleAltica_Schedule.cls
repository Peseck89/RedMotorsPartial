global  class cT_batchCumpleAltica_Schedule implements Schedulable {
   global void execute(SchedulableContext sc) {
      cT_batchCumpleAltica b = new cT_batchCumpleAltica(); 
      database.executebatch(b);
   }
}