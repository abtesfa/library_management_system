# Frontend architecture (Clean Architecture, feature-first)

```
lib/
  main.dart
  core/            shared code: config, constants, theme, error, di, common widgets
  features/
    <feature>/
      domain/        entities, repository interfaces, use cases   (pure Dart)
      data/          models (JSON), remote data sources, repository implementations
      presentation/  screens, widgets, providers
```

Dependency rule: `presentation -> domain <- data`. Domain imports nothing from
Flutter, `http` or the data layer.

Features: `auth`, `books`, `borrowing`, `dashboard`, `landing`, `library`
(app-wide catalogue/circulation state), `notifications`, `reservations`,
`settings`, `staff`.

`core/di/injector.dart` creates data sources -> repositories -> use cases lazily.
Screens and providers ask it for use cases (`injector.getAllBooks`, ...).

Behaviour notes
- Errors are still thrown as exceptions with the same messages as before.
  `ApiException` is used only where the UI must tell "server refused" apart
  from "could not connect" (librarian borrow/return/find, book categories).
- `LibraryService` keeps its name and public API; it now only calls use cases.
- Backend (`backend/`) and the root-level files were not touched.
