/**
* @description       : 
* @author            : David Evangelista david@incompany.cr
* @group             : 
* @last modified on  : 20-10-2022
* @last modified by  : esteban@incompany.cr
**/
public class SaldosCallout {
	public static HttpResponse postData(String actualToken, enviodeSaldos__c saldo)
	{
		HttpResponse response;
		try 
		{    
			HttpRequest req = new HttpRequest();
			Http http = new Http();
			// Set values to Parameters
			req.setHeader('Authorization', 'Bearer '+actualToken);
        	req.setHeader('Content-Type', 'application/json;charset=UTF-8');
			req.setEndpoint('https://test-snapcompliance-altica-serv-api-load.azurewebsites.net/Customers/SendBalance');
			req.setMethod('POST');
			req.setBody(SaldosHelper.getRequestJSON(saldo));
			response = http.send(req); 
			if(response.getStatusCode() == 200)
			{
				System.debug('Response is:' + response.getBody());
			}
			else
			{
				System.debug('Response is:' + response.getBody() + 'Status:' + response.getStatusCode()) ;
			}
		}
		catch (Exception e) {       
			System.debug('Error is :' + e.getMessage() + 'LN:' + e.getLineNumber() );         
		}
        return response;
    }
	
	public static HttpResponse getSaldosDataFromAltica()
    {
        HttpResponse response;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://35.226.4.74/api/LagoDeDatos/obtenerSaldos');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        response = http.send(request);
        // Parse the JSON response
        if(response.getStatusCode() != 200) {
            System.debug('Server Status: ' + response.getStatusCode() + ' ' + response.getStatus()+' '+response.getBody());
            System.debug(response.getBody());
        } else {
            System.debug(response.getBody());
        }
        
        return response;
    }
    
}