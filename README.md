# Expense Splitter Flutter

Минимальное Flutter-приложение для деления общего чека поровну.

Что умеет:
- ввести общую сумму чека,
- добавить участников,
- указать, сколько заплатил каждый,
- показать равную долю на человека,
- показать переплату или недоплату каждого,
- построить простой список переводов, кто кому должен.

## Локальный запуск

Нужен Flutter stable.

```bash
flutter create . --platforms=android,ios,windows
flutter pub get
flutter run
```

## Сборка

### Android APK
```bash
flutter create . --platforms=android
flutter pub get
flutter build apk --release
```

### Windows x64
```bash
flutter create . --platforms=windows
flutter pub get
flutter build windows --release
```

### iOS
```bash
flutter create . --platforms=ios
flutter pub get
flutter build ios --simulator
```

## GitHub Actions artifacts

В репозитории добавлены workflows:
- `.github/workflows/android.yml` — собирает Android APK,
- `.github/workflows/windows.yml` — собирает Windows x64 zip,
- `.github/workflows/ios.yml` — собирает iOS simulator app.

## Ограничение по iPhone

Готовый билд для реального iPhone нельзя выпускать без Apple signing / provisioning profile и macOS signing setup.
Поэтому в CI собирается только **iOS simulator** артефакт. Для запуска на реальном iPhone потребуется подписанная локальная или CI-сборка с Apple credentials.
