/**
 * An apex page controller that exposes the site forgot password functionality
 */
	@IsTest (SeeAllData=true) 
	public with sharing class ForgotPasswordControllerTest {
  	@IsTest
    public static void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'escsol1f@gmail.com';     	

        controller.bienvenida = true;         

    	controller.userExist = true;
        controller.seEnvio = true;
        
        list<user> lstUser = [Select id,email from user WHERE Username = 'escsol1f@gmail.com' OR Email = 'escsol1f@gmail.com'];
        
    	controller.username =  lstUser[0].email;     	
        
        controller.bienvenida = true;   
         test.startTest();
         controller.forgotPassword();
         controller.aceptaPassword=true;
        controller.verifyNewPassword = 'true';
         controller.password = 'Yandrax41$1'; 
         controller.changePassword();         
         test.stopTest();
    }
    @IsTest
    public static void wrongPassword() {        
       // Instantiate a new controller with all parameters in the page
    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'escsol1f@gmail.com';     	

        controller.bienvenida = true;         

    	controller.userExist = true;
        
        list<user> lstUser = [Select id,email from user WHERE Username = 'escsol1f@gmail.com' OR Email = 'escsol1f@gmail.com'];
    	controller.username =  lstUser[0].email;     	
        
        controller.bienvenida = true;   
         test.startTest();         
         controller.password = 'Yaaa'; 
	     controller.forgotPassword();
         controller.changePassword();         
         test.stopTest();  
    }
    
}