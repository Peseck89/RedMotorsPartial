// Clase para manejar el bypass de triggers
public with sharing class TriggerBypassUtil {
    private static Set<String> bypassedTriggers = new Set<String>();
    
    public static void bypassTrigger(String triggerName) {
        bypassedTriggers.add(triggerName);
    }
    
    public static void clearBypass(String triggerName) {
        bypassedTriggers.remove(triggerName);
    }
    
    public static Boolean isBypassed(String triggerName) {
        return bypassedTriggers.contains(triggerName);
    }
    
    public static void clearAllBypasses() {
        bypassedTriggers.clear();
    }
}