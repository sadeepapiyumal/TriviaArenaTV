# Xcode Configuration Checklist

## Step 1: Create iOS Target

- [ ] Open `TriviaArenaTV.xcodeproj` in Xcode
- [ ] File > New > Target…
- [ ] Select **iOS > App**
- [ ] Name: `TriviaArenaController`
- [ ] Set Team, Organization, Bundle ID
- [ ] Click **Finish**

---

## Step 2: Assign Files to Targets

### tvOS Target (TriviaArenaTV)

Select each file and open **File Inspector** (⌘⌥1). Check **Target Membership**:

- [ ] PlayerModel.swift → TriviaArenaTV ✓
- [ ] QuestionModel.swift → TriviaArenaTV ✓
- [ ] WebSocketServer.swift → TriviaArenaTV ✓
- [ ] GameViewModel.swift → TriviaArenaTV ✓
- [ ] LobbyView.swift → TriviaArenaTV ✓
- [ ] QuestionView.swift → TriviaArenaTV ✓
- [ ] BuzzerView.swift → TriviaArenaTV ✓
- [ ] ScoreboardView.swift → TriviaArenaTV ✓
- [ ] Questions.json → TriviaArenaTV ✓
- [ ] TriviaArenaTVApp.swift → TriviaArenaTV ✓ (already there)
- [ ] ContentView.swift → TriviaArenaTV ✓ (already there)

### iOS Target (TriviaArenaController)

- [ ] TriviaArenaControllerApp.swift → TriviaArenaController ✓
- [ ] ControllerClient.swift → TriviaArenaController ✓
- [ ] JoinView.swift → TriviaArenaController ✓
- [ ] ControllerMainView.swift → TriviaArenaController ✓
- [ ] AnswerButtonsView.swift → TriviaArenaController ✓
- [ ] BuzzerButtonView.swift → TriviaArenaController ✓

---

## Step 3: Configure Info.plist (tvOS)

1. Select **TriviaArenaTV** target
2. Go to **Build Settings** tab
3. Search for **Info.plist File** → Verify it exists
4. Right-click on **Info.plist** in navigator → **Open As > Source Code**
5. Add these keys (before closing `</dict>`):

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

- [ ] NSLocalNetworkUsageDescription added
- [ ] NSBonjourServices added
- [ ] NSApplicationTransportSecurity added

---

## Step 4: Configure Info.plist (iOS)

1. Select **TriviaArenaController** target
2. Go to **Build Settings** tab
3. Search for **Info.plist File** → Verify it exists
4. Right-click on **Info.plist** in navigator → **Open As > Source Code**
5. Add the same keys as Step 3

- [ ] NSLocalNetworkUsageDescription added
- [ ] NSBonjourServices added
- [ ] NSApplicationTransportSecurity added

---

## Step 5: Verify Build Settings

### tvOS Target

1. Select **TriviaArenaTV** target
2. Go to **Build Settings** tab
3. Verify:
   - [ ] **Minimum Deployments**: tvOS 14.0 or later
   - [ ] **Swift Language Version**: Swift 5.9 or later
   - [ ] **Supported Platforms**: tvOS

### iOS Target

1. Select **TriviaArenaController** target
2. Go to **Build Settings** tab
3. Verify:
   - [ ] **Minimum Deployments**: iOS 14.0 or later
   - [ ] **Swift Language Version**: Swift 5.9 or later
   - [ ] **Supported Platforms**: iOS

---

## Step 6: Verify Schemes

1. Product > Scheme > Edit Scheme…
2. Verify **TriviaArenaTV** scheme:
   - [ ] Executable: TriviaArenaTV
   - [ ] Build Configuration: Debug
   - [ ] Run: tvOS Simulator or Apple TV device

3. Verify **TriviaArenaController** scheme:
   - [ ] Executable: TriviaArenaController
   - [ ] Build Configuration: Debug
   - [ ] Run: iOS Simulator or iPhone device

---

## Step 7: Build & Test

### Build tvOS Target
```bash
# In Xcode:
# 1. Select TriviaArenaTV scheme
# 2. Select tvOS Simulator or Apple TV device
# 3. Press Cmd+B to build
```

- [ ] tvOS target builds without errors
- [ ] No warnings about missing files

### Build iOS Target
```bash
# In Xcode:
# 1. Select TriviaArenaController scheme
# 2. Select iPhone Simulator or iPhone device
# 3. Press Cmd+B to build
```

- [ ] iOS target builds without errors
- [ ] No warnings about missing files

---

## Step 8: Run on Simulators

### Run tvOS Simulator
```bash
# In Xcode:
# 1. Select TriviaArenaTV scheme
# 2. Select tvOS Simulator (e.g., "Apple TV 4K (3rd generation)")
# 3. Press Cmd+R
```

- [ ] tvOS app launches
- [ ] Lobby screen shows "Waiting for Players"
- [ ] No crashes

### Run iOS Simulator
```bash
# In Xcode:
# 1. Select TriviaArenaController scheme
# 2. Select iPhone Simulator (e.g., "iPhone 15")
# 3. Press Cmd+R
```

- [ ] iOS app launches
- [ ] Join screen shows
- [ ] Can enter TV IP and name
- [ ] Can tap "Join Room"

---

## Step 9: Test Connection

1. On iPhone simulator, enter TV IP: `127.0.0.1`
2. Enter name: `Player 1`
3. Tap **Join Room**

- [ ] No error message
- [ ] "Open Controller" button appears
- [ ] On TV, see "Player 1" in Lobby with green dot

---

## Step 10: Test Game Flow

1. On TV, tap **Start Game**
2. On iPhone, see question and answer buttons
3. On iPhone, tap an answer

- [ ] Answer button locks
- [ ] On TV, see timer bar
- [ ] On TV, tap **Buzzer Mode**
- [ ] On iPhone, see red BUZZ button
- [ ] On iPhone, tap BUZZ
- [ ] On TV, see "Player 1 buzzed first!" with green highlight
- [ ] On TV, tap **Scoreboard**
- [ ] See "Player 1" with updated score

- [ ] All game phases work
- [ ] No crashes
- [ ] Animations smooth

---

## Step 11: Final Checks

- [ ] All 9 tvOS files present and assigned to tvOS target
- [ ] All 6 iOS files present and assigned to iOS target
- [ ] Questions.json in tvOS bundle
- [ ] Info.plist keys added for both targets
- [ ] Both targets build without errors
- [ ] Both targets run on simulators
- [ ] Connection works (127.0.0.1 on same Mac)
- [ ] Game flow complete (lobby → question → buzzer → scoreboard)
- [ ] No console errors or warnings

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "File not found" error | Check File Inspector > Target Membership |
| Build fails | Clean build folder (Cmd+Shift+K) and rebuild |
| App won't launch | Check scheme is correct (Product > Scheme) |
| Connection fails | Verify IP is `127.0.0.1` for simulators on same Mac |
| Questions.json not found | Add to tvOS target bundle (File Inspector) |

---

## Ready to Deploy?

Once all checks pass:

1. **For real devices**: Connect Apple TV and iPhone to same Wi‑Fi
2. **Find Apple TV IP**: Settings > AirPlay and HomeKit
3. **Deploy tvOS**: Select Apple TV device, Cmd+R
4. **Deploy iOS**: Select iPhone device, Cmd+R
5. **Enter TV IP** in iOS app join screen
6. **Play!**

---

**All set? Let's build! 🚀**
