use std::collections::{BTreeMap, VecDeque, HashMap};
use std::time::{SystemTime, UNIX_EPOCH};
use std::cmp::Ordering;

// Order structure
#[derive(Debug, Clone)]
pub struct Order {
    pub id: u64,
    pub quantity: u64,
    pub timestamp: u64,
    pub order_type: OrderType,
    pub client_id: String,
}

#[derive(Debug, Clone)]
pub enum OrderType {
    Limit,
    Market,
    Stop,
}

// PriceLevel aggregates all orders at a specific price
#[derive(Debug, Clone)]
pub struct PriceLevel {
    pub price: f64,
    pub total_quantity: u64,
    pub orders: VecDeque<Order>,
    pub order_count: usize,
    pub first_order_time: u64,
}

impl PriceLevel {
    pub fn new(price: f64) -> Self {
        Self {
            price,
            total_quantity: 0,
            orders: VecDeque::new(),
            order_count: 0,
            first_order_time: get_timestamp(),
        }
    }

    pub fn add_order(&mut self, order: Order) {
        self.total_quantity += order.quantity;
        self.order_count += 1;
        if self.orders.is_empty() {
            self.first_order_time = order.timestamp;
        }
        self.orders.push_back(order);
    }

    pub fn remove_order(&mut self, order_id: u64) -> Option<Order> {
        if let Some(pos) = self.orders.iter().position(|order| order.id == order_id) {
            let removed_order = self.orders.remove(pos).unwrap();
            self.total_quantity -= removed_order.quantity;
            self.order_count -= 1;
            Some(removed_order)
        } else {
            None
        }
    }

    pub fn match_quantity(&mut self, mut quantity: u64) -> Vec<Order> {
        let mut matched_orders = Vec::new();
        
        while quantity > 0 && !self.orders.is_empty() {
            let mut order = self.orders.pop_front().unwrap();
            
            if order.quantity <= quantity {
                // Full fill
                quantity -= order.quantity;
                self.total_quantity -= order.quantity;
                self.order_count -= 1;
                matched_orders.push(order);
            } else {
                // Partial fill
                order.quantity -= quantity;
                self.total_quantity -= quantity;
                matched_orders.push(Order {
                    id: order.id,
                    quantity,
                    timestamp: order.timestamp,
                    order_type: order.order_type.clone(),
                    client_id: order.client_id.clone(),
                });
                self.orders.push_front(order);
                quantity = 0;
            }
        }
        
        matched_orders
    }

    pub fn is_empty(&self) -> bool {
        self.orders.is_empty()
    }
}

// Custom wrapper for descending order (for bids)
#[derive(Debug, Clone, Copy, PartialEq)]
struct DescendingF64(f64);

impl Eq for DescendingF64 {}

impl PartialOrd for DescendingF64 {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        // Reverse the comparison for descending order
        other.0.partial_cmp(&self.0)
    }
}

impl Ord for DescendingF64 {
    fn cmp(&self, other: &Self) -> Ordering {
        self.partial_cmp(other).unwrap_or(Ordering::Equal)
    }
}

// Main OrderBook structure
pub struct OrderBook {
    // BTreeMap provides O(log n) operations and maintains sorted order
    bids: BTreeMap<DescendingF64, PriceLevel>,  // Descending order (highest first)
    asks: BTreeMap<OrderedF64, PriceLevel>,     // Ascending order (lowest first)
    
    // Fast lookup for order cancellation
    order_to_price: HashMap<u64, (f64, bool)>, // (price, is_bid)
    
    // Cache best bid/ask for O(1) access
    best_bid: Option<f64>,
    best_ask: Option<f64>,
}

// Custom wrapper for ascending order (for asks)
#[derive(Debug, Clone, Copy, PartialEq)]
struct OrderedF64(f64);

impl Eq for OrderedF64 {}

impl PartialOrd for OrderedF64 {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        self.0.partial_cmp(&other.0)
    }
}

impl Ord for OrderedF64 {
    fn cmp(&self, other: &Self) -> Ordering {
        self.partial_cmp(other).unwrap_or(Ordering::Equal)
    }
}

impl OrderBook {
    pub fn new() -> Self {
        Self {
            bids: BTreeMap::new(),
            asks: BTreeMap::new(),
            order_to_price: HashMap::new(),
            best_bid: None,
            best_ask: None,
        }
    }

    pub fn add_bid(&mut self, price: f64, order: Order) {
        let order_id = order.id;
        
        let price_level = self.bids.entry(DescendingF64(price))
            .or_insert_with(|| PriceLevel::new(price));
        
        price_level.add_order(order);
        self.order_to_price.insert(order_id, (price, true));
        
        // Update best bid
        if self.best_bid.is_none() || price > self.best_bid.unwrap() {
            self.best_bid = Some(price);
        }
    }

    pub fn add_ask(&mut self, price: f64, order: Order) {
        let order_id = order.id;
        
        let price_level = self.asks.entry(OrderedF64(price))
            .or_insert_with(|| PriceLevel::new(price));
        
        price_level.add_order(order);
        self.order_to_price.insert(order_id, (price, false));
        
        // Update best ask
        if self.best_ask.is_none() || price < self.best_ask.unwrap() {
            self.best_ask = Some(price);
        }
    }

    pub fn cancel_order(&mut self, order_id: u64) -> Option<Order> {
        if let Some((price, is_bid)) = self.order_to_price.remove(&order_id) {
            if is_bid {
                if let Some(price_level) = self.bids.get_mut(&DescendingF64(price)) {
                    let removed = price_level.remove_order(order_id);
                    if price_level.is_empty() {
                        self.bids.remove(&DescendingF64(price));
                        self.update_best_bid();
                    }
                    removed
                } else {
                    None
                }
            } else {
                if let Some(price_level) = self.asks.get_mut(&OrderedF64(price)) {
                    let removed = price_level.remove_order(order_id);
                    if price_level.is_empty() {
                        self.asks.remove(&OrderedF64(price));
                        self.update_best_ask();
                    }
                    removed
                } else {
                    None
                }
            }
        } else {
            None
        }
    }

    pub fn market_buy(&mut self, quantity: u64) -> Vec<Order> {
        let mut remaining_quantity = quantity;
        let mut matched_orders = Vec::new();
        
        while remaining_quantity > 0 && !self.asks.is_empty() {
            let (price_key, mut price_level) = self.asks.pop_first().unwrap();
            let price = price_key.0;
            
            let matches = price_level.match_quantity(remaining_quantity);
            for order in &matches {
                remaining_quantity -= order.quantity;
                self.order_to_price.remove(&order.id);
            }
            matched_orders.extend(matches);
            
            if !price_level.is_empty() {
                self.asks.insert(price_key, price_level);
            } else {
                self.update_best_ask();
            }
        }
        
        matched_orders
    }

    pub fn market_sell(&mut self, quantity: u64) -> Vec<Order> {
        let mut remaining_quantity = quantity;
        let mut matched_orders = Vec::new();
        
        while remaining_quantity > 0 && !self.bids.is_empty() {
            let (price_key, mut price_level) = self.bids.pop_first().unwrap();
            let price = price_key.0;
            
            let matches = price_level.match_quantity(remaining_quantity);
            for order in &matches {
                remaining_quantity -= order.quantity;
                self.order_to_price.remove(&order.id);
            }
            matched_orders.extend(matches);
            
            if !price_level.is_empty() {
                self.bids.insert(price_key, price_level);
            } else {
                self.update_best_bid();
            }
        }
        
        matched_orders
    }

    fn update_best_bid(&mut self) {
        self.best_bid = self.bids.keys().next().map(|k| k.0);
    }

    fn update_best_ask(&mut self) {
        self.best_ask = self.asks.keys().next().map(|k| k.0);
    }

    pub fn get_best_bid(&self) -> Option<f64> {
        self.best_bid
    }

    pub fn get_best_ask(&self) -> Option<f64> {
        self.best_ask
    }

    pub fn get_spread(&self) -> Option<f64> {
        match (self.best_bid, self.best_ask) {
            (Some(bid), Some(ask)) => Some(ask - bid),
            _ => None,
        }
    }

    pub fn get_market_depth(&self, levels: usize) -> (Vec<(f64, u64)>, Vec<(f64, u64)>) {
        let bids: Vec<(f64, u64)> = self.bids.iter()
            .take(levels)
            .map(|(price, level)| (price.0, level.total_quantity))
            .collect();
        
        let asks: Vec<(f64, u64)> = self.asks.iter()
            .take(levels)
            .map(|(price, level)| (price.0, level.total_quantity))
            .collect();
        
        (bids, asks)
    }

    pub fn print_order_book(&self, levels: usize) {
        let (bids, asks) = self.get_market_depth(levels);
        
        println!("=== ORDER BOOK ===");
        println!("ASKS (Sell Orders):");
        for (price, qty) in asks.iter().rev() {
            println!("  ${:.2} | {}", price, qty);
        }
        
        if let Some(spread) = self.get_spread() {
            println!("--- SPREAD: ${:.2} ---", spread);
        }
        
        println!("BIDS (Buy Orders):");
        for (price, qty) in bids {
            println!("  ${:.2} | {}", price, qty);
        }
        println!("==================");
    }
}

// Helper function to get current timestamp
fn get_timestamp() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_millis() as u64
}

// Example usage
fn main() {
    let mut order_book = OrderBook::new();
    
    // Add some buy orders (bids)
    order_book.add_bid(100.50, Order {
        id: 1,
        quantity: 1000,
        timestamp: get_timestamp(),
        order_type: OrderType::Limit,
        client_id: "client1".to_string(),
    });
    
    order_book.add_bid(100.25, Order {
        id: 2,
        quantity: 500,
        timestamp: get_timestamp(),
        order_type: OrderType::Limit,
        client_id: "client2".to_string(),
    });
    
    // Add some sell orders (asks)
    order_book.add_ask(100.75, Order {
        id: 3,
        quantity: 800,
        timestamp: get_timestamp(),
        order_type: OrderType::Limit,
        client_id: "client3".to_string(),
    });
    
    order_book.add_ask(101.00, Order {
        id: 4,
        quantity: 1200,
        timestamp: get_timestamp(),
        order_type: OrderType::Limit,
        client_id: "client4".to_string(),
    });
    
    // Display the order book
    order_book.print_order_book(5);
    
    // Execute a market buy order
    println!("\nExecuting market buy for 500 shares...");
    let matches = order_book.market_buy(500);
    println!("Matched orders: {:?}", matches);
    
    // Display updated order book
    order_book.print_order_book(5);
}
