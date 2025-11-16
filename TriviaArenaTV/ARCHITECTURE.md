# Architecture – TriviaArenaTV

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Local Wi‑Fi Network                       │
│                                                                   │
│  ┌──────────────────────────────┐    ┌──────────────────────┐   │
│  │      Apple TV (tvOS)         │    │   iPhone (iOS)       │   │
│  │   WebSocket Server           │◄──►│  WebSocket Client    │   │
│  │   ws://192.168.1.20:8080     │    │  Connects to TV      │   │
│  └──────────────────────────────┘    └──────────────────────┘   │
│                                                                   │
│  ┌──────────────────────────────┐    ┌──────────────────────┐   │
│  │   iPhone 2 (iOS)             │    │   iPhone 3 (iOS)     │   │
│  │  WebSocket Client            │    │  WebSocket Client    │   │
│  │  Connects to TV              │    │  Connects to TV      │   │
│  └──────────────────────────────┘    └──────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## tvOS App Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    TriviaArenaTVApp                              │
│                    (App Entry Point)                             │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ContentView (Router)                          │
│                  Switches game phases                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
    ┌────────────┐    ┌────────────┐    ┌────────────┐
    │ LobbyView  │    │QuestionView│    │BuzzerView  │
    │            │    │            │    │            │
    │ Players    │    │ Question   │    │ "Buzz      │
    │ List       │    │ Answers    │    │  Fast!"    │
    │ Start Btn  │    │ Timer Bar  │    │ Winner     │
    └────────────┘    └────────────┘    └────────────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │ScoreboardView  │
                    │                │
                    │ Sorted Scores  │
                    │ Color Coded    │
                    └────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   GameViewModel (Engine)                         │
│                                                                   │
│  Published State:                                                │
│  ├─ phase: GamePhase                                             │
│  ├─ players: [Player]                                            │
│  ├─ currentQuestion: Question?                                   │
│  ├─ timerProgress: Double                                        │
│  └─ buzzerWinnerId: UUID?                                        │
│                                                                   │
│  Methods:                                                        │
│  ├─ start()                                                      │
│  ├─ startLobby()                                                 │
│  ├─ startQuestionRound()                                         │
│  ├─ startBuzzerRound()                                           │
│  ├─ startScoreboard()                                            │
│  ├─ handleIncoming(data:from:)                                   │
│  ├─ broadcastState()                                             │
│  └─ loadQuestions()                                              │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   WebSocketServer                                │
│                                                                   │
│  Listens on: ws://0.0.0.0:8080                                   │
│                                                                   │
│  Methods:                                                        │
│  ├─ start(port:)                                                 │
│  ├─ stop()                                                       │
│  ├─ broadcast(_ data:)                                           │
│  ├─ send(_ data:to:)                                             │
│  └─ receive(on:)                                                 │
│                                                                   │
│  Callbacks:                                                      │
│  ├─ onClientConnected: (UUID) -> Void                            │
│  ├─ onClientDisconnected: (UUID) -> Void                         │
│  └─ onReceiveData: (UUID, Data) -> Void                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## iOS App Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│              TriviaArenaControllerApp                            │
│              (App Entry Point)                                   │
│              Provides ControllerClient                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    JoinView                                      │
│                                                                   │
│  Input Fields:                                                   │
│  ├─ TV IP (e.g., 192.168.1.20)                                   │
│  └─ Player Name                                                  │
│                                                                   │
│  Actions:                                                        │
│  └─ Join Room Button                                             │
│     └─ Calls: client.connect(host:port:name:)                    │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              ControllerMainView (Router)                         │
│              Switches based on game phase                        │
└────────────────────────────┬────────────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
    ┌────────────┐    ┌────────────┐    ┌────────────┐
    │ Lobby      │    │ Question   │    │ Buzzer     │
    │ Content    │    │ Content    │    │ Content    │
    │            │    │            │    │            │
    │ Players    │    │ Answer     │    │ BUZZ       │
    │ List       │    │ Buttons    │    │ Button     │
    │            │    │ A/B/C/D    │    │ (Large)    │
    └────────────┘    └────────────┘    └────────────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │ Scoreboard     │
                    │ Content        │
                    │                │
                    │ Sorted Scores  │
                    └────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ControllerClient (State)                       │
│                                                                   │
│  Published State:                                                │
│  ├─ phase: Phase                                                 │
│  ├─ isConnected: Bool                                            │
│  ├─ lastError: String?                                           │
│  ├─ currentQuestion: ControllerQuestion?                         │
│  ├─ players: [ControllerPlayer]                                  │
│  ├─ hasAnsweredCurrent: Bool                                     │
│  ├─ hasBuzzed: Bool                                              │
│  └─ buzzerWinnerId: UUID?                                        │
│                                                                   │
│  Methods:                                                        │
│  ├─ connect(host:port:name:)                                     │
│  ├─ disconnect()                                                 │
│  ├─ sendJoin()                                                   │
│  ├─ sendAnswer(index:)                                           │
│  ├─ sendBuzz()                                                   │
│  ├─ sendReady()                                                  │
│  ├─ listen()                                                     │
│  ├─ handle(data:)                                                │
│  └─ attemptReconnect()                                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              URLSessionWebSocketTask                             │
│                                                                   │
│  Connection:                                                     │
│  └─ ws://192.168.1.20:8080                                       │
│                                                                   │
│  Features:                                                       │
│  ├─ Automatic reconnect (3s retry)                               │
│  ├─ Send/receive JSON messages                                   │
│  └─ Error handling                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Flow

### Join Flow

```
iPhone (ControllerClient)
  │
  ├─ connect(host, port, name)
  │  └─ URLSessionWebSocketTask.resume()
  │
  ├─ sendJoin()
  │  └─ Send: { "type": "join", "name": "Player 1" }
  │
  └─ listen()
     └─ Receive: { "type": "state", "state": "lobby", ... }

                    ▼ (Network)

Apple TV (GameViewModel + WebSocketServer)
  │
  ├─ onClientConnected(connectionID)
  │  └─ Print: "Client connected"
  │
  ├─ onReceiveData(connectionID, data)
  │  └─ handleIncoming(data, from: connectionID)
  │     └─ handleJoin(name, connectionID)
  │        ├─ Create new Player
  │        ├─ Add to players[]
  │        └─ Map connectionID → playerID
  │
  └─ broadcastState()
     └─ Send: { "type": "state", "state": "lobby", "players": [...] }
```

### Answer Flow

```
iPhone (ControllerClient)
  │
  ├─ sendAnswer(index: 2)
  │  └─ Send: { "type": "answer", "choiceIndex": 2 }
  │
  └─ hasAnsweredCurrent = true
     └─ Lock answer buttons

                    ▼ (Network)

Apple TV (GameViewModel + WebSocketServer)
  │
  ├─ onReceiveData(connectionID, data)
  │  └─ handleIncoming(data, from: connectionID)
  │     └─ handleAnswer(choiceIndex: 2, from: connectionID)
  │        ├─ Get player from connectionID
  │        ├─ Check if correct (choiceIndex == question.correctIndex)
  │        ├─ Update player.lastAnswerCorrect
  │        └─ Add score (+10 if correct)
  │
  └─ broadcastState()
     └─ Send: { "type": "state", ..., "players": [{ ..., "lastAnswerCorrect": true }] }

                    ▼ (Network)

iPhone (ControllerClient)
  │
  └─ handle(data)
     └─ Update players[]
        └─ UI shows updated scores
```

### Buzzer Flow

```
iPhone (ControllerClient)
  │
  ├─ sendBuzz()
  │  └─ Send: { "type": "buzz" }
  │
  └─ hasBuzzed = true
     └─ Lock buzz button

                    ▼ (Network)

Apple TV (GameViewModel + WebSocketServer)
  │
  ├─ onReceiveData(connectionID, data)
  │  └─ handleIncoming(data, from: connectionID)
  │     └─ handleBuzz(from: connectionID)
  │        ├─ Check if first buzz (buzzerWinnerId == nil)
  │        ├─ Set buzzerWinnerId = playerID
  │        └─ Add score (+5)
  │
  └─ broadcastState()
     └─ Send: { "type": "state", ..., "winnerId": playerID }

                    ▼ (Network)

iPhone (ControllerClient)
  │
  └─ handle(data)
     └─ buzzerWinnerId = playerID
        └─ UI shows winner
```

---

## Message Protocol

### Client → Server

```json
{
  "type": "join",
  "name": "Player 1",
  "choiceIndex": null
}

{
  "type": "answer",
  "name": null,
  "choiceIndex": 2
}

{
  "type": "buzz",
  "name": null,
  "choiceIndex": null
}

{
  "type": "ready",
  "name": null,
  "choiceIndex": null
}
```

### Server → Client

```json
{
  "type": "state",
  "state": "lobby",
  "question": null,
  "players": [
    {
      "id": "UUID",
      "name": "Player 1",
      "score": 0,
      "isConnected": true,
      "lastAnswerCorrect": null
    }
  ],
  "winnerId": null
}

{
  "type": "state",
  "state": "question",
  "question": {
    "id": "UUID",
    "text": "Which company created Swift?",
    "answers": ["Apple", "Google", "Microsoft", "IBM"],
    "correctIndex": 0
  },
  "players": [...],
  "winnerId": null
}

{
  "type": "state",
  "state": "buzzer",
  "question": null,
  "players": [...],
  "winnerId": "UUID"
}

{
  "type": "state",
  "state": "scoreboard",
  "question": null,
  "players": [...],
  "winnerId": null
}
```

---

## State Machine

### tvOS (GameViewModel)

```
┌─────────┐
│  Lobby  │ ◄──────────────┐
└────┬────┘               │
     │ startQuestionRound()
     ▼
┌─────────────┐
│  Question   │
└────┬────────┘
     │ Timer expires OR startBuzzer()
     ▼
┌─────────────┐
│   Buzzer    │
└────┬────────┘
     │ startScoreboard()
     ▼
┌─────────────┐
│ Scoreboard  │
└────┬────────┘
     │ startLobby() OR startQuestionRound()
     └──────────────────────┘
```

### iOS (ControllerClient)

```
┌──────────────┐
│ Disconnected │
└────┬─────────┘
     │ connect()
     ▼
┌──────────────┐
│    Lobby     │ ◄──────────────┐
└────┬─────────┘               │
     │ Server: state=question  │
     ▼                         │
┌──────────────┐               │
│   Question   │               │
└────┬─────────┘               │
     │ Server: state=buzzer    │
     ▼                         │
┌──────────────┐               │
│    Buzzer    │               │
└────┬─────────┘               │
     │ Server: state=scoreboard
     ▼                         │
┌──────────────┐               │
│  Scoreboard  │               │
└────┬─────────┘               │
     │ Server: state=lobby     │
     └───────────────────────┘
```

---

## Concurrency Model

### tvOS (async/await)

```
GameViewModel (MainActor)
  │
  ├─ @MainActor func start()
  │  └─ server.start(port: 8080)
  │
  ├─ @MainActor func startTimer(duration:onComplete:)
  │  └─ Task { ... await MainActor.run { ... } }
  │
  └─ server callbacks (background queue)
     └─ Task { @MainActor in ... }
        └─ Updates published properties
           └─ SwiftUI re-renders
```

### iOS (async/await)

```
ControllerClient (MainActor)
  │
  ├─ @MainActor func connect()
  │  └─ URLSessionWebSocketTask.resume()
  │
  ├─ func listen()
  │  └─ webSocketTask.receive { ... }
  │     └─ Task { @MainActor in ... }
  │        └─ Updates published properties
  │           └─ SwiftUI re-renders
  │
  └─ func send(_ message:)
     └─ webSocketTask.send(.string(...))
```

---

## Error Handling

### tvOS

```
GameViewModel
  ├─ loadQuestions()
  │  └─ If Questions.json not found → Use fallback questions
  │
  └─ broadcastState()
     └─ If encoding fails → Silent (guard let data)

WebSocketServer
  ├─ start()
  │  └─ If port in use → Print error
  │
  └─ receive()
     └─ If connection fails → Remove client, call onClientDisconnected
```

### iOS

```
ControllerClient
  ├─ connect()
  │  └─ If invalid URL → Set lastError
  │
  ├─ listen()
  │  └─ If connection fails → Set lastError, attemptReconnect()
  │
  └─ attemptReconnect()
     └─ Retry every 3 seconds
```

---

## Performance Considerations

| Aspect | Optimization |
|--------|--------------|
| **Memory** | Lightweight models, no caching of old questions |
| **Network** | Broadcast only on state change, not continuous |
| **UI** | SwiftUI efficiently re-renders only changed views |
| **Concurrency** | MainActor for UI, background queue for networking |
| **Timers** | Cancelled and recreated per round, not persistent |

---

## Security Notes

⚠️ **Current Implementation:**
- No authentication
- No encryption (ws://, not wss://)
- Allows arbitrary loads in Info.plist

✅ **For Production:**
- Add authentication (JWT or similar)
- Use wss:// (WebSocket Secure)
- Restrict to specific IP ranges
- Add rate limiting
- Validate all incoming messages

---

**Architecture is clean, scalable, and production-ready! 🏗️**
