# MultiScreen Trivia Arena – Multiplayer Quiz Game for tvOS + iOS

A production-quality, full-stack multiplayer trivia game featuring an **Apple TV host** and **iPhone controllers** connected via WebSocket over local Wi‑Fi.

---

## 🎮 Features

✅ **tvOS Host App**
- WebSocket server on local Wi‑Fi (port 8080)
- Manages game state and player connections
- Beautiful SwiftUI UI with animations
- Real-time player join/leave effects
- Timer bar animation
- Scoreboard with color-coded results

✅ **iOS Controller App**
- Join room with player name
- Answer 4-choice questions (A/B/C/D)
- Buzzer mode for fast-response rounds
- Live scoreboard sync
- Automatic reconnection (3-second retry)
- Clean, responsive UI

✅ **Game Engine**
- MVVM architecture
- Async/await concurrency
- 5 sample trivia questions (JSON-based)
- Scoring system (correct +10, buzzer +5)
- 4 game phases: Lobby → Question → Buzzer → Scoreboard
- 10-second timer per question

✅ **Networking**
- Native Swift WebSocket (Network.framework)
- JSON message protocol
- Handles multiple simultaneous controllers
- Graceful disconnect handling
- Reconnection logic

---

## 📁 Project Structure

```
TriviaArenaTV/
├── TriviaArenaTV/                    (tvOS app target)
│   ├── TriviaArenaTVApp.swift        (app entry point)
│   ├── ContentView.swift             (root view router)
│   ├── PlayerModel.swift             (player data model)
│   ├── QuestionModel.swift           (question data model)
│   ├── WebSocketServer.swift         (Network.framework server)
│   ├── GameViewModel.swift           (game engine + state)
│   ├── LobbyView.swift               (waiting for players)
│   ├── QuestionView.swift            (Q&A round)
│   ├── BuzzerView.swift              (buzz mode)
│   ├── ScoreboardView.swift          (final scores)
│   └── Questions.json                (sample questions)
│
├── TriviaArenaController/            (iOS app target)
│   ├── TriviaArenaControllerApp.swift (app entry point)
│   ├── ControllerClient.swift        (WebSocket client + state)
│   ├── JoinView.swift                (enter TV IP & name)
│   ├── ControllerMainView.swift      (phase-based UI router)
│   ├── AnswerButtonsView.swift       (A/B/C/D buttons)
│   └── BuzzerButtonView.swift        (large buzz button)
│
├── SETUP_GUIDE.md                    (detailed setup instructions)
├── QUICK_START.md                    (30-second quickstart)
├── XCODE_CONFIG_CHECKLIST.md         (step-by-step Xcode setup)
└── README.md                         (this file)
```

---

## 🚀 Quick Start

### 1. Create iOS Target
```
File > New > Target… > iOS App > Name: TriviaArenaController
```

### 2. Assign Files to Targets
Use File Inspector (⌘⌥1) > Target Membership to assign:
- **tvOS**: 9 files + Questions.json
- **iOS**: 6 files

### 3. Update Info.plist
Add network permissions to both targets (see XCODE_CONFIG_CHECKLIST.md)

### 4. Run on Simulators
```bash
# Terminal 1: tvOS
Select TriviaArenaTV scheme > tvOS Simulator > Cmd+R

# Terminal 2: iOS
Select TriviaArenaController scheme > iPhone Simulator > Cmd+R
```

### 5. Test
- On iPhone: Enter `127.0.0.1` as TV IP, enter name, tap Join
- On TV: See player appear, tap Start Game
- Answer questions, buzz, see scoreboard!

**Full details**: See `QUICK_START.md` and `SETUP_GUIDE.md`

---

## 🎯 Game Flow

| Phase | Duration | TV Display | Controller Display | Action |
|-------|----------|-----------|-------------------|--------|
| **Lobby** | ∞ | Players list | Players list | Host: Start Game |
| **Question** | 10s | Q + 4 answers + timer | 4 answer buttons | Player: Tap answer |
| **Buzzer** | ∞ | "Buzz Fast!" | Red BUZZ button | Player: Tap BUZZ |
| **Scoreboard** | ∞ | Sorted scores | Sorted scores | Host: Next Question |

---

## 📊 Scoring

- **Correct Answer**: +10 points
- **Buzzer Win**: +5 points
- **Incorrect Answer**: 0 points
- **Scoreboard**: Sorted by score (highest first)

---

## 🌐 Networking Protocol

### Client → Server (Controller sends)

```json
{ "type": "join", "name": "Player 1", "choiceIndex": null }
{ "type": "answer", "name": null, "choiceIndex": 2 }
{ "type": "buzz", "name": null, "choiceIndex": null }
{ "type": "ready", "name": null, "choiceIndex": null }
```

### Server → Client (TV broadcasts)

```json
{
  "type": "state",
  "state": "question",
  "question": { "id": "...", "text": "...", "answers": [...], "correctIndex": 0 },
  "players": [
    { "id": "...", "name": "Player 1", "score": 10, "isConnected": true, "lastAnswerCorrect": true }
  ],
  "winnerId": null
}
```

---

## 🔧 Configuration

### Info.plist (Both Targets)

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>Used to connect controllers to the Apple TV over local Wi‑Fi.</string>

<key>NSBonjourServices</key>
<array><string>_ws._tcp</string></array>

<key>NSApplicationTransportSecurity</key>
<dict>
  <key>NSAllowsLocalNetworking</key><true/>
  <key>NSAllowsArbitraryLoads</key><true/>
</dict>
```

### Deployment Targets

- **tvOS**: 14.0+
- **iOS**: 14.0+
- **Swift**: 5.9+

---

## 🧪 Testing

### Simulators (Same Mac)
1. Run tvOS Simulator (TriviaArenaTV scheme)
2. Run iPhone Simulator (TriviaArenaController scheme)
3. On iPhone: Enter `127.0.0.1` as TV IP
4. Test all game phases

### Real Devices
1. Connect Apple TV to Wi‑Fi, note IP (Settings > AirPlay and HomeKit)
2. Connect iPhone to **same Wi‑Fi**
3. Deploy tvOS app to Apple TV
4. Deploy iOS app to iPhone
5. On iPhone: Enter Apple TV IP
6. Play!

---

## 🎨 Customization

### Add Questions
Edit `Questions.json`:
```json
{
  "id": "...",
  "text": "Your question?",
  "answers": ["A", "B", "C", "D"],
  "correctIndex": 0
}
```

### Change Scoring
In `GameViewModel.swift`:
```swift
if isCorrect {
    players[idx].score += 20  // Change from 10
}
```

### Change Timer
In `GameViewModel.swift`:
```swift
startTimer(duration: 15) { ... }  // Change from 10
```

### Customize Colors
In view files (e.g., `LobbyView.swift`):
```swift
.foregroundColor(.cyan)  // Change from .white
```

---

## 🐛 Troubleshooting

| Issue | Fix |
|-------|-----|
| "Failed to start WebSocket listener" | Port 8080 in use; change port or kill process |
| iPhone can't connect to TV | Same Wi‑Fi? Correct IP? Check firewall |
| Questions.json not found | Add to tvOS target bundle (File Inspector > Target Membership) |
| Frequent disconnects | Weak Wi‑Fi; move closer to router |
| Build fails | Clean build folder (Cmd+Shift+K) and rebuild |

---

## 📚 Documentation

- **QUICK_START.md** – 30-second setup
- **SETUP_GUIDE.md** – Detailed setup & running instructions
- **XCODE_CONFIG_CHECKLIST.md** – Step-by-step Xcode configuration

---

## ✨ Code Quality

✅ Production-ready Swift code
✅ MVVM architecture
✅ Async/await concurrency
✅ Comprehensive error handling
✅ Inline code comments
✅ No external dependencies (uses native frameworks)
✅ Tested on simulators and real devices

---

## 🚢 Deployment

### App Store (Optional)

1. Create App IDs for both targets
2. Create provisioning profiles
3. Archive both apps
4. Submit to App Store Connect

### Local Testing

1. Deploy tvOS app to Apple TV
2. Deploy iOS app to iPhone
3. Both on same Wi‑Fi network
4. Play!

---

## 📖 Architecture

### tvOS (Host)

```
TriviaArenaTVApp
  └─ ContentView (router)
      ├─ LobbyView
      ├─ QuestionView
      ├─ BuzzerView
      └─ ScoreboardView
         └─ GameViewModel (engine)
            ├─ WebSocketServer (Network.framework)
            ├─ Player[] (state)
            ├─ Question (current)
            └─ GamePhase (enum)
```

### iOS (Controller)

```
TriviaArenaControllerApp
  └─ JoinView
      └─ ControllerMainView (router)
          ├─ Lobby content
          ├─ Question content
          ├─ Buzzer content
          └─ Scoreboard content
             └─ ControllerClient (WebSocket client)
                ├─ URLSessionWebSocketTask
                ├─ Phase (enum)
                ├─ Question (current)
                └─ Player[] (state)
```

---

## 🎓 Learning Resources

- **SwiftUI**: https://developer.apple.com/tutorials/swiftui
- **Network.framework**: https://developer.apple.com/documentation/network
- **WebSocket**: https://tools.ietf.org/html/rfc6455
- **MVVM**: https://developer.apple.com/tutorials/swiftui/managing-user-input

---

## 📝 License

This project is provided as-is for educational and commercial use.

---

## 🤝 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review inline code comments in Swift files
3. Consult SETUP_GUIDE.md for detailed instructions
4. Verify Info.plist configuration (XCODE_CONFIG_CHECKLIST.md)

---

## 🎉 Ready to Play?

1. Follow QUICK_START.md
2. Run on simulators or real devices
3. Invite friends to join
4. Have fun! 🎮

---

**Built with ❤️ using SwiftUI, Network.framework, and async/await**

**Happy trivia! 🧠✨**
