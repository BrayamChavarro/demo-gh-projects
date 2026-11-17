# Runbook de la presentación

> Notas del presentador. Este archivo no forma parte del producto; se puede borrar antes de publicar el repositorio.

---

## 0. Preflight — 15 minutos antes

Cada casilla existe porque su ausencia rompe una parte de la demo en vivo.

- [ ] `gh auth status` responde con una cuenta autenticada.
- [ ] El repositorio está publicado en GitHub y los tres archivos de `.github/ISSUE_TEMPLATE/` están en `main`.
- [ ] El Project existe **y está enlazado al repositorio** (pestaña `Projects` del repo muestra el tablero).
- [ ] Workflow **Auto-add to project** activo, con el filtro apuntando a este repositorio.
  *Sin esto, el issue nuevo no aparece en el tablero y el cierre no mueve nada.*
- [ ] Workflow **Item closed** activo, con la acción `Set status to Done`.
  *Sin esto, cerrar el issue no mueve la tarjeta.*
- [ ] Al menos 20 issues creados, con **assignees distintos** y labels variados.
  *Sin volumen, Burn up es una línea plana y el gráfico por responsable sale vacío.*
- [ ] Un issue de descarte ya cerrado para verificar la animación antes de la charla.
- [ ] Sesión de GitHub iniciada en el navegador de la demo.
- [ ] Pestañas abiertas en el orden de la charla (ver abajo).

### Pestañas a dejar abiertas

1. El repositorio, pestaña `Code`.
2. `Settings` → sección `Features`.
3. `.github/ISSUE_TEMPLATE/` en el explorador de archivos.
4. `Issues` → `New issue`.
5. El tablero en vista `Board`.
6. El tablero con `...` → `Workflows` abierto.
7. El tablero con `Insights` abierto.
8. Terminal con el repositorio clonado.

---

## 1. Ruta A — Plantillas de issues

### Vista de configuración (sin tocar código)

`Settings` → bajar hasta **Features** → **Issues** → **Set up templates**.

Señalar que GitHub ofrece plantillas base y que el botón escribe los archivos por vos.

### Vista de código (avanzada)

Carpeta `.github/ISSUE_TEMPLATE/` → abrir `bug_report.yml`.

Mostrar y nombrar:

- `name` y `description`: lo que ve el usuario en el menú de selección.
- `title` con prefijo: normaliza los títulos sin intervención manual.
- `labels`: clasificación automática al crear el issue.
- `body[].type`: `markdown`, `checkboxes`, `textarea`, `input`, `dropdown`.
- `validations.required: true`: el botón de envío queda deshabilitado.
- `render: shell`: el bloque de logs sale con formato de código.
- `config.yml` con `blank_issues_enabled: false`: elimina el issue en blanco.

### Vista del usuario final

Pestaña `Issues` → botón verde **New issue**.

En lugar de un cuadro vacío aparece el menú con los dos formularios y los contact links. Entrar a **Bug report** y mostrar los campos obligatorios.

---

## 2. Ruta B — Tablero Kanban

1. Foto de perfil → **Your projects** (o la pestaña `Projects` de la organización).
2. **New project** → barra lateral izquierda → **Board** → **Create**.
3. En el repositorio: pestaña `Projects` → **Link a project** → elegir el tablero.

Mostrar en el tablero:

- Cambio de vista `Board` / `Table` / `Roadmap`.
- Campos personalizados: `Status`, `Priority`, `Size`, `Iteration`.
- Vista agrupada por `Status` y filtros guardados.

---

## 3. Ruta C — Automatización

Dentro del tablero: `...` (esquina superior derecha) → **Workflows**.

Los dos relevantes para la charla:

| Workflow | Qué hace | Por qué importa |
| --- | --- | --- |
| **Auto-add to project** | Agrega el issue al tablero al crearse | Sin esto la tarjeta nunca aparece |
| **Item closed** | Pasa el item a `Done` al cerrarse | Es el corazón del cierre de la demo |

Aclarar la distinción: son **dos** automatizaciones independientes. Habilitar solo la segunda no produce ningún efecto visible.

---

## 4. Ruta D — Insights

Dentro del tablero: ícono de gráfica **Insights** (junto a `...`).

1. Por defecto aparece **Burn up**. Señalar cómo se lee: alcance total contra trabajo completado.
2. **New chart** (abajo a la izquierda).
3. `Layout`: **Column** · `X-axis`: **Assignee** · `Group by`: **Status**.

Resultado: carga de trabajo por desarrollador, apilada por estado.

Advertencia: el gráfico cuenta únicamente items **abiertos y no archivados** del tablero. Si no hay responsables asignados, las columnas salen vacías.

---

## 5. Cierre — 2 minutos

Pantalla dividida: tablero a la izquierda, terminal a la derecha.

1. Navegador → `Issues` → **New issue** → **Bug report**.
2. Título: `Sign-in form hangs on submit`. Completar los obligatorios. **Submit new issue**.
3. Tablero → la tarjeta aparece sola en `Todo`. Anotar el número real (por ejemplo `#10`).
4. Terminal:

```bash
gh issue close 10 --comment "Fixed and verified in production"
```

5. Navegador → la tarjeta se mueve a `Done` y el Burn up se actualiza sin tocar el mouse.

Reemplazar `10` por el número real del issue creado. El número aparece en la URL y en el título del issue.

---

## 6. Si algo falla

| Síntoma | Causa más probable | Salida |
| --- | --- | --- |
| `New issue` muestra un cuadro en blanco | Los `.yml` no están en la rama por defecto | Verificar que estén en `main` |
| El formulario no aparece en el menú | YAML inválido | Revisar indentación con 2 espacios |
| El issue no aparece en el tablero | Auto-add desactivado o filtro incorrecto | Crearlo a mano con `Add items` |
| La tarjeta no se mueve al cerrar | Workflow *Item closed* desactivado | Moverla a mano y explicar la automatización |
| El gráfico por responsable sale vacío | Issues sin assignee | Asignar 3 responsables |

---

## 7. Lo que no se puede versionar

El tablero, sus vistas, sus workflows y sus gráficos viven en **GitHub Projects** (cuenta u organización). No existe un archivo en el repositorio que los defina ni que los reproduzca al clonar. La configuración es manual en el navegador, o programática mediante la API de Projects v2 y la CLI `gh`.
