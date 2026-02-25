/**
 * Controller for RedMotors_OrderProgress component
 * Manages order progress data and job details
 * 
 * Current implementation uses hardcoded sample data for demonstration.
 * Future enhancement: Replace loadSampleData() with loadFromOrder(Id orderId)
 * to fetch real data from Work_Order__c and related objects.
 */
public with sharing class RedMotors_OrderProgressCtrl {
    
    // Public properties exposed to the component
    public String orderNumber { get; set; }
    public Id orderId { get; set; }
    public Integer totalJobs { get; set; }
    public Integer completedJobs { get; set; }
    public List<JobViewModel> jobs { get; set; }
    public Integer globalProgress { get; set; }
    
    /**
     * Constructor - initializes the controller with sample data
     */
    public RedMotors_OrderProgressCtrl() {
        loadSampleData();
    }
    
    /**
     * Loads hardcoded sample data for demonstration purposes
     */
    private void loadSampleData() {
        // Initialize the jobs list
        jobs = new List<JobViewModel>();
        
        // Job 1: Cambio de aceite - En curso
        JobViewModel job1 = new JobViewModel();
        job1.jobName = 'Cambio de aceite';
        job1.mechanicName = 'Juan Mora';
        job1.status = 'En curso';
        job1.progress = 70;
        job1.elapsedMinutes = 45;
        job1.totalMinutes = 60;
        job1.notes = '';
        jobs.add(job1);
        
        // Job 2: Lavado exterior - Finalizado
        JobViewModel job2 = new JobViewModel();
        job2.jobName = 'Lavado exterior';
        job2.mechanicName = 'Luis Rojas';
        job2.status = 'Finalizado';
        job2.progress = 100;
        job2.elapsedMinutes = 30;
        job2.totalMinutes = 30;
        job2.notes = 'Foto cargada';
        jobs.add(job2);
        
        // Job 3: Alineación - Pendiente
        JobViewModel job3 = new JobViewModel();
        job3.jobName = 'Alineación';
        job3.mechanicName = 'Andrés Jiménez';
        job3.status = 'Pendiente';
        job3.progress = 0;
        job3.elapsedMinutes = 0;
        job3.totalMinutes = 0;
        job3.notes = 'Esperando elevador';
        jobs.add(job3);
        
        // Job 4: Diagnóstico eléctrico - Pausado
        JobViewModel job4 = new JobViewModel();
        job4.jobName = 'Diagnóstico eléctrico';
        job4.mechanicName = 'Pedro Vargas';
        job4.status = 'Pausado';
        job4.progress = 50;
        job4.elapsedMinutes = 40;
        job4.totalMinutes = 80;
        job4.notes = 'W3 - carga de taller';
        jobs.add(job4);
        
        // Job 5: Lavado interior - Rechazado
        JobViewModel job5 = new JobViewModel();
        job5.jobName = 'Lavado interior';
        job5.mechanicName = 'Luis Rojas';
        job5.status = 'Rechazado';
        job5.progress = 0;
        job5.elapsedMinutes = 0;
        job5.totalMinutes = 0;
        job5.notes = 'Cliente no lo aprobó';
        jobs.add(job5);
        
        // Calculate totals
        totalJobs = jobs.size();
        completedJobs = 0;
        Double totalProgressSum = 0;
        
        for (JobViewModel job : jobs) {
            if (job.status == 'Finalizado') {
                completedJobs++;
            }
            totalProgressSum += job.progress;
        }
        
        // Calculate global progress average
        if (totalJobs > 0) {
            globalProgress = (Integer)(totalProgressSum / totalJobs);
        } else {
            globalProgress = 0;
        }
        
        // Set sample order number
        orderNumber = 'ORD-12345';
    }
    
    /**
     * Inner class representing a job for display in the component
     * This ViewModel pattern separates display logic from data model
     * 
     * Note: Properties must be public for Visualforce access
     * Using camelCase for Visualforce compatibility
     */
    public class JobViewModel {
        public String jobName { get; set; }
        public String mechanicName { get; set; }
        public String status { get; set; }
        public Integer progress { get; set; }
        public Integer elapsedMinutes { get; set; }
        public Integer totalMinutes { get; set; }
        public String notes { get; set; }
        
        public JobViewModel() {
            this.jobName = '';
            this.mechanicName = '';
            this.status = '';
            this.progress = 0;
            this.elapsedMinutes = 0;
            this.totalMinutes = 0;
            this.notes = '';
        }
    }
}