# Real-Time Stock Price Tracker

SwiftUI app that shows a watchlist of 25 symbols with live simulated prices over a WebSocket echo server, plus a detail screen per symbol.

Stack: **SwiftUI**, **MVVM**, **Coordinator** navigation, **async/await**, and an **`actor`**-based price feed. Unit tests use **Swift Testing**.

> Prices are not from a market API. The assessment uses Postman Echo (`wss://ws.postman-echo.com/raw`): the app generates random updates, sends them, and applies prices when the echo returns.

---

## Requirements

- Xcode 26.x (deployment target iOS 26.2)
- iOS Simulator or device
- Network access for the echo WebSocket

---

## Setup

1. Clone this repository.
2. Open `multibankgroup-stocks.xcodeproj` in Xcode.
3. Select the `multibankgroup-stocks` scheme and a simulator.
4. Run with ⌘R.

### Tests

Product → Test (⌘U), or:

```bash
xcodebuild test \
  -scheme multibankgroup-stocks \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Use any installed simulator name in the destination string.

---

## Features

- 25 scrollable symbols: name, price, percent change
- Start / Stop WebSocket feed with connection status
- Sort by price or price change; tap again to toggle ascending / descending
- Detail screen: symbol title, live price, same change indicator, description
- List and detail stay in sync while the feed runs

---

## Architecture

MVVM + Coordinator, with the feed behind protocols so screens stay testable and easy to extend.

```mermaid
flowchart TB
  subgraph ui [UI]
    ListView[SymbolsListView]
    DetailView[SymbolDetailView]
  end

  subgraph presentation [Presentation]
    ListVM[SymbolsListViewModel]
    DetailVM[SymbolDetailViewModel]
    Coord[AppCoordinator]
  end

  subgraph domain [Domain]
    Stock[Stock]
    Events[PriceFeedEvent]
  end

  subgraph data [Data]
    Proto[PriceFeedServicing]
    Feed[PriceFeedService actor]
    WS[URLSessionWebSocketTask]
  end

  ListView --> ListVM
  DetailView --> DetailVM
  ListVM --> Coord
  ListVM --> Proto
  DetailVM --> Proto
  Feed -.conforms.-> Proto
  Feed --> Stock
  Feed --> Events
  Feed --> WS
  Coord --> DetailView
```

### Design choices

| Choice | Reason |
|--------|--------|
| **MVVM** | Screen logic in ViewModels; Views stay declarative. |
| **Coordinator** | Navigation in one place (`AppRoute` + `NavigationPath`). |
| **`StockQuoting` / `PriceFeedControlling`** | Interface segregation: detail only needs quotes; list also needs start/stop. |
| **`actor` price feed** | Serializes stock mutations across send/receive loops. ViewModels stay `@MainActor` and mirror events into UI state. |
| **`AsyncStream` events** | Feed stays UI-agnostic; each screen can subscribe independently. |
| **DTO vs domain** | `PriceUpdate` is wire JSON; `Stock` owns `apply` and derived change values. |
| **Local catalog** | No market API in the brief — symbols and seed prices are hardcoded. |

### Project layout

```
multibankgroup-stocks/
  App/           # Coordinator, routes
  Catalog/       # Seed watchlist (25 symbols)
  Models/        # Domain, DTOs, events
  Services/      # Feed protocols + WebSocket actor
  ViewModels/
  Views/
multibankgroup-stocksTests/
```

---

## Flows

### Launch

One feed and one coordinator live for the app lifetime. The list ViewModel is held in `@State` so pushing detail does not recreate the list.

```mermaid
sequenceDiagram
  participant App
  participant Coord as AppCoordinator
  participant Feed as PriceFeedService
  participant ListVM as SymbolsListViewModel
  participant List as SymbolsListView

  App->>Feed: create
  App->>Coord: create
  App->>ListVM: create(feed, onSelectSymbol)
  App->>List: show(listVM)
  List->>ListVM: listenForEvents() via .task
  ListVM->>Feed: makeEventStream()
  Feed-->>ListVM: snapshot stocks + status
```

### Live price updates

```mermaid
sequenceDiagram
  participant User
  participant List as SymbolsListView
  participant ListVM as SymbolsListViewModel
  participant Feed as PriceFeedService
  participant Echo as PostmanEcho

  User->>List: Start
  List->>ListVM: start()
  ListVM->>Feed: start()
  Feed->>Echo: open WebSocket
  Feed-->>ListVM: connection(connected)

  loop on an interval
    Feed->>Feed: nudge a few random symbols
    Feed->>Echo: send PriceUpdate JSON
    Echo-->>Feed: echo same JSON
    Feed->>Feed: Stock.apply + broadcast
    Feed-->>ListVM: stocks([...])
    ListVM->>List: UI refresh
  end
```

The UI updates **only after the echo** — that is what validates the WebSocket path.

### Sorting

Sorting is presentation state on the list ViewModel (`sortOption`, `sortDirection`, `sortedStocks`).

- First tap on a sort key selects it and uses **descending** (high → low).
- Tap the **same** key again to toggle **ascending** / **descending**.
- Tap the **other** key to switch metric and reset to descending.
- Ties break on symbol so equal values stay predictable.

```mermaid
flowchart LR
  Stocks[stocks from feed] --> Key{sortOption}
  Key -->|price| DirPrice{sortDirection}
  Key -->|priceChange| DirPct{sortDirection}
  DirPrice -->|descending| PriceDesc[price high to low]
  DirPrice -->|ascending| PriceAsc[price low to high]
  DirPct -->|descending| PctDesc[changePercent high to low]
  DirPct -->|ascending| PctAsc[changePercent low to high]
  PriceDesc --> Tie[symbol tiebreaker]
  PriceAsc --> Tie
  PctDesc --> Tie
  PctAsc --> Tie
  Tie --> UI[List rows]
```

### Detail navigation

```mermaid
sequenceDiagram
  participant User
  participant ListVM as SymbolsListViewModel
  participant Coord as AppCoordinator
  participant DetailVM as SymbolDetailViewModel
  participant Detail as SymbolDetailView
  participant Feed as PriceFeedService

  User->>ListVM: selectSymbol
  ListVM->>Coord: showDetail(symbol)
  Coord->>Detail: push detail
  Detail->>DetailVM: listenForEvents() via .task
  DetailVM->>Feed: makeEventStream()
  Feed-->>DetailVM: live snapshots
```

List and detail each call `makeEventStream()`, so both can listen at the same time against one feed actor.

### Stop

Cancels the feed task group, closes the socket, and broadcasts `disconnected`. Last prices remain on screen until Start again.

---

## Testing

Swift Testing, no network calls.

| Suite | Coverage |
|-------|----------|
| `StockTests` | `apply`, change %, catalog size |
| `SymbolsListViewModelTests` | sorting, tiebreakers, start/stop, navigation callback |
| `SymbolDetailViewModelTests` | symbol selection and price updates via `consume` |
| `AppCoordinatorTests` | push / pop path |

ViewModels expose `consume(_:)` — the same path `listenForEvents()` uses — so tests drive events without timers. `FakePriceFeed` replaces the real actor.

---

## Assumptions

- Prices are simulated; Postman Echo only returns what the app sends.
- “Connected” means the local feed socket and loops are running.
