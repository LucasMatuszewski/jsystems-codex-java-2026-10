# Cargo Tracker: małe zadania do pracy z agentem

Wybierz jedno zadanie, zapisz krótki kontrakt, zobacz czerwony test i dopiero potem zmieniaj kod. Poniższe ustalenia dotyczą `master` o SHA `4d26b8fd59a7f0bac6e42d5d19a8cd1b379353b5`, sprawdzonego 28.10.2026. To nasze zadania szkoleniowe, nie lista zgłoszeń zaakceptowanych przez upstream. Nie przypisujemy im fikcyjnych numerów GitHub.

Wszystkie ścieżki Java są względem `src/main/java/org/eclipse/cargotracker/`; testy trafiają do analogicznego pakietu pod `src/test/java`. Rozmiar XS = 15-25 minut, S = 30-45 minut, z przeglądem wyniku. Zadania mają rozłączne pliki docelowe. Uruchamiaj pełny build po scaleniu, pojedyncze testy wcześniej.

## T1. UnLocode niezależny od języka systemu

**Kontekst:** `domain/model/location/UnLocode.java`, konstruktor używa `toUpperCase()` bez Locale. Rzeczywista próba na JDK 17 z ustawieniem `tr-TR` zwróciła `FİHEL` dla `fihel`, zamiast ASCII `FIHEL`. Wartość po normalizacji narusza własny wzorzec kodu lokalizacji. Istnieje `UnLocodeTest`, ale nie sprawdza tureckiego locale.

**Kryteria:** test ustawiający tureckie locale odtwarza błąd; locale jest zawsze przywrócone w bloku `finally`; wynik to `FIHEL`; normalizacja używa `Locale.ROOT`; dotychczasowe przypadki walidacji i równości nadal przechodzą. Test nie zależy od domyślnego języka VM.

**Rozmiar:** S. Pliki: `UnLocode.java`, `UnLocodeTest.java`.

## T2. Kontrakt wartości TrackingId

**Kontekst:** `domain/model/cargo/TrackingId.java`; brak dedykowanego `TrackingIdTest`. Konstruktor odrzuca null przez `Objects.requireNonNull`, ale pusty tekst blokuje dopiero Bean Validation. Nie zmieniamy tego kontraktu przy dopisywaniu testów.

**Kryteria:** nowy test obejmuje null, identyczną wartość w dwóch obiektach, różne wartości, inny typ, null w equals, zgodność hashCode i toString. Osobny przypadek dokumentuje, że konstruktor aktualnie przyjmuje pusty tekst. Test nie wymaga serwera ani bazy. Bez zmian produkcyjnych.

**Rozmiar:** XS. Plik: nowy `domain/model/cargo/TrackingIdTest.java` w testach.

## T3. Kontrakt wartości VoyageNumber

**Kontekst:** `domain/model/voyage/VoyageNumber.java`; brak dedykowanego testu, mimo implementacji equals, hashCode i reprezentacji tekstowej.

**Kryteria:** test null według istniejącego konstruktora, równość i nierówność, equals z null i innym typem, hashCode dla równych wartości, `getIdString()` i `toString()`. Sprawdź także zachowanie wielkości liter, bez dopisywania nowej normalizacji. Bez kontenera i bez zmian produkcyjnych.

**Rozmiar:** XS. Plik: nowy `domain/model/voyage/VoyageNumberTest.java` w testach.

## T4. Testy konwersji dat

**Kontekst:** `application/util/DateConverter.java`; brak dedykowanych testów. Sprawdzona próba `10/28/2026 1:05 PM` po odczycie i zapisie daje `10/28/2026 1:5 PM`, bo wzorzec to `M/d/yyyy h:m a`. To obecny kontrakt, nie obietnica zer wiodących.

**Kryteria:** testy round-trip LocalDate i LocalDateTime, północ i południe, data przestępna, nieparsowalny tekst i null. Asercje jawnie dokumentują aktualne formatowanie minut. Locale inicjalizacji formatterów jest kontrolowane i opisane; nie uznawaj automatycznej korekty nieprawidłowej daty przez parser za ścisłą walidację. Bez zmiany formatów publicznych.

**Rozmiar:** S. Plik: nowy `application/util/DateConverterTest.java` w testach.

## T5. AND: tablica prawdy i krótkie spięcie

**Kontekst:** `domain/shared/AndSpecification.java`; nie ma dedykowanego testu. Część klas trafia do testu integracyjnego przez ShrinkWrap, ale to nie zastępuje asercji kontraktu operatora.

**Kryteria:** cztery kombinacje true/false, prawy operand nie jest wywołany przy false po lewej, oba operandy otrzymują ten sam obiekt. Użyj licznika albo prostej implementacji Specification, bez kontenera i bez nowej biblioteki mocków.

**Rozmiar:** XS. Plik: nowy `domain/shared/AndSpecificationTest.java` w testach.

## T6. OR: tablica prawdy i krótkie spięcie

**Kontekst:** `domain/shared/OrSpecification.java`; brak dedykowanych testów dla `||` i kolejności wywołań.

**Kryteria:** cztery kombinacje true/false, prawy operand nie jest wywołany przy true po lewej, zostaje wywołany przy false, otrzymuje właściwy obiekt. Test działa niezależnie od T5.

**Rozmiar:** XS. Plik: nowy `domain/shared/OrSpecificationTest.java` w testach.

## T7. NOT: negacja bez utraty argumentu

**Kontekst:** `domain/shared/NotSpecification.java`; brak dedykowanego testu. Sprawdź kod przed przyjęciem założeń o sygnaturze.

**Kryteria:** negacja true i false, dokładnie jedno wywołanie predykatu, przekazanie tego samego argumentu. Test bez kontenera; bez zmiany interfejsu Specification ani innych operatorów.

**Rozmiar:** XS. Plik: nowy `domain/shared/NotSpecificationTest.java` w testach.

## T8. Status IN_PORT pokazuje faktyczny port

**Kontekst:** `interfaces/tracking/web/CargoTrackingViewAdapter.java`, metoda `getStatusText()`: gałąź IN_PORT używa nazwy miejsca docelowego z RouteSpecification, zamiast ostatniej lokalizacji z Delivery. Dla podróży z portem pośrednim może wyświetlić miejsce, do którego ładunek jeszcze nie dotarł. Brak dedykowanego testu adaptera. Odczyt SSE przykładowego ABC123 potwierdził IN_PORT i ostatnią lokalizację USNYC; tekst Faces wylicza inna klasa.

**Kryteria:** test z ładunkiem w porcie pośrednim innym niż cel odtwarza błędny tekst; po poprawce tekst zawiera bieżący port. Przypadki NOT_RECEIVED i CLAIMED pozostają poprawne. Dane buduj przez publiczny model i historię obsługi, bez refleksyjnego podmieniania pól Delivery. Uzgodnij brzmienie komunikatu przed zmianą.

**Rozmiar:** S. Pliki: adapter oraz nowy `interfaces/tracking/web/CargoTrackingViewAdapterTest.java` w testach.

## T9. Nieznany typ zdarzenia odrzucany na granicy REST

**Kontekst:** `interfaces/handling/rest/HandlingReport.java` ogranicza eventType tylko przez NotBlank i Size 4-7. `HandlingReportService.java` wywołuje `HandlingEvent.Type.valueOf()`. Tekst `BOGUS` spełnia te adnotacje, lecz nie należy do enumu. To luka potwierdzona analizą kodu; odpowiedzi HTTP dla tego konkretnego payloadu nie sprawdzono. POST pustego obiektu rzeczywiście zwrócił 400.

**Kryteria:** walidator odrzuca BOGUS, małe litery i pusty tekst; przyjmuje RECEIVE, LOAD, UNLOAD, CUSTOMS i CLAIM. Żądanie z niepoprawnym typem kończy się 400, bez publikacji zdarzenia. Osobno pokaż test Bean Validation i sprawdzenie HTTP; nie nazywaj zwykłego wywołania Java testem HTTP. Nie zmieniaj formatu completionTime ani protokołu JMS.

**Rozmiar:** S. Pliki: `HandlingReport.java`, nowy `interfaces/handling/rest/HandlingReportValidationTest.java` w testach; ewentualny test HTTP w osobnym nowym pliku. Nie zmieniaj serwisu, jeśli wystarczy walidacja DTO.

## Utworzenie zgłoszeń we własnym GitLabie

**Status N dla wszystkich poleceń poniżej: nie uruchomiono, nie mamy tu konta GitLab.** Składnię sprawdzono 28.10.2026 w [oficjalnej dokumentacji glab issue create](https://docs.gitlab.com/cli/issue/create/). Uruchom w katalogu swojego Cargo Tracker z `origin` wskazującym własny projekt. Każde polecenie tworzy nowe zgłoszenie, więc nie wykonuj go drugi raz bez sprawdzenia listy issues. Opisy zawierają najważniejsze kryteria; pełne warunki są powyżej.

```bash
glab issue create --title 'T1: UnLocode niezależny od locale' --description 'S, 30-45 min. src/main/java/org/eclipse/cargotracker/domain/model/location/UnLocode.java i analogiczny UnLocodeTest. Dla tr-TR fihel daje FİHEL. Odtwórz czerwonym testem, przywracaj locale w finally, użyj Locale.ROOT, oczekuj FIHEL. Zachowaj pozostałą walidację.' --yes
```

```bash
glab issue create --title 'T2: Testy wartości TrackingId' --description 'XS, 15-25 min. Nowy src/test/java/org/eclipse/cargotracker/domain/model/cargo/TrackingIdTest.java. Null, równość i nierówność, inny typ, hashCode, getIdString i toString. Udokumentuj przyjmowanie pustego tekstu przez konstruktor. Bez kontenera i zmian produkcyjnych.' --yes
```

```bash
glab issue create --title 'T3: Testy wartości VoyageNumber' --description 'XS, 15-25 min. Nowy src/test/java/org/eclipse/cargotracker/domain/model/voyage/VoyageNumberTest.java. Sprawdź null, equals, hashCode, getIdString, toString i zachowanie wielkości liter według obecnego konstruktora. Bez kontenera i nowej normalizacji.' --yes
```

```bash
glab issue create --title 'T4: Testy DateConverter' --description 'S, 30-45 min. Nowy src/test/java/org/eclipse/cargotracker/application/util/DateConverterTest.java. Round-trip daty i czasu, północ, południe, rok przestępny, błędny tekst i null. Kontroluj locale inicjalizacji. Obecny wzorzec h:m nie dodaje zer minut. Nie zmieniaj formatu.' --yes
```

```bash
glab issue create --title 'T5: AND i krótkie spięcie' --description 'XS, 15-25 min. Nowy src/test/java/org/eclipse/cargotracker/domain/shared/AndSpecificationTest.java. Cztery kombinacje prawdy, pominięcie prawego operandu przy false i przekazywanie argumentu. Licznik zamiast biblioteki mocków, bez kontenera.' --yes
```

```bash
glab issue create --title 'T6: OR i krótkie spięcie' --description 'XS, 15-25 min. Nowy src/test/java/org/eclipse/cargotracker/domain/shared/OrSpecificationTest.java. Cztery kombinacje prawdy, pominięcie prawego operandu przy true, jego wywołanie przy false i przekazywanie argumentu. Bez kontenera.' --yes
```

```bash
glab issue create --title 'T7: Testy negacji NOT' --description 'XS, 15-25 min. Nowy src/test/java/org/eclipse/cargotracker/domain/shared/NotSpecificationTest.java. Negacja true i false, jedno wywołanie predykatu i ten sam argument. Bez zmiany interfejsu Specification ani innych operatorów.' --yes
```

```bash
glab issue create --title 'T8: IN_PORT pokazuje bieżący port' --description 'S, 30-45 min. interfaces/tracking/web/CargoTrackingViewAdapter.java pod src/main/java/org/eclipse/cargotracker oraz nowy test w analogicznym pakiecie. Odtwórz port pośredni różny od celu. Tekst IN_PORT ma wskazywać ostatnią lokalizację. Zachowaj NOT_RECEIVED i CLAIMED, używaj publicznego modelu bez refleksji.' --yes
```

```bash
glab issue create --title 'T9: Walidacja typu zdarzenia REST' --description 'S, 30-45 min. interfaces/handling/rest/HandlingReport.java pod src/main/java/org/eclipse/cargotracker i nowy test walidacji. Size 4-7 przyjmuje BOGUS, a valueOf go odrzuca. Przyjmuj RECEIVE, LOAD, UNLOAD, CUSTOMS, CLAIM; inne wartości i pusty tekst mają dać 400 bez publikacji zdarzenia. Pokaż walidację DTO i osobno HTTP. Bez zmiany dat i JMS.' --yes
```
