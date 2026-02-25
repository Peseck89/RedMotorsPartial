/**
 * Using without sharing as need to run query on Organization table
 */
public without sharing class Utilities {

    //Get instance from INSTANCE.visual.force.com page so we can build
    public Static String getInstance(){
        String instance = '';
        Organization o = [SELECT OrganizationType, InstanceName FROM Organization limit 1];
		System.debug('organization getInstance() ' + o);
        String orgType = o.OrganizationType;
        System.debug('orgType getInstance() ' + orgType);
		String insName = o.InstanceName;
		System.debug('insName getInstance() ' + insName);

        if(orgType == 'Developer Edition' || insName.startsWithIgnoreCase('cs')){
            List<String> parts = ApexPages.currentPage().getHeaders().get('Host').split('\\.');
			System.debug('parts getInstance() ' + parts);
            instance = parts[parts.size() - 4] + '.';
			System.debug('instance getInstance() ' + instance);
        }
        return instance;
    }
    //Needed in cases if current org is sandbox
    public static String getSubdomainPrefix(){
        Organization o = [SELECT OrganizationType, InstanceName FROM Organization limit 1];
		System.debug('organization getSubdomainPrefix() ' + o);
        String orgType = o.OrganizationType;
		System.debug('orgType getSubdomainPrefix() ' + orgType);
        String insName = o.InstanceName;
		System.debug('insName getSubdomainPrefix() ' + insName);
        if(insName.startsWithIgnoreCase('cs')){
			
			if(insName.equalsIgnoreCase('cs51')){
				return '';
			}else{
				System.debug('UserInfo.getUserName().substringAfterLast... ' + UserInfo.getUserName().substringAfterLast('.'));
				return UserInfo.getUserName().substringAfterLast('.')+ '-';			
			}	


        }
        return '';
    }
}