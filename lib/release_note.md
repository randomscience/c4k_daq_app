# Wersja aplikacji: 0.2.1
# Nazwa: Łatka dnia pierwszego
# Data publikacji: 01/09/2023

## Lista zmian wprowadzonych w aktualizacji
1. Zwiększenie czasu oczekiwania na wysłanie danych do bazy. Aplikacja oczekuje teraz do 5 minut na wysłanie pojedynczego nagrania. Maksymalny czas oczekiwania na wysłanie pojedynczego pomiaru: 9*5+1=46min.
2. Biblioteka przechowuje nagrania pomiędzy zamknięciami aplikacji. Po zapisaniu pomiaru do "Oczekiwanych", nagrania są przechowywane nawet gdy aplikacja nie jest uruchomiona.
3. Rozszerzenie pojęcia ID, teraz wspierany jest dowolny teks nawet emotikony!
4. Możliwe jest wysyłanie kilku nagrań jednocześnie.
5. Ogólne usprawnienia do działania aplikacji i stabilizacja systemu.
6. Do paczki wysyłanych informacji dodano "hardware_id"