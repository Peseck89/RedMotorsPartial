@IsTest(SeeAllData=true)
public class walkingCommunityController_test {
	@IsTest() 
    public static void testGetModelos () {
        walkingCommunityController.getModelos();
        walkingCommunityController.getFamilia('BMW');
        walkingCommunityController.getFamilia('MINI');
        walkingCommunityController.getVehiculos('X1','BMW');
        walkingCommunityController.dummy();
    }
}