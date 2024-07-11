Translations = Translations or {
notifications = {
    ["char_deleted"] = "Personagem excluído!",
    ["deleted_other_char"] = "Você excluiu com sucesso o personagem com ID de cidadão %{citizenid}.",
    ["forgot_citizenid"] = "Você esqueceu de inserir um ID de cidadão!",
},

commands = {
    -- /deletechar
    ["deletechar_description"] = "Exclui o personagem de outro jogador",
    ["citizenid"] = "ID de Cidadão",
    ["citizenid_help"] = "O ID de cidadão do personagem que você deseja excluir",

    -- /logout
    ["logout_description"] = "Sair do Personagem (Somente para Admins)",

    -- /closeNUI
    ["closeNUI_description"] = "Fechar Multi NUI"
},

misc = {
    ["droppedplayer"] = "Você desconectou do RSGCore"
},

ui = {
    -- Main
    characters_header = "Meus Personagens",
    emptyslot = "Slot Vazio",
    play_button = "Jogar",
    create_button = "Criar Personagem",
    delete_button = "Excluir Personagem",

    -- Character Information
    charinfo_header = "Informações do Personagem",
    charinfo_description = "Selecione um slot de personagem para ver todas as informações sobre seu personagem.",
    name = "Nome",
    male = "Masculino",
    female = "Feminino",
    firstname = "Primeiro Nome",
    lastname = "Sobrenome",
    nationality = "Nacionalidade",
    gender = "Gênero",
    birthdate = "Data de Nascimento",
    job = "Profissão",
    jobgrade = "Grau da Profissão",
    cash = "Dinheiro",
    bank = "Banco",
    phonenumber = "Número de Telefone",
    accountnumber = "Número de Conta",

    chardel_header = "Registro de Personagem",

    -- Delete character
    deletechar_header = "Excluir Personagem",
    deletechar_description = "Tem certeza de que deseja excluir seu personagem?",

    -- Buttons
    cancel = "Cancelar",
    confirm = "Confirmar",

    -- Loading Text
    retrieving_playerdata = "Recuperando dados do jogador",
    validating_playerdata = "Validando dados do jogador",
    retrieving_characters = "Recuperando personagens",
    validating_characters = "Validando personagens",

    -- Notifications
    ran_into_issue = "Encontramos um problema",
    profanity = "Parece que você está tentando usar palavras obscenas ou impróprias em seu nome ou nacionalidade!",
    forgotten_field = "Parece que você esqueceu de preencher um ou mais campos!"
}
}

if GetConvar('rsg_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
