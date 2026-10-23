cat << 'EOF' > README.md
# 🍏 Food Expiry Tracker & Recipe Discovery (iOS)

A native iOS application designed to track household food inventory, reduce kitchen waste through expiration analytics, and generate intelligent recipe recommendations using current inventory.

---

## ✨ Features
* **Inventory Management:** Full CRUD operations for fridge, pantry, and freezer items with unit conversion and category management.
* **Smart Expiration Logic:** Categorizes items into *Fresh* (>3 days), *Expiring Soon* (0–3 days), and *Expired* (<0 days).
* **Recipe Discovery:** Integrates with the **Spoonacular REST API** using Swift Concurrency to suggest recipes based on available ingredients, prioritizing items near expiration.
* **Real-time Analytics:** Visual dashboard summarizing current food status and urgent consumption priorities.

---

## 🛠 Tech Stack
* **Language:** Swift
* **UI Framework:** SwiftUI (`@EnvironmentObject`, custom dynamic lists, sheets)
* **Backend:** ParseSwift / Back4App (User Auth, Relational Pointers, Custom ACLs)
* **Networking:** Swift Concurrency (`async/await`), `URLSession`, REST APIs
* **Dependency Manager:** Swift Package Manager (SPM)

---

## 🚀 Getting Started

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/Isha2004-coder/Food-Expiry-Tracker.git](https://github.com/Isha2004-coder/Food-Expiry-Tracker.git)
   cd Food-Expiry-Tracker
