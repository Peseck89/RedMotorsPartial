/**
	@Autor: David Leon Sanchez
	@Fecha creacion: 17/08/2017 
	@Proyecto: Altica
	@Proposito: TriggerHandler para el Objeto Task

**/

public class TaskTriggerHandler extends TriggerHandler {
	private Map<Id, Task> newTaskMap;
	private List<Task> ListNewTask;
	
	private Map<Id, Task> MapOldTask;
	private List<Task> ListOldTask;
	
	public TaskTriggerHandler(){
		this.newTaskMap = (Map<Id, Task>) Trigger.newMap;
		this.ListNewTask = (List<Task>) Trigger.New;
		this.ListOldTask = (List<Task>) Trigger.Old;
		this.MapOldTask = (Map<Id, Task>) Trigger.oldMap;	
	}

	/*
		Metodo donde se si el Status = Completed, obtiene el ID del objeto al que este ligada la Tarea y 
		lo guarda en una lista para luego enviarla por parametro al metodo TaskService.updateField();
	*/
	public override void afterUpdate(){

 		ejecutarConfirmacionLectura(ListNewTask, MapOldTask);

		System.debug('********************** Entro afterUpdate ********************** ');
		Set<Id> idsOp = new Set<Id>();
		String id;

		for(Task t : ListNewTask){
			System.debug('************************* tarea ************************** ' + t);
			if(t.Status.equals('Completed') && t.WhatId != null){
				id = (String)t.WhatId;
				idsOp.add(id.substring(0,15)); //Se toman los primeros 15 car�cteres del id para que luego no de problemas el select del m�todo update Fiel de Task Service
			}			
		}
		System.debug('************************** Ids Tarea.Op *********************** ' + idsOp);
		if(!idsOp.isEmpty() && idsOp.size() > 0){
			TaskService.updateField(idsOp);
		}
	}

	private void ejecutarConfirmacionLectura(List<Task> newList, Map<Id, Task> oldMap){
		// Evita recursividad cuando el Schedule modifica el campo
		if(Trigger.isAfter && Trigger.isUpdate){
			for(Task t : newList){
				if(t.Confirmacion_de_lectura__c == false && oldMap.get(t.Id)?.Confirmacion_de_lectura__c == true){
					System.debug('⛔ Evitando recursividad: se revirtió estado desde el Schedule');
					return;
				}
			}
		}

		Set<Id> tareasParaReverso = new Set<Id>();

		for(Task t : newList){
			
			Boolean oldValue = oldMap?.get(t.Id)?.Confirmacion_de_lectura__c;
			Boolean newValue = t.Confirmacion_de_lectura__c;

			if(newValue == true && oldValue != true){
        
				// 🔥 NUEVO -> validar que WhatId sea un SObject válido
				if(t.WhatId != null){
					try{
						t.WhatId.getSObjectType(); // si truena, cae al catch
					} catch (Exception e){
						System.debug('⚠ WhatId NO SOPORTADO → ' + t.WhatId);
						continue; // evita que el trigger truene
					}
				}

				tareasParaReverso.add(t.Id);
			}
		}

		if(!tareasParaReverso.isEmpty()){
			Configuracion_Bloqueo__mdt conf = Configuracion_Bloqueo__mdt.getInstance('Default');
			if(conf == null){
				System.debug('⛔ Metadata no accesible en este contexto → salida segura');
				return; // evita que el trigger truene
			}


			Boolean activo = conf.Repetir__c;
			Integer minutos = Integer.valueOf(conf.Tiempo_Minutos__c);
			// Programar job diferido
			String cron = generarCron(minutos);

			if(activo){
				System.schedule(
					'Revert_Confirmacion_'+DateTime.now().getTime(),
					cron,
					new RevertirLecturaTask(tareasParaReverso)
				);
			}
			
		}
	}

	private String generarCron(Integer minutos){
		Datetime runTime = Datetime.now().addMinutes(minutos);
		return String.format(
			'{0} {1} {2} {3} {4} ? {5}',
			new List<String>{
				String.valueOf(runTime.second()),
				String.valueOf(runTime.minute()),
				String.valueOf(runTime.hour()),
				String.valueOf(runTime.day()),
				String.valueOf(runTime.month()),
				String.valueOf(runTime.year())
			}
		);
	}

	/*
		Metodo donde se si el Status = Completed y se guarda directamente en el historial de actividades, obtiene el ID del objeto al que este ligada la Tarea y 
	  	lo guarda en una lista para luego enviarla por parametro al metodo TaskService.updateField();
	*/
	public override void afterInsert(){
	System.debug('********************** Entro afterInsert ********************** ');
		Set<Id> idsOp = new Set<Id>();
		String id;

		for(Task t : ListNewTask){
			System.debug('****************************** tarea nueva *********************** ' + t);
			if(t.Status.equals('Completed') && t.whatId != null){
				System.debug('******************* whatId ****************' + t.whatId);
				id = (String)t.WhatId;
				System.debug('******************* id entero ****************' + id);
				idsOp.add(id.substring(0,15));
				System.debug('********************* id ******************** ' + id.substring(0,15));
			}
		}
		System.debug('*************************** Ids Tarea.Op nuevas ************************** ' + idsOp);
		if(!idsOp.isEmpty() && idsOp.size() > 0){
			TaskService.updateField(idsOp);
		}
	}
}