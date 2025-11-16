# Quick Start – TriviaArenaTV

## 30-Second Setup

1. **Open Xcode** → `TriviaArenaTV.xcodeproj`
2. **Create iOS target**: File > New > Target… > iOS App > Name: `TriviaArenaController`
3. **Assign files to targets** (File Inspector > Target Membership):
   - tvOS: PlayerModel, QuestionModel, WebSocketServer, GameViewModel, LobbyView, QuestionView, BuzzerView, ScoreboardView, Questions.json
   - iOS: TriviaArenaControllerApp, ControllerClient, JoinView, ControllerMainView, AnswerButtonsView, BuzzerButtonView
4. **Update Info.plist** for both targets (see SETUP_GUIDE.md Part 2)
5. **Run!**

---

## Test on Simulators (Same Mac)

### Terminal 1: Run tvOS Simulator
```bash
# In Xcode:
# 1. Select TriviaArenaTV scheme
# 2. Select tvOS Simulator (e.g., "Apple TV 4K (3rd generation)")
# 3. Press Cmd+R
```

### Terminal 2: Run iOS Simulator
```bash
# In Xcode:
# 1. Select TriviaArenaController scheme
# 2. Select iPhone Simulator (e.g., "iPhone 15")
# 3. Press Cmd+R
```

### On iPhone Simulator
- Enter TV IP: `127.0.0.1`
- Enter name: `Player 1`
- Tap **Join Room** → **Open Controller**

### On TV Simulator
- See "Player 1" appear in Lobby
- Tap **Start Game**
- On iPhone, tap an answer
- On TV, tap **Buzzer Mode**
- On iPhone, tap **BUZZ**
- On TV, see winner highlighted
- Tap **Scoreboard** to see final scores

---

## Test on Real Devices

### Apple TV Setup
1. Connect Apple TV to Wi‑Fi
2. Settings > AirPlay and HomeKit → Note IP (e.g., `192.168.1.20`)
3. Connect to Mac via USB or wireless
4. In Xcode: Select TriviaArenaTV scheme > Select Apple TV device > Cmd+R

### iPhone Setup
1. Connect iPhone to **same Wi‑Fi** as Apple TV
2. In Xcode: Select TriviaArenaController scheme > Select iPhone device > Cmd+R
3. Enter Apple TV IP (e.g., `192.168.1.20`)
4. Enter name, tap **Join Room**

---

## Game Flow

| Phase | TV Shows | Controllers Show | Action |
|-------|----------|------------------|--------|
| **Lobby** | Players list | Players list | TV: Tap "Start Game" |
| **Question** | Q + 4 answers + timer | 4 answer buttons | Controllers: Tap answer |
| **Buzzer** | "Buzz Fast!" | Red BUZZ button | Controllers: Tap BUZZ |
| **Scoreboard** | Sorted scores | Sorted scores | TV: Tap "Next Question" |

---

## Key Files

| File | Purpose |
|------|---------|
| `GameViewModel.swift` | tvOS game engine, WebSocket server, scoring |
| `WebSocketServer.swift` | Network.framework WebSocket host |
| `ControllerClient.swift` | iOS WebSocket client, reconnect logic |
| `Questions.json` | Sample trivia questions |
| `LobbyView.swift`, `QuestionView.swift`, etc. | UI views |

---

## Scoring

- **Correct Answer**: +10 points
- **Buzzer Win**: +5 points
- **Incorrect Answer**: 0 points

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| "Failed to start WebSocket listener" | Port 8080 in use; change port or kill process |
| iPhone can't connect | Same Wi‑Fi? Correct IP? Check firewall |
| Questions.json not found | Add to tvOS target bundle (File Inspector) |
| Frequent disconnects | Weak Wi‑Fi; move closer to router |

---

## Customization

**Add Questions**: Edit `Questions.json`

**Change Scoring**: Edit `GameViewModel.handleAnswer()` and `handleBuzz()`

**Change Timer**: Edit `GameViewModel.startQuestionRound()` duration parameter

**Change Colors**: Edit view files (e.g., `.foregroundColor(.cyan)`)

---

## Next Steps

- [ ] Run on simulators (same Mac)
- [ ] Run on real Apple TV + iPhone
- [ ] Add more questions to Questions.json
- [ ] Customize colors and fonts
- [ ] Test with 3+ controllers
- [ ] Deploy to App Store (if needed)

---

**Ready to play? Let's go! 🎮**
