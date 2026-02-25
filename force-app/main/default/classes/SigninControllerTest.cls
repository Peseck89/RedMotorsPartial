@isTest
public class SigninControllerTest {
@isTest(SeeAllData=True)
    public static void SigninController()
    {
        SigninController newSigin = new SigninController();
        newSigin.login();
        newSigin.getEncodedSiteUrl();
    }
}