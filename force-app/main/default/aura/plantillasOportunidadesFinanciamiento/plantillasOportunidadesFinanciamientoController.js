({
  init: function (cmp, event, helper) {
    cmp.set('v.mycolumns', [
      { label: 'Plantilla Nro.', fieldName: 'Name', type: 'autonumber' },
      { label: 'Nombre de Plantilla', fieldName: 'Nombre_de_Plantilla__c', type: 'Text' }

    ]);

    helper.getData(cmp);


  },

  pdfGenerator: function (component, event, helper) {

    var sendDataProc = component.get("v.plantillasToPDF");
    let selectedRows = [];
    selectedRows = component.find('plantillasList').getSelectedRows();
    var plantillasSeleccionadas = [];
    for (var i = 0; i < selectedRows.length; i++) {

      var row = selectedRows[i];


      plantillasSeleccionadas.push(row.Plantilla__c);


    }


    console.log(JSON.parse(JSON.stringify(plantillasSeleccionadas[0])));




    var dataToSend = plantillasSeleccionadas; //this is data you want to send for PDF generation
    console.log(dataToSend)

    //invoke vf page js method
    sendDataProc(dataToSend, function () {
      //handle callback
    });

  }



})