#!/usr/bin/env python3

import subprocess
import sys
import os

GITLEAKS_URL = "https://github.com/zricethezav/gitleaks/releases/latest/download/gitleaks-{platform}-{arch}"

def install_gitleaks():
    # Визначаємо платформу та архітектуру
    platform = sys.platform
    if platform.startswith("linux"):
        platform = "linux"
    elif platform.startswith("darwin"):
        platform = "darwin"
    elif platform.startswith("win"):
        platform = "windows"
    else:
        print("Не підтримувана платформа")
        sys.exit(1)

    arch = "amd64"  # Припускаємо, що використовується 64-бітна архітектура

    # Завантажуємо URL для поточної платформи та архітектури
    download_url = GITLEAKS_URL.format(platform=platform, arch=arch)

    # Завантажуємо gitleaks
    process = subprocess.Popen(["curl", "-L", download_url], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, error = process.communicate()

    if process.returncode != 0:
        print("Помилка під час завантаження gitleaks:")
        print(error.decode("utf-8"))
        sys.exit(1)

    # Зберігаємо gitleaks в поточну директорію
    with open("gitleaks", "wb") as f:
        f.write(output)

    # Надаємо права на виконання
    os.chmod("gitleaks", 0o755)

    print("Gitleaks успішно встановлено")

def run_gitleaks():
    # Виконуємо gitleaks для перевірки наявності секретів
    process = subprocess.Popen(["./gitleaks", "--path", "."], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, error = process.communicate()

    return output.decode("utf-8"), error.decode("utf-8"), process.returncode

def main():
    # Отримуємо значення enable з git config
    enable = subprocess.check_output(["git", "config", "hooks.gitleaks.enable"]).decode("utf-8").strip()

    if enable.lower() != "true":
        # Якщо enable не встановлено на "true", пропускаємо перевірку
        sys.exit(0)

    # Перевіряємо, чи gitleaks встановлено
    try:
        subprocess.check_output(["./gitleaks", "--version"])
    except FileNotFoundError:
        print("Gitleaks не знайдено. Встановлюємо...")
        install_gitleaks()

    # Запускаємо gitleaks
    output, error, returncode = run_gitleaks()

    if returncode != 0:
        # Якщо повернутий код не дорівнює 0, відхиляємо коміт
        print("Gitleaks виявив наявність секретів у коді:")
        print(output)
        sys.exit(1)

if __name__ == "__main__":
    main()
