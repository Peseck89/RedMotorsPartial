import { api, wire } from 'lwc';
import columns from './columns';
import { reduceErrors } from 'c/ldsUtils';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDetalleCosto from '@salesforce/apex/RM_VN_ConsultarCosteo_Ctrl.getDetalleCosto';

export default class Rm_vn_consultar_detalle_costo_modalbox extends LightningModal {
    columns = columns;
    
    productName;

    @api vehiculoId;
    records = [];
    wiredRecordsResult;
    isLoading = false;

    sfdcBaseURL;
    connectedCallback() {
        this.sfdcBaseURL = window.location.origin;  
        this.isLoading = true;       
    } 
    totalMontoDolar = 0.0;
    totalMontoLocal = 0.0;
    @wire(getDetalleCosto,{ vehiculoId: "$vehiculoId"})
    wiredRecords(result) {
        this.records = [];       
        this.wiredRecordsResult = result;
        if (result.data) {
            Object.values(result.data).forEach((item, index) => {
                if (typeof item === "object") {
                    let actions = [];
                    actions.push({ label: 'Consultar detalle costo', name: 'consultar-detalle-consteo' });
                    let record = {
                        actions: actions,
                        Id :  item.Id,
                        name :  item.Name,
                        rubro : item.Rubro__c ? item.Rubro__c : '',
                        linea : item.id_linea_gasto__c ? item.id_linea_gasto__c : '',
                        dollarAmount : item.Monto_Dolar__c ? item.Monto_Dolar__c : undefined,
                        colonAmount : item.Monto_local__c ? item.Monto_local__c : undefined
                    };
                    this.records[index] = record;
                    this.productName = item.Product__r ? item.Product__r.Name : '';
                    this.totalMontoDolar += item.Monto_Dolar__c ? item.Monto_Dolar__c : 0;
                    this.totalMontoLocal += item.Monto_local__c ? item.Monto_local__c : 0;
                }
            });

            let lastRecord = {
                lastRecord : true,
                rubro : 'Total:',
                name : '',
                linea : '',
                dollarAmount : this.totalMontoDolar,
                colonAmount : this.totalMontoLocal
            };
            //add to the end of the list
            this.records.push(lastRecord);

        }else if(result.error){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error !',
                    message: reduceErrors(result.error).join(', '),
                    variant: 'error'
                })
            );
        }
        this.isLoading = false;
        console.log(this.records);
    }

    handleExportToExcel() {
        let excelDoc = '';
        excelDoc += '<table style="border-collapse: collapse; width: 100%; height: 54px;" border="1">';
        excelDoc += '<thead>';
        excelDoc += '<tr style="height: 18px;">';
        excelDoc += '<th style="width: 100%; height: 18px; text-align: center; background-color: #f0f0f0;" colspan="5">'+this.productName+'</th>';
        excelDoc += '</tr>';
        excelDoc += '<tr style="height: 18px;">';
        excelDoc += '<th style="width: 20%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Linea</strong></th>';
        excelDoc += '<th style="width: 20%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Nombre</strong></th>';
        excelDoc += '<th style="width: 20%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Rubro</strong></th>';
        excelDoc += '<th style="width: 20%; height: 18px; text-align: right; background-color: #f0f0f0;"><strong>Monto(USD)</strong></th>';
        excelDoc += '<th style="width: 20%; height: 18px; text-align: right; background-color: #f0f0f0;"><strong>Monto(CRC)</strong></th>';
        excelDoc += '</tr>';
        excelDoc += '</thead>';
        excelDoc += '<tbody>';
                        this.records.forEach(record => {
                            if(!record.lastRecord){
                                excelDoc += '<tr>';
                                    excelDoc += '<td>'+record.linea+'</td>';
                                    excelDoc += '<td>'+record.name+'</td>';
                                    excelDoc += '<td>'+record.rubro+'</td>';
                                    excelDoc += '<td>'+record.dollarAmount.toFixed(2)+'</td>';
                                    excelDoc += '<td>'+record.colonAmount.toFixed(2)+'</td>';
                                excelDoc += '</tr>';
                            }
                        });

                        excelDoc += '<tr>';
                            excelDoc += '<td style="text-align: right; " colspan="3"><strong>Total:</strong></td>';
                            excelDoc += '<td>'+this.totalMontoDolar.toFixed(2)+'</td>';
                            excelDoc += '<td>'+this.totalMontoLocal.toFixed(2)+'</td>';
                        excelDoc += '</tr>';
            excelDoc += '</tbody>';
            excelDoc += '</table>';

            console.log('excelDoc');
            console.log(excelDoc);

            let element = 'data:application/vnd.ms-excel,' + encodeURIComponent(excelDoc);
            let downloadElement = document.createElement('a');
            downloadElement.href = element;
            downloadElement.target = '_self';

            downloadElement.download = 'Consulta de Costeo '+this.productName+'.xls';
            document.body.appendChild(downloadElement);
            downloadElement.click();
    }
    
    handleExportToCSV(separator) {
        let csvContent = "data:text/csv;charset=utf-8,";

        // headers
        csvContent += this.productName + separator + separator + separator + separator + "\r\n";
        csvContent += "Linea" + separator + "Nombre" + separator + "Rubro" + separator + "Monto(USD)" + separator + "Monto(CRC)\r\n";

        // rows
        this.records.forEach(record => {
            if(!record.lastRecord){
                csvContent += record.linea + separator + record.name + separator + record.rubro + separator + record.dollarAmount.toFixed(2) + separator + record.colonAmount.toFixed(2) + "\r\n";
            }
        });

        // total
        csvContent += separator + separator + "Total" + separator + this.totalMontoDolar.toFixed(2) + separator + this.totalMontoLocal.toFixed(2) + "\r\n";

        const encodedUri = encodeURI(csvContent);
        const link = document.createElement("a");
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", "Consulta de Costeo "+this.productName+".csv");
        document.body.appendChild(link); // Required for Firefox

        link.click(); // This will download the data file named "Consulta de Costeo [productName].csv".
    }

    handleExportSelect(event){
        const selectedItemValue = event.detail.value;
        if(selectedItemValue === 'comma'){
            this.handleExportToCSV(',');
        }else if(selectedItemValue === 'semicolon'){
            this.handleExportToCSV(';');
        }
    }

    get isExportDisabled(){
        return this.records.length === 0;
    }
}