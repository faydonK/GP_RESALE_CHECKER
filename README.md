
# GP(Explorer) Resale Checker

🤖 **Script Ruby automatisé pour surveiller la disponibilité des billets de revente sur GP Explorer**

Surveillez automatiquement si des billets revendus sont disponibles (non compatible avec les __Aire d'acceuil__ et les __Parking__). Si un/des billets sont disponibles, vous entendrez un son de Windows 4 fois.

## ⚡ Prérequis

### 💎 Ruby
📥 Téléchargez et installez Ruby depuis [rubyinstaller.org](https://rubyinstaller.org/)

### 
| Navigateur  Compatible | Chemin Windows |
|:------------:|----------------|
| **Brave** | `C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe` |
| **Chrome** | `C:/Program Files/Google/Chrome/Application/chrome.exe` |
| **Edge** | `C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe` |
| **Opera** | `C:/Users/%USERNAME%/AppData/Local/Programs/Opera/opera.exe` |

(Tous les navigateurs basés sur Chromium)

## 🔧 Installation

### 1️⃣ Télécharger le projet
```bash
git clone https://github.com/faydonK/GP_RESALE_CHECKER.git
cd GP_RESALE_CHECKER
```

### 2️⃣ Installer les dépendances Ruby
```bash
gem install selenium-webdriver
gem install win32-sound
```

## 3️⃣ Configuration

Ouvrez `main.rb` et modifiez:

```ruby
BROWSER_PATH = 
--
CYCLE_CHECKS = 
```

### 4️⃣ Lancer le script
```bash
ruby main.rb
```



### 🛑 Arrêt du script
`Ctrl + C` pour arrêter le script

---

**⚠️ NOTE** : TOUT CE PROGRAMME A ÉTÉ FAIT A PAR MES MAIN ET CORRIGER(aide, etc...) PAR __CLAUDE SONNET 4__ (parce que je ne suis pas non plus le goat en Ruby).