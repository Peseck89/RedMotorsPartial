({
    renderCases: function (component, cases) {
        // Find the timeline element to append the case items
        var timeline = document.querySelector('.timeline');
        if (!timeline) {
            console.error("Timeline container not found");
            return;
        }

        // Clear previous content
        timeline.innerHTML = ''; 

        // Sort cases by CreatedDate in ascending order (oldest to newest)
        // cases.sort(function(a, b) {
        //     return new Date(a.CreatedDate) - new Date(b.CreatedDate);
        // });

        cases.sort(function(a, b) {
            return new Date(b.CreatedDate) - new Date(a.CreatedDate);
        });

        cases.forEach(function (caseData, index) {
            var caseId = caseData.CaseId;
            var caseNumb = caseData.CaseNumber;
            var placa = caseData.Placa;
            var woId = caseData.WorkOrderNumber;
            var createdDate = new Date(caseData.CreatedDate).toLocaleDateString('es-ES'); // Formato DD/MM/YYYY
            var kilometraje = caseData.Kilometraje || '000'; // Default if Kilometraje is not provided
            var territorio = caseData.Territorio || 'Escazú-Mecanica Rapida'; // Default if Territorio is not provided
            var asesor = caseData.Asesor || 'Nombre Apellido'; // Default if Asesor is not provided

            var alignmentClass = (index % 2 === 0) ? 'left' : 'right'; // Alternate left and right alignment

            var timelineItem = document.createElement('div');
            timelineItem.className = `container-timeline ${alignmentClass}`;
            timelineItem.innerHTML = `
                <div class="content">
                    <h2>Caso: ${caseNumb}</h2>
                    <p><strong>Placa: </strong> ${placa}</p>
                    <p><strong>Fecha: </strong> ${createdDate}</p>
                    <p><strong>Servicio: </strong> ${territorio}</p>
                    <button style="margin-top:20px"  class="btn-c btn-primary-c">Ver más</button>
                </div>
            `;

            // Get reference to the button
            var button = timelineItem.querySelector('.btn-c.btn-primary-c');

            // Assign the onclick event to redirect to the URL based on CaseId
            button.onclick = function() {
                window.open(`/apex/AssetWorkHistoryCommunity?caseId=${caseId}`, '_blank');
                // window.location.href = `/apex/AssetWorkHistoryCommunity?caseId=${caseId}`;

            };

            timeline.appendChild(timelineItem);
        });

    }
})