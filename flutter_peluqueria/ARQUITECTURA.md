# Arquitectura Técnica - Barbería Noir

Documento detallado sobre la arquitectura y decisiones técnicas de la aplicación.

## 📐 Visión General

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTACIÓN (UI)                        │
│  Screens, Widgets, Dialogs, Notificaciones                  │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│              STATE MANAGEMENT (Riverpod)                     │
│  Providers, Notifiers, FutureProvider, NotifierProvider      │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│           LÓGICA Y ORQUESTACIÓN (Application)                │
│  Services, DTOs, API Calls                                   │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│         REPOSITORIOS Y ACCESO A DATOS (Data)                 │
│  HTTP Client, Local Storage, Database Operations             │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│             INFRAESTRUCTURA (Core + Domain)                  │
│  Config, Routing, Theme, Models, Utilities                   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                    ┌──────▼──────┐
                    │ Backend API  │
                    │   MongoDB    │
                    └─────────────┘
```

## 🏛️ Capas de Arquitectura

### 1. **Presentation (Presentación)**
**Responsabilidad**: Mostrar información al usuario e capturar interacciones

**Componentes**:
- **Screens**: Pantallas principales (ej: `appointments_screen.dart`)
- **Widgets**: Componentes reutilizables
- **Dialogs**: Diálogos modales (confirmación, etc.)
- **State Management**: Conexión con Riverpod

**Características**:
- Desplegable y reactiva
- Observa cambios de estado
- Dispara acciones del usuario
- No contiene lógica de negocio

**Ejemplo**:
```dart
class AppointmentsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar estado
    final appointmentsAsync = ref.watch(appointmentProviderProvider);
    
    return appointmentsAsync.when(
      data: (citas) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (err, st) => ErrorWidget(error: err),
    );
  }
}
```

### 2. **Application (Lógica)**
**Responsabilidad**: Coordinar la lógica de negocio y manejar estado

**Componentes**:
- **Providers (Riverpod)**: State management
  - `FutureProvider`: Para datos asíncronos (lectura)
  - `NotifierProvider`: Para estado mutable (CRUD)
- **DTOs**: Data Transfer Objects (serialización)
- **Notifiers**: Clases que manejan la lógica de estado

**Decisiones de Diseño**:

#### Providers de Lectura (FutureProvider)
```dart
final appointmentProviderProvider = FutureProvider<List<Cita>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  final response = await dioClient.get('/client/appointments');
  return response.data['citas'].map((json) => Cita.fromJson(json)).toList();
});
```

**Ventajas**:
- Automático caching
- Manejo de loading/error
- Fácil refrescar con `ref.invalidate()`

#### Providers de Escritura (NotifierProvider)
```dart
class CancelAppointmentNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> cancelAppointment(String citaId, String motivo) async {
    state = const AsyncValue.loading();
    try {
      final dioClient = ref.read(dioClientProvider);
      await dioClient.patch('/client/appointments/$citaId/cancel', 
        data: {'motivo': motivo});
      ref.invalidate(appointmentProviderProvider); // Refrescar lista
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final cancelAppointmentNotifierProvider = 
  NotifierProvider<CancelAppointmentNotifier, AsyncValue<void>>(
    () => CancelAppointmentNotifier(),
  );
```

**Patrón de Invalidación**:
- Cuando se modifica un recurso (crear, editar, eliminar)
- Se invalida el provider que lo listaba
- Riverpod refetch automáticamente
- UI se actualiza con datos nuevos

### 3. **Data (Datos)**
**Responsabilidad**: Acceso a datos desde API y almacenamiento local

**Componentes**:
- **HTTP Client (Dio)**: Comunicación con API
- **Interceptores**: Autenticación, logging, manejo de errores
- **Storage**: SharedPreferences, SecureStorage
- **DTOs**: Serialización/Deserialización

**Configuración de Dio**:
```dart
final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Interceptor de autenticación
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(authTokenProvider);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
  );

  // Logger
  dio.interceptors.add(PrettyDioLogger());

  return dio;
});
```

### 4. **Domain (Dominio)**
**Responsabilidad**: Definiciones de entidades y lógica de negocio pura

**Componentes**:
- **Models**: Clases de datos inmutables
- **ValueObjects**: Valores que representan conceptos
- **Use Cases**: Lógica de negocio aislada

**Ejemplo de Modelo**:
```dart
class Cita {
  final String id;
  final String clienteId;
  final String peluqueroId;
  final String servicioId;
  final DateTime fechaHoraInicio;
  final Duration duracion;
  final String estado; // 'Confirmada', 'Pendiente', 'Cancelada'
  final String? notasCliente;
  final String? motivoCancelacion;

  Cita({
    required this.id,
    required this.clienteId,
    // ... otros campos
  });

  factory Cita.fromJson(Map<String, dynamic> json) => Cita(
    id: json['_id'] as String,
    // ... mapeo de campos
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    // ... serialización
  };
}
```

### 5. **Core (Infraestructura)**
**Responsabilidad**: Configuración transversal, utilidades, tema

**Subdirectorios**:

#### `config/`
- Variables de entorno
- URLs base de API
- Constantes globales

#### `routing/`
- GoRouter: definición de rutas
- Guards: protección de rutas
- Transiciones: animaciones de navegación

#### `theme/`
- Paleta de colores
- Estilos globales
- TextThemes

#### `widgets/`
- Componentes reutilizables
- Notificaciones
- Elementos comunes (botones, campos, etc.)

#### `utils/`
- Funciones auxiliares
- Extensiones
- Validadores

## 🔌 Flujo de Datos

### Flujo Típico: Obtener Lista de Citas

```
Usuario abre AppointmentsScreen
         │
         ▼
ref.watch(appointmentProviderProvider)
         │
         ▼
¿Datos en caché? 
   ├─ Sí → Mostrar datos
   └─ No → Hacer request
         │
         ▼
ref.watch(dioClientProvider).get('/client/appointments')
         │
         ▼
Interceptor agrega Authorization header
         │
         ▼
Backend responde con lista de citas
         │
         ▼
Riverpod cachea la respuesta
         │
         ▼
Widget se reconstruye con AsyncValue.data(citas)
         │
         ▼
ListView muestra citas
```

### Flujo Completo: Crear Cita

```
Usuario completa formulario y toca "Confirmar"
         │
         ▼
Validar campos requeridos
         │
         ▼
CreateAppointmentRequest(peluqueroId, servicioId, ...)
         │
         ▼
ref.read(createAppointmentProvider(request).future)
         │
         ▼
POST /api/client/appointments con datos
         │
         ▼
Backend valida y crea en MongoDB
         │
         ▼
Backend responde: { message, cita: {...} }
         │
         ▼
createAppointmentProvider invalida appointmentProviderProvider
         │
         ▼
appointmentProviderProvider refetch automático
         │
         ▼
GET /api/client/appointments
         │
         ▼
Riverpod actualiza caché
         │
         ▼
AppointmentsScreen se reconstruye con nueva lista
         │
         ▼
Nueva cita aparece en UI
```

## 🔐 Manejo de Autenticación

### Token Flow

```
1. Usuario hace login
   ├─ POST /api/auth/login
   ├─ Backend valida y retorna { token, user }
   └─ Token se almacena en SecureStorage

2. Cada request incluye token
   ├─ Interceptor lo agrega al header
   └─ Authorization: Bearer <token>

3. Si token expira
   ├─ Backend retorna 401 Unauthorized
   ├─ Interceptor lo detecta
   └─ Redirige a login

4. Logout
   ├─ POST /api/auth/logout
   ├─ Token se elimina de storage
   └─ Usuario redirigido a login
```

### Providers de Auth

```dart
// Token guardado
final authTokenProvider = StateProvider<String?>((ref) {
  return null; // Se carga del storage al iniciar
});

// Usuario actual
final currentUserProvider = FutureProvider<Usuario?>((ref) {
  final token = ref.watch(authTokenProvider);
  if (token == null) return null;
  // Decodificar JWT y retornar usuario
});

// Notifier para login/logout
final authNotifierProvider = NotifierProvider<AuthNotifier, ...>(
  () => AuthNotifier(),
);
```

## 🎯 Patrones de Error Handling

### En Presentación
```dart
appointmentsAsync.when(
  data: (citas) => ListView(...),
  loading: () => LoadingWidget(),
  error: (error, stackTrace) {
    showFloatingNotification(
      context,
      title: 'Error',
      message: error.toString(),
      type: NotificationType.error,
    );
    return SizedBox.shrink();
  },
);
```

### En Notifiers
```dart
try {
  // Operación
  await dioClient.patch(...);
  ref.invalidate(appointmentProviderProvider);
  state = const AsyncValue.data(null);
} catch (e, stackTrace) {
  state = AsyncValue.error(e, stackTrace);
  rethrow; // Para que la pantalla lo maneje
}
```

### En API
```dart
// DioException es lanzado automáticamente
catch (e) {
  if (e is DioException) {
    if (e.response?.statusCode == 400) {
      // Error de validación
      throw Exception('Validación: ${e.response?.data}');
    } else if (e.response?.statusCode == 401) {
      // No autorizado
      throw Exception('Sesión expirada');
    }
  }
  throw Exception('Error al procesar: $e');
}
```

## 🧪 Testabilidad

### Por qué esta arquitectura es testeable:

1. **Separación de Concerns**: Cada capa tiene una responsabilidad
2. **Providers Inyectables**: Riverpod permite reemplazar providers en tests
3. **DTOs Simples**: Fáciles de mockear
4. **Modelos Inmutables**: Predecibles

### Ejemplo de Test:
```dart
test('Create appointment should invalidate list', () async {
  // Arrange
  final container = ProviderContainer();
  final mockDio = MockDio();
  
  // Override provider con mock
  container.read(dioClientProvider).overrideWithValue(mockDio);
  
  // Act
  final result = await container.read(
    createAppointmentProvider(request).future
  );
  
  // Assert
  expect(result, isA<Cita>());
  verify(mockDio.post).called(1);
});
```

## 📊 Diagrama de Estado (Riverpod)

```
Initial State (vacío/null)
        │
        ▼
Loading (cargando datos)
        │
        ├─ Success → AsyncValue.data(datos)
        │   │
        │   └─ Usuarios pueden actuar
        │       │
        │       └─ Invalidar caché
        │           │
        │           └─ Vuelve a Loading
        │
        └─ Error → AsyncValue.error(exception)
            │
            └─ Usuarios ven mensaje de error
                │
                └─ Pueden reintentar
```

## 🚀 Optimizaciones

### Caching
- **FutureProvider**: Cachea automáticamente
- **Invalidation**: Control manual de actualización
- **Deduplication**: Riverpod evita requests duplicados

### Performance
- **Lazy Loading**: Solo carga cuando se necesita
- **Code Splitting**: Features separadas
- **Asset Optimization**: Imágenes optimizadas

## 🔄 Ciclo de Desarrollo

1. **Feature Planning**
   - Definir pantallas
   - Definir modelos en `domain/`

2. **Backend Integration**
   - Endpoint especificado en `ENDPOINTS_MAPPING.md`
   - DTOs en `data/dtos/`

3. **State Management**
   - Provider en `application/`
   - Caché estrategia definida

4. **Presentation**
   - Screen en `presentation/`
   - Widgets reutilizables si es necesario

5. **Testing & Refinement**
   - Validación en device real
   - Ajustes de UI/UX

## 📚 Referencias

- [Riverpod Docs](https://riverpod.dev)
- [GoRouter Docs](https://pub.dev/packages/go_router)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture)

---

**Última actualización**: Diciembre 2025
