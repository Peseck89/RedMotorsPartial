@isTest (SeeAllData=true)
public class crearShadowBloquesTest {
	@isTest
    private static void testBloques() {
		List<Event> lstEvent = [Select id,StartDateTime,EndDateTime,OwnerId,RecordTypeId,Owner.FirstName From Event Where id = '00UPH000003ZMbp2AG'];
        crearShadowBloques.onBeforeInsert(lstEvent);
    }
}