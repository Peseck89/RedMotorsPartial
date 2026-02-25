import { LightningElement, track, wire, api } from 'lwc';
import getDatos from '@salesforce/apex/ct_CustomAsset.getCuentaInfo';
import getAssets from '@salesforce/apex/ct_CustomAsset.getAssets';
import getUsuarioComunidad from '@salesforce/apex/ct_CustomAsset.getUsuarioComunidad';
import getUltimaVisita from '@salesforce/apex/ct_CustomAsset.getUltimaVisita';
import uploadFile from '@salesforce/apex/ct_CustomAsset.uploadFile';


const columns = [
    { label: 'Marca', fieldName: 'Marca_Nvo__c' },
    { label: 'Modelo', fieldName: 'Modelo_Nvo__c' },
    { label: 'Año', fieldName: 'Anio__c' },
    { label: 'Placa', fieldName: 'Name' }
];

export default class CustomAccountSection_lwc extends LightningElement {
    columns = columns;
    @track data = [];
    @api recordId;
    @track nombre;
    @track apellido;
    @track nombreCompleto
    @track cedula;
    @track tipoIdentificacion;
    @track nombreIdentificacion
    @track telefono;
    @track email;
    @track empEmail;
    @track codSoft;
    @track fechaUltimaVisita;
    @track customerLifetimeValue;
    @track otroVehiculo;
    @track contactosRelacionados;
    @track bmwServiceUserCheck;
    @track showBmwUser = false;
    @track accountComunidad = false;
    @track imageUser = 'https://t3.ftcdn.net/jpg/03/58/90/78/360_F_358907879_Vdu96gF4XVhjCZxN2kCG0THTsSQi8IhT.jpg';
    @track imageUrl;
    @track isPersonAccount = false;    
    @track ultimoEvento = ''; 
    @track noTieneImagen = true;
    @track file;
    handleFileChange(event) {
        this.file = event.target.files[0];
        console.log(this.file);
    }
    
    @track showSpinner = false

    cargarImagen(){
        this.noTieneImagen = !this.noTieneImagen;
    }

    handleUpload() {
        this.showSpinner = true
        if (this.file) {
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                // console.log('this.file.name');
                // console.log(this.file.name);
                // console.log('base64Data');
                // console.log(base64);
                // console.log('this.recordId');
                // console.log(this.recordId);
                uploadFile({ base64Data: base64, fileName: this.file.name , recordId:this.recordId})
                    .then(result => {
                        // console.log('result');
                        // console.log(result);
                        this.imageUrl = result;
                        this.imageUser = result;
                        this.noTieneImagen = true;
                        this.showSpinner = false
                    })
                    .catch(error => {
                        console.error(error);
                        this.showSpinner = false
                        // this.showSpinner = false
                    });
            };
            // console.log( 'this.imageUrl');
            // console.log( this.imageUrl);
            reader.readAsDataURL(this.file);
            // this.showSpinner = false
        }
    }

    connectedCallback(){
        getAssets({ recordId: this.recordId})
      .then(result => {
        // handle success, maybe show a success message              
        // console.log('vehiculo creado correctamente: ' + result);
        if(result){

            this.data = result;
            // console.log('Data vehiculos', this.data);

        }
      })
      .catch(error => {
          // handle error
          console.error('Error updating record', error);
      });
    }
    
    @wire(getUsuarioComunidad, { recordId: '$recordId' })
    getComunidadSetting({ error, data }) {
        if (data != undefined) {
            // console.log('======================data Comunidad======================');
            // console.log(data);
            if(data[0] != undefined && data[0] != null && data[0] != ''){
                this.showBmwUser = true;
            }
        
            // console.log('Bmw Service User', this.bmwServiceUserCheck);
            
        } else if (error) {
            console.log(error)
           this.fechaUltimaVisita = '';
        }
    }

    @wire(getUltimaVisita, { recordId: '$recordId' })
    getVisitSetting({ error, data }) {
        if (data != undefined) {
            // console.log('======================data Event======================');
            // console.log(data);
            if(data[0] != undefined && data[0] != null && data[0] != ''){
                this.fechaUltimaVisita = data[0].StartDateTimeF__c;
            }
        
            // console.log('Bmw Service User', this.bmwServiceUserCheck);
            
        } else if (error) {
            console.log(error)
           this.fechaUltimaVisita = '';
        }
    }

    @wire(getDatos, { recordId: '$recordId' })
    getAccountSetting({ error, data }) {
        if (data) {
            console.log('======================data======================');
            console.log(data);
            this.nombre = data[0].Account.FirstName;
            this.apellido = data[0].Account.LastName;
            this.nombreCompleto = data[0].Account.Name
            this.cedula = data[0].Account.Cedula__c;
            this.tipoIdentificacion = data[0].Account.Tipo_de_Documento__c;
            this.telefono = data[0].Account.Phone;
            this.email = data[0].Account.PersonEmail;
            this.empEmail = data[0].Account.CorreoElectronicoEmpresarial__c;
            this.codSoft = data[0].Account.codigoSoftland__c;
            //this.fechaUltimaVisita = data[0].UltimaVisitaAlTaller__c;
            this.customerLifetimeValue = data[0].customerLifetimeValue;
            this.otroVehiculo = data[0].otroVehiculo;
            // console.log('Datos otro vehiculo:',this.otroVehiculo);
            this.contactosRelacionados = data[0].contactosRelacionados;
            this.bmwServiceUserCheck = data[0].bmwServiceUserCheck;
            this.isPersonAccount = data[0].Account.IsPersonAccount;

            // console.log('Es cuenta personal?', this.isPersonAccount);

            if (this.isPersonAccount === true) {
                if(this.tipoIdentificacion == '01') {
                    this.nombreIdentificacion = 'Cédula física'
                } else if (this.tipoIdentificacion == '03') {
                    this.nombreIdentificacion = 'Dimex'
                } else if (this.tipoIdentificacion == '04') {
                    this.nombreIdentificacion = 'NITE'
                }
            } else if (this.isPersonAccount !== true){
                if(this.tipoIdentificacion == '02') {
                    this.nombreIdentificacion = 'Cédula juridica'
                } else if (this.tipoIdentificacion == '03') {
                    this.nombreIdentificacion = 'Dimex'
                } else if (this.tipoIdentificacion == '04') {
                    this.nombreIdentificacion = 'NITE'
                }
            }

            if(data[0].Image_URL__c != null && data[0].Image_URL__c != ''){
                var str =  data[0].Image_URL__c;
            //     str = str.replace(/^<p>/, '').replace(/<\/p>$/, '');
            //     // Extract the src attribute value
            //     let srcMatch = str.match(/src="([^"]*)"/);

            //     if (srcMatch && srcMatch[1]) {
            //         let srcValue = srcMatch[1];
            //         srcValue = srcValue.replace(/&amp;/g, '&');                
                    this.imageUser =  str;
                    this.noTieneImagen = true;
            //     }
                
            }else{
                this.noTieneImagen = false;
            }

            // if(this.bmwServiceUserCheck === null || this.bmwServiceUserCheck === undefined || this.bmwServiceUserCheck === '') {
            //     this.showBmwUser = false
            // } else {
            //     this.showBmwUser = true
            // }

            // console.log('Bmw Service User', this.bmwServiceUserCheck);
            
        } else if (error) {
            console.log(error);
        }
    }
}