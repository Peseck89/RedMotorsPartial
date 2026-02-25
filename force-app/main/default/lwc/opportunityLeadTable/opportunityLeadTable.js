import { LightningElement, track } from 'lwc';
import getRecords from '@salesforce/apex/OpportunityLeadController.getRecords';
import getRecordCount from '@salesforce/apex/OpportunityLeadController.getRecordCount';
import getAllRecords from '@salesforce/apex/OpportunityLeadController.getAllRecords';


export default class OpportunityLeadTable extends LightningElement {
    @track records = [];
    @track page = 1;
    @track totalPages = 0;
    @track pageSize = 20;
    @track recordCount = 0;

    columns = [
        { label: 'Fecha de creacion', fieldName: 'CreatedDate', type: 'date', typeAttributes: {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
        }},
        { label: 'Creado por', fieldName: 'CreatedBy.Name' },
        { label: 'Origen del candidato', fieldName: 'Origen_1__c' },
        { label: 'Acción', fieldName: 'Action__c' },
        { label: 'Sucursal', fieldName: 'Sucursal__c' },   
        { label: 'Marca', fieldName: 'Marca__c' },     
        { label: 'Familia', fieldName: 'Familia1__c' },   
        { label: 'Modelo', fieldName: 'Modelo_De_Inter_s1__c' },     
        {
            label: 'Nombre',
            fieldName: 'recordLink',
            type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'FirstName'
                },
                target: '_blank'
            }
        },
        { label: 'Apellidos', fieldName: 'LastName' },                        
        { label: 'Correo', fieldName: 'Email' },
        { label: 'Movil', fieldName: 'Phone' },  
        { label: 'Propietario del candidato', fieldName: 'Owner_Name__c' },   
        { label: 'Estado de candidato', fieldName: 'Status' }, 
        { label: 'Fecha Posible de Compra', fieldName: 'FechaPosibleCompra__c' }
    ];

    connectedCallback() {
        this.loadRecords();
        this.loadRecordCount();
    }

    loadRecords() {
        getRecords({ pageSize: this.pageSize, pageNumber: this.page })
            .then(result => {
                this.records = result.map(record => {
                    return {
                        ...record,
                        recordLink: '/' + record.Id
                    };
                });
            })
            .catch(error => {
                console.error('Error fetching records:', error);
            });
    }

    loadRecordCount() {
        getRecordCount()
            .then(result => {
                this.recordCount = result;
                console.log('this.recordCount');
                console.log(this.recordCount);
                this.totalPages = Math.ceil(this.recordCount / this.pageSize);
            })
            .catch(error => {
                console.error('Error fetching record count:', error);
            });
    }

    handleNextPage() {
        if (this.page < this.totalPages) {
            this.page++;
            this.loadRecords();
        }
    }

    handlePreviousPage() {
        if (this.page > 1) {
            this.page--;
            this.loadRecords();
        }
    }

    get isFirstPage() {
        return this.page === 1;
    }

    get isLastPage() {
        return this.page >= this.totalPages;
    }

    exportToExcel() {
        getAllRecords()
            .then(allRecords => {
                if (!allRecords || allRecords.length === 0) {
                    alert('No data available to export');
                    return;
                }
    
                // Create CSV header from columns
                let csvString = this.columns.map(col => col.label).join(',') + '\n';
    
                // Create CSV rows from all records
                allRecords.forEach(record => {
                    let row = [];
                    this.columns.forEach(col => {
                        let cellValue = record[col.fieldName] !== undefined ? record[col.fieldName] : '';
                        // Escape double quotes and handle special characters
                        cellValue = cellValue.toString().replace(/"/g, '""');
                        row.push('"' + cellValue + '"');
                    });
                    csvString += row.join(',') + '\n';
                });
    
                // Base64 encode the CSV string
                const base64CsvString = btoa(unescape(encodeURIComponent(csvString)));
    
                // Create a data URL for the CSV file
                const dataUrl = 'data:text/csv;charset=utf-8;base64,' + base64CsvString;
    
                // Create a link to trigger the download
                const link = document.createElement('a');
                link.href = dataUrl;
                link.download = 'Opportunities_and_Leads.csv';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            })
            .catch(error => {
                console.error('Error fetching all records:', error);
            });
    }
    
    
    
}