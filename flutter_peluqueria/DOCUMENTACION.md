# 📚 Documentación del Proyecto - Barbería Noir

Bienvenido a la documentación completa de la aplicación Barbería Noir. Esta guía te ayudará a entender, desarrollar y mantener el proyecto.

## 📖 Índice de Documentación

### 1. **[README.md](./README.md)** - Guía Principal
   - 📋 Características de la app
   - 🏗️ Arquitectura del proyecto
   - 📁 Estructura de directorios
   - 🚀 Instalación y configuración
   - 🛠️ Stack tecnológico
   - 📡 Endpoints de API

   **Para quién**: Usuarios nuevos en el proyecto, resumen ejecutivo

---

### 2. **[ARQUITECTURA.md](./ARQUITECTURA.md)** - Detalles Técnicos
   - 📐 Visión arquitectónica
   - 🏛️ Explicación de cada capa
   - 🔌 Flujo de datos
   - 🔐 Manejo de autenticación
   - 🎯 Patrones de error
   - 🧪 Testabilidad

   **Para quién**: Desarrolladores mid-level, arquitectos, code reviewers

---

### 3. **[GUIA_DESARROLLO.md](./GUIA_DESARROLLO.md)** - Guía Práctica
   - 🚀 Setup inicial
   - 📝 Convenciones de código
   - 🔧 Tareas comunes
   - 🎯 Patrones reutilizables
   - 🐛 Debugging
   - ✅ Checklist antes de commit

   **Para quién**: Desarrolladores trabajando en features, nuevos miembros del equipo

---

### 4. **[ENDPOINTS_MAPPING.md](./ENDPOINTS_MAPPING.md)** - API Reference
   - 📡 Todos los endpoints disponibles
   - 📥 Request/Response examples
   - 🔐 Autenticación requerida
   - ⚠️ Códigos de error

   **Para quién**: Integradores frontend, testers de API

---

### 5. **[RESPONSE_EXAMPLES.md](./RESPONSE_EXAMPLES.md)** - Ejemplos de Respuestas
   - 📄 JSON de ejemplo por endpoint
   - 📊 Estructura de datos
   - 🔄 Casos de error

   **Para quién**: Frontend developers, debugging de responses

---

## 🎯 Guía Rápida por Rol

### 👨‍💼 Product Manager / Stakeholder
1. Lee **README.md** - Entiende qué hace la app
2. Ve las características implementadas
3. Consulta el roadmap en README

### 👨‍💻 Desarrollador Nuevo
1. Lee **README.md** - Visión general
2. Sigue **GUIA_DESARROLLO.md** - Setup
3. Explora el código en `lib/`
4. Consulta **ARQUITECTURA.md** cuando necesites entender el flujo

### 🏗️ Arquitecto de Software / Tech Lead
1. Lee **ARQUITECTURA.md** - Decisiones técnicas
2. Revisa **GUIA_DESARROLLO.md** - Patrones seguidos
3. Consulta **README.md** - Stack y dependencias

### 🧪 QA / Tester
1. Lee **README.md** - Características
2. Consulta **ENDPOINTS_MAPPING.md** - Qué testear
3. Ve **RESPONSE_EXAMPLES.md** - Respuestas esperadas

### 🔧 DevOps / SRE
1. Lee README sección Stack Tecnológico
2. Consulta variables de entorno en **GUIA_DESARROLLO.md**
3. Revisa configuración en `core/config/`

---

## 🗺️ Mapa de Código por Funcionalidad

### Autenticación
```
features/auth/
├── presentation/
│   ├── login_screen.dart      ← Pantalla de login
│   └── register_screen.dart   ← Pantalla de registro
├── application/
│   └── auth_provider.dart     ← State de autenticación
└── data/
    └── dtos/                  ← Request/Response DTOs
```
📖 **Ver**: README.md → Features → Autenticación

### Gestión de Citas
```
features/client/
├── presentation/
│   ├── appointments_screen.dart       ← Listado
│   ├── book_appointment_screen.dart   ← Crear
│   └── edit_appointment_screen.dart   ← Editar
├── application/
│   └── appointment_provider.dart      ← State management
└── data/
    └── dtos/                          ← DTOs
```
📖 **Ver**: README.md → Features → Gestión de Citas
📖 **Ver**: ENDPOINTS_MAPPING.md → /api/client/appointments

### Servicios
```
features/client/
├── presentation/
│   └── services_screen.dart           ← Listado
├── application/
│   └── service_provider.dart          ← State management
```
📖 **Ver**: ENDPOINTS_MAPPING.md → /api/client/services

---

## 🔄 Flujos Principales

### Crear una Cita (Happy Path)
```
1. Usuario abre AppointmentsScreen
   ├─ Pantalla: features/client/presentation/appointments_screen.dart
   ├─ State: appointmentProviderProvider (appointment_provider.dart)
   └─ Endpoint: GET /api/client/appointments

2. Usuario toca "Agendar Cita"
   ├─ Navega a: book_appointment_screen.dart
   └─ Route: /book-appointment

3. Selecciona Servicio
   ├─ State: serviceProviderProvider (service_provider.dart)
   └─ Endpoint: GET /api/client/services

4. Selecciona Peluquero
   ├─ State: hairstylistProviderProvider
   └─ Endpoint: GET /api/client/hairstylists?serviceId=...

5. Completa datos y confirma
   ├─ Provider: createAppointmentProvider (appointment_provider.dart)
   └─ Endpoint: POST /api/client/appointments

6. Backend crea cita
   ├─ Respuesta: 201 Created
   └─ Body: {message, cita: {...}}

7. Frontend invalida caché
   ├─ invalidate(appointmentProviderProvider)
   └─ RefreshFutureProvider automático

8. Usuario vuelve a appointments_screen
   ├─ GET /api/client/appointments (refetch)
   └─ Nueva cita aparece en el listado
```
📖 **Documentación**: ARQUITECTURA.md → Flujo de Datos
📖 **Código**: features/client/application/appointment_provider.dart
📖 **API**: ENDPOINTS_MAPPING.md → POST /api/client/appointments

---

## 📊 Estructura de Datos

### Cita (Appointment)
```json
{
  "_id": "ObjectId",
  "clienteId": "ObjectId",
  "peluqueroId": "ObjectId", 
  "servicioId": "ObjectId",
  "fechaHoraInicio": "2024-12-10T14:30:00Z",
  "duracion": 30,
  "estado": "Confirmada|Pendiente|Cancelada",
  "notasCliente": "Comentario opcional",
  "motivoCancelacion": "Motivo si está cancelada"
}
```
📖 **Ver**: domain/models/cita.dart
📖 **Ejemplo**: RESPONSE_EXAMPLES.md → Cita

### Usuario / Cliente
```json
{
  "_id": "ObjectId",
  "nombre": "Juan",
  "email": "juan@example.com",
  "telefono": "123456789",
  "rol": "cliente|peluquero",
  "estado": "activo|pendiente|rechazado"
}
```
📖 **Ver**: domain/models/usuario.dart, cliente.dart

---

## 🛠️ Stack Tecnológico

| Layer | Tecnología | Documentación |
|-------|------------|---------------|
| **Frontend Framework** | Flutter 3.10+ | [flutter.dev](https://flutter.dev) |
| **State Management** | Riverpod 3.0+ | [riverpod.dev](https://riverpod.dev) |
| **Routing** | GoRouter 17.0+ | [pub.dev](https://pub.dev/packages/go_router) |
| **HTTP Client** | Dio 5.9+ | [pub.dev](https://pub.dev/packages/dio) |
| **Logging** | Pretty Dio Logger | [pub.dev](https://pub.dev/packages/pretty_dio_logger) |
| **Storage** | Secure Storage + SharedPrefs | [pub.dev](https://pub.dev/packages/flutter_secure_storage) |
| **Backend** | Express.js + MongoDB | [expressjs.com](https://expressjs.com) |
| **API** | REST con JWT | JWT.io |

---

## ⚡ Instalación Rápida

```bash
# 1. Clonar y actualizar
git clone <repo-url>
cd flutter_peluqueria
flutter pub get

# 2. Configurar .env
cp .env.example .env
# Editar con: API_BASE_URL=http://localhost:5000

# 3. Ejecutar
flutter run

# 4. Backend en otra terminal
cd backend_peluqueria
npm install && npm start
```

📖 **Detalles**: GUIA_DESARROLLO.md → Comenzar

---

## 📋 Checklist para Nuevos Desarrolladores

- [ ] Lee README.md completo
- [ ] Clona repositorio y ejecuta `flutter pub get`
- [ ] Configura .env con URL del backend
- [ ] Ejecuta `flutter run` en emulador/device
- [ ] Lee GUIA_DESARROLLO.md → Convenciones
- [ ] Lee ARQUITECTURA.md → Entender capas
- [ ] Explora features/client/presentation/
- [ ] Comprende cómo funcionan Riverpod providers
- [ ] Hace un pequeño cambio (UI) y verifica hot reload
- [ ] ¡Listo para contribuir!

---

## 🤝 Contribuir

1. Crea rama: `git checkout -b feature/mi-feature`
2. Haz cambios siguiendo GUIA_DESARROLLO.md
3. Ejecuta `flutter analyze` sin errores
4. Haz commit descriptivo
5. Push y crea Pull Request
6. Espera review y feedback

---

## 🐛 Soporte y Debugging

### Problema: App no compila
**Solución**: `flutter clean && flutter pub get && flutter pub get`

### Problema: No conecta a backend
**Solución**: Verificar .env y que backend esté en puerto 5000

### Problema: Hot reload no funciona
**Solución**: Usa hot restart (Cmd+Shift+F5)

📖 **Más problemas**: GUIA_DESARROLLO.md → Problemas Comunes

---

## 📞 Contacto

Para preguntas sobre:
- **Diseño/Arquitectura**: Consultar ARQUITECTURA.md
- **Implementación**: Consultar GUIA_DESARROLLO.md
- **API**: Consultar ENDPOINTS_MAPPING.md
- **Dependencias**: Ver pubspec.yaml

---

## 📈 Versiones

- **Versión Actual**: 1.0.0
- **Flutter**: ^3.10.0
- **Dart**: ^3.0.0
- **Última Actualización**: Diciembre 2025

---

## 📚 Recursos Externos

- [Flutter Official Docs](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design 3](https://m3.material.io)
- [REST API Best Practices](https://restfulapi.net)
- [Riverpod Tutorials](https://riverpod.dev/docs/introduction/why_riverpod)

---

**¿Dónde empezar?**
1. Si no sabes nada del proyecto → **README.md**
2. Si vas a desarrollar → **GUIA_DESARROLLO.md**
3. Si necesitas entender cómo funciona → **ARQUITECTURA.md**
4. Si integras con API → **ENDPOINTS_MAPPING.md**

¡Bienvenido al equipo! 🚀
