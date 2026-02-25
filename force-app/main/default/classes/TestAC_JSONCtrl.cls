/* Class:       TestAC_JSONCtrl
 * Created On:  3/31/2016
 * Created by:  OpFocus Team
 * Description: 
 */

@isTest
public class TestAC_JSONCtrl {
	
	
	static testMethod void myTest1() {
		User u = [Select Id, Email, FirstName from User where Id =:UserInfo.getUserId()];
		Test.setCurrentPage(Page.AC_JSON);
		ApexPages.currentPage().getParameters().put('q',u.FirstName);
		ApexPages.currentPage().getParameters().put('obj','User');
		ApexPages.currentPage().getParameters().put('label','FirstName');
		ApexPages.currentPage().getParameters().put('detail','Email');
		ApexPages.currentPage().getParameters().put('value','Id');
		AC_JSONCtrl ctrl = new AC_JSONCtrl();
		ctrl.getJSON();

	}

	static testMethod void myTest2() {
		User u = [Select Id, Email, FirstName,LastName from User where Id =:UserInfo.getUserId()];
		Test.setCurrentPage(Page.AC_JSON);
		ApexPages.currentPage().getParameters().put('q',u.FirstName);
		ApexPages.currentPage().getParameters().put('obj','User');
		ApexPages.currentPage().getParameters().put('label','FirstName');
		ApexPages.currentPage().getParameters().put('detail','Email,LastName');
		ApexPages.currentPage().getParameters().put('value','Id');
		AC_JSONCtrl ctrl = new AC_JSONCtrl();
		ctrl.getJSON();

	}
	
}