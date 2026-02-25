import { LightningElement, api, track, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import signaturePad from '@salesforce/resourceUrl/signaturepad';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveDibujo from '@salesforce/apex/PdfSignatureClass.SaveDibujo';
import getTipoImagen from '@salesforce/apex/PdfSignatureClass.getImageFromAsset';
import DiagramaAuto from '@salesforce/resourceUrl/DiagramaAuto';
import DiagramaMoto	 from '@salesforce/resourceUrl/DiagramaMoto';
import DiagramaCuadra from '@salesforce/resourceUrl/DiagramaCuadra';
import DiagramaMule from '@salesforce/resourceUrl/DiagramaMule';
export default class DibujarVehiculoComponent extends NavigationMixin(LightningElement) {
    @api recId;
    @track imageUrl='';
    @api tipoImagen;
    @track isSaveButtonDisabled = true;
    @track isClearButtonDisabled = true;
    signaturePadInstance;
    signaturePadLoaded = false;
    @track isLoading = false;
    @track images = [];
    @track strokeHistory = [];
    imageMap = {
        'Auto': DiagramaAuto,
        'Moto': DiagramaMoto,
        'Cuadra': DiagramaCuadra,
        'Mula': DiagramaMule
    };

    @wire(getTipoImagen, { caseId: '$recId' })
    wiredTipoImagen({ error, data }) {
        if (data) {
            this.handleTipoImagen(data);
        } else if (error) {
            console.error('Error obteniendo tipo de imagen:', error);
        }
    }

    handleTipoImagen(tipoImagen) {
        if (!tipoImagen) return;
        this.tipoImagen = tipoImagen;
        const normalizedKey = String(tipoImagen).trim();
        const matchedKey = Object.keys(this.imageMap).find(
            key => key.localeCompare(normalizedKey, undefined, { sensitivity: 'base' }) === 0
        );
        if (matchedKey) {
            const resourcePath = this.imageMap[matchedKey];
            const timestamp = Date.now();
            this.imageUrl = this.imageMap[tipoImagen];
            this.loadDrawingPad();
        } else {
            console.warn('No se encontró imagen para:', tipoImagen);
        }
    }

    async loadDrawingPad() {
        if (this.signaturePadLoaded) {
            return;
        }
        this.signaturePadLoaded = true;
        try {
            await loadScript(this, signaturePad + '/signaturepad/signaturepad.min.js');

            const canvas = this.template.querySelector('.vehicle-drawing-pad');
            if (canvas) {
                const container = this.template.querySelector('.vehicle-drawing-container');
                canvas.width = container.clientWidth;
                canvas.height = container.clientHeight;
                const ctx = canvas.getContext('2d');
                this.backgroundImage = new Image();
                this.backgroundImage.src = this.imageUrl;
                this.backgroundImage.onload = () => {
                    ctx.drawImage(this.backgroundImage, 0, 0, canvas.width, canvas.height);
                };
                this.signaturePadInstance = new window.SignaturePad(canvas, {
                    backgroundColor: 'rgba(0, 0, 0, 0)', 
                    penColor: 'red'
                });
                this.signaturePadInstance.addEventListener('endStroke', () => {
                    const data = this.signaturePadInstance.toData();
                    if (data.length > 0) {
                        this.strokeHistory = data;
                        this.isSaveButtonDisabled = false;
                        this.isClearButtonDisabled = false;
                    }
                });
            }
        } catch (error) {
            console.error('Error al cargar SignaturePad Vehicle:', error);
        }
    }

    loadImage(url) {
        return new Promise((resolve, reject) => {
            const img = new Image();
            img.crossOrigin = 'Anonymous'; 
            img.src = `${url}?t=${Date.now()}`;
            img.onload = () => resolve(img);
            img.onerror = reject;
        });
    }

    handleUndo() {
        if (this.strokeHistory.length === 0 || !this.backgroundImage) return;
        this.strokeHistory.pop(); 
        const canvas = this.template.querySelector('.vehicle-drawing-pad');
        const ctx = canvas.getContext('2d');
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.drawImage(this.backgroundImage, 0, 0, canvas.width, canvas.height);
        ctx.strokeStyle = 'red';
        ctx.lineWidth = 3;
        ctx.lineCap = 'round';
        ctx.lineJoin = 'round';
        for (const stroke of this.strokeHistory) {
            ctx.beginPath();
            for (let i = 0; i < stroke.points.length; i++) {
                const point = stroke.points[i];
                if (i === 0) {
                    ctx.moveTo(point.x, point.y);
                } else {
                    ctx.lineTo(point.x, point.y);
                }
            }
            ctx.stroke();
        }
        this.signaturePadInstance._data = JSON.parse(JSON.stringify(this.strokeHistory));
        if (this.strokeHistory.length === 0) {
            this.isClearButtonDisabled = true;
            this.isSaveButtonDisabled = true;
        }
    }


    handleClearDrawing() {
        if (this.signaturePadInstance) {
            const canvas = this.template.querySelector('.vehicle-drawing-pad');
            const ctx = canvas.getContext('2d');
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            const backgroundImage = new Image();
            backgroundImage.src = this.imageUrl;
            backgroundImage.onload = () => {
                ctx.drawImage(backgroundImage, 0, 0, canvas.width, canvas.height);
            };
            this.isClearButtonDisabled = true;
            this.isSaveButtonDisabled = true;
            this.strokeHistory = [];
            this.signaturePadInstance.clear();
        }
    }
    handleSaveDrawing() {
        this.isLoading = true;
        this.isSaveButtonDisabled = true;
        this.isClearButtonDisabled = true;
        if (!this.signaturePadInstance || this.signaturePadInstance.isEmpty()) {
            this.showToast('Error', 'El dibujo del vehículo está vacío.', 'error');
            this.isLoading = false;
            return;
        }
        const signatureData = this.signaturePadInstance.toDataURL('image/png').split(',')[1];
        saveDibujo({
            recordId: this.recId,
            dibujoBase64: signatureData,
            tipoVehiculo: this.tipoImagen
        })
        .then((dibujoId) => {
            this.showToast('Éxito', 'Dibujo de vehículo guardado correctamente.', 'success');
            this.signaturePadInstance.clear();
            const closeEvent = new CustomEvent('close');
            this.dispatchEvent(closeEvent);   
        })
        .catch(error => {
            this.showToast('Error', 'No se pudo completar la operación. ' + error, 'error');
        })
        .finally(() => {
            this.isLoading = false; 
        });
    }
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}