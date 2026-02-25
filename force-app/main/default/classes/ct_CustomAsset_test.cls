@isTest(seeAllData=true)
public class ct_CustomAsset_test {
@IsTest
    static void testGetData(){
        List<Asset> lstAsset = [Select Id From Asset Where Name = 'DBZ0981'];
		String strAsset = lstAsset[0].Id;
        List<String> idCoche = new List<String>();
        idCoche.add(strAsset);
        ct_CustomAsset.getCuentaInfo(strAsset);      
        ct_CustomAsset.getHistorialInfo(strAsset);
        ct_CustomAsset.getCasosRelacionados(strAsset);
        ct_CustomAsset.getImagen(strAsset);
        ct_CustomAsset.obtenerUrlImagen(idCoche);
        ct_CustomAsset.getAssets(strAsset);
        ct_CustomAsset.getUltimaVisita(strAsset);
        ct_CustomAsset.getUsuarioComunidad(strAsset);
        ct_CustomAsset.getProximaVisita(strAsset);
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('This is a test image'));
        String fileName = 'testImage.png';
        ct_CustomAsset.uploadFile(base64Data, fileName, strAsset);
    }
}