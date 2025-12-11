# Barbería Noir - Aplicación Multiplataforma

Una aplicación Flutter moderna para la gestión de citas en peluquerías, con soporte para clientes y peluqueros. Construida con arquitectura limpia, state management con Riverpod y enrutamiento con GoRouter.

## 📋 Tabla de Contenidos

- [Características](#características)
- [Arquitectura](#arquitectura)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Instalación](#instalación)
- [Configuración](#configuración)
- [Uso](#uso)
- [Stack Tecnológico](#stack-tecnológico)
- [Endpoints API](#endpoints-api)

## ✨ Características

### Para Clientes
- **Autenticación y Registro**: Sistema de login/registro seguro con JWT
- **Búsqueda de Peluqueros**: Filtrar peluqueros por servicios especializados
- **Agendar Citas**: Reservar citas seleccionando fecha, hora y peluquero
- **Gestión de Citas**: Ver, editar, cancelar y eliminar citas
- **Historial**: Visualizar citas confirmadas, pendientes y canceladas
- **Panel de Perfil**: Editar información personal

### Para Peluqueros
- **Gestión de Disponibilidad**: Administrar horarios y servicios
- **Calendario de Citas**: Ver citas agendadas por día
- **Notificaciones**: Recibir alertas de nuevas citas
- **Panel de Control**: Estadísticas de citas

## 🏗️ Arquitectura

El proyecto sigue una arquitectura **limpia con capas** adaptada para Flutter:

```
lib/
├── main.dart                 # Punto de entrada de la app
├── core/                     # Capa de infraestructura
│   ├── config/              # Variables de entorno y configuración
│   ├── routing/             # Enrutamiento con GoRouter
│   ├── theme/               # Tema y estilos globales
│   ├── utils/               # Utilidades compartidas
│   └── widgets/             # Widgets reutilizables
├── domain/                   # Capa de dominio
│   └── models/              # Modelos de datos (Entidades)
├── features/                # Capa de presentación y lógica
│   ├── auth/               # Feature de Autenticación
│   ├── client/             # Feature de Cliente
│   └── hairstylist/        # Feature de Peluquero
└── data/                    # Capa de datos
    └── Servicios y repositorios
```

### Patrones Utilizados

- **State Management**: Riverpod (FutureProvider, NotifierProvider)
- **Routing**: GoRouter (navegación type-safe)
- **HTTP Client**: Dio con interceptores
- **Inyección de Dependencias**: Riverpod providers
- **Persistencia**: SharedPreferences y Secure Storage

## 📁 Estructura del Proyecto

### `/core` - Capa de Infraestructura

#### `config/`
- **environment.dart**: Carga variables de entorno desde `.env`
- Gestiona URL base de la API

#### `routing/`
- **app_router.dart**: Configuración de todas las rutas
- Estructura:
  - `/`: Home (redirige según autenticación)
  - `/login`: Pantalla de login
  - `/register`: Pantalla de registro
  - `/home`: Dashboard del cliente
  - `/services`: Listado de servicios
  - `/appointments`: Gestión de citas
  - `/book-appointment`: Agendar cita
  - `/edit-appointment/:id`: Editar cita
  - `/peluquero/home`: Dashboard del peluquero

#### `theme/`
- **app_theme.dart**: Tema oscuro de la aplicación
- **Paleta de colores**:
  - Primario: Oro (#D4AF37)
  - Fondo: Negro (#0E0E10)
  - Texto: Blanco
  - Acentos: Grises

#### `widgets/`
- **floating_notification.dart**: Sistema de notificaciones flotantes
  - Tipos: success, error, warning, info
  - Tema unificado (negro + oro + blanco)

### `/domain` - Capa de Dominio

#### `models/`
Modelos de datos puros (sin lógica de negocio):

- **usuario.dart**: Modelo base de usuario
- **cliente.dart**: Datos específicos del cliente
- **peluquero.dart**: Datos del peluquero + servicios especializados
- **cita.dart**: Estructura de cita con estado y detalles
- **servicio.dart**: Servicios ofrecidos
- **ausencia.dart**: Ausencias del peluquero
- **negocio.dart**: Información del negocio

### `/features` - Capa de Presentación

#### `auth/` - Autenticación

**Estructura:**
```
auth/
├── presentation/
│   ├── login_screen.dart      # Pantalla de login simplificada
│   └── register_screen.dart   # Pantalla de registro simplificada
├── application/
│   └── auth_provider.dart     # State management de autenticación
└── data/
    └── dtos/
        ├── login_request.dart
        └── register_request.dart
```

**Características:**
- Validación de credenciales
- Almacenamiento seguro de JWT
- Manejo de errores de validación
- Soporte para rol (cliente/peluquero)

#### `client/` - Funcionalidades del Cliente

**Estructura:**
```
client/
├── presentation/
│   ├── client_home_screen.dart       # Dashboard principal
│   ├── home_screen.dart              # Pantalla de inicio
│   ├── services_screen.dart          # Listado de servicios
│   ├── appointments_screen.dart      # Gestión de citas
│   ├── book_appointment_screen.dart  # Agendar cita
│   ├── edit_appointment_screen.dart  # Editar cita
│   └── profile_screen.dart           # Perfil del usuario
├── application/
│   ├── appointment_provider.dart     # State de citas
│   ├── client_provider.dart          # State del cliente
│   └── service_provider.dart         # State de servicios
└── data/
    └── dtos/
        ├── create_appointment_request.dart
        └── update_appointment_request.dart
```

**Pantallas:**

1. **client_home_screen.dart**
   - Muestra negocio destacado con descripción
   - Servicios especiales
   - Estadísticas de citas
   - Navegación a servicios y citas

2. **home_screen.dart**
   - Presenta negocio principal
   - Información del peluquero destacado
   - Opciones de servicios y citas
   - Sección de reseñas/testimonios

3. **services_screen.dart**
   - Listado completo de servicios
   - Filtrado por categoría
   - Información de precio y duración
   - Búsqueda de peluqueros por servicio

4. **appointments_screen.dart**
   - Tres secciones: Confirmadas, Pendientes, Canceladas
   - Tarjetas de cita con detalles completos
   - Acciones: Editar, Cancelar (confirmadas/pendientes), Eliminar (canceladas)
   - Diálogos de confirmación con motivo de cancelación

5. **book_appointment_screen.dart**
   - Seleccionar servicio
   - Seleccionar peluquero
   - Elegir fecha y hora
   - Campo de notas opcionales
   - Validación de campos requeridos

6. **edit_appointment_screen.dart**
   - Editar los detalles de una cita existente
   - Misma lógica que agendar con valores precargados
   - Validación similar

#### `hairstylist/` - Funcionalidades del Peluquero

**Estructura:**
```
hairstylist/
├── presentation/
│   └── hairstylist_home_screen.dart  # Dashboard del peluquero
└── (en desarrollo)
```

## 🚀 Instalación

### Requisitos
- Flutter 3.10+
- Dart 3.0+
- Android Studio o Xcode
- Node.js (para el backend)

### Pasos

1. **Clonar el repositorio**
```bash
git clone <repo-url>
cd flutter_peluqueria
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar variables de entorno**
```bash
cp .env.example .env
# Editar .env con la URL del backend
```

4. **Ejecutar la app**
```bash
flutter run
```

## ⚙️ Configuración

### Variables de Entorno (.env)

```env
API_BASE_URL=http://localhost:5000
API_TIMEOUT=30
```

### Tema y Colores

Editar `core/theme/app_theme.dart`:

```dart
// Paleta actual:
- Primario (Oro): #D4AF37
- Fondo: #0E0E10
- Texto: #FFFFFF
- Éxito: #4CAF50
- Error: #F44336
- Advertencia: #FF9800
```

## 📱 Uso

### Flujo de Cliente

1. **Registrarse**
   - Ingresar nombre, email, teléfono, contraseña
   - Seleccionar rol "cliente"
   - Confirmación en email

2. **Login**
   - Usar credenciales registradas
   - Token JWT se almacena automáticamente

3. **Explorar Servicios**
   - Ver todos los servicios disponibles
   - Filtrar por tipo

4. **Agendar Cita**
   - Seleccionar servicio
   - Elegir peluquero disponible
   - Elegir fecha y hora
   - Agregar notas (opcional)
   - Confirmar

5. **Gestionar Citas**
   - Ver citas por estado
   - Editar detalles
   - Cancelar (con motivo)
   - Eliminar (solo si están canceladas)

## 🛠️ Stack Tecnológico

### Frontend (Flutter)
- **Framework**: Flutter 3.10+
- **State Management**: Riverpod 3.0+
- **Routing**: GoRouter 17.0+
- **HTTP Client**: Dio 5.9+
- **Logging**: Pretty Dio Logger 1.4+
- **Storage**: 
  - Secure Storage 9.2+ (credenciales)
  - Shared Preferences 2.5+ (datos locales)
- **Environment**: Flutter Dotenv 6.0+
- **Internacionalización**: Intl 0.20+

### Backend (TypeScript/Express)
- **Runtime**: Node.js
- **Framework**: Express.js
- **Base de Datos**: MongoDB
- **Autenticación**: JWT
- **Validación**: Joi

### API REST
- Base URL: `http://localhost:5000/api`
- Autenticación: Bearer Token (JWT)
- Content-Type: `application/json`

## 📡 Endpoints API

### Autenticación
```
POST   /auth/register          - Registrar nuevo usuario
POST   /auth/login             - Login
POST   /auth/logout            - Logout
GET    /auth/services          - Obtener servicios
```

### Cliente - Citas
```
GET    /client/appointments              - Listar citas del cliente
POST   /client/appointments              - Crear cita
PATCH  /client/appointments/:id          - Editar cita
PATCH  /client/appointments/:id/cancel   - Cancelar cita
DELETE /client/appointments/:id          - Eliminar cita
```

### Cliente - Servicios y Peluqueros
```
GET    /client/services                  - Listar servicios
GET    /client/hairstylists?serviceId=.. - Filtrar peluqueros por servicio
GET    /client/profile                   - Perfil del cliente
PATCH  /client/profile                   - Actualizar perfil
```

### Admin
```
GET    /admin/clients          - Listar clientes
GET    /admin/hairstylists     - Listar peluqueros
PATCH  /admin/users/:id/approve - Aprobar peluquero
DELETE /admin/users/:id         - Eliminar usuario
```

## 🔐 Seguridad

- **JWT**: Tokens con expiración
- **Secure Storage**: Credenciales encriptadas
- **HTTPS**: Conexiones seguras en producción
- **Validación**: Lado cliente y servidor
- **CORS**: Configurado en backend

## 📊 Gestión de Estado (Riverpod)

### Providers principales

**Auth:**
- `authNotifierProvider`: State de autenticación
- `dioClientProvider`: Cliente HTTP configurado

**Client:**
- `appointmentProviderProvider`: Listado de citas
- `createAppointmentProvider`: Crear cita
- `cancelAppointmentNotifierProvider`: Cancelar cita
- `updateAppointmentNotifierProvider`: Editar cita
- `deleteAppointmentNotifierProvider`: Eliminar cita
- `serviceProviderProvider`: Listado de servicios
- `hairstylistProviderProvider`: Peluqueros filtrados

### Patrón de Invalidación

Cuando se crea, edita o elimina una cita, el provider de citas se invalida automáticamente, refrescando la lista:

```dart
// En notifier
ref.invalidate(appointmentProviderProvider);
```

## 🎨 Diseño UI/UX

### Paleta Unificada
- **Tema Oscuro**: Fondo #0E0E10 (negro profundo)
- **Acento Primario**: #D4AF37 (oro)
- **Texto**: Blanco (#FFFFFF)
- **Bordes**: Oro semi-transparente

### Componentes Reutilizables
- **Notificaciones Flotantes**: Sistema unificado con 4 tipos
- **Tarjetas**: Estilo consistente con bordes oro
- **Botones**: Gradientes y estilos personalizados
- **Diálogos**: Confirmación con animaciones

## 🐛 Depuración

### Logs HTTP
Pretty Dio Logger muestra automáticamente:
- Request/Response headers
- Body de solicitudes
- Tiempo de respuesta
- Errores detallados

### Flutter Analyze
```bash
flutter analyze
```

## 📝 Convenciones de Código

- **Nombres de Archivos**: snake_case (ej: `auth_provider.dart`)
- **Nombres de Clases**: PascalCase
- **Nombres de Variables**: camelCase
- **Constantes**: camelCase o UPPER_CASE

## 🔄 Flujos Principales

### Crear Cita
1. Usuario navega a "Agendar Cita"
2. Selecciona servicio → Backend valida
3. Selecciona peluquero → Obtiene disponibilidad
4. Elige fecha/hora → Verifica disponibilidad
5. Confirma → POST /api/client/appointments
6. Backend retorna cita creada con ID
7. Provider invalida lista de citas
8. UI se refresca con nueva cita

### Cancelar Cita
1. Usuario elige cita y toca "Cancelar"
2. Se abre diálogo pidiendo motivo
3. Envía PATCH /api/client/appointments/:id/cancel
4. Cita cambia estado a "Cancelada"
5. Se invalida lista
6. UI mueve cita a sección "Canceladas"

### Eliminar Cita
1. Usuario elige cita cancelada y toca "Eliminar"
2. Se pide confirmación
3. Envía DELETE /api/client/appointments/:id
4. Backend valida que sea cancelada
5. Cita se elimina permanentemente
6. Se invalida lista
7. Cita desaparece de UI

## 📈 Mejoras Futuras

- [ ] Notificaciones Push
- [ ] Sistema de reseñas
- [ ] Historial de transacciones
- [ ] Descuentos y promociones
- [ ] Integración de pagos
- [ ] Reportes para peluqueros
- [ ] Sincronización offline
- [ ] Soporte multi-idioma completo

## 📞 Soporte

Para reportar bugs o sugerencias, crear un issue en el repositorio.

---

**Última actualización**: Diciembre 2025
**Versión**: 1.0.0
**Estado**: En desarrollo activo
