# Clínica Médica San Gabriel

Landing page profesional y responsiva para una clínica médica, con sistema de reserva de citas y panel administrativo local.

## Vista previa

El proyecto es un único archivo `index.html` que contiene HTML, CSS y JavaScript integrados. No requiere instalación ni backend.

## Funcionalidades

- Hero, sección "Sobre nosotros", servicios y contacto con mapa simulado.
- Reserva de citas con validación de:
  - Nombre completo.
  - DPI de 13 dígitos (con formato automático).
  - Número de teléfono.
  - Especialidad.
  - Fecha de lunes a viernes.
  - Bloques fijos de 2 horas entre 8:00 AM y 8:00 PM.
- Bloqueo de horarios ya reservados y confirmación dinámica con código de cita.
- Persistencia en `localStorage` con la clave `csg_appointments_v1`.
- Panel administrativo con login, estadísticas, búsqueda y cancelación de citas.
- Al cancelar una cita, el horario se libera automáticamente en el formulario público.
- Diseño adaptable a móviles y escritorio, con mejoras de accesibilidad.

## Acceso administrativo

| Campo | Valor |
|---|---|
| Usuario | `Administrador` |
| Contraseña | `admin12345` |

> Las credenciales son de demostración y están visibles en el código. Para un entorno real se debe implementar autenticación con un backend.

## Cómo ejecutar localmente

Abre `index.html` directamente en el navegador o sirve la carpeta con Python:

```bash
python3 -m http.server 4173
```

Luego visita `http://127.0.0.1:4173/`.

## Publicación

Al ser un sitio estático, puede publicarse gratis en:

- **Netlify Drop:** https://app.netlify.com/drop
- **Vercel:** `vercel` en la carpeta del proyecto.
- **GitHub Pages:** Settings → Pages → Deploy from a branch → `main` / root.

## Limitación importante

Las citas se guardan en el `localStorage` de cada navegador. Esto significa que:

- Cada visitante solo ve sus propias reservas.
- El panel administrativo solo muestra las citas creadas en ese mismo navegador.
- Borrar los datos del navegador elimina las citas.

Para que las citas sean compartidas entre todos los usuarios y el panel administrativo, se necesita un backend con base de datos (por ejemplo Supabase, Firebase o un servidor propio con PostgreSQL).

## Estructura

```
.
├── index.html
└── README.md
```
