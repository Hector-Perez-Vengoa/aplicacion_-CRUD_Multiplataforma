# Plan Frontend Flutter para Backend Peluquería

## Arquitectura
- Presentación: Flutter con navegación declarativa (`go_router`), theming consistente y vistas separadas por rol (cliente, peluquero, admin opcional).
- Estado: Riverpod para auth global y features; providers por dominio.
- Datos: Repositorios que usan servicios HTTP (Dio) + almacenamiento local (`flutter_secure_storage` para token, `SharedPreferences` para ajustes ligeros).
- Dominio: Modelos con `json_serializable` únicamente (se eliminó `freezed` por simplicidad en consumo de APIs), DTOs y casos de uso ligeros por feature.

## Autenticación y roles
- Base endpoints `/api/auth`, `/api/client`, `/api/hairstylist`, `/api/admin`.
- JWT en header `Authorization: Bearer <token>`; si 401 → limpiar sesión y reenviar a login.
- Roles: `cliente`, `peluquero`, `admin`; guards en rutas según rol.

## Flujos por rol
- Público: onboarding, ver servicios públicos (`/api/auth/services`), registro (cliente/peluquero), login, OAuth Google (webview/custom tabs + callback).
- Cliente: listar servicios, peluqueros por servicio, disponibilidad, crear cita, ver/historial, detalle, cancelar, perfil, cambiar contraseña.
- Peluquero: agenda día/semana, detalle de cita con historial, marcar completada/no-show, perfil, cambiar contraseña.
- Admin (opcional móvil): CRUD servicios, gestión peluqueros (aprobar/estado), ausencias, citas con filtros, clientes, configuración de negocio.

## Modelos clave
- Entidades: `Usuario`, `Cliente`, `Peluquero`, `Servicio`, `Cita`, `Ausencia`, `NegocioConfig`, `DisponibilidadSlot`.
- DTOs para requests: login/register, crear/cancelar cita, actualizar perfil, cambiar contraseña, aprobar/toggle estados.
- Fechas en ISO 8601; manejar `DateTime` con `toUtc()/toLocal()` y formateo de zona horaria.

## Servicios HTTP
- Cliente Dio con interceptores: añadir token, log en debug, manejo de 401.
- Timeouts, traducción de errores a `Failure` (network, auth, validation, server).
- Helpers para queries (agenda, appointments, clients, services) y construcción de filtros.

## Navegación y UX
- Rutas: `/login`, `/register`, `/oauth-callback`, `/home` (tabs cliente), `/hairstylist/*`, `/admin/*`.
- Guards: si no hay token → login; si rol no coincide → redirigir a home de su rol.
- UI: estados de carga/empty/error reutilizables; pull-to-refresh; confirmaciones en acciones destructivas.
- Agenda: vista día/semana para peluquero con slots de 15 min.

## Configuración y entorno
- `lib/core/config/environment.dart` usando `flutter_dotenv` con `API_BASE_URL`.
- Flavors dev/staging/prod (nombre/id de app diferenciados).
- Internacionalización: al menos es-ES (`flutter_localizations`).

## Testing y calidad
- Unit tests: mapeo DTOs y repos con DioAdapter mock.
- Widget tests: pantallas de login y flujo de crear cita con providers fake.
- Lints: `flutter_lints` + reglas (prefer_const, avoid_print); formato con `dart format`.

## Plan de implementación
1. ✅ Bootstrap Flutter, configurar dependencias (riverpod, dio, json_serializable, go_router, secure_storage, dotenv) y estructura `core/feature/...`.
2. ✅ Auth: modelos `Usuario/AuthResponse` con JsonSerializable, repo y servicios; login/register/me/logout; guard de rutas; persistencia de token.
3. 🔄 Cliente: servicios, peluqueros, disponibilidad, crear/gestionar citas, perfil.
4. 🔄 Peluquero: agenda y gestión de citas.
5. ⏳ Admin (si se incluye) para gestión completa.
6. ⏳ UX transversal: estados comunes, theming, accesibilidad, i18n.
7. ⏳ Tests clave y endurecimiento de errores.

### Cambios realizados
- **Eliminado Freezed**: Migrado a clases simples con `@JsonSerializable` para facilitar consumo de APIs
- Modelos convertidos: Usuario, AuthResponse, LoginRequest, RegisterRequest, Cliente, Peluquero, Servicio, Cita, Ausencia, DisponibilidadSlot
- Auth provider usando `Notifier` pattern (Riverpod 3.x)
- Dio client configurado con interceptores (token, logging)
- Flutter Secure Storage para persistencia de token
- Go Router con guards de autenticación

## Arquitectura de carpetas (afinada)
```
lib/
	core/
		config/	      # env, constantes, API base URL
		routing/	  # go_router, guards por rol
		theme/	      # colores, tipografía, spacing
		utils/	      # helpers (fecha/hora, formatos)
		widgets/	  # UI compartida (loaders, empty, error)

	data/
		clients/	  # dio client + interceptores
		repositories/   # repos transversales
		dtos/	      # DTOs transversales si aplica

	domain/
		models/	      # modelos inmutables compartidos

	features/
		auth/
			domain/
				services/
				models/	     # si algo es exclusivo
			application/
			presentation/	 # login, register, oauth callback
			data/
				repositories/
				dtos/
		client/
			domain/
				services/
			application/
			presentation/	 # home tabs, servicios, peluqueros, disponibilidad, citas
			data/
				repositories/
				dtos/
		hairstylist/
			domain/
				services/
			application/
			presentation/	 # agenda día/semana, detalle cita
			data/
				repositories/
				dtos/

	l10n/	              # intl ARB si se usa intl
```

## Dependencias e imports base
- Estado: `flutter_riverpod` (providers).
- Navegación: `go_router`.
- HTTP: `dio` + `pretty_dio_logger` (solo debug).
- Modelos/serialización: `json_annotation`, `json_serializable`, `build_runner` (Freezed eliminado por simplicidad).
- Storage: `flutter_secure_storage`, `shared_preferences`.
- Env: `flutter_dotenv`.
- UI extra: `intl` (fechas), `pull_to_refresh` (opcional), `table_calendar` (opcional agenda).
- Testing: `flutter_test`, `mocktail`, `dio_mock_adapter` o similar.

### Ejemplos de imports clave
```dart
// Routing
import 'package:go_router/go_router.dart';

// Estado
import 'package:flutter_riverpod/flutter_riverpod.dart';

// HTTP
import 'package:dio/dio.dart';

// Modelos (sin Freezed)
import 'package:json_annotation/json_annotation.dart';
part 'usuario.g.dart';

// Almacenamiento seguro
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Env
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Utils de fecha
import 'package:intl/intl.dart';
```
