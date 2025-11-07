# Diagrama de Arquitectura del Proyecto

## Arquitectura Global

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  UI Pages    │  │    Cubits    │  │   Widgets    │      │
│  │              │  │              │  │              │      │
│  │ - ApiList    │  │ - ApiCubit   │  │ - TeamCard   │      │
│  │ - Prefs      │  │ - PrefCubit  │  │ - Loading    │      │
│  │ - Detail     │  │              │  │ - Error      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                                │
└─────────┼──────────────────┼────────────────────────────────┘
          │                  │
          └──────────┬───────┘
                     │ Emits States / Calls Methods
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│                   (Business Logic)                           │
│                                                              │
│  ┌──────────────────────┐    ┌──────────────────────┐      │
│  │     Entities         │    │   Repositories       │      │
│  │                      │    │   (Interfaces)       │      │
│  │  - Team              │    │                      │      │
│  │  - Preference        │    │  - TeamRepository    │      │
│  │                      │    │  - PrefRepository    │      │
│  └──────────────────────┘    └──────────────────────┘      │
│                                        │                     │
└────────────────────────────────────────┼─────────────────────┘
                                         │ Implements
                                         ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│                                                              │
│  ┌──────────────────────┐    ┌──────────────────────┐      │
│  │  Repositories Impl   │    │      Models          │      │
│  │                      │    │                      │      │
│  │ - TeamRepoImpl       │◄───│ - TeamModel          │      │
│  │ - PrefRepoImpl       │    │ - PreferenceModel    │      │
│  └──────────────────────┘    │ - ApiResponseModel   │      │
│           │                   └──────────────────────┘      │
│           │                                                  │
│           ▼                                                  │
│  ┌──────────────────────────────────────────────────┐      │
│  │            DataSources                            │      │
│  │                                                   │      │
│  │  ┌──────────────────┐    ┌──────────────────┐   │      │
│  │  │ Remote DataSrc   │    │  Local DataSrc   │   │      │
│  │  │                  │    │                  │   │      │
│  │  │ - HTTP Client    │    │ - Hive Box       │   │      │
│  │  │ - API Calls      │    │ - CRUD Ops       │   │      │
│  │  └──────────────────┘    └──────────────────┘   │      │
│  └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
           │                              │
           ▼                              ▼
    ┌─────────────┐              ┌──────────────┐
    │ Kings League│              │ Hive Local   │
    │     API     │              │   Storage    │
    └─────────────┘              └──────────────┘
```

## 🔄 Flujo de Datos

### 1. Obtener Equipos desde API

```
User Tap "Load Teams"
        │
        ▼
┌───────────────────┐
│   ApiListPage     │ (UI)
└───────────────────┘
        │ onInit()
        ▼
┌───────────────────┐
│    ApiCubit       │ getTeams()
└───────────────────┘
        │
        ▼
┌───────────────────┐
│ TeamRepository    │ (Interface)
└───────────────────┘
        │
        ▼
┌───────────────────┐
│ TeamRepoImpl      │ getTeams()
└───────────────────┘
        │
        ▼
┌───────────────────┐
│ RemoteDataSource  │ HTTP GET
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Kings League API │
└───────────────────┘
        │ JSON Response
        ▼
┌───────────────────┐
│   TeamModel       │ fromJson()
└───────────────────┘
        │ toEntity()
        ▼
┌───────────────────┐
│   Team Entity     │
└───────────────────┘
        │ Right(teams)
        ▼
┌───────────────────┐
│    ApiCubit       │ emit(ApiLoaded)
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  ApiListPage      │ BlocBuilder rebuilds
└───────────────────┘
        │
        ▼
    Display Teams List
```

### 2. Guardar Preferencia

```
User Fills Form & Taps "Save"
        │
        ▼
┌───────────────────┐
│ PreferenceForm    │ (UI)
└───────────────────┘
        │ onSave()
        ▼
┌───────────────────┐
│ PreferenceCubit   │ savePreference()
└───────────────────┘
        │
        ▼
┌───────────────────┐
│ PrefRepository    │ (Interface)
└───────────────────┘
        │
        ▼
┌───────────────────┐
│ PrefRepoImpl      │ savePreference()
└───────────────────┘
        │
        ▼
┌───────────────────┐
│ LocalDataSource   │ Hive put()
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Hive Box         │ Store PreferenceModel
└───────────────────┘
        │ Success
        ▼
┌───────────────────┐
│ PreferenceCubit   │ emit(ActionSuccess)
└───────────────────┘
        │
        ▼
┌───────────────────┐
│ PreferenceForm    │ Show SnackBar & Navigate
└───────────────────┘
```

## Estructura de Carpetas Detallada

```
lib/
│
├── 📁 core/                          # Código compartido
│   ├── 📁 constants/
│   │   └── 📄 api_constants.dart     # URLs, timeouts, config
│   ├── 📁 errors/
│   │   ├── 📄 exceptions.dart        # ServerException, CacheException
│   │   └── 📄 failures.dart          # ServerFailure, CacheFailure
│   ├── 📁 injection/
│   │   └── 📄 injection_container.dart # GetIt configuration
│   └── 📁 router/
│       └── 📄 app_router.dart        # go_router routes
│
├── 📁 data/                          # Capa de datos
│   ├── 📁 datasources/
│   │   ├── 📄 team_remote_datasource.dart
│   │   │   ├── getTeams() -> List<TeamModel>
│   │   │   └── searchTeams(query) -> List<TeamModel>
│   │   └── 📄 preference_local_datasource.dart
│   │       ├── getAllPreferences()
│   │       ├── savePreference()
│   │       ├── updatePreference()
│   │       └── deletePreference()
│   │
│   ├── 📁 models/
│   │   ├── 📄 team_model.dart
│   │   │   ├── extends Team
│   │   │   ├── fromJson()
│   │   │   └── toJson()
│   │   ├── 📄 preference_model.dart
│   │   │   ├── @HiveType
│   │   │   ├── toEntity()
│   │   │   └── fromEntity()
│   │   └── 📄 api_response_model.dart
│   │       └── fromJson() -> List<TeamModel>
│   │
│   └── 📁 repositories/
│       ├── 📄 team_repository_impl.dart
│       │   └── implements TeamRepository
│       └── 📄 preference_repository_impl.dart
│           └── implements PreferenceRepository
│
├── 📁 domain/                        # Capa de dominio
│   ├── 📁 entities/
│   │   ├── 📄 team.dart
│   │   │   └── class Team extends Equatable
│   │   └── 📄 preference.dart
│   │       └── class Preference extends Equatable
│   │
│   └── 📁 repositories/
│       ├── 📄 team_repository.dart
│       │   └── abstract class (interface)
│       └── 📄 preference_repository.dart
│           └── abstract class (interface)
│
├── 📁 presentation/                  # Capa de presentación
│   ├── 📁 cubits/
│   │   ├── 📁 api_cubit/
│   │   │   ├── 📄 api_cubit.dart
│   │   │   │   ├── getTeams()
│   │   │   │   ├── searchTeams(query)
│   │   │   │   └── retry()
│   │   │   └── 📄 api_state.dart
│   │   │       ├── ApiInitial
│   │   │       ├── ApiLoading
│   │   │       ├── ApiLoaded
│   │   │       └── ApiError
│   │   │
│   │   └── 📁 preference_cubit/
│   │       ├── 📄 preference_cubit.dart
│   │       │   ├── getAllPreferences()
│   │       │   ├── savePreferenceFromTeam()
│   │       │   ├── updatePreference()
│   │       │   └── deletePreference()
│   │       └── 📄 preference_state.dart
│   │           ├── PreferenceInitial
│   │           ├── PreferenceLoading
│   │           ├── PreferenceLoaded
│   │           ├── PreferenceActionSuccess
│   │           └── PreferenceError
│   │
│   ├── 📁 pages/
│   │   ├── 📁 api_list/
│   │   │   └── 📄 api_list_page.dart        # /api-list
│   │   ├── 📁 preferences/
│   │   │   ├── 📄 preferences_list_page.dart  # /prefs
│   │   │   └── 📄 preference_form_page.dart   # /prefs/new
│   │   └── 📁 team_detail/
│   │       └── 📄 team_detail_page.dart      # /prefs/:id
│   │
│   └── 📁 widgets/
│       ├── 📁 common/
│       │   ├── 📄 loading_widget.dart
│       │   ├── 📄 error_widget.dart
│       │   └── 📄 empty_state_widget.dart
│       └── 📁 team_card/
│           └── 📄 team_card.dart
│
└── 📄 main.dart                      # Entry point
    ├── initializeDependencies()
    ├── MultiBlocProvider
    └── MaterialApp.router
```

## Inyección de Dependencias

```
┌─────────────────────────────────────────┐
│      GetIt Service Locator (sl)         │
├─────────────────────────────────────────┤
│                                          │
│  External Dependencies:                 │
│  └─ http.Client                         │
│                                          │
│  DataSources:                            │
│  ├─ TeamDataSource                      │
│  └─ PreferenceLocalDataSource           │
│                                          │
│  Repositories:                           │
│  ├─ TeamRepository                      │
│  └─ PreferenceRepository                │
│                                          │
│  Cubits (Factory):                      │
│  ├─ ApiCubit                            │
│  └─ PreferenceCubit                     │
│                                          │
└─────────────────────────────────────────┘

Registro:
sl.registerLazySingleton(() => http.Client())
sl.registerLazySingleton(() => TeamDataSourceImpl(client: sl()))
sl.registerFactory(() => ApiCubit(repository: sl()))

Uso:
final cubit = sl<ApiCubit>();
```

## Principios SOLID implementados

### 1. Single Responsibility Principle (SRP)
- Cada clase tiene una única responsabilidad
- `TeamDataSource`: Solo consumir API
- `PreferenceLocalDataSource`: Solo gestionar Hive
- `ApiCubit`: Solo gestionar estado de API

### 2. Open/Closed Principle (OCP)
- Clases abiertas para extensión, cerradas para modificación
- Nuevos estados se agregan sin modificar Cubit existente

### 3. Liskov Substitution Principle (LSP)
- `TeamModel` puede usarse donde se espera `Team`
- Implementaciones de repositorios pueden intercambiarse

### 4. Interface Segregation Principle (ISP)
- Interfaces específicas y pequeñas
- `TeamRepository` vs `PreferenceRepository`

### 5. Dependency Inversion Principle (DIP)
- Dependencias apuntan hacia abstracciones
- Cubits dependen de interfaces, no implementaciones
- DataSources inyectados, no instanciados directamente

## Manejo de Errores

```
Exception (Data Layer)
        │
        ▼
Try-Catch in DataSource
        │
        ▼
Throw Custom Exception
        │
        ▼
Repository catches
        │
        ▼
Return Either<Failure, Data>
        │
        ▼
Cubit receives result
        │
        ├─ Left(Failure) ──► emit(ErrorState)
        │
        └─ Right(Data) ────► emit(SuccessState)
        │
        ▼
UI shows error or data
```

## Navegación de Rutas

```
App Start
    │
    ▼
/api-list (Initial Route)
    │
    ├─► Tap "Favoritos (Ícono)" ──────► /prefs
    │                               │
    │                               ├─► Tap Team ──► /prefs/:id
    │                               │                     │
    │                               │                     └─► Tap Back ──► /prefs
    │                               │
    │                               └─► Tap "Nueva" ──► /prefs/new
    │                                                      │
    │                                                      └─► Save ──► /prefs
    │
    └─► Tap "+" ───────────────► /prefs/new
```

## Patrones de Diseño Utilizados

1. **Repository Pattern**: Abstracción de fuentes de datos
2. **BLoC Pattern**: Gestión de estado
3. **Dependency Injection**: GetIt service locator
4. **Factory Pattern**: Creación de Cubits
5. **Singleton Pattern**: Repositories y DataSources
6. **Adapter Pattern**: Conversión entre Entities y Models
7. **Observer Pattern**: BLoC streams

Esta arquitectura garantiza un código limpio, organizado y profesional que cumple con los más altos estándares de la industria.