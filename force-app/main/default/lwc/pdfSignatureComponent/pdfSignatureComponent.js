import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import pdfjsLib from '@salesforce/resourceUrl/pdfjs';
import signaturePad from '@salesforce/resourceUrl/signaturepad';
import saveSignature from '@salesforce/apex/PdfSignatureClass.SaveSignature';
import generatePDF from '@salesforce/apex/PdfSignatureClass.GeneratePDF';
import sendSignedPDFEmail from '@salesforce/apex/PdfSignatureClass.sendSignedPDFEmail';
import getContactInfo from '@salesforce/apex/PdfSignatureClass.getContactInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class PdfSignatureComponent extends NavigationMixin(LightningElement) {
    @api recId;
    @track imageUrl='';
    @api tipoImagen;
    //@api visualforcePDF;
    @api visualforceFirmado;
    @api fromButton;
    @track nombreFirma = '';
    @track isSaveButtonDisabled = true;
    @track isClearButtonDisabled = true;
    @api pdfUrl;
    @api showModal = false;
    signaturePadInstance;
    signaturePadLoaded = false;
    @track isLoading = false;
    @api contactName;
    @api contactEmail;

    @track images = [];
    _visualforcePDF;
    @api 
    get visualforcePDF() {
        return this._visualforcePDF;
    }
    set visualforcePDF(value) {
        this._visualforcePDF = value;
        this.updatePdfUrl();
    }

    updatePdfUrl() {
        if (this.visualforcePDF && this.recId) {
            this.pdfUrl = window.location.origin + `/apex/${this.visualforcePDF}?Id=${this.recId}`;
        }
    }

    connectedCallback() {
        this.updatePdfUrl();
        getContactInfo({ caseId: this.recId })
        .then(data => {
            this.contactName = data.name;
            this.contactEmail = data.email;
        })
        .catch(error => {
            console.error('Error al obtener info del contacto:', error);
        });
    }
    renderedCallback() {
        if (this.signaturePadLoaded) return;
        this.signaturePadLoaded = true;
        this.loadSignaturePad();
       
    }

    async loadSignaturePad() {
        try {
            await Promise.all([
                loadScript(this, pdfjsLib + '/pdfjs/pdf.min.js'),
                loadScript(this, signaturePad + '/signaturepad/signaturepad.min.js')
            ]);

            if (!window.SignaturePad) {
                throw new Error('SignaturePad no está definido después de la carga.');
            }

            const canvas = this.template.querySelector('canvas');
            if (canvas) {
                canvas.width = canvas.offsetWidth;
                canvas.height = canvas.offsetHeight;
                this.signaturePadInstance = new window.SignaturePad(canvas, {
                    backgroundColor: 'rgba(255, 255, 255, 0)',
                    penColor: 'blue'
                });

                // Escuchar cambios en el canvas (firma)
                this.signaturePadInstance.addEventListener('endStroke', () => {
                    this.updateButtonStates();
                });
            } 
        } catch (error) {
            console.error('Error al cargar los scripts:', error);
        }
    }

    handleClearSignature() {
        this.signaturePadInstance.clear();
        this.updateButtonStates(); 
    }

    handleNombreChange(event) {
        this.nombreFirma = event.target.value;
        this.isSaveButtonDisabled = !(!this.signaturePadInstance.isEmpty() && this.nombreFirma != '');

    }
    handleSaveSignature() {
        this.isLoading = true;
        this.isSaveButtonDisabled = true;
        this.isClearButtonDisabled = true;
        if (!this.signaturePadInstance || this.signaturePadInstance.isEmpty()) {
            this.showToast('Error', 'La firma está vacía.', 'error');
            this.isLoading = false;
            return;
        }
        const signatureData = this.signaturePadInstance.toDataURL('image/png').split(',')[1]; // Obtener solo Base64
        saveSignature({
            nombre: this.nombreFirma,
            recordId: this.recId,
            visualforce: this.visualforcePDF,
            signatureBase64: signatureData
        })
        .then((firmaId) => {
            this.showToast('Éxito', 'Firma guardada correctamente.', 'success');
            this.signaturePadInstance.clear();
            this.updateButtonStates();
    
            // Paso 2: Generar el PDF después de guardar la firma
            return generatePDF({
                recordId: this.recId,
                fromButton: this.fromButton,
                visualforceFirmado: this.visualforceFirmado
            });
        })
        .then((contentDocumentId) => {
            this.contentDocumentId = contentDocumentId;
            this.showModal = true;
            //this.handleConfirmEmailSend();
        })
        .catch(error => {
            this.isLoading = false;
            this.showToast('Error', 'No se pudo completar la operación. ' + error, 'error');
        })
        .finally(() => {
            //this.isLoading = false; // Desactivar el spinner cuando termine la operación
        });
    }
    handleOpenOrdenDeTrabajoFirmada(){
        if (this.visualforceFirmado && this.recId) {
                const isMobileApp = /SalesforceMobile/i.test(navigator.userAgent);
                setTimeout(() => {
                    const fileUrl = `/lightning/r/ContentDocument/${this.contentDocumentId}/view`;
        
                    if (isMobileApp) {
                        this.showToast('Éxito', 'Archivo generado correctamente, puedes verlo ingresando a la sección de Archivos.', 'success');
                        this.isLoading = false;
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                            recordId: this.recId,
                            objectApiName: 'Case',
                            actionName: 'view'
                            }
                        });
        
                    } else {
                        this.isLoading = false;
                        window.open(fileUrl, '_self');
                    }
                }, 4000); 
        }
    }
    handlecloseModal(){
        this.showModal = false;
        this.handleOpenOrdenDeTrabajoFirmada();
    }
    handleConfirmEmailSend() {
        this.isLoading = true;
        sendSignedPDFEmail({ recordId: this.recId, contentDocumentId: this.contentDocumentId })
            .then(() => {
                this.showToast('Éxito', 'La orden fue enviada por correo.', 'success');
                this.showModal = false;
                this.handleOpenOrdenDeTrabajoFirmada();
            })
            .catch(error => {
                this.showToast('Error', 'No se pudo enviar el correo. ' + error.body.message, 'error');
            })
            .finally(() => this.isLoading = false);
    }
    updateButtonStates() {
        this.isClearButtonDisabled = this.signaturePadInstance.isEmpty();
        this.isSaveButtonDisabled = !(!this.signaturePadInstance.isEmpty() && this.nombreFirma != '');
    }
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}