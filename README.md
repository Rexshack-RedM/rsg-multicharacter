<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 👥 rsg-multicharacter
**Multi‑character creation and selection system for RedM using RSG Core.**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> Create, delete, and manage multiple characters per account.  
> Includes starter horse and starter item systems integrated with RSG Core.

---

## 🛠️ Dependencies
- **rsg-core** (framework & events)  
- **ox_lib** (dialogs, locale)  
- **oxmysql** (database handling)  
- **rsg-horses** (required for starter horse feature)  

**License:** GPL‑3.0

---

## ✨ Features
- 🧑‍🤝‍🧑 **Multi‑character selection** — configurable number of character slots.  
- 🐎 **Starter horse system** — gives new characters a horse automatically.  
- 🎁 **Starter items** — auto‑granted via `RSGCore.Shared.StarterItems`.  
- 🧠 **Preloading synchronization** — prevents desyncs during character load.  
- 🗃️ **Persistent horse IDs** — generated via `GenerateHorseId()` for each player horse.  
- ⚙️ **Configurable slots per license** (override default).  
- 🌍 **Multi‑language** (7 locale files included).

---

## ⚙️ Configuration (`config.lua`)
```lua
Config = {}

-- Give a horse when creating a new character
Config.StarterHorse = true
Config.StarterHorseModel = 'a_c_horse_mp_mangy_backup'
Config.StarterHorseStable = 'valentine'
Config.StarterHorseName = 'Starter Horse'

-- Default number of character slots
Config.DefaultNumberOfCharacters = 5

-- Optional: override slots per license
Config.PlayersNumberOfCharacters = {
    { license = "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", numberOfChars = 2 },
}
```

> 💡 Each player can have a different number of slots by defining their license and slot count.

---

## 🔁 How It Works
1. On connection, the player is presented with a **character selection UI**.  
2. The server checks their license in `Config.PlayersNumberOfCharacters`.  
3. If no override is found, they receive `Config.DefaultNumberOfCharacters` slots.  
4. When a new character is created:  
   - Starter items from `RSGCore.Shared.StarterItems` are given.  
   - If enabled, a **starter horse** is generated and added to their stable.  
5. All characters and horses are stored persistently in the database.

---

## 📂 Installation
1. Place `rsg-multicharacter` in your `resources/[rsg]` folder.  
2. Ensure `rsg-core`, `ox_lib`, and `oxmysql` are installed.  
3. Add to your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure oxmysql
   ensure rsg-core
   ensure rsg-horses
   ensure rsg-multicharacter
   ```
4. Restart your server.  

> 📦 Database tables (`players`, `player_horses`, etc.) are automatically handled by RSG Core and RSG Horses.

---

## 💎 Credits
- **qbcore‑redm‑framework** — Original base resource https://github.com/qbcore-redm-framework  
- **QRCore‑RedM‑Re** — Conversion and rework https://github.com/QRCore-RedM-Re  
- **RSG / Rexshack‑RedM** — adaptation & maintenance  
- **Community contributors & translators**  
- License: GPL‑3.0
