# Auditoría de almacenamiento de la laptop — 2026-08-11

## Resultado ejecutivo

Auditoría exclusivamente de análisis y solo lectura. No se borró, movió, renombró, comprimió ni modificó ningún archivo existente; no se limpió la Papelera, no se alteró Windows y no se ejecutaron operaciones destructivas sobre repositorios.

| Indicador | Resultado |
|---|---:|
| Espacio local analizado | ≈ 7.75 GiB |
| Google Drive observado y protegido | 3.407 GiB usados en la unidad montada |
| Espacio total representado | ≈ 11.16 GiB |
| Archivos en carpetas locales principales | 108,741 |
| Espacio potencialmente recuperable seguro después de aprobación | ≈ 1.59 GiB |
| Espacio que requiere revisión | ≈ 2.42 GiB |
| Duplicados exactos locales de proyecto confirmados en Drive | 27 archivos / 893.975 MiB |
| Worktrees respaldados candidatos a retiro futuro | 18 / 738.1 MiB |
| Instaladores EXE/MSI encontrados en el alcance principal | 0 |
| Carpetas `node_modules` encontradas | 0 |

Los tamaños son aproximados y usan GiB/MiB binarios. Las rutas anidadas del ranking son inclusivas y, por tanto, no deben sumarse entre sí.

## Alcance y método

Se revisaron por metadatos `Documents`, `Downloads`, `Videos`, `Pictures`, repositorios, carpetas visibles de caché/herramientas, OneDrive y la unidad montada de Google Drive. La ruta local `Desktop` no existe; el Escritorio está redirigido a OneDrive. No se inspeccionó `AppData`, perfiles de navegador, credenciales, autenticación de Salesforce, SSH, certificados ni contenido personal irrelevante.

Las comprobaciones incluyeron tamaños, fechas, extensiones, SHA-256 en candidatos razonables, estructura central de ZIP, estado de repositorios, worktrees y verificación directa de ramas remotas. No se ejecutó `fetch`; la comparación remota fue de solo lectura el 2026-08-11.

## Inventario principal

| Ruta | Tamaño | Archivos | Observación |
|---|---:|---:|---|
| `C:\Users\dokur\Documents` | ≈ 2.91 GiB | 108,734 | Principal concentración local |
| `C:\Users\dokur\Downloads` | ≈ 1.8 MiB | 4 | Sin instaladores |
| `C:\Users\dokur\Pictures` | ≈ 0.02 MiB | 1 | Icono RedMotors único |
| `C:\Users\dokur\Videos` | ≈ 0 MiB | 2 | Sin archivos grandes |
| `C:\Users\dokur\Desktop` | No existe | — | Redirigido a OneDrive |
| `C:\Users\dokur\.vscode` | 2,712.70 MiB | 103,051 | Extensiones activas; no tocar |
| `C:\Users\dokur\.codex` | 1,126.53 MiB | 8,205 | Datos activos; no tocar salvo revisión específica |
| `C:\Users\dokur\.cache` | 1,050.18 MiB | 21,206 | Runtime reconstruible, pero requiere revisión de uso |
| `C:\Users\dokur\.claude` | 63.27 MiB | 622 | Datos de aplicación; no tocar |
| `G:\` | 3.407 GiB usados | — | Google Drive; `NO_TOCAR_DRIVE` |
| `C:\Users\dokur\OneDrive` | Presencia confirmada | 10 archivos locales visibles | Sincronizado; `NO_TOCAR` |

## Ranking de las 30 rutas de mayor consumo

| # | Ruta | Tamaño aprox. | Clasificación |
|---:|---|---:|---|
| 1 | `G:\` | 3.407 GiB usados | `NO_TOCAR_DRIVE` |
| 2 | `C:\Users\dokur\Documents` | 2.91 GiB | `REVISAR_MANUALMENTE` |
| 3 | `C:\Users\dokur\.vscode` | 2,712.70 MiB | `NO_TOCAR` |
| 4 | `C:\Users\dokur\.vscode\extensions` | 2,712.70 MiB | `NO_TOCAR` |
| 5 | `G:\Mi unidad\Proyecto VN-RQ106` | 1,246.20 MiB | `NO_TOCAR_DRIVE` |
| 6 | `C:\Users\dokur\.codex` | 1,126.53 MiB | `NO_TOCAR` |
| 7 | `C:\Users\dokur\Documents\Archivos perdidos (65660)` | ≈ 1.08 GiB | `REVISAR_MANUALMENTE` |
| 8 | `...\Archivos perdidos (65660)\Archivos RAW (3951)` | ≈ 1.08 GiB | `REVISAR_MANUALMENTE` |
| 9 | `C:\Users\dokur\.cache` | 1,050.18 MiB | `REVISAR_MANUALMENTE` |
| 10 | `C:\Users\dokur\.cache\codex-runtimes` | 1,050.18 MiB | `REVISAR_MANUALMENTE` |
| 11 | `...\Archivos RAW (3951)\ZIP file (55)` | 992.38 MiB | `REVISAR_MANUALMENTE` |
| 12 | `C:\Users\dokur\Documents\Repositorios` | ≈ 0.96 GiB | `CONSERVAR_ACTIVO` |
| 13 | `C:\Users\dokur\Documents\Evidencias\RedMotors` | 892.88 MiB | `CONSERVAR_RESPALDO` |
| 14 | `...\Evidencias\RedMotors\VN-RQ106` | 856.91 MiB | `CONSERVAR_RESPALDO` |
| 15 | `...\VN-RQ106\Evidencias para Drive` | 855.84 MiB | `CONSERVAR_RESPALDO` |
| 16 | `C:\Users\dokur\.codex\plugins` | 406.62 MiB | `NO_TOCAR` |
| 17 | `C:\Users\dokur\.codex\.sandbox-bin` | 357.44 MiB | `NO_TOCAR` |
| 18 | `C:\Users\dokur\.codex\.tmp` | 130.45 MiB | `REVISAR_MANUALMENTE` |
| 19 | `G:\Mi unidad\Marcas Chinas Sprint Agosto` | 121.13 MiB | `NO_TOCAR_DRIVE` |
| 20 | `C:\Users\dokur\.codex\sessions` | 118.34 MiB | `NO_TOCAR` |
| 21 | `...\Archivos RAW (3951)\JPEG Graphics file (1840)` | ≈ 112.64 MiB | `REVISAR_MANUALMENTE` |
| 22 | `...\Repositorios\RedMotorsPartial-Sandbox` | 91.5 MiB | `NO_TOCAR` |
| 23 | `C:\Users\dokur\.claude` | 63.27 MiB | `NO_TOCAR` |
| 24 | `...\Repositorios\RedMotors-Sprint2-Flows-Components` | 51.9 MiB | `CONSERVAR_ACTIVO` |
| 25 | `...\Repositorios\RedMotors-Empresa-Marcas-Chinas` | 44.1 MiB | `REVISAR_MANUALMENTE` |
| 26 | `...\Repositorios\RedMotors-Sprint1-Integracion` | 43.4 MiB | `BORRAR_SEGURO_DESPUES_DE_CONFIRMACION` |
| 27 | `...\Repositorios\RedMotors-Sprint1-Cierre-Luis-Definiciones` | 43.3 MiB | `BORRAR_SEGURO_DESPUES_DE_CONFIRMACION` |
| 28 | `...\Repositorios\RedMotors-Sprint1-Next8-Reconcile` | 43.2 MiB | `NO_TOCAR` |
| 29 | Varios worktrees RedMotors respaldados | ≈ 40.0–40.5 MiB cada uno | `BORRAR_SEGURO_DESPUES_DE_CONFIRMACION` |
| 30 | `...\Evidencias\RedMotors\Marcas Chinas\Sprint 3` | 35.97 MiB | `CONSERVAR_ACTIVO` |

## Archivos individuales más grandes

| Tamaño | Ruta resumida | Estado |
|---:|---|---|
| 512.00 MiB | `...\ZIP file (55)\Recovered_zip_file(15).zip` | ZIP inválido; revisión manual |
| 230.26 MiB | VN-RQ106, grabación con asesor, parte 1 | Duplicado exacto en Drive |
| 219.43 MiB | VN-RQ106, grabación con asesor, parte 2 | Duplicado exacto en Drive |
| 147.44 MiB | VN-RQ106, aprobación/rechazo/reenvío | Duplicado exacto en Drive |
| 76.59 MiB | VN-RQ106, registro de anticipo | Duplicado exacto en Drive |
| 48.29 MiB | VN-RQ106, QA de reserva rechazada | Duplicado exacto en Drive |
| 39.00 MiB | VN-RQ106, QA de reserva aprobada | Duplicado exacto en Drive |
| 36.09 MiB | `Recovered_zip_file(34).zip` | ZIP inválido; revisión manual |
| 33.88 MiB | VN-RQ106, corrección Organization parte 2 | Duplicado exacto en Drive |
| 30.21 MiB | `Recovered_zip_file(35).zip` | ZIP inválido; revisión manual |

No se encontraron archivos locales grandes con más de un año de antigüedad dentro de las carpetas principales.

## Tipos de archivo

| Categoría | Tamaño | Cantidad |
|---|---:|---:|
| ZIP/RAR/7z | 0.97 GiB | 45 |
| Videos | 0.87 GiB | 12 |
| PDF | 0.01 GiB | 25 |
| DOC/DOCX | 0.01 GiB | 27 |
| CSV/TSV | 0.01 GiB | 32 |
| Logs | < 0.01 GiB | 77 |
| Instaladores | 0 | 0 |
| Temporales por extensión | 0 | 0 |

## Duplicados exactos

### Confirmados contra Google Drive

- VN-RQ106: 24 archivos, 856.91 MiB, todos con SHA-256 idéntico entre `Documents` y `G:\Mi unidad\Proyecto VN-RQ106`.
- Marcas Chinas Sprint 3: 2 videos, 35.97 MiB, SHA-256 idéntico en Drive.
- `Downloads\Evidencia_Sprint2_Empresa_Pricebook_Corregido.docx`: 1.098 MiB, SHA-256 idéntico en Drive.
- Total local confirmado en Drive: 27 archivos y 893.975 MiB.

### Duplicados locales

Se detectaron 64 grupos exactos de al menos 100 KiB, con 459.987 MiB de copias adicionales. Casi todo corresponde a archivos repetidos por los worktrees RedMotors; este volumen no se suma al ahorro de worktrees para evitar doble conteo.

Otros casos:

- El PDF final de VN-RQ106 en Evidencias es exacto al PDF versionado en `docs/VN-RQ106/entrega-final` y también está en Drive.
- `Recovered_zip_file(16).zip` y `(27).zip` son exactos entre sí, pero ambos son ZIP inválidos; se mantienen en revisión manual.
- Ocho pares de JPG recuperados son duplicados exactos; se mantienen en revisión manual por pertenecer a una recuperación de archivos.
- Cuatro ZIP de auditoría son copias exactas, entrada por entrada, de sus carpetas homónimas; juntos ocupan ≈ 0.515 MiB.

## Posibles versiones anteriores

- En el repositorio activo existen series nominales `V2`, `V3` y `V4`; la vigencia debe resolverse con el índice maestro, no por fecha solamente.
- El contexto activo declara como sustituidos para ejecución los archivos preliminares de Sprint 3; deben conservarse solo por trazabilidad.
- Drive contiene cuatro versiones de `Template_QA_Equipo-Redmotors_VN-RQ106` y borradores/entregables de VN-RQ106. Se clasifican `NO_TOCAR_DRIVE`.
- OneDrive y Drive contienen copias de la evidencia de Sprint 1 con tamaños diferentes; son `POSIBLE_VERSION_ANTERIOR`, no duplicados exactos.
- Los reportes y matrices de auditoría Etapa 1/2/3 son históricos encadenados, no copias intercambiables.

## ZIP y recuperación de archivos

Los 41 archivos `Recovered_zip_file(...)` suman 992.38 MiB y ninguno tiene una estructura central ZIP legible. Esto indica archivos incompletos, fragmentos recuperados o extensiones incorrectas. No son `BORRAR_SEGURO`; requieren decisión humana sobre la recuperación original. El archivo de 512 MiB concentra más de la mitad del conjunto.

## Repositorios y worktrees

La estructura RedMotors consta de un repositorio común en `RedMotorsPartial-Sandbox` y 20 worktrees registrados. La rama activa de Empresa/Marcas Chinas está en `RedMotors-Sprint2-Flows-Components`, limpia y verificada directamente contra remoto. Al cierre de la auditoría, su HEAD era `0821eaef97`, fechado 2026-08-11.

| Grupo | Estado | Tamaño | Clasificación |
|---|---|---:|---|
| Worktree activo Empresa/Marcas Chinas | Limpio, HEAD exacto en remoto | 51.9 MiB | `CONSERVAR_ACTIVO` |
| 18 worktrees históricos | Limpios, cada HEAD exacto en remoto | 738.1 MiB | `BORRAR_SEGURO_DESPUES_DE_CONFIRMACION` |
| `RedMotors-Sprint1-Next8-Reconcile` | Un documento no rastreado | 43.2 MiB | `NO_TOCAR` |
| `RedMotorsPartial-Sandbox` | Archivo modificado y `stash` único | 91.5 MiB | `NO_TOCAR` |
| `RedMotors-Empresa-Marcas-Chinas` | Enlace Git roto a una ruta inexistente | 44.1 MiB | `REVISAR_MANUALMENTE` |
| `Altica-Produccion` | Modificación local en configuración del editor | 5.6 MiB | `NO_TOCAR` |
| `Altica-Sandbox` | Limpio y respaldado | 4.1 MiB | `CONSERVAR_ACTIVO` |

El worktree roto tiene 43 rutas ausentes en el activo (1.82 MiB), principalmente archivos `describe-*.json` y carpetas `tmp-partial`; otros 4,477 archivos difieren del activo por corresponder a una base antigua. No debe eliminarse sin revisión puntual.

## Estado de VN-RQ106

- La rama de VN-RQ106 tiene HEAD exacto en remoto y 13 entregables versionados bajo `docs/VN-RQ106`.
- La evidencia local de 856.91 MiB está íntegramente respaldada en Drive con hashes idénticos.
- El repositorio principal aloja la base Git común de todos los worktrees; no es eliminable como una carpeta independiente.
- Existe una modificación local en `force-app/main/default/lwc/jsconfig.json`.
- Existe un `stash` local no respaldado con cuatro commits internos y archivos únicos: contexto, borradores DOCX, dos hojas QA XLSX, respaldos técnicos y registros.

Conclusión: el contenido de evidencias de VN-RQ106 puede proponerse para retiro local después de aprobación, pero VN-RQ106 no puede eliminarse completamente todavía. Primero debe preservarse y revisar el `stash`, resolver la modificación local y reorganizar la base común de worktrees.

## Estado de Empresa / Marcas Chinas

`RedMotors-Sprint2-Flows-Components` es el entorno autoritativo actual. Contiene trabajo reciente de Sprint 3 y preparación de Sprint 4, está limpio y su HEAD coincide con remoto. El contexto activo y el índice maestro del repositorio gobiernan la vigencia documental.

Para Sprint 4 se debe conservar:

- El worktree activo completo.
- `docs/empresa-marcas-chinas`, especialmente contexto activo, índice maestro, matriz de vigencia, fuentes de alcance, cierres de Sprint 3 y auditoría de cobertura de Sprint 4.
- Videos de Sprint 3 en Drive y, hasta aprobación de limpieza, sus dos copias locales.
- Documentos oficiales y reportes de Marcas Chinas en Drive.
- El borrador no rastreado de cierre técnico hasta decidir si se incorpora o archiva.

## RedMotors fuera de Repositorios

| Ruta | Tamaño | Estado |
|---|---:|---|
| `Documents\Evidencias\RedMotors` | 892.88 MiB | Respaldado en Drive; conservar hasta aprobación |
| `Documents\Auditorias-RedMotors-PEKING` | 5.03 MiB | Información local de auditoría; conservar respaldo |
| `Documents\RedMotors_PEKING_Etapa1_Auditoria` | 0.04 MiB | Paquete local con ZIP exacto; archivar |
| `Downloads\Evidencia_Sprint2_Empresa_Pricebook_Corregido.docx` | 1.098 MiB | Duplicado exacto en Drive |
| `Pictures\Icon\redmotors_launcher_icon_v8_fixed_complete.ico` | 0.02 MiB | Sin copia en repositorios; conservar |

## INFORMACION_UNICA_NO_RESPALDADA

1. `RedMotors-Sprint1-Next8-Reconcile\docs\empresa-marcas-chinas\CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`, no rastreado.
2. Modificación local de `RedMotorsPartial-Sandbox\force-app\main\default\lwc\jsconfig.json`.
3. `stash@{0}` de VN-RQ106 con documentos, hojas QA, respaldos técnicos y registros no presentes en la rama remota.
4. `Documents\Auditorias-RedMotors-PEKING` y el paquete Etapa 1: tienen copias ZIP locales, pero no se comprobó respaldo externo.
5. El icono RedMotors de `Pictures`: no tiene copia exacta en los repositorios revisados.
6. Las 43 rutas del worktree roto ausentes del activo: probablemente temporales, pero su respaldo no es demostrable mientras el enlace Git esté roto.
7. La carpeta `Archivos perdidos (65660)`: origen y respaldo desconocidos; puede contener información personal única y exige revisión humana.

## Espacio recuperable por categoría

| Categoría | Espacio | Tratamiento |
|---|---:|---|
| Copias locales exactas ya respaldadas en Drive | 893.975 MiB | Seguro después de aprobación |
| 18 worktrees remotos, limpios e históricos | 738.1 MiB | Seguro después de aprobación y retiro controlado |
| ZIP exactos de carpetas de auditoría | 0.515 MiB | Seguro después de elegir copia autoritativa |
| Duplicados dentro de worktrees | 459.987 MiB | No sumar: incluido en el retiro de worktrees |
| ZIP recuperados inválidos | 992.38 MiB | Revisión manual |
| Otros archivos recuperados | ≈ 113 MiB | Revisión manual |
| Runtime visible en `.cache` | 1,050.18 MiB | Revisión manual; no borrar mientras esté en uso |
| Temporales visibles de la aplicación | 130.45 MiB | Revisión manual con aplicación cerrada |
| Worktree roto | 44.1 MiB | Revisión manual |
| Instaladores / `node_modules` | 0 | Sin acción |

**ESPACIO_POTENCIALMENTE_RECUPERABLE_SEGURO:** ≈ 1.59 GiB, sin contar Drive y sin doble contabilizar duplicados internos de worktrees.

**ESPACIO_REQUIERE_REVISION:** ≈ 2.42 GiB.

**ESPACIO_NO_TOCAR:** ≈ 7.15 GiB, incluyendo Google Drive, aplicaciones activas y datos que no entran en una categoría segura.

## Limitaciones

- No se inspeccionó contenido personal ajeno a la organización del almacenamiento.
- No se accedió a `AppData`, autenticación, credenciales ni configuraciones sensibles.
- OneDrive usa redirecciones/reparse points; solo se contabilizaron los archivos locales visibles.
- Los tamaños de Google Drive son lógicos o los reportados por la unidad montada y no se consideran recuperables.
- Una rama remota puede cambiar después de esta auditoría; cualquier limpieza futura debe repetir estado, remoto y hashes inmediatamente antes de actuar.

## Confirmación

Esta auditoría no ejecutó ninguna fase de limpieza. No se borró, movió, renombró, comprimió ni alteró ningún archivo existente.
