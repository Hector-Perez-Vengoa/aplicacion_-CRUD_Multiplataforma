# Mapeo de Endpoints API

Este documento muestra el mapeo de endpoints entre lo que la app Flutter espera y los endpoints correctos del backend.

## Cambios Realizados

Todos los endpoints han sido actualizados para que la app Flutter use correctamente las rutas del backend Express.

### Endpoints para Clientes (Autenticación requerida como 'cliente')

| Funcionalidad | Endpoint | Tipo | Parámetros | Provider/Uso |
|---|---|---|---|---|
| Obtener Servicios | `/api/client/services` | GET | - | `serviceProviderProvider` |
| Obtener Peluqueros | `/api/client/hairstylists` | GET | `serviceId` (query) | `hairstylistProviderProvider(serviceId)` |
| Crear Cita | `/api/client/appointments` | POST | - | `createAppointmentProvider` |
| Obtener Mis Citas | `/api/client/appointments` | GET | - | `appointmentProviderProvider` |
| Cancelar Cita | `/api/client/appointments/:id/cancel` | PATCH | - | `cancelAppointmentNotifierProvider` |

### Endpoints para Peluqueros (Autenticación requerida como 'peluquero')

| Funcionalidad | Endpoint | Tipo | Provider/Uso |
|---|---|---|---|
| Obtener Agenda/Citas | `/api/hairstylist/agenda` | GET | `hairstylistAppointmentsProviderProvider` |

### Endpoints Públicos

| Funcionalidad | Endpoint | Tipo | Uso |
|---|---|---|---|
| Login | `/api/auth/login` | POST | `authNotifierProvider.login()` |
| Registro | `/api/auth/register` | POST | `authNotifierProvider.register()` |
| Obtener Servicios (Público) | `/api/auth/services` | GET | `publicServiceProviderProvider` |

## Estructura de las Peticiones

### Obtener Peluqueros (GET /api/client/hairstylists?serviceId=:serviceId)

**Parámetros requeridos:**
- `serviceId` (query): ID del servicio para el cual obtener peluqueros especializados

**Ejemplo en Flutter:**
```dart
final response = await dioClient.get(
  '/client/hairstylists',
  queryParameters: {'serviceId': '507f1f77bcf86cd799439011'}
);
```

**El provider es parametrizado:**
```dart
final hairstylistsAsync = ref.watch(hairstylistProviderProvider(serviceId));
```

### Crear Cita (POST /api/client/appointments)

```dart
{
  "peluqueroId": "string",
  "servicioId": "string",
  "fecha": "ISO8601 DateTime",
  "hora": "HH:mm"
}
```

### Cancelar Cita (PATCH /api/client/appointments/:id/cancel)

```dart
{
  "motivo": "string (opcional)"
}
```

## Tokens y Autenticación

- Todos los endpoints excepto login y registro requieren autenticación
- El token se envía en el header: `Authorization: Bearer {token}`
- El token se obtiene en login/register y se almacena en `SecureStorageService`
- El token se incluye automáticamente en todas las peticiones via `DioClient`

## Gestión de Errores

### Error 404 - Ruta no encontrada

Si ves este error, verifica que:
1. El endpoint sea el correcto según la tabla anterior
2. El usuario esté autenticado (token válido)
3. El usuario tenga el rol correcto (cliente, peluquero, admin)

### Error 401 - No autorizado

- Token expirado o inválido
- Usuario sin el rol requerido para el endpoint

## Notas importantes sobre los providers

### Servicios
- **`serviceProviderProvider`**: Usa `/api/client/services` y requiere autenticación (cliente)
- **`publicServiceProviderProvider`**: Usa `/api/auth/services` y NO requiere autenticación (para registro)

Usa `publicServiceProviderProvider` en el registro para mostrar servicios sin estar autenticado.

Para verificar que los endpoints funcionan correctamente, puedes usar:

```bash
# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","contrasena":"password"}'

# Obtener servicios (reemplaza {token} con el token del login)
curl -X GET http://localhost:5000/api/client/services \
  -H "Authorization: Bearer {token}"

# Obtener peluqueros
curl -X GET http://localhost:5000/api/client/hairstylists \
  -H "Authorization: Bearer {token}"

# Obtener mis citas
curl -X GET http://localhost:5000/api/client/appointments \
  -H "Authorization: Bearer {token}"
```
