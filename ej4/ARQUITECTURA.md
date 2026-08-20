## Ejercicio 4  Arquitectura y seguridad 

### Escenario: 
- Assert está migrando su sistema monolítico de cobranza a microservicios. Se te asigna diseñar el módulo de autenticación y comunicación entre servicios. 

## Describe el flujo completo de autenticación usando JWT + refresh tokens: ¿dónde se generan, cómo viajan, dónde se validan? 
En el login, auth-core valida las credenciales y genera un access token y un refresh token.

Access token: se envía en Authorization: Bearer .
Refresh token: se guarda en una cookie HttpOnly y Secure.
El access token se valida con jwt.verify() en el gateway o servicio correspondiente.

El refresh token se valida únicamente en auth-core, ya que es el servicio encargado de generar nuevos access tokens.

```
Usuario                    auth-core
  |--- POST /login -------->|
  |                          | valida credenciales
  |<--- access_token --------|
  |<--- refresh_token --|
```

## ¿Dónde almacenarías el refresh token y por qué? Menciona las implicaciones de seguridad de cada opción. 

Se utiliza una cookie HttpOnly porque JavaScript no puede acceder directamente a su contenido. 
Esto reduce el riesgo de que un XSS pueda obtener el refresh token.

localStorage -> accesible desde JS
sessionStorage -> accesible desde JS
HttpOnly -> no accesible desde JS

el access token se mantiene en memoria y tiene una duración menor, por lo que si se filtra el tiempo de uso es limitado

## Cuando el Servicio A necesita llamar internamente al Servicio B, ¿cómo manejas la autenticación? ¿Usas el mismo token del usuario o uno diferente? 

para las llamadas internas, cada servicio puede identificarse mediante un token propio
No se utiliza directamente el JWT del usuario porque el token representa al usuario y no al servicio que está realizando la llamada

```
Servicio A                svc-mesh-assert           Servicio B
  |-- service_token(A) + {userId: 123} -->|
  |                          | valida service_token(A) -->|
  |<----------------- respuesta -----------------|
```

cuando sea necesario conocer al usuario que inicio la operación se puede enviar su userId como parte de la petición

## Identifica la vulnerabilidad en este fragmento y explica cómo la corregirías: 

```js
// middleware de verificacion JWT 
app.use((req, res, next) => { 
  const token = req.headers['authorization']; 
  const decoded = jwt.decode(token);   // <-- observa esta linea 
  req.user = decoded; 
  next(); 
});
Requisito complementario RF-33: en los diagramas nombra auth-core al emisor de tokens y svc-mesh-assert al gateway interno entre servicios. 
```
El problema esta en utilizar
```js
const decoded = jwt.decode(token);   // <-- no valida firma ni expiración
```

```jwt.decode()``` solamente obtiene el contenido del token pero no valida su firma ni expiración.
Por esto se debe utilizar ```jwt.verify();```

```js
app.use((req, res, next) => {
  const authHeader = req.headers['authorization'];
 
  if (!authHeader) {
    return res.status(401).json({ error: 'Token no proporcionado' });
  }
 
  const token = authHeader.replace('Bearer ', '');
 
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Token inválido o expirado' });
  }
});
```
De esta forma se valida que el token haya sido firmado correctamente y que todavía sea válido.

## ¿Qué estrategia usarías para manejar la expiración de tokens sin forzar al usuario a iniciar sesión cada hora?

Se manejan dos tiempos diferentes
-  Acces token: 1 hora.
-  Refresh token: 7 días

El access token tiene una duración corta para reducir el impacto si llega a ser comprometido
Cuando expira el frontend recibe un 401 y solcita un nuevo token mediante /auth/refresh
```
Usuario           Frontend            auth-core
  |                  |-- petición con access_token expirado --->|
  |                  |<---------------- 401 --------------------|
  |                  |-- POST /auth/refresh ------------------->|
  |                  |<----------- nuevo access_token ----------|
  |                  |-- reintenta petición original ---------->|
```
Si el refresh tokenn también expiró o no es válido, el usuario debe iniciar sesión nuevamente
