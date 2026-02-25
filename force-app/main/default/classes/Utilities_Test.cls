@isTest
private class Utilities_Test {
    @isTest
    private static void getInstance(){
        String instance = '';
        Organization o = [SELECT OrganizationType, InstanceName FROM Organization limit 1];
		System.debug('organization getInstance() test ' + o);
        String orgType = o.OrganizationType;
		System.debug('orgType getInstance() test ' + orgType);
        String insName = o.InstanceName;
		System.debug('insName getInstance() test ' + insName);

        //Set this header to test it
        ApexPages.currentPage().getHeaders().put('Host', insName+'.visual.force.com');

        if(orgType == 'Developer Edition'|| insName.startsWithIgnoreCase('cs')){
            List<String> parts = ApexPages.currentPage().getHeaders().get('Host').split('\\.');
			System.debug('parts getInstance() test ' + parts);
            instance = parts[parts.size() - 4] + '.';
			System.debug('instance getInstance() test ' + instance);
        }
		

        System.assertEquals(instance, Utilities.getInstance());
    }
    @isTest
    private static void getSubdomainPrefix(){
        //This will always be empty unless it's sandbox
        System.assertEquals('', Utilities.getSubdomainPrefix());
    }

}