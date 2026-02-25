@isTest

public class singInWalking_test {
    @isTest(SeeAllData=True)
	public static void SigninController()
    {
        singInWalking newSigin = new singInWalking();
        newSigin.saltarLoginMini();
        newSigin.saltarLogin();
        newSigin.saltarLoginMoto();
    }
}