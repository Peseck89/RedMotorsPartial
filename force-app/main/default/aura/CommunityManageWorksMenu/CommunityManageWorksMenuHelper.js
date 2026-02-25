({
    renderCases: function (component, cases) {
        var cardGrid = component.find("cardGrid").getElement();
        cardGrid.innerHTML = ''; // Limpiar contenido previo

        cases.forEach(function (caseData) {
            var caseId = caseData.CaseId;
            var woId = caseData.WorkOrderNumber;
            var createdDate = new Date(caseData.CreatedDate).toLocaleDateString('es-ES'); // Formato DD/MM/YYYY
            var totalPrice = caseData.TotalPrice;
            var totalPriceIva = totalPrice * 1.13;
            var totalPriceFixed = totalPriceIva.toFixed(2);
            var placa = caseData.Placa;
            var marca = component.get('v.marcaSelected')

            var caseCard = document.createElement('div');
            caseCard.className = 'card-c';
            caseCard.innerHTML = `
                <div class="card-header-c">
                    <h2 class="card-title-c">OT ${woId}</h2>
                    <p class="card-description-c"><strong>Fecha: </strong>${createdDate}</p>
                    <p class="card-description-c"><strong>Monto: </strong>$${totalPriceFixed}</p>
                </div>
                <div class="card-content-c">
                    <span class="badge-c">Placa: ${placa}</span>
                </div>
                <div class="card-footer-c">
                    <button class="btn-c btn-primary-c">Ver más</button>
                </div>
            `;
            
            // Obtener referencia al botón
            var button = caseCard.querySelector('.btn-c.btn-primary-c');
            
            // Asignar el evento onclick para redirigir a la URL basada en CaseId
            button.onclick = function() {
                    window.location.href = `/s/communitymanageworks?id=${caseId}?marca=${marca}`;

            };

            cardGrid.appendChild(caseCard);
        });
    },

    renderQuotes: function (component, quotes) {
    var cardGrid = component.find("cardGrid").getElement();
    
    // No limpiar el contenido para mantener los casos ya renderizados

    quotes.forEach(function (quoteData) {
        var quoteId = quoteData.QuoteId;
        var quoteNumber = quoteData.QuoteNumber;
        var createdDate = new Date(quoteData.CreatedDate).toLocaleDateString('es-ES');
        var grandTotal = quoteData.GrandTotal.toFixed(2);
        var placa = quoteData.Placa;
        var marca = component.get('v.marcaSelected');

        var quoteCard = document.createElement('div');
        quoteCard.className = 'card-c';
        quoteCard.innerHTML = `
            <div class="card-header-c">
                <h2 class="card-title-c">Quote ${quoteNumber}</h2>
                <p class="card-description-c"><strong>Fecha: </strong>${createdDate}</p>
                <p class="card-description-c"><strong>Monto: </strong>$${grandTotal}</p>
            </div>
            <div class="card-content-c">
                <span class="badge-c">Placa: ${placa}</span>
            </div>
            <div class="card-footer-c">
                <button class="btn-c btn-primary-c">Ver más</button>
            </div>
        `;
        
        // Obtener referencia al botón
        var button = quoteCard.querySelector('.btn-c.btn-primary-c');
        
        // Asignar el evento onclick para redirigir a la URL basada en QuoteId
        button.onclick = function() {
            window.location.href = `/s/quotemanageworks?quoteId=${quoteId}&marca=${marca}`;
            // window.location.href = `/s/communitymanageworks?recordId=${quoteId}&recordType=Quote&marca=${marca}`;
        };

        cardGrid.appendChild(quoteCard);
    });
}
})