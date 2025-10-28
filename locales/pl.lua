Translations = Translations or {
    notifications = {
        ["char_deleted"] = "Postać usunięta!",
        ["deleted_other_char"] = "Pomyślnie usunięto postać o Citizen ID %{citizenid}.",
        ["forgot_citizenid"] = "Nie wpisałeś Citizen ID!",
    },

    commands = {
        -- /deletechar
        ["deletechar_description"] = "Usuwa postać innego gracza",
        ["citizenid"] = "Citizen ID",
        ["citizenid_help"] = "Citizen ID postaci, którą chcesz usunąć",

        -- /logout
        ["logout_description"] = "Wyloguj się z postaci (tylko Admin)",

        -- /closeNUI
        ["closeNUI_description"] = "Zamknij Multi NUI"
    },

    misc = {
        ["droppedplayer"] = "Zostałeś rozłączony z RSGCore"
    },

    ui = {
        -- Główne
        characters_header = "Moje postacie",
        emptyslot = "Pusty slot",
        play_button = "Graj",
        create_button = "Stwórz postać",
        delete_button = "Usuń postać",

        -- Informacje o postaci
        charinfo_header = "Informacje o postaci",
        charinfo_description = "Wybierz slot postaci, aby zobaczyć wszystkie informacje o niej.",
        name = "Imię",
        male = "Mężczyzna",
        female = "Kobieta",
        firstname = "Imię",
        lastname = "Nazwisko",
        nationality = "Narodowość",
        gender = "Płeć",
        birthdate = "Data urodzenia",
        job = "Praca",
        jobgrade = "Stopień w pracy",
        cash = "Gotówka",
        bank = "Bank",
        phonenumber = "Numer telefonu",
        accountnumber = "Numer konta",

        chardel_header = "Utworzyć nową postać?",

        -- Usuwanie postaci
        deletechar_header = "Usuń postać",
        deletechar_description = "Czy na pewno chcesz usunąć tę postać?",

        -- Przyciski
        cancel = "Anuluj",
        confirm = "Potwierdź",

        -- Tekst ładowania
        retrieving_playerdata = "Pobieranie danych gracza",
        validating_playerdata = "Weryfikacja danych gracza",
        retrieving_characters = "Pobieranie postaci",
        validating_characters = "Weryfikacja postaci",

        -- Powiadomienia
        ran_into_issue = "Wystąpił problem",
        profanity = "Wygląda na to, że próbujesz użyć niecenzuralnych słów w imieniu lub narodowości!",
        forgotten_field = "Wygląda na to, że zapomniałeś uzupełnić jedno lub więcej pól!"
    }
}

if GetConvar('rsg_locale', 'en') == 'pl' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
