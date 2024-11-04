Translations = Translations or {
    notifications = {
        ["char_deleted"] = "Ο χαρακτήρας διαγράφηκε!",
        ["deleted_other_char"] = "Διέγραψες επιτυχώς τον χαρακτήρα με citizen id %{citizenid}.",
        ["forgot_citizenid"] = "Ξέχασες να εισάγεις ένα citizen id!",
    },

    commands = {
        -- /deletechar
        ["deletechar_description"] = "Διαγράφει τον χαρακτήρα άλλου παίκτη",
        ["citizenid"] = "Citizen ID",
        ["citizenid_help"] = "Το Citizen ID του χαρακτήρα που θέλεις να διαγράψεις",

        -- /logout
        ["logout_description"] = "Αποσύνδεση από τον Χαρακτήρα (Μόνο για Admin)",

        -- /closeNUI
        ["closeNUI_description"] = "Κλείσιμο Multi NUI"
    },

    misc = {
        ["droppedplayer"] = "Αποσυνδέθηκες από το RSGCore"
    },

    ui = {
        -- Main
        characters_header = "Οι Χαρακτήρες Μου",
        emptyslot = "Κενή Θέση",
        play_button = "Παίξε",
        create_button = "Δημιουργία Χαρακτήρα",
        delete_button = "Διαγραφή Χαρακτήρα",

        -- Character Information
        charinfo_header = "Πληροφορίες Χαρακτήρα",
        charinfo_description = "Επίλεξε μια θέση χαρακτήρα για να δεις όλες τις πληροφορίες του.",
        name = "Όνομα",
        male = "Άνδρας",
        female = "Γυναίκα",
        firstname = "Όνομα",
        lastname = "Επώνυμο",
        nationality = "Εθνικότητα",
        gender = "Φύλο",
        birthdate = "Ημερομηνία Γέννησης",
        job = "Επάγγελμα",
        jobgrade = "Βαθμός Επαγγέλματος",
        cash = "Μετρητά",
        bank = "Τράπεζα",
        phonenumber = "Αριθμός Τηλεφώνου",
        accountnumber = "Αριθμός Λογαριασμού",

        chardel_header = "Δημιουργία Νέου Χαρακτήρα?",

        -- Delete character
        deletechar_header = "Διαγραφή Χαρακτήρα",
        deletechar_description = "Είσαι σίγουρος ότι θέλεις να διαγράψεις τον χαρακτήρα σου;",

        -- Buttons
        cancel = "Ακύρωση",
        confirm = "Επιβεβαίωση",

        -- Loading Text
        retrieving_playerdata = "Ανάκτηση δεδομένων παίκτη",
        validating_playerdata = "Επικύρωση δεδομένων παίκτη",
        retrieving_characters = "Ανάκτηση χαρακτήρων",
        validating_characters = "Επικύρωση χαρακτήρων",

        -- Notifications
        ran_into_issue = "Αντιμετωπίσαμε ένα πρόβλημα",
        profanity = "Φαίνεται ότι προσπαθείς να χρησιμοποιήσεις προσβλητική γλώσσα / κακές λέξεις στο όνομα ή στην εθνικότητά σου!",
        forgotten_field = "Φαίνεται ότι έχεις ξεχάσει να συμπληρώσεις ένα ή περισσότερα πεδία!"
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
