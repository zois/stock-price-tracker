//
//  PriceFeedService.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//

import Foundation

// MARK: - PriceFeedService -

/// Owns the echo WebSocket and the stock list.
/// Actor so mutations stay serialized; ViewModels mirror `makeEventStream()` on the main actor.
actor PriceFeedService: PriceFeedServicing {

    // MARK: - State -

    private(set) var stocks: [Stock]
    private(set) var connectionStatus: ConnectionStatus = .disconnected

    private var eventContinuations: [UUID: AsyncStream<PriceFeedEvent>.Continuation] = [:]
    private var webSocketTask: URLSessionWebSocketTask?
    private var feedTask: Task<Void, Never>?

    private let url: URL
    private let session: URLSession

    // MARK: - Init -

    init(
        stocks: [Stock] = StockCatalog.stocks,
        url: URL = URL(string: "wss://ws.postman-echo.com/raw")!,
        session: URLSession = .shared
    ) {
        self.stocks = stocks
        self.url = url
        self.session = session
    }
}

// MARK: - Private -

private extension PriceFeedService {
    func setConnection(_ status: ConnectionStatus) {
        connectionStatus = status
        broadcast(.connection(status))
    }

    func publishStocks() {
        broadcast(.stocks(stocks))
    }

    func broadcast(_ event: PriceFeedEvent) {
        for continuation in eventContinuations.values {
            continuation.yield(event)
        }
    }

    func addContinuation(
        id: UUID,
        _ continuation: AsyncStream<PriceFeedEvent>.Continuation
    ) {
        eventContinuations[id] = continuation
        // Catch new subscribers up with current snapshot.
        continuation.yield(.connection(connectionStatus))
        continuation.yield(.stocks(stocks))
    }

    func removeContinuation(id: UUID) {
        eventContinuations[id] = nil
    }

    /// Called when the task group ends (error, cancel, or stop).
    func feedDidFinish() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        feedTask = nil

        // stop() may already have set this — don't double-broadcast.
        if connectionStatus != .disconnected {
            setConnection(.disconnected)
        }
    }

    func runSendLoop() async {
        while !Task.isCancelled {
            do {
                try await sendRandomUpdates(count: 3)
                try await Task.sleep(for: .milliseconds(750))
            } catch {
                break
            }
        }
    }

    func runReceiveLoop() async {
        while !Task.isCancelled {
            guard let webSocketTask else { break }

            do {
                let message = try await webSocketTask.receive()
                switch message {
                case .string(let text):
                    handleEchoedMessage(text)
                case .data(let data):
                    handleEchoedData(data)
                @unknown default:
                    break
                }
            } catch {
                break
            }
        }
    }

    /// Sends several one-symbol messages; each still comes back via echo before UI apply.
    func sendRandomUpdates(count: Int) async throws {
        guard !stocks.isEmpty else { return }
        let ticks = min(count, stocks.count)
        var indices = Array(stocks.indices)
        indices.shuffle()
        for index in indices.prefix(ticks) {
            try await sendUpdate(for: stocks[index])
        }
    }

    func sendUpdate(for stock: Stock) async throws {
        guard let webSocketTask else { return }
        let factor = Double.random(in: 0.99...1.01)
        let nudged = (stock.price * factor * 100).rounded() / 100
        let update = PriceUpdate(symbol: stock.symbol, price: nudged)
        let data = try JSONEncoder().encode(update)
        guard let text = String(data: data, encoding: .utf8) else { return }
        try await webSocketTask.send(.string(text))
    }

    func handleEchoedMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        handleEchoedData(data)
    }

    func handleEchoedData(_ data: Data) {
        guard let update = try? JSONDecoder().decode(PriceUpdate.self, from: data),
              let index = stocks.firstIndex(where: { $0.symbol == update.symbol })
        else { return }

        stocks[index].apply(update)
        publishStocks()
    }
}

// MARK: - StockQuoting -

extension PriceFeedService {

    func stock(for symbol: String) -> Stock? {
        stocks.first { $0.symbol == symbol }
    }

    func makeEventStream() -> AsyncStream<PriceFeedEvent> {
        let id = UUID()
        let (stream, continuation) = AsyncStream.makeStream(of: PriceFeedEvent.self)

        addContinuation(id: id, continuation)

        continuation.onTermination = { _ in
            Task {
                await self.removeContinuation(id: id)
            }
        }

        return stream
    }
}

// MARK: - PriceFeedControlling -

extension PriceFeedService {

    func start() {
        guard connectionStatus == .disconnected else { return }

        let socket = session.webSocketTask(with: url)
        webSocketTask = socket
        socket.resume()
        setConnection(.connected)

        // Parent task owns both loops; cancel it in stop().
        feedTask = Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.runSendLoop() }
                group.addTask { await self.runReceiveLoop() }

                // If either loop exits, tear the other down.
                await group.next()
                group.cancelAll()
                await group.waitForAll()
            }

            self.feedDidFinish()
        }
    }

    func stop() {
        feedTask?.cancel()
        feedTask = nil

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil

        setConnection(.disconnected)
    }
}
