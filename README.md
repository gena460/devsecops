# devsecops 

Приклад скрипта на мові Python для git pre-commit hook, який автоматично встановлює gitleaks залежно від операційної системи, використовуючи git config для включення/відключення хука, а також інсталює його за допомогою методу "curl pipe sh"

 1. Скопіюйте вміст скрипта, наприклад, у новий файл в вашому репозиторії з такою ж назвою `pre-commit-hook.sh`

 2. Щоб скористатися скриптом, створіть файл `pre-commit` у папці `.git/hooks/` вашого репозиторію з таким вмістом:
```
 #!/bin/sh
 python3 /повний/шлях/до/pre-commit-hook.sh
```
 3. Виконайте наступні команди, щоб включити хук та встановити значення enable в git config:
```
 git config hooks.gitleaks.enable true
 chmod +x /повний/шлях/до/файлу/pre-commit
```
Тепер при кожному коміті, git автоматично виконає скрипт, встановить gitleaks (якщо він не встановлений) і перевірить наявність секретів за допомогою gitleaks. Якщо будуть знайдені секрети або опція вимкнена, коміт буде відхилений.