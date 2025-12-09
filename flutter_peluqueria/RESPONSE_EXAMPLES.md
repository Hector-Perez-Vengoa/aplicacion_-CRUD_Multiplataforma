# Ejemplos de Respuestas del Backend

Este archivo contiene ejemplos de las respuestas JSON que el backend debe enviar para que la app Flutter funcione correctamente.

## Endpoints API Utilizados

### Para Clientes:
- `POST /api/auth/login` - Login
- `POST /api/auth/register` - Registro
- `GET /api/client/services` - Obtener servicios disponibles
- `GET /api/client/hairstylists` - Obtener peluqueros disponibles
- `GET /api/client/availability` - Obtener horarios disponibles
- `POST /api/client/appointments` - Crear cita
- `GET /api/client/appointments` - Obtener mis citas
- `PATCH /api/client/appointments/:id/cancel` - Cancelar cita

### Para Peluqueros:
- `GET /api/hairstylist/agenda` - Obtener agenda/citas del peluquero

## Login/Register Response

### Opción 1: Estructura plana (recomendada)
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "usuario": {
    "_id": "6756c8f8a1b2c3d4e5f67890",
    "nombre": "Juan Pérez",
    "email": "juan@example.com",
    "telefono": "123456789",
    "rol": "cliente",
    "activo": true,
    "createdAt": "2024-12-09T10:00:00.000Z",
    "updatedAt": "2024-12-09T10:00:00.000Z"
  },
  "redirectUrl": "/home"
}
```

### Opción 2: Estructura anidada en 'data'
```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "usuario": {
      "_id": "6756c8f8a1b2c3d4e5f67890",
      "nombre": "María García",
      "email": "maria@example.com",
      "telefono": "987654321",
      "rol": "peluquero",
      "activo": true,
      "createdAt": "2024-12-09T10:00:00.000Z",
      "updatedAt": "2024-12-09T10:00:00.000Z"
    },
    "redirectUrl": "/hairstylist"
  }
}
```

### Opción 3: Usuario con campo 'user' en lugar de 'usuario'
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "6756c8f8a1b2c3d4e5f67890",
    "nombre": "Admin User",
    "email": "admin@example.com",
    "telefono": "555555555",
    "rol": "admin",
    "activo": true
  }
}
```

## Campos del Usuario

### Campos obligatorios:
- `_id` o `id`: ID del usuario
- `nombre` o `name`: Nombre completo
- `email`: Correo electrónico
- `rol` o `role`: Rol del usuario (cliente, peluquero, admin)

### Campos opcionales:
- `telefono` o `phone`: Teléfono (default: "")
- `activo` o `active`: Estado activo (default: true)
- `createdAt`: Fecha de creación
- `updatedAt`: Fecha de actualización
- `redirectUrl`: URL de redirección después del login

## Ejemplo de Error de Login

```json
{
  "message": "Credenciales inválidas",
  "statusCode": 401
}
```

## Servicios Response

```json
[
  {
    "_id": "6756c8f8a1b2c3d4e5f67890",
    "nombre": "Corte de cabello",
    "descripcion": "Corte clásico profesional",
    "duracion": 30,
    "precio": 25.00
  },
  {
    "_id": "6756c8f8a1b2c3d4e5f67891",
    "nombre": "Tinte",
    "descripcion": "Tinte profesional",
    "duracion": 60,
    "precio": 50.00
  }
]
```

## Peluqueros Response

```json
[
  {
    "_id": "6756c8f8a1b2c3d4e5f67892",
    "usuario": "6756c8f8a1b2c3d4e5f67890",
    "serviciosEspecializados": ["6756c8f8a1b2c3d4e5f67890", "6756c8f8a1b2c3d4e5f67891"],
    "horarioDisponible": {
      "lunes": {"inicio": "09:00", "fin": "18:00", "disponible": true},
      "martes": {"inicio": "09:00", "fin": "18:00", "disponible": true}
    },
    "estado": "activo"
  }
]
```

## Citas Response

```json
[
  {
    "_id": "6756c8f8a1b2c3d4e5f67893",
    "cliente": "6756c8f8a1b2c3d4e5f67890",
    "peluquero": "6756c8f8a1b2c3d4e5f67892",
    "servicio": "6756c8f8a1b2c3d4e5f67890",
    "fechaInicio": "2024-12-15T10:00:00.000Z",
    "fechaFin": "2024-12-15T10:30:00.000Z",
    "estado": "confirmada",
    "precioTotal": 25.00,
    "notasCliente": "Preferencia de corte en los lados"
  }
]
```

## Agenda Peluquero Response

Similar al de Citas, pero con las citas asignadas al peluquero autenticado.

## Notas Importantes

1. **Token**: Debe ser una cadena de texto (String), no null
2. **Usuario**: Debe ser un objeto JSON válido, no null
3. **Rol**: Los valores válidos son: "cliente", "peluquero", "admin"
4. **RedirectUrl**: Es opcional, pero si se proporciona debe ser un String

## Estructura Actual del Código Flutter

El código Flutter ahora soporta múltiples formatos:
- Token puede estar en `json['token']` o `json['data']['token']`
- Usuario puede estar en `json['usuario']`, `json['user']`, `json['data']['usuario']` o `json['data']['user']`
- Los campos del usuario aceptan variantes en inglés y español
