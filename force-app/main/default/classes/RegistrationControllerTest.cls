@isTest
public class RegistrationControllerTest {
	@isTest(SeeAllData=True)
    public static void getCalendarAvailabilityC()
    {
        RegistrationController regContrp = new RegistrationController();
        regContrp.dummy();
        regContrp.redirectPopup();
        regContrp.closePopup();
        regContrp.showPopup();
        regContrp.volver();
        regContrp.login();
        //regContrp.sendRegistrationRequest();
        regContrp.getEncodedSiteUrl();
    }
}