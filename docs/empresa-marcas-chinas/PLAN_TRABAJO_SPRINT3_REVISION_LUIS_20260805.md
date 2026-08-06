# Plan de trabajo propuesto — Sprint 3

## 1. Objetivo

Se revisó la versión actualizada del alcance para separar correctamente el trabajo de Sprint 3 de los pendientes que continúan en Sprint 1 y Sprint 2. El objetivo de esta propuesta es confirmar primero qué componentes forman parte real de Sprint 3 y evitar iniciar cambios con cantidades aproximadas o supuestos funcionales.

## 2. Alcance identificado para Sprint 3

La tabla del alcance asigna expresamente a Sprint 3 estos tres frentes:

- Layouts, FlexiPages y Quick Actions.
- Validation Rules, Approval Processes y roles nuevos.
- Custom Metadata y configuración Softland.

Las cantidades indicadas en el documento son aproximadas. Por eso, el primer trabajo será validar el inventario exacto: qué componentes existen, cuáles están activos, cuáles ya contienen trabajo previo y cuáles realmente necesitan atención para PEKING.

## 3. Temas pendientes de asignación

El documento también incluye los siguientes temas con estimación, pero sin un Sprint asignado:

- List Views.
- Global Value Sets.
- Creación y carga de Pricebooks y PricebookEntry.
- Pruebas E2E y regresión.

Estos temas se mantendrán separados hasta confirmar si deben incorporarse a Sprint 3 o gestionarse en otro frente. Su importancia para el cierre general no se interpreta como autorización para ejecutarlos dentro de Sprint 3.

## 4. Primer paso propuesto

Propongo comenzar con S3-0, una revisión de lectura que permita:

- revisar qué componentes existen realmente;
- comparar la metadata versionada con la disponible en Partial;
- identificar cuáles están activos;
- confirmar cuáles aplican a PEKING;
- excluir los procesos exclusivos de vehículos usados;
- detectar dependencias y decisiones pendientes;
- reunir evidencia sin modificar Salesforce.

Esta revisión no crea, modifica, activa ni despliega componentes. Tampoco utiliza datos o definiciones comerciales no confirmadas.

## 5. Resultado esperado

Al terminar S3-0 se entregará:

- la lista nominal de componentes;
- el estado real de cada componente;
- los elementos que requieren cambios;
- los bloqueos técnicos o funcionales;
- la evidencia disponible y la que falta;
- una propuesta del primer lote funcional para aprobación.

La lista nominal permitirá evitar que un grupo se considere cerrado solo porque uno de sus elementos tenga evidencia.

## 6. Decisiones solicitadas

Para continuar, solicito confirmar:

1. Si está de acuerdo con que Sprint 3 contiene los tres bloques identificados: interfaz declarativa; reglas, aprobaciones y roles; y configuración Softland.
2. Dónde deben quedar los cuatro bloques sin Sprint escrito: List Views, Global Value Sets, Pricebooks/PricebookEntry y pruebas E2E/regresión.
3. Si autoriza comenzar S3-0 como análisis exclusivamente de lectura.
4. Si desea revisar nuevamente el primer lote funcional antes de autorizar su implementación.

También se mantendrán fuera del alcance automático los ajustes amplios de Profiles y Permission Sets, salvo que se autoricen expresamente o aparezca una dependencia mínima de acceso que deba evaluarse.

## 7. Estado de otros Sprints

Sprint 2 continúa pausado por cinco Flows pendientes de definiciones de negocio. Sprint 1 conserva validaciones pendientes sobre su propio alcance. Ningún pendiente anterior será absorbido silenciosamente por Sprint 3.

Los elementos adicionales identificados en el documento posterior de Red Motors tampoco entran automáticamente. Si alguno resulta necesario, se presentará de forma separada con su justificación, impacto y autorización requerida.
