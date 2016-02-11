## Entwicklungs Guidelines

### Lizenzen

Cryptopus ist ein Open Source Projekt. Entsprechend müssen in jedem File Header
Lizenzinformationen eingefügt werden. Dies kann manuell geschehen oder über den folgenden Rake Task:

    rake license:insert

Der Hauplizenztext und weitere Konfiguration sind  unter `lib/tasks/license.rake`.
