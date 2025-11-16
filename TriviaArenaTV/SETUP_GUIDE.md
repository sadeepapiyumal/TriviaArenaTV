# MultiScreen Trivia Arena – Setup & Running Guide

## Project Overview

**TriviaArenaTV** (tvOS) runs a WebSocket server that hosts the game, manages players, and displays the game state.

**TriviaArenaController** (iOS) is a companion app that connects to the TV and lets players answer questions, buzz, and see the scoreboard.

---

## Part 1: Xcode Project Setup

### 1.1 Create the iOS Target

1. In Xcode, open your `TriviaArenaTV.xcodeproj`.
2. Select the project in the navigator.
3. Click **File > New > Target…**
4. Choose **iOS > App**.
5. Name it **TriviaArenaController**.
6. Set **Team**, **Organization**, and other details to match your tvOS target.
7. Click **Finish**.

### 1.2 Add Files to Targets

**tvOS Target (TriviaArenaTV):**
- PlayerModel.swift
- QuestionModel.swift
- WebSocketServer.swift
- GameViewModel.swift
- LobbyView.swift
- QuestionView.swift
- BuzzerView.swift
- ScoreboardView.swift
- Questions.json

**iOS Target (TriviaArenaController):**
- TriviaArenaControllerApp.swift
- ControllerClient.swift
- JoinView.swift
- ControllerMainView.swift
- AnswerButtonsView.swift
- BuzzerButtonView.swift

To assign files to targets:
1. Select a file in the navigator.
2. Open the **File Inspector** (right panel, ⌘⌥1).
3. Under **Target Membership**, check/uncheck targets as needed.

---

## Part 2: Info.plist Configuration

### 2.1 tvOS Target (TriviaArenaTV)

1. Select the **TriviaArenaTV** target.
2. Go to **Build Settings** tab.
3. Search for **Info.plist File** and verify it points to the correct plist.
4. Open **Info.plist** (or right-click → Open As → Source Code).
5. Add these keys:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>Used to connect controllers to the Apple TV over local Wi‑Fi.</string>

<key>NSBonjourServices</key>
<array>
  <string>_ws._tcp</string>
</array>

<key>NSApplicationTransportSecurity</key>
<dict>
  <key>NSAllowsLocalNetworking</key>
  <true/>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

### 2.2 iOS Target (TriviaArenaController)

1. Select the **TriviaArenaController** target.
2. Go to **Build Settings** tab.
3. Search for **Info.plist File** and verify it points to the correct plist.
4. Open **Info.plist** (or right-click → Open As → Source Code).
5. Add the same keys as above:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>Used to connect to the Apple TV over local Wi‑Fi.</string>

<key>NSBonjourServices</key>
<array>
  <string>_ws._tcp</string>
</array>

<key>NSApplicationTransportSecurity</key>
<dict>
  <key>NSAllowsLocalNetworking</key>
  <true/>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

---

## Part 3: Running on Simulators (Quick Test)

### 3.1 Run tvOS Simulator

1. Select **TriviaArenaTV** scheme.
2. Choose a **tvOS Simulator** (e.g., "Apple TV 4K (3rd generation)").
3. Press **Cmd+R** to build and run.
4. The TV app will start and listen on `ws://127.0.0.1:8080`.

### 3.2 Run iOS Simulator

1. Select **TriviaArenaController** scheme.
2. Choose an **iPhone Simulator** (e.g., "iPhone 15").
3. Press **Cmd+R** to build and run.
4. In the **Join View**:
   - Enter TV IP: `127.0.0.1` (for simulator on same Mac)
   - Enter your name (e.g., "Player 1")
   - Tap **Join Room**
   - Tap **Open Controller**

### 3.3 Test the Flow

**On TV:**
- See "Waiting for Players" in the Lobby.
- See your player appear with a green dot.
- Tap **Start Game** to begin a question round.

**On iPhone:**
- See the question and 4 answer buttons (A/B/C/D).
- Tap an answer to submit (button locks).
- See the timer bar on TV counting down.

**Switch to Buzzer:**
- On TV, tap **Buzzer Mode**.
- On iPhone, see a large red **BUZZ** button.
- Tap it; TV highlights you as the winner.

**Scoreboard:**
- On TV, tap **Scoreboard**.
- See all players sorted by score.

---

## Part 4: Running on Real Devices

### 4.1 Prerequisites

- **Apple TV** (4K or later) connected to Wi‑Fi.
- **iPhone** connected to the **same Wi‑Fi network**.
- Both devices on the same local network (e.g., `192.168.1.x`).

### 4.2 Find Apple TV IP

1. On Apple TV, go to **Settings > AirPlay and HomeKit**.
2. Note the IP address (e.g., `192.168.1.20`).

### 4.3 Deploy tvOS App

1. Connect Apple TV to Mac via USB (or use wireless pairing).
2. In Xcode, select **TriviaArenaTV** scheme.
3. Select your **Apple TV** device (appears in scheme selector).
4. Press **Cmd+R** to build and deploy.
5. The app will run on the TV and listen on `ws://<TV_IP>:8080`.

### 4.4 Deploy iOS App

1. Connect iPhone to Mac via USB (or use wireless pairing).
2. In Xcode, select **TriviaArenaController** scheme.
3. Select your **iPhone** device.
4. Press **Cmd+R** to build and deploy.
5. In the **Join View**:
   - Enter the Apple TV IP (e.g., `192.168.1.20`).
   - Enter your name.
   - Tap **Join Room**.

### 4.5 Reconnect Logic

If the iPhone loses connection:
- The app automatically attempts to reconnect every 3 seconds.
- Once reconnected, it re-sends the join message.
- The TV will re-add the player to the lobby.

---

## Part 5: File Structure Summary

```
TriviaArenaTV/
├── TriviaArenaTV/                    (tvOS target)
│   ├── TriviaArenaTVApp.swift
│   ├── ContentView.swift
│   ├── PlayerModel.swift
│   ├── QuestionModel.swift
│   ├── WebSocketServer.swift
│   ├── GameViewModel.swift
│   ├── LobbyView.swift
│   ├── QuestionView.swift
│   ├── BuzzerView.swift
│   ├── ScoreboardView.swift
│   └── Questions.json
│
├── TriviaArenaController/            (iOS target)
│   ├── TriviaArenaControllerApp.swift
│   ├── ControllerClient.swift
│   ├── JoinView.swift
│   ├── ControllerMainView.swift
│   ├── AnswerButtonsView.swift
│   └── BuzzerButtonView.swift
│
└── SETUP_GUIDE.md                    (this file)
```

---

## Part 6: Game Flow & Features

### Lobby Phase
- **TV**: Shows "Waiting for Players" with a list of connected players (green dot = connected).
- **Controllers**: See the lobby with player list and scores.
- **Action**: TV host taps **Start Game** to begin.

### Question Phase
- **TV**: Displays the question text, 4 answers (A/B/C/D), and a timer bar.
- **Controllers**: Show 4 answer buttons. Tap one to submit. Button locks after answering.
- **Scoring**: Correct answer = +10 points. Incorrect = 0 points.
- **Timer**: 10 seconds per question. Auto-advances to Scoreboard when time expires.

### Buzzer Phase
- **TV**: Shows "Buzz Fast!" and waits for the first buzz.
- **Controllers**: Large red **BUZZ** button. First tap wins.
- **Scoring**: Buzzer winner gets +5 points.
- **Highlight**: TV highlights the winner's name in green.

### Scoreboard Phase
- **TV**: Shows all players sorted by score (highest first).
- **Controllers**: See the same scoreboard.
- **Color Coding**:
  - Green background = last answer was correct.
  - Red background = last answer was incorrect.
  - Gray background = no answer submitted.
- **Action**: TV host taps **Next Question** or **Lobby** to continue.

---

## Part 7: Networking Protocol

### WebSocket Messages

**Client → Server (Controller sends):**
```json
{
  "type": "join",
  "name": "Player 1",
  "choiceIndex": null
}
```

```json
{
  "type": "answer",
  "name": null,
  "choiceIndex": 2
}
```

```json
{
  "type": "buzz",
  "name": null,
  "choiceIndex": null
}
```

**Server → Client (TV broadcasts):**
```json
{
  "type": "state",
  "state": "question",
  "question": {
    "id": "...",
    "text": "Which company created Swift?",
    "answers": ["Apple", "Google", "Microsoft", "IBM"],
    "correctIndex": 0
  },
  "players": [
    {
      "id": "...",
      "name": "Player 1",
      "score": 10,
      "isConnected": true,
      "lastAnswerCorrect": true
    }
  ],
  "winnerId": null
}
```

---

## Part 8: Troubleshooting

### Issue: "Failed to start WebSocket listener"
- **Cause**: Port 8080 is already in use.
- **Fix**: Change the port in `GameViewModel.start()` or kill the process using port 8080.

### Issue: iPhone can't connect to TV
- **Cause**: Different Wi‑Fi networks or firewall blocking.
- **Fix**: Ensure both devices are on the same network. Check router settings.

### Issue: "Invalid host" error on iPhone
- **Cause**: Incorrect IP address entered.
- **Fix**: Double-check the TV IP in Settings > AirPlay and HomeKit.

### Issue: Controller disconnects frequently
- **Cause**: Weak Wi‑Fi signal or network congestion.
- **Fix**: Move closer to the router or reduce interference.

### Issue: Questions.json not found
- **Cause**: File not added to tvOS target bundle.
- **Fix**: Select Questions.json in Xcode, open File Inspector, and check **Target Membership** for TriviaArenaTV.

---

## Part 9: Customization

### Add More Questions
Edit `Questions.json` and add more question objects:
```json
{
  "id": "F6666666-6666-6666-6666-666666666666",
  "text": "Your question here?",
  "answers": ["Option A", "Option B", "Option C", "Option D"],
  "correctIndex": 0
}
```

### Change Scoring
In `GameViewModel.swift`, modify the `handleAnswer()` and `handleBuzz()` methods:
```swift
if isCorrect {
    players[idx].score += 20  // Change from 10 to 20
}
```

### Change Timer Duration
In `GameViewModel.swift`, modify `startQuestionRound()`:
```swift
startTimer(duration: 15) { ... }  // Change from 10 to 15 seconds
```

### Customize UI Colors
Edit the view files (e.g., `LobbyView.swift`) and change color values:
```swift
.foregroundColor(.cyan)  // Change from .white
```

---

## Part 10: Production Checklist

- [ ] Test on real Apple TV and iPhone devices.
- [ ] Verify all 5 sample questions load correctly.
- [ ] Test player join/leave scenarios.
- [ ] Test reconnection after network loss.
- [ ] Test all game phases (lobby, question, buzzer, scoreboard).
- [ ] Verify scoring is accurate.
- [ ] Check timer bar animation is smooth.
- [ ] Verify player animations on join.
- [ ] Test with 2+ controllers simultaneously.
- [ ] Check Info.plist permissions are set correctly.
- [ ] Build and archive for App Store (if needed).

---

## Support

For issues or questions, refer to the inline code comments in each Swift file. All code is production-ready and uses async/await for modern concurrency.

Happy trivia! 🎉
