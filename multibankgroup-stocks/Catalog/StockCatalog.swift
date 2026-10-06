//
//  StockCatalog.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//

// MARK: - StockCatalog -

/// Hardcoded watchlist. nonisolated: pure Sendable seed data,
/// safe to read from the price-feed actor (and anywhere else).
enum StockCatalog {

    nonisolated static let stocks: [Stock] = [
        Stock(symbol: "AAPL", name: "Apple", description: "Consumer electronics and services.", price: 198.40, previousPrice: 198.40),
        Stock(symbol: "GOOG", name: "Alphabet", description: "Search, cloud, and advertising.", price: 176.20, previousPrice: 176.20),
        Stock(symbol: "MSFT", name: "Microsoft", description: "Software, cloud, and productivity.", price: 430.15, previousPrice: 430.15),
        Stock(symbol: "AMZN", name: "Amazon", description: "E-commerce and cloud infrastructure.", price: 186.70, previousPrice: 186.70),
        Stock(symbol: "NVDA", name: "NVIDIA", description: "GPUs and AI accelerators.", price: 122.50, previousPrice: 122.50),
        Stock(symbol: "TSLA", name: "Tesla", description: "Electric vehicles and energy.", price: 248.90, previousPrice: 248.90),
        Stock(symbol: "META", name: "Meta", description: "Social platforms and Reality Labs.", price: 512.30, previousPrice: 512.30),
        Stock(symbol: "NFLX", name: "Netflix", description: "Streaming entertainment.", price: 705.10, previousPrice: 705.10),
        Stock(symbol: "AMD", name: "AMD", description: "CPUs and GPUs.", price: 164.80, previousPrice: 164.80),
        Stock(symbol: "INTC", name: "Intel", description: "Semiconductors and foundry.", price: 32.40, previousPrice: 32.40),
        Stock(symbol: "IBM", name: "IBM", description: "Enterprise IT and consulting.", price: 188.60, previousPrice: 188.60),
        Stock(symbol: "ORCL", name: "Oracle", description: "Databases and cloud apps.", price: 142.25, previousPrice: 142.25),
        Stock(symbol: "CRM", name: "Salesforce", description: "CRM and enterprise SaaS.", price: 278.90, previousPrice: 278.90),
        Stock(symbol: "UBER", name: "Uber", description: "Mobility and delivery.", price: 74.15, previousPrice: 74.15),
        Stock(symbol: "LYFT", name: "Lyft", description: "Rideshare mobility.", price: 14.80, previousPrice: 14.80),
        Stock(symbol: "SHOP", name: "Shopify", description: "E-commerce platform.", price: 78.40, previousPrice: 78.40),
        Stock(symbol: "SQ", name: "Block", description: "Payments and financial tools.", price: 71.20, previousPrice: 71.20),
        Stock(symbol: "PYPL", name: "PayPal", description: "Digital payments.", price: 68.55, previousPrice: 68.55),
        Stock(symbol: "BA", name: "Boeing", description: "Aerospace and defense.", price: 178.30, previousPrice: 178.30),
        Stock(symbol: "DIS", name: "Disney", description: "Media, parks, and streaming.", price: 112.70, previousPrice: 112.70),
        Stock(symbol: "NKE", name: "Nike", description: "Athletic apparel and footwear.", price: 89.10, previousPrice: 89.10),
        Stock(symbol: "KO", name: "Coca-Cola", description: "Beverages and brands.", price: 63.45, previousPrice: 63.45),
        Stock(symbol: "PEP", name: "PepsiCo", description: "Snacks and beverages.", price: 171.80, previousPrice: 171.80),
        Stock(symbol: "JPM", name: "JPMorgan", description: "Global banking and markets.", price: 205.60, previousPrice: 205.60),
        Stock(symbol: "V", name: "Visa", description: "Card payments network.", price: 279.40, previousPrice: 279.40),
    ]
}
