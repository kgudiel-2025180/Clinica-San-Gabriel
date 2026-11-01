# Clínica Médica San Gabriel

Landing page responsiva con agenda de citas en línea. El sitio es estático (`index.html`) y usa **Supabase** como backend para que las reservas se compartan entre todos los visitantes y el panel administrativo pueda verlas desde cualquier dispositivo.

## Enlaces

- **Sitio publicado:** https://kgudiel-2025180.github.io/Clinica-San-Gabriel/
- **Repositorio:** https://github.com/kgudiel-2025180/Clinica-San-Gabriel

## Funcionalidades

- Hero, sección "Sobre nosotros", servicios, contacto y preguntas frecuentes.
- Reserva pública con validación de:
  - Nombre completo.
  - DPI de 13 dígitos con formato automático.
  - Número de teléfono.
  - Especialidad.
  - Fecha de lunes a viernes.
  - Bloques fijos de 2 horas entre 8:00 AM y 8:00 PM.
- Disponibilidad consultada en tiempo real desde Supabase.
- Bloqueo de horarios duplicados mediante restricción `UNIQUE (date, slot)` y función RPC.
- Confirmación con código de cita generado en el servidor.
- Panel administrativo con autenticación real de Supabase Auth.
- Estadísticas, búsqueda y cancelación de citas.
- Al cancelar una cita, el horario se libera inmediatamente para todos.
- Diseño adaptable a móviles y escritorio.

## Arquitectura

```
Navegador (GitHub Pages)
   │
   ├── Reserva pública ──► RPC get_booked_slots / create_appointment
   │
   └── Panel admin ──────► Supabase Auth + consultas con RLS
                              │
                              └── PostgreSQL: public.appointments
```

La **publishable key** de Supabase es pública y puede estar en el navegador. La seguridad la proporcionan las políticas RLS y las funciones `security definer`. La **secret key** nunca debe usarse en el frontend.

## Configuración de Supabase

1. Crea un proyecto en https://supabase.com.
2. Abre **SQL Editor → New query**, pega el contenido de [`supabase/schema.sql`](supabase/schema.sql) y ejecuta.
3. Crea el usuario administrador en **Authentication → Users → Add user**:
   - Correo electrónico.
   - Contraseña.
   - Marca **Auto Confirm User**.
4. Copia los datos del proyecto desde **Settings → Data API**:
   - `Project URL`.
   - `Publishable key` (o `anon public key`).
5. Edita las constantes al inicio del script en `index.html`:

```js
const SUPABASE_URL = 'https://TU-PROYECTO.supabase.co';
const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_...';
```

> No pongas la `sb_secret_...` ni la `service_role` en el código del navegador.

## Acceso administrativo

El panel se abre con el botón **Acceso administrativo** del sitio.

- **Correo:** el usuario creado en Supabase Auth.
- **Contraseña:** la definida al crearlo.

La sesión se conserva en el navegador hasta que se pulsa **Cerrar sesión**. Desde el panel se ven todas las citas registradas por cualquier visitante.

## Ejecutar localmente

Abre `index.html` directamente o sirve la carpeta:

```bash
python3 -m http.server 4173
```

Luego visita http://127.0.0.1:4173/.

## Publicación en GitHub Pages

1. Sube `index.html`, `README.md` y `supabase/schema.sql` a la rama `main`.
2. Ve a **Settings → Pages**.
3. En *Build and deployment*, elige **Deploy from a branch**.
4. Selecciona la rama `main` y la carpeta `/ (root)`.
5. Guarda. GitHub Pages reconstruye el sitio en 1–2 minutos.

## Estructura

```
.
├── index.html
├── README.md
└── supabase
    └── schema.sql
```

## Notas de seguridad

- Las citas incluyen DPI y teléfono, por lo que solo un usuario autenticado puede leerlas o eliminarlas.
- El formulario público no puede leer la tabla directamente: solo consulta horarios ocupados mediante RPC.
- La creación de citas se valida en el servidor (día hábil, bloque válido y DPI de 13 dígitos).
- Si una persona intenta reservar un horario ya ocupado, la base de datos lo rechaza aunque dos personas envíen el formulario al mismo tiempo.
