@isTest
global class MockHttpResponeCrearPedidoConErrores implements HttpCalloutMock{
	// Implement this interface method

    global HTTPResponse respond(HTTPRequest req) {
        cls_ClientJSON cls = new cls_ClientJSON();
        cls.Data=new List<cls_Client>();
        
        cls_ClientJSONResponse client = new cls_ClientJSONResponse();
        client.operationResult = new cls_OperationResult();
        client.operationResult.code='00';
        system.debug('test mock endpoint::'+ req.getEndpoint());
        
        
        String myJSON = JSON.serialize(client);
        //string url=Label.URLSoftland;
        //string url='http://143.208.181.92:5080';
 
        string endp = req.getEndpoint();
        if(endp.containsIgnoreCase('getListPaged')){
            system.debug('contains get List paged');
            myJSON=JSON.serialize(cls);
        }
        else if(endp.containsIgnoreCase('add')){
            cls_OrderJSONResponse ordRes = new cls_OrderJSONResponse();
            ordRes.code='00';
            
            cls_OrderJSONResponse resp= new cls_OrderJSONResponse();
            resp.detail='abc';
            resp.errorCode='03';
            resp.code='99';
            
            ordRes.Data = new List<cls_OrderJSONResponse>();
            ordRes.Data.add(resp);
            
            myJSON=JSON.serialize(ordRes);
        } else if(endp.containsIgnoreCase('update')){
            cls_OrderJSONResponse ordRes = new cls_OrderJSONResponse();
            ordRes.code='00';
            
            cls_OrderJSONResponse resp= new cls_OrderJSONResponse();
            resp.detail='abc';
            resp.errorCode='03';
            resp.code='99';
            
            ordRes.Data = new List<cls_OrderJSONResponse>();
            ordRes.Data.add(resp);
            
            myJSON=JSON.serialize(ordRes);
        }
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(myJSON);
        res.setStatusCode(200);
        system.debug('res:::'+res.getBody());
        return res;
    }
    
}