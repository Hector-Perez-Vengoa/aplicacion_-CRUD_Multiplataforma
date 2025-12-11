# Guía de Desarrollo - Barbería Noir

Guía práctica para desarrolladores que trabajan en el proyecto.

## 🚀 Comenzar

### Setup Inicial

```bash
# 1. Clonar repo
git clone <repo-url>
cd flutter_peluqueria

# 2. Instalar dependencias
flutter pub get

# 3. Configurar .env
cp .env.example .env
# Editar con URL del backend

# 4. Ejecutar en emulador/device
flutter run
```

### Backend Esperado

El backend debe estar corriendo en `http://localhost:5000`

```bash
# En otra terminal
cd backend_peluqueria
npm install
npm start
```

## 📋 Estructura de Carpetas

```
lib/
├── main.dart                          ← Punto de entrada
│
├── core/                              ← Infraestructura compartida
│   ├── config/
│   │   └── environment.dart          ← Variables de entorno
│   ├── routing/
│   │   └── app_router.dart           ← Rutas GoRouter
│   ├── theme/
│   │   └── app_theme.dart            ← Estilos y colores
│   ├── utils/
│   │   └── ...                       ← Funciones auxiliares
│   └── widgets/
│       └── floating_notification.dart ← Sistema de notificaciones
│
├── domain/                            ← Entidades (sin lógica)
│   └── models/
│       ├── cita.dart
│       ├── usuario.dart
│       ├── peluquero.dart
│       ├── servicio.dart
│       └── cliente.dart
│
├── features/                          ← Lógica y presentación
│   ├── auth/                         ← Autenticación
│   │   ├── presentation/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── application/
│   │   │   └── auth_provider.dart
│   │   └── data/
│   │       └── dtos/
│   │
│   ├── client/                       ← Funcionalidades cliente
│   │   ├── presentation/
│   │   │   ├── client_home_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── services_screen.dart
│   │   │   ├── appointments_screen.dart
│   │   │   ├── book_appointment_screen.dart
│   │   │   ├── edit_appointment_screen.dart
│   │   │   └── profile_screen.dart
│   │   ├── application/
│   │   │   ├── appointment_provider.dart
│   │   │   ├── service_provider.dart
│   │   │   └── client_provider.dart
│   │   └── data/
│   │       └── dtos/
│   │
│   └── hairstylist/                 ← Funcionalidades peluquero
│       ├── presentation/
│       │   └── hairstylist_home_screen.dart
│       └── application/
│
└── data/                             ← Capa de datos
    └── (servicios de acceso a datos)
```

## 📝 Convenciones de Código

### Nombres de Archivos
- **snake_case** para archivos
  ```
  ✓ appointment_screen.dart
  ✗ AppointmentScreen.dart
  ✗ appointmentScreen.dart
  ```

### Nombres de Clases
- **PascalCase** para clases
  ```dart
  class AppointmentScreen extends StatelessWidget {}
  class AppointmentProvider extends Notifier {}
  ```

### Nombres de Variables
- **camelCase** para variables
  ```dart
  final appointmentList = [...];
  String userName = 'Juan';
  ```

### Nombres de Constantes
- **UPPER_SNAKE_CASE** para constantes globales
  ```dart
  const String API_BASE_URL = 'http://localhost:5000';
  const Duration REQUEST_TIMEOUT = Duration(seconds: 30);
  ```

### Imports
- Agrupar y ordenar:
  ```dart
  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  
  import '../../../domain/models/cita.dart';
  import '../../../core/widgets/floating_notification.dart';
  ```

## 🔧 Tareas Comunes

### Crear una Nueva Pantalla

1. **Crear archivo en presentación**
   ```
   features/client/presentation/new_screen.dart
   ```

2. **Estructura base**
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:go_router/go_router.dart';

   class NewScreen extends ConsumerWidget {
     const NewScreen({super.key});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       return Scaffold(
         appBar: AppBar(title: const Text('Nueva Pantalla')),
         body: const Center(child: Text('Contenido')),
       );
     }
   }
   ```

3. **Agregar ruta en `core/routing/app_router.dart`**
   ```dart
   GoRoute(
     path: '/new-screen',
     name: 'newScreen',
     builder: (context, state) => const NewScreen(),
   ),
   ```

4. **Navegar**
   ```dart
   context.pushNamed('newScreen');
   // o
   context.go('/new-screen');
   ```

### Crear un Provider

1. **En `application/my_provider.dart`**
   ```dart
   import 'package:flutter_riverpod/flutter_riverpod.dart';

   // Para lectura (automático caching)
   final myListProvider = FutureProvider<List<MyModel>>((ref) async {
     final dioClient = ref.watch(dioClientProvider);
     final response = await dioClient.get('/my-endpoint');
     return (response.data as List)
         .map((json) => MyModel.fromJson(json))
         .toList();
   });

   // Para escritura (con notifier)
   class MyNotifier extends Notifier<AsyncValue<MyModel>> {
     @override
     AsyncValue<MyModel> build() => const AsyncValue.data(null);

     Future<MyModel> createItem(String name) async {
       state = const AsyncValue.loading();
       try {
         final dioClient = ref.read(dioClientProvider);
         final response = await dioClient.post(
           '/my-endpoint',
           data: {'name': name},
         );
         final model = MyModel.fromJson(response.data);
         
         // Invalidar lista para refrescar
         ref.invalidate(myListProvider);
         
         state = AsyncValue.data(model);
         return model;
       } catch (e, st) {
         state = AsyncValue.error(e, st);
         rethrow;
       }
     }
   }

   final myNotifierProvider = NotifierProvider<MyNotifier, AsyncValue<MyModel>>(
     () => MyNotifier(),
   );
   ```

2. **Usar en pantalla**
   ```dart
   // Lectura
   final data = ref.watch(myListProvider);

   // Escritura
   ref.read(myNotifierProvider.notifier).createItem('nuevo');
   ```

### Crear un Modelo

1. **En `domain/models/my_model.dart`**
   ```dart
   class MyModel {
     final String id;
     final String name;
     final DateTime createdAt;

     MyModel({
       required this.id,
       required this.name,
       required this.createdAt,
     });

     factory MyModel.fromJson(Map<String, dynamic> json) => MyModel(
       id: json['_id'] as String,
       name: json['name'] as String,
       createdAt: DateTime.parse(json['createdAt'] as String),
     );

     Map<String, dynamic> toJson() => {
       '_id': id,
       'name': name,
       'createdAt': createdAt.toIso8601String(),
     };
   }
   ```

### Agregar un Endpoint

1. **Backend**: Implementar en Node.js/Express

2. **Frontend DTO**: `features/[feature]/data/dtos/my_request.dart`
   ```dart
   class MyRequest {
     final String name;
     final String? description;

     MyRequest({required this.name, this.description});

     Map<String, dynamic> toJson() => {
       'name': name,
       if (description != null) 'description': description,
     };
   }
   ```

3. **Provider**: Crear en `application/`
   ```dart
   final myEndpointProvider = FutureProvider.family<MyModel, MyRequest>(
     (ref, request) async {
       final dio = ref.watch(dioClientProvider);
       final response = await dio.post('/my-endpoint', data: request.toJson());
       return MyModel.fromJson(response.data);
     },
   );
   ```

4. **Usar en Screen**
   ```dart
   final request = MyRequest(name: 'Test');
   final result = await ref.read(myEndpointProvider(request).future);
   ```

## 🎯 Patrones Comunes

### Validación de Formulario

```dart
bool _validateForm() {
  if (_nameController.text.isEmpty) {
    showFloatingNotification(
      context,
      title: 'Error',
      message: 'El nombre es requerido',
      type: NotificationType.error,
    );
    return false;
  }
  return true;
}

void _submitForm() {
  if (!_validateForm()) return;
  // Proceder...
}
```

### Loading Dialog

```dart
void _showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Procesando...'),
        ],
      ),
    ),
  );
}

// Usar:
_showLoadingDialog(context);
try {
  // operación
} finally {
  if (mounted && Navigator.canPop(context)) {
    Navigator.of(context).pop();
  }
}
```

### Confirmación Dialog

```dart
Future<bool> _showConfirmDialog(
  BuildContext context,
  String title,
  String message,
) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  ) ?? false;
}

// Usar:
if (await _showConfirmDialog(context, 'Eliminar', '¿Está seguro?')) {
  // Proceder con eliminación
}
```

### Notificaciones

```dart
// Éxito
await showFloatingNotification(
  context,
  title: 'Éxito',
  message: 'Operación completada',
  type: NotificationType.success,
  duration: const Duration(seconds: 2),
);

// Error
await showFloatingNotification(
  context,
  title: 'Error',
  message: 'Algo salió mal: $error',
  type: NotificationType.error,
  duration: const Duration(seconds: 3),
);

// Advertencia
await showFloatingNotification(
  context,
  title: 'Advertencia',
  message: 'Por favor completa todos los campos',
  type: NotificationType.warning,
  duration: const Duration(seconds: 3),
);
```

## 🐛 Debugging

### Activar Logs de Dio
Ya está habilitado con `PrettyDioLogger` - verá en consola:
```
╔═══════════════════════════════════════════════════════════╗
║ Request ║ POST http://localhost:5000/api/auth/login
├─────────────────────────────────────────────────────────┤
║ Headers │ Content-Type: application/json
║ Body    │ {email: test@test.com, password: ...}
╚═══════════════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════════════╗
║ Response ║ Status: 200 OK ║ Time: 150 ms
├─────────────────────────────────────────────────────────┤
║ Body    │ {token: ..., user: {...}}
╚═══════════════════════════════════════════════════════════╝
```

### Flutter DevTools

```bash
# Abrir DevTools
flutter pub global activate devtools
flutter pub global run devtools

# O desde VS Code: View → Command Palette → Flutter: Open DevTools
```

### Revisar Estado de Riverpod

En DevTools → Riverpod tab:
- Ver todos los providers activos
- Ver valores cacheados
- Invalidar providers manualmente
- Ver historial de cambios

### Print Debug

```dart
print('DEBUG: $variable');
debugPrint('DEBUG: $variable'); // Mejor, respeta línea máx
```

## ✅ Antes de Hacer Commit

1. **Análisis**
   ```bash
   flutter analyze
   ```

2. **Formato**
   ```bash
   dart format lib/ -l 100
   ```

3. **Tests** (cuando existan)
   ```bash
   flutter test
   ```

4. **Verificar en Device Real**
   - Probar flujo completo
   - Verificar UI en diferentes tamaños
   - Verificar conexión a backend

## 📊 Git Workflow

```bash
# Crear rama para feature
git checkout -b feature/nombre-feature

# Hacer commits frecuentes
git commit -m "feat: descripción breve"

# Hacer push
git push origin feature/nombre-feature

# Crear Pull Request en GitHub
# Esperar review y merge
```

### Formato de Commits
```
feat: Agregar nueva feature
fix: Corregir bug específico
refactor: Mejorar código sin cambiar funcionalidad
style: Cambios de formato (spaces, tabs, etc)
docs: Actualizar documentación
chore: Actualizar dependencias, etc
```

## 🚨 Problemas Comunes

### "Campos requeridos" en Notificación

**Problema**: Notificación aparece con texto subrayado
**Solución**: Asegurar que el texto no tenga decoración

```dart
style: TextStyle(
  decoration: TextDecoration.none, // ← Agregado
)
```

### Cita creada pero no aparece en listado

**Problema**: Backend responde 201, pero no aparece en UI
**Solución**: Invalidar provider después de crear

```dart
// En el notifier:
ref.invalidate(appointmentProviderProvider);
```

### Colores inconsistentes en notificaciones

**Problema**: Notificaciones con colores personalizados
**Solución**: Usar `type: NotificationType.success` en lugar de `color:`

```dart
// Mal:
color: Colors.green.shade50,

// Bien:
type: NotificationType.success,
```

### Errores de tipo en Riverpod

**Problema**: `Type mismatch` en providers
**Solución**: Verificar tipos genéricos

```dart
// Asegurar <Tipo> correcto
final provider = FutureProvider<List<Cita>>(...);
final notifier = NotifierProvider<MyNotifier, AsyncValue<void>>(...);
```

## 📚 Recursos Útiles

- [Flutter Docs](https://flutter.dev/docs)
- [Riverpod Docs](https://riverpod.dev)
- [GoRouter Docs](https://pub.dev/packages/go_router)
- [Dio Docs](https://pub.dev/packages/dio)
- [Material Design](https://material.io/design)

## 💡 Tips & Tricks

### Hot Reload en VS Code
- `Ctrl+S` (o `Cmd+S`) guarda y hot reload
- `Ctrl+Shift+F5` (o `Cmd+Shift+F5`) hot restart
- Hot reload mantiene estado
- Hot restart reinicia la app

### Ayuda Rápida
```bash
# Ver comandos flutter
flutter --help

# Analizar proyecto
flutter analyze

# Ver información de device
flutter devices

# Limpiar compilación
flutter clean
```

---

**Última actualización**: Diciembre 2025
**Versión**: 1.0.0
