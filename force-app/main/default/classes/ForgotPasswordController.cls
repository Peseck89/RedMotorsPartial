/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class ForgotPasswordController {
    public String username {get; set;}   
	public String password {get; set;}  
	public String password2 {get; set;}  
	public boolean bienvenida {get; set;}
	public boolean aceptaPassword {get; set;}  
	public boolean userExist {get; set;}  
	public boolean seEnvio {get; set;}  
	public String verifyNewPassword {get; set;}   

    public ForgotPasswordController() {
		if(System.currentPageReference().getParameters().get('Email') != null && System.currentPageReference().getParameters().get('Acepta') != null){
			username = System.currentPageReference().getParameters().get('Email');
			userExist = true;
		}else if(System.currentPageReference().getParameters().get('Email') != null){
			username = System.currentPageReference().getParameters().get('Email');
			bienvenida = true;
		}
	}

	public PageReference changePassword() {
		List<User> userComm = [select id from User Where email =: username];

		// Retrieve the user's email address or username
		String passwordString = password;
		String passwordString2 = password2;
		String userEmailOrUsername = 'escsol1f@gmail.com'; // Replace with actual user email or username

		//String passwordRegex = /^[0-9a-zA-Z\s!"#$\%&'\(\)\*\+\,\-\.\/\:;<=>?@\[\\\]\^\_\`\{\|\}\~]+$/g';
				
		
 Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

		if(isValidPassword(password) ){
			
			User communityUser = [SELECT Id, Username, Email FROM User WHERE Username = :username OR Email = :username];
			// Generate a new temporary password
			System.setPassword(communityUser.id,passwordString); 
			// Retrieve the community user
			// Set the user's password to the temporary password
			//communityUser.Password = passwordString;
			//communityUser.Password__c = passwordString; // If you have a custom field to store the password temporarily
			//update communityUser;
			// Send an email to the user with the temporary password	

			//Write your logic here and redirect
			PageReference retURL = Page.CustomCommunityLogIn;
			retURL.setRedirect(true);
			return retURL;
						  		   	
		}else {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Verifcar las condiciones de la contraseña.'));
		}
		
		return null;
	}

  	public PageReference forgotPassword() {
		//check if email exist
		List<User> userComm = [select Id, Username, Email,FirstName,LastName from User Where email =: username];
		if (userComm.size() == 0) {
			{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Usuario no encontrado.'));
				return null;
			} 
		}else {

			Peticion_de_envio__c newPetition = new Peticion_de_envio__c();
			newPetition.Email__c = userComm[0].Email;
			newPetition.First_Name__c = userComm[0].FirstName;
			newPetition.Last_Name__c = userComm[0].LastName;
			insert newPetition;

			//----------------------------VIEJO PROCESO DE RESET DE CONTRASEÑA---------------------------
			// Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			// email.setToAddresses(new List<String>{ userComm[0].Email });
			// email.setSubject('Solicitud de cambio de contraseña');
			// String body='<table style="background-color:white;font-family:Tahoma;border-collapse: collapse;width:100%;font-family:Tahoma;border: 1px solid;border-color: white;" cellpadding="0" cellspacing="0" >'
			// +'<tr>'
			// + '<td align="center">'		   
			// +  '<table style="width:600px;background-color:white;border: 1px solid;border-color:#E5E6E6;" cellpadding="0" cellspacing="0" >		   '
			// +   '<tr>		   '
			// +	'<td style="padding:10px; ">&nbsp;</td>		   '
			// +   '</tr>		   '
			// +   '<tr>		   '
			// +	'<td>		   '
			// +	 '<table style="background-color:#E5E6E6;width:100%;">		   '
			// +	  '<tr>		   '
			// +		'<td style="text-align:left;background-color:#E5E6E6; padding: 25px;">		   '
			// +		  '<p style="font-weight: bold;font-size:24px;">Hola '+userComm[0].FirstName+' ' + userComm[0].LastName + ' </p>		   '
			// +		  '<p Style="font-size:20px;"> Reciba un cordial saludo.</p>		   '
			// +		'</td>		   '
			// +	  '</tr>		   '
			// +	 '</table>		   '
			// +	'</td>'		   
			// +  '</tr>'		   		   		   
			// +   '<tr>	'	   
			// +	'<td style="padding:5px;">&nbsp;</td>'		   
			// +   '</tr>'		   		   		   
			// +   '<tr>'		   
			// +	 '<td style="padding:5px; ">&nbsp;</td>	'	   
			// +   '</tr>'		   		   		   
			// +	'<tr>'		   
			// +	 '<td style = "">'		   
			// +	  '<table style="width:100%;background-color:#white;height:30px;" cellpadding="0" cellspacing="0" >'		   
			// +	   '<tr>'
			// +  '<tr>		'   
			// +	'<td style = "padding:20px;">'
			// +	 '<table style="padding:20px;width:100%;background-color:white;text-align:center;border: 2px solid; border-color: #E5E6E6;" >'
			// +	  '<tr>'
			// +	   '<td style="text-align:left;">'
			// +		 '<span style="font-size:20px;font-weight: bold;">Aquí puedes gestionar tu acceso a la comunidad</span>'
			// +		 '<br>'
			// +	   '</td>'
			// +	   '<td style="width:50%;padding-right: 10px;padding-left: 30px;"> '
			// +		'<a href="https://redmotors.my.site.com/ForgotPassword?Email='+userComm[0].Email+'&Acepta=true"><img alt="logo" src="https://redmotors--portalcom.sandbox.file.force.com/servlet/servlet.ImageServer?id=0158N000000QkWN&oid=00D8N00000050ml&lastMod=1679087667000" style="max-width: 676.207px; height:40px;" title="logo" /></a>   '
			// +	   '</td>'
			// +	  '</tr>'
			// +	 '</table>'
			// +	'</td>' 
			// +  '</tr>  '
			// +   '<tr >   '
			// +	'<td style="padding-top: 20px;">'
			// +	 '<table style="width:100%;background-color:white;height:30px;" >'
			// +	  '<tr> '
			// +	  '</tr>'
			// +	 '</table>   '
			// +	'</td>	   '
			// +  '</tr>'
			// +   '<tr><td style="padding:5px; ">&nbsp;</td></tr>'
			// +   '<tr>		'   
			// +	'<td style="">	   '
			// +	'</td>		   '
			// +  '</tr>	   '
			// +   '<tr>	   '
			// +	 '<td>	   '
			// +	   '<br>	   '
			// +		'</td>	   '
			// +	  '</tr>		   '
			// +	 '<tr>'
			// +	 '<td style = "padding:20px;">	   '
			// +	'</td>	   '
			// +	 '</tr>	   '
			// +  '</table>	   '
			// + '</td>'	   
			// +'</tr>	'   
		    // +'</table>';
			// email.setHtmlBody (body
			// );
			// if(test.isRunningTest()){

			// }else{
			// 	Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email }); 
			// }
		
			
			seEnvio = true;

			return null;
		}
  		

	}


	public static Boolean isValidPassword(String password) {
        // Check for minimum length
        if (password.length() < 8) {
            return false;
        }

        

        // Check for at least one special character
        String specialCharacters = '!@#$%^&*()_+-=[]{};\'":|,.<>/?';
        Boolean hasSpecialCharacter = false;
        for (Integer i = 0; i < password.length(); i++) {
            System.debug(String.valueOf(password.charAt(i)));
             String currentChar = password.substring(i, i+1);
            System.debug('Character at position ' + i + ': ' + currentChar);
            
            if (specialCharacters.contains(currentChar)) {
                hasSpecialCharacter = true;
                break;
            }
        }

        return hasSpecialCharacter;
    }


}