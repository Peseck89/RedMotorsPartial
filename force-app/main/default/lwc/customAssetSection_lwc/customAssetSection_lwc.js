import { LightningElement, track, wire, api } from 'lwc';
import getDatos from '@salesforce/apex/ct_CustomAsset.getCuentaInfo';
import getImagen from '@salesforce/apex/ct_CustomAsset.getImagen';
import NumPlaca from "@salesforce/resourceUrl/NumPlaca";
import getProximaVisita from "@salesforce/apex/ct_CustomAsset.getProximaVisita";
export default class CustomAssetSection_lwc extends LightningElement {

    numPlaca = NumPlaca;

    @api recordId;
    @track placa
    @track numeroDeChasis;
    @track marca;
    @track modalodeloNvo;
    @track anio;
    @track color;
    @track tipoVehiculo
    @track kilometros;
    @track nombreContacto;
    @track cedContacto;
    @track tipoCedContacto;
    @track correoContacto;
    @track telContacto;
    @track empresa;
    @track noContieneImagen = true;

    @track mostrarHoras = false

    @track imagenCoche;
    @track imagenDefault;
    @track proxVisita = 'No tiene una visita programada'; 

    connectedCallback(){
        getImagen({ recordId: this.recordId})
      .then(result => {
        // handle success, maybe show a success message              
        console.log('Imagen del coche: ' + result);
        if(result){
            this.noContieneImagen = false;
            this.imagenCoche = 'https://redmotors.file.force.com/servlet/servlet.ImageServer?id='+result + '&oid=00D0P000000Dvkz';

        }
      })
      .catch(error => {
          // handle error
          console.error('Error updating record', error);
      });
    }
    @wire(getDatos, { recordId: '$recordId' })
    getAccountSetting({ error, data }) {
        if (data) {
            // console.log('======================data======================');
            // console.log(data);
            this.placa = data[0].Name;
            this.numeroDeChasis = data[0].NumeroDeChasis__c;
            this.marca = data[0].Marca_Nvo__c;
            this.modalodeloNvo = data[0].Modelo_Nvo2__c;
            this.anio = data[0].Anio__c;
            this.color = data[0].Color__c;
            this.tipoVehiculo = data[0].Tipo_de_veh_culo__c

            if (this.tipoVehiculo == 'Automovil') {
                this.imagenDefault = 'https://images.vexels.com/media/users/3/154251/isolated/preview/fef0c563c39f2746c35604e969ffe3ef-bmw-car-front-view-silhouette.png?width=1130'
            } else if (this.tipoVehiculo == 'Motocicleta') {
                this.imagenDefault = 'https://images.vexels.com/media/users/3/177844/isolated/preview/f290c1364a5561d4258d88bd8746a330-silueta-detallada-de-moto-moto.png'
            } else if (this.tipoVehiculo == 'Mula') {
                this.imagenDefault = 'https://images.vexels.com/media/users/3/210406/isolated/preview/fc5411dda9fca811b09bbd9ad1954a24-silueta-de-buggy-al-aire-libre.png'
            } else if (this.tipoVehiculo == 'Cuadraciclo') {
                this.imagenDefault = 'https://images.vexels.com/media/users/3/259472/isolated/lists/6257c6869e78b624c462151ff6e3a26e-silueta-detallada-de-atv.png'
            } else {
                this.imagenDefault = 'https://images.vexels.com/media/users/3/154251/isolated/preview/fef0c563c39f2746c35604e969ffe3ef-bmw-car-front-view-silhouette.png?width=1130'
            }
            // console.log('Tipo de vehiculo',this.tipoVehiculo, typeof(this.tipoVehiculo));
            this.ultKilometraje = data[0].Kilometros__c;
            console.log(this.ultKilometraje)
            if(this.ultKilometraje != null && this.ultKilometraje != undefined && this.ultKilometraje != ''){
                this.formatedKilometraje = this.ultKilometraje.toLocaleString()
            }else{
                this.formatedKilometraje = '0'
            }
            

            if(data[0].ContactId != null && data[0].ContactId != undefined){
                this.nombreContacto = data[0].Contact.Name;
                this.cedContacto = data[0].Contact.Cedula__c;
                this.tipoCedContacto = data[0].Contact.Tipo_de_Documento__c;
                this.correoContacto = data[0].Contact.Correo_Electronico__c;
                this.telContacto = data[0].Contact.Phone;
                this.empresa = data[0].Contact.Empresa__c;
            }

            if(data[0].Tipo_de_veh_culo__c == "Mula" || data[0].Tipo_de_veh_culo__c == "Cuadraciclo") {
                this.mostrarHoras = true
                // console.log('Horas', this.mostrarHoras);
            } else {
                // console.log('Horas', this.mostrarHoras);
            }
            

        } else if (error) {
            console.log(error);
        }
    }

    @wire(getProximaVisita, { recordId: '$recordId' })
    getEventSetting({ error, data }) {
        if (data) {
            // console.log('======================data Event======================');
            // console.log(data);
            if(data[0] != undefined && data[0] != null && data[0] != ''){
                this.proxVisita = data[0].StartDateTimeF__c;
            }                    
        } else if (error) {
            console.log(error);
        }
    }
}