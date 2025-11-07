# Decisiones Técnicas
## Kings League Teams Manager App

---

## Arquitectura: Clean Architecture

### ¿Por qué Clean Architecture?

**Decisión**: Implementar una arquitectura en capas separando Domain, Data y Presentation.

**Justificación**:

1. **Separación de responsabilidades**: Cada capa tiene un propósito específico y bien definido:
    - **Domain**: Lógica de negocio pura, sin dependencias externas
    - **Data**: Implementación de acceso a datos (API, Base de datos)
    - **Presentation**: UI y gestión de estado

2. **Testabilidad**: Las capas pueden probarse de forma independiente sin necesidad de infraestructura completa

3. **Mantenibilidad**: Los cambios en una capa no afectan a las demás. Por ejemplo:
    - Cambiar de Hive a SQLite solo afecta la capa Data
    - Modificar la UI no requiere tocar lógica de negocio

4. **Escalabilidad**: Se vuelve fácil agregar nuevas funcionalidades sin romper código existente

5. **Requerimiento de la prueba**: El documento especifica código limpio y modular

**Beneficios obtenidos**:
- Si la API cambia su estructura, solo modificamos `data/datasources` y `data/models`
- Si cambiamos de Hive a SQLite, solo modificamos `data/datasources` y `data/models`
- La lógica de negocio (domain) permanece intacta ante cambios técnicos
- Los Cubits solo conocen interfaces, no implementaciones concretas

**Ejemplo práctico**:
```dart
// Cubit depende de la interfaz (Domain)
class ApiCubit extends Cubit<ApiState> {
  final TeamRepository repository; // ← Interfaz, no implementación
  
  Future<void> getTeams() async {
    final result = await repository.getTeams();
    // ...
  }
}

// La implementación puede cambiar sin afectar el Cubit
class TeamRepositoryImpl implements TeamRepository {
  final TeamDataSource dataSource;
  // Puede usar cualquier DataSource
}
```

---

## Persistencia Local: Hive

### ¿Por qué Hive sobre SQLite o Drift?

**Opciones evaluadas**:

| Tecnología | Ventajas | Desventajas |
|------------|----------|-------------|
| **SQLite** | Robusto, SQL queries, ampliamente usado | Más complejo, requiere queries SQL, más boilerplate |
| **Drift** | Type-safe, SQL, código generado | Mayor configuración, curva de aprendizaje |
| **Hive** | Simple, rápido, NoSQL, menos código | No soporta relaciones complejas |

**Decisión**: Hive

**Justificación**:

1. **Simplicidad**: No requiere queries SQL complejas por lo que se ajusta para este caso de uso
   ```dart
   // Hive - Simple y directo
   await box.put('key', preference);
   final pref = box.get('key');

   // vs SQLite - Más verboso
   await db.insert('preferences', preference.toMap());
   final maps = await db.query('preferences', where: 'id = ?', whereArgs: [id]);
   final pref = Preference.fromMap(maps.first);
   ```

2. **Performance**: Hive es más rápido que SQLite para operaciones simples de lectura/escritura
    - Hive: ~1ms para operaciones CRUD
    - SQLite: ~10ms con overhead de queries

3. **Configuración mínima**: Menos boilerplate que Drift
    - Solo necesitas definir el modelo con anotaciones
    - Build runner genera el adaptador automáticamente

4. **Type-safe**: Con code generation, mantiene seguridad de tipos
   ```dart
   @HiveType(typeId: 0)
   class PreferenceModel extends HiveObject {
     @HiveField(0)
     final String id;
   }
   ```

5. **Caso de uso adecuado**: Guardamos objetos completos (preferencias), no necesitamos:
    - Relaciones complejas entre tablas
    - Queries SQL avanzadas (JOINs, GROUP BY, etc.)
    - Transacciones complejas


---

## Gestión de Estado: BLoC/Cubit

### ¿Por qué Cubit y no otros gestores de estado?

**Opciones evaluadas**:

| Gestor de Estado | Complejidad | Curva de Aprendizaje | Escalabilidad |
|------------------|-------------|---------------------|---------------|
| **Provider** | Baja | Baja | Media |
| **Riverpod** | Media-Alta | Media | Alta |
| **GetX** | Baja | Baja | Media |
| **BLoC/Cubit** | Media | Media | Muy Alta |

**Decisión**: Cubit (de la familia BLoC)

**Justificación**:

1. **Requerimiento explícito**: El documento especifica usar BLoC/Cubit

2. **Predecible**: Flujo unidireccional de datos
   ```
   Event/Method → Cubit → New State → UI Rebuild
   ```

3. **Separación de lógica**: UI completamente separada de lógica de negocio
   ```dart
   // Lógica aislada en el Cubit
   class ApiCubit extends Cubit<ApiState> {
     Future<void> getTeams() async {
       emit(ApiLoading());
       final result = await repository.getTeams();
       result.fold(
         (failure) => emit(ApiError(message: failure.message)),
         (teams) => emit(ApiLoaded(teams: teams)),
       );
     }
   }
   
   // UI solo observa y reacciona
   BlocBuilder<ApiCubit, ApiState>(
     builder: (context, state) {
       if (state is ApiLoading) return LoadingWidget();
       if (state is ApiError) return ErrorWidget(state.message);
       if (state is ApiLoaded) return TeamsList(state.teams);
     },
   )
   ```

**Cubit vs BLoC completo**:

Elegí **Cubit** en lugar de BLoC completo porque:

| Aspecto | Cubit | BLoC |
|---------|-------|------|
| **Complejidad** | Más simple | Más complejo |
| **Uso** | `emit(newState)` | `add(Event) + mapEventToState` |
| **Código** | Menos boilerplate | Más boilerplate |
| **Caso de uso** | CRUD simple | Lógica compleja con múltiples eventos |

```dart
// Cubit - Directo
void deletePreference(String id) {
  emit(PreferenceLoading());
  // lógica...
  emit(PreferenceActionSuccess());
}

// BLoC - Más código
// Requiere: Event class + mapEventToState + add(event)
```

Para operaciones CRUD simples como las de este proyecto, **Cubit es suficiente y más eficiente**.

**Estados implementados**:

```dart
// Estados claros y predecibles
abstract class ApiState extends Equatable {}

class ApiInitial extends ApiState {}
class ApiLoading extends ApiState {}
class ApiLoaded extends ApiState {
  final List<Team> teams;
  final List<Team> filteredTeams;
  final String searchQuery;
}
class ApiError extends ApiState {
  final String message;
}
```

---

## Navegación: go_router

### ¿Por qué go_router?

1. **Declarativo**: Define rutas de forma clara y estructurada
   ```dart
   GoRoute(
     path: '/prefs/:id',
     name: 'preference-detail',
     builder: (context, state) {
       final id = state.pathParameters['id']!;
       return TeamDetailPage(preferenceId: id);
     },
   )
   ```

2. **Type-safe**: Parámetros de ruta con validación en tiempo de compilación
   ```dart
   // Typo-safe navigation
   context.push('/prefs/$id');
   context.go(AppRouter.preferences);
   ```

3. **Deep linking**: Soporte nativo para URLs, útil para web y compartir enlaces

4. **Redirecciones**: Fácil implementar guards y redirecciones
   ```dart
   redirect: (context, state) {
     if (!isAuthenticated) return '/login';
     return null;
   }
   ```

5. **Recomendación oficial**: Google recomienda go_router para nuevos proyectos Flutter

6. **Menos boilerplate**: Mucho más simple que Navigator 2.0 manual
   ```dart
   // go_router - Una línea
   context.push('/prefs/new');
   
   // Navigator 2.0 - Múltiples líneas
   Navigator.of(context).push(
     MaterialPageRoute(
       builder: (context) => PreferenceFormPage(),
     ),
   );
   ```

7. **Manejo de rutas dinámicas**: Parámetros y query strings fáciles de manejar

**Comparativa con Navigator tradicional**:

| Característica | Navigator 1.0 | Navigator 2.0 | go_router |
|---------------|---------------|---------------|-----------|
| Configuración | Simple | Compleja | Media |
| Deep Links | Manual | Soportado | Integrado |
| Type Safety | No | Parcial | Sí |
| Declarativo | No | Sí | Sí |
| Boilerplate | Bajo | Alto | Medio |

**Rutas implementadas**:
```dart
/api-list       → Lista de equipos de la API
/prefs          → Lista de preferencias guardadas
/prefs/new      → Formulario nueva preferencia
/prefs/:id      → Detalle de preferencia específica
```

---

## Inyección de Dependencias: GetIt

### ¿Por qué GetIt?

**Decisión**: GetIt como service locator

**Justificación**:

1. **Simplicidad**: API muy simple y directa de usar
   ```dart
   // Registro
   sl.registerLazySingleton<TeamRepository>(
     () => TeamRepositoryImpl(remoteDataSource: sl()),
   );
   
   // Uso
   final repository = sl<TeamRepository>();
   ```

2. **Sin código generado**: No requiere build_runner adicional (aunque ya se ha usado para Hive)

3. **Singleton pattern**: Maneja ciclos de vida automáticamente
    - `registerSingleton`: Instancia única creada inmediatamente
    - `registerLazySingleton`: Instancia única creada al primer uso
    - `registerFactory`: Nueva instancia en cada llamada

4. **Testeable**: Fácil reemplazar dependencias reales con mocks en tests
   ```dart
   // En tests
   sl.registerLazySingleton<TeamRepository>(
     () => MockTeamRepository(),
   );
   ```

5. **Desacoplamiento**: Las clases no necesitan conocer cómo se crean sus dependencias

6. **Explícito**: No hay "magia" oculta, todo es visible en `injection_container.dart`

**Ventajas sobre alternativas**:

| Característica | GetIt | Provider | Injectable |
|---------------|-------|----------|-----------|
| Setup | Simple | Context required | Requiere generación |
| Tests | Fácil | Medio | Fácil |
| Boilerplate | Bajo | Bajo | Medio |
| Flexibility | Alta | Media | Alta |

**Estructura implementada**:
```dart
Future<void> initializeDependencies() async {
  // External
  sl.registerLazySingleton(() => http.Client());

  // DataSources (Singleton)
  sl.registerLazySingleton<TeamDataSource>(
    () => TeamDataSourceImpl(client: sl()),
  );
  
  // Repositories (Singleton)
  sl.registerLazySingleton<TeamRepository>(
    () => TeamRepositoryImpl(remoteDataSource: sl()),
  );
  
  // Cubits (Factory - nueva instancia cada vez)
  sl.registerFactory(() => ApiCubit(teamRepository: sl()));
}
```

**Por qué Factory para Cubits**:
- Cada pantalla necesita su propia instancia
- Evita state compartido entre navegaciones
- Limpia automáticamente al cerrar la pantalla

---

## HTTP Client: http package

1. **Simplicidad**: Para este caso de uso, http es suficiente
   ```dart
   final response = await client.get(
     Uri.parse('$baseUrl/teams'),
     headers: {'Content-Type': 'application/json'},
   );
   ```

2. **Oficial**: Mantenido por el equipo de Dart/Flutter

3. **Documentación**: Documentación oficial y abundantes ejemplos

4. **Suficiente para API REST simple**:
    - Solo GET requests
    - Headers simples
    - JSON parsing básico

**Para este proyecto**: Consumimos una API REST simple de solo lectura, `http` es perfecto y evita over-engineering.

**Implementación**:
```dart
class TeamDataSource implements TeamDataSource {
  final http.Client client;
  
  @override
  Future<List<TeamModel>> getTeams() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.teamsEndpoint}'),
    ).timeout(ApiConstants.connectionTimeout);
    
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final apiResponse = ApiResponseModel.fromJson(jsonResponse);
      return apiResponse.data;
    }
    
    throw ServerException('Error: ${response.statusCode}');
  }
}
```

---

## Caché de Imágenes: cached_network_image

### ¿Por qué no Image.network directo?

**Decisión**: cached_network_image

**Justificación**:

1. **Performance**: Evita descargar imágenes repetidas
    - Primera carga: Descarga desde red
    - Siguientes cargas: Carga desde cache (instantáneo)

2. **Placeholders**: Muestra widget personalizado mientras carga
   ```dart
   CachedNetworkImage(
     imageUrl: team.logoUrl,
     placeholder: (context, url) => CircularProgressIndicator(),
     errorWidget: (context, url, error) => Icon(Icons.error),
   )
   ```

3. **Error handling**: Widget de error personalizado sin crashear

4. **Experiencia de usuario**:
    - Carga instantánea en revisitas
    - Feedback visual durante carga
    - Fallback elegante en errores

5. **Gestión automática**:
    - Limpia cache automáticamente
    - Maneja expiración de imágenes
    - Optimiza memoria

**Comparativa**:

| Característica | Image.network | cached_network_image |
|---------------|---------------|----------------------|
| Cache | No | Sí |
| Placeholder | No | Sí |
| Error Widget | Básico | Personalizable |
| Performance | Baja | Alta |
| Gestión memoria | Manual | Automática |

---

## Patrón Either: dartz

### ¿Por qué Either<Failure, Success>?

**Decisión**: Usar `Either` de dartz en repositories

**Justificación**:

1. **Programación funcional**: Manejo explícito de errores sin excepciones

2. **Type-safe**: El compilador fuerza manejar ambos casos (éxito y error)
   ```dart
   Future<Either<Failure, List<Team>>> getTeams() async {
     try {
       final teams = await dataSource.getTeams();
       return Right(teams); // Éxito
     } on ServerException catch (e) {
       return Left(ServerFailure(e.message)); // Fallo
     }
   }
   ```

3. **No puedes ignorar errores**: El tipo `Either` obliga a manejar ambos casos
   ```dart
   final result = await repository.getTeams();
   
   // Debes manejar ambos casos con fold
   result.fold(
     (failure) => print('Error: ${failure.message}'),
     (teams) => print('Success: ${teams.length} teams'),
   );
   ```

4. **Clean Architecture**: Estándar en arquitectura limpia para separar capas

5. **Predecible**: No hay excepciones inesperadas volando por el código

6. **Composible**: Fácil encadenar operaciones
   ```dart
   return result
     .map((teams) => teams.where((t) => t.isActive))
     .fold(
       (failure) => Left(failure),
       (filtered) => Right(filtered),
     );
   ```

**Ventajas sobre try-catch tradicional**:

```dart
// Con Either - Explícito y type-safe
Future<Either<Failure, List<Team>>> getTeams() async {
  try {
    final teams = await dataSource.getTeams();
    return Right(teams);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}

// Sin Either - Puede no manejarse
Future<List<Team>> getTeams() async {
  final teams = await dataSource.getTeams(); // ¿Y si falla?
  return teams; // Exception sin manejar puede crashear la app
}
```

**Uso en Cubits**:
```dart
final result = await repository.getTeams();

result.fold(
  (failure) => emit(ApiError(message: failure.message)),
  (teams) => emit(ApiLoaded(teams: teams)),
);
```

---

## Separación Entity vs Model

### ¿Por qué duplicar clases?

**Decisión**: Entidades en domain, Modelos en data

**Justificación**:

1. **Separation of Concerns**: Domain no debe conocer detalles de implementación
    - Domain: Lógica de negocio pura
    - Data: Sabe cómo serializar JSON, guardar en Hive

2. **Independencia**: Cambios en formato de API no afectan lógica de negocio
   ```dart
   // Domain - No sabe de JSON
   class Team {
     final String name;
     final String logoUrl;
   }
   
   // Data - Sabe serializar
   class TeamModel extends Team {
     factory TeamModel.fromJson(Map<String, dynamic> json) {
       return TeamModel(
         name: json['name'],
         logoUrl: json['logoUrl'],
       );
     }
   }
   ```

3. **Testabilidad**: Domain puede testearse sin dependencias de serialización

4. **Arquitectura limpia**: Principio de dependencia invertida
   ```
   Presentation → Domain ← Data
                    ↑
              (Interfaces)
   ```

5. **Flexibilidad**: Misma entidad, múltiples representaciones
    - TeamModel: JSON de API
    - PreferenceModel: Hive storage
    - TeamEntity: Lógica de negocio

**Ejemplo práctico**:

Si la API cambia de:
```json
{"name": "Porcinos FC"}
```

A:
```json
{"team_name": "Porcinos FC"}
```

Solo cambias `TeamModel.fromJson()`, la entidad `Team` y toda la app permanecen igual.

**Trade-off**:
- ✅ Más código inicialmente
- ✅ Mejor mantenibilidad a largo plazo
- ✅ Tests más simples
- ✅ Cambios localizados

---

## 🎯 Resumen de Decisiones

| Aspecto | Decisión | Alternativa Considerada | Razón Principal |
|---------|----------|------------------------|-----------------|
| **Arquitectura** | Clean Architecture | MVC, MVVM | Escalabilidad, testabilidad, separación |
| **Estado** | Cubit | Provider, Riverpod, GetX | Requerimiento + predecibilidad |
| **Persistencia** | Hive | SQLite, Drift | Simplicidad para CRUD simple |
| **Navegación** | go_router 17 | Navigator 2.0 | Declarativo, menos boilerplate |
| **DI** | GetIt | Provider, Injectable | Simplicidad, explícito |
| **HTTP** | http | Dio | Suficiente para API REST simple |
| **Funcional** | dartz (Either) | Try-Catch | Type-safe error handling |
| **UI** | Material 3 | Custom widgets | Consistencia, mantenimiento |
| **Imágenes** | cached_network_image | Image.network | Performance, UX |

---

## Mejoras Futuras

Si este proyecto escalara a producción, consideraría:

### Corto Plazo
1. **Testing completo**: Unit, widget e integration tests (cobertura 80%+)
2. **Error logging**: Sistema de logs con categorías (debug, info, error)
3. **Loading states**: Skeletons en lugar de spinners genéricos
4. **Offline mode**: Mejorar experiencia sin conexión

### Mediano Plazo
5. **CI/CD**: GitHub Actions para builds y tests automáticos
6. **Analytics**: Firebase Analytics para métricas de uso
7. **Crash reporting**: Sentry o Firebase Crashlytics
8. **Performance monitoring**: Firebase Performance

### Largo Plazo
9. **Localización**: Soporte multi-idioma (i18n)
10. **Themes**: Dark mode y temas personalizables
11. **Sync**: Sincronización entre dispositivos (Firebase)
12. **Advanced search**: Filtros por liga, país, etc.
13. **Social features**: Compartir equipos favoritos
14. **Push notifications**: Notificaciones de actualizaciones

### Optimizaciones Técnicas
- **Code splitting**: Lazy loading de módulos
- **Image optimization**: WebP, diferentes resoluciones
- **Cache strategy**: Políticas de caché más sofisticadas (TTL, invalidación)
- **State persistence**: Guardar estado de búsqueda
- **Pagination**: Cargar equipos en páginas si la lista crece
- **Background sync**: Actualizar datos en background

---

## Lo que se aprendió

### Lo que funcionó bien
1. Clean Architecture facilitó testing y mantenimiento
2. Cubit fue suficiente para la complejidad del proyecto
3. Hive simplificó enormemente la persistencia
4. go_router hizo la navegación clara y mantenible
5. Either forzó manejo explícito de errores

### Lo que mejoraría
1. Agregar tests desde el inicio (TDD)
2. Implementar logging desde el principio
3. Documentar decisiones en tiempo real
4. Usar feature flags para desarrollos experimentales

### Trade-offs aceptados
1. Más código inicial (entities + models) por mejor arquitectura
2. Curva de aprendizaje de Cubit por predecibilidad
3. Boilerplate de GetIt por inyección explícita

---

## Conclusión

Cada decisión técnica en este proyecto se tomó considerando cuidadosamente:

1. **Requerimientos del proyecto**: Cumplir especificaciones de la prueba técnica
2. **Mejores prácticas**: Seguir estándares de la industria Flutter
3. **Mantenibilidad**: Código fácil de entender y modificar
4. **Escalabilidad**: Arquitectura que soporte crecimiento
5. **Performance**: Optimización sin over-engineering
6. **Developer Experience**: Herramientas y patrones que facilitan el desarrollo

El resultado es una aplicación **robusta**, **escalable** y **mantenible** que cumple con todos los requerimientos de la prueba técnica mientras sigue las mejores prácticas de desarrollo Flutter.

--- 

**Autor**: David Vargas Dominguez  
**Proyecto**: Kings League Teams Manager  
**Fecha**: Diciembre 2025
**Versión**: 1.0.0  
**Estado**: Prueba técnica completada ✅

---

## Contacto y Feedback

Para discusiones sobre estas decisiones técnicas o sugerencias de mejora, por favor:
- Abre un issue en el repositorio
- Inicia una discusión en GitHub Discussions
- Contactáme a mi correo davidvargas.d45@gmail.com

**¡Gracias por leer esta justificación técnica completa!**