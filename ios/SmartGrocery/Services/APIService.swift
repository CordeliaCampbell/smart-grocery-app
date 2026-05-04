import Foundation

// MARK: - Errors

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case serverError(Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:         return "Invalid URL."
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .serverError(let c):  return "Server error \(c)."
        case .decodingError(let e): return "Decoding error: \(e.localizedDescription)"
        }
    }
}

// MARK: - Service

final class APIService {
    static let shared = APIService()
    // TODO: replace with your Railway URL, e.g. "https://smart-grocery-app-production.up.railway.app"
    static let baseURL = "http://10.0.0.199:8000"

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: String = APIService.baseURL) {
        session = URLSession.shared
        decoder = JSONDecoder()
        encoder = JSONEncoder()
    }

    // MARK: - Private helpers

    private func fetch<T: Decodable>(path: String) async throws -> T {
        guard let url = URL(string: "\(Self.baseURL)\(path)") else { throw APIError.invalidURL }
        let (data, response) = try await session.data(from: url)
        try validate(response)
        return try decodeOrThrow(data)
    }

    private func mutate<Body: Encodable, Response: Decodable>(
        path: String, method: String, body: Body
    ) async throws -> Response {
        guard let url = URL(string: "\(Self.baseURL)\(path)") else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try encoder.encode(body)
        let (data, response) = try await session.data(for: req)
        try validate(response)
        return try decodeOrThrow(data)
    }

    private func remove(path: String) async throws {
        guard let url = URL(string: "\(Self.baseURL)\(path)") else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        let (_, response) = try await session.data(for: req)
        try validate(response)
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverError(http.statusCode)
        }
    }

    private func decodeOrThrow<T: Decodable>(_ data: Data) throws -> T {
        do { return try decoder.decode(T.self, from: data) }
        catch { throw APIError.decodingError(error) }
    }

    // MARK: - Items

    func fetchItems(categoryId: Int? = nil) async throws -> [Item] {
        let qs = categoryId.map { "?category_id=\($0)" } ?? ""
        return try await fetch(path: "/items/\(qs)")
    }

    func createItem(_ item: ItemCreate) async throws -> Item {
        return try await mutate(path: "/items/", method: "POST", body: item)
    }

    func updateItem(id: Int, _ updates: ItemUpdate) async throws -> Item {
        return try await mutate(path: "/items/\(id)", method: "PATCH", body: updates)
    }

    func deleteItem(id: Int) async throws {
        try await remove(path: "/items/\(id)")
    }

    // MARK: - Categories

    func fetchCategories() async throws -> [Category] {
        return try await fetch(path: "/categories/")
    }

    // MARK: - Lists

    func fetchLists() async throws -> [GroceryList] {
        return try await fetch(path: "/lists/")
    }

    func createList(_ list: ListCreate) async throws -> GroceryList {
        return try await mutate(path: "/lists/", method: "POST", body: list)
    }

    func fetchListDetail(id: Int) async throws -> GroceryListDetail {
        return try await fetch(path: "/lists/\(id)")
    }

    func deleteList(id: Int) async throws {
        try await remove(path: "/lists/\(id)")
    }

    func addListItem(listId: Int, _ item: ListItemCreate) async throws -> ListItem {
        return try await mutate(path: "/lists/\(listId)/items", method: "POST", body: item)
    }

    func updateListItem(listId: Int, itemId: Int, _ updates: ListItemUpdate) async throws -> ListItem {
        return try await mutate(path: "/lists/\(listId)/items/\(itemId)", method: "PATCH", body: updates)
    }

    func deleteListItem(listId: Int, itemId: Int) async throws {
        try await remove(path: "/lists/\(listId)/items/\(itemId)")
    }

    // MARK: - Reminders

    func fetchReminders() async throws -> [Reminder] {
        return try await fetch(path: "/reminders/")
    }

    func createReminder(_ reminder: ReminderCreate) async throws -> Reminder {
        return try await mutate(path: "/reminders/", method: "POST", body: reminder)
    }

    func updateReminder(id: Int, _ updates: ReminderUpdate) async throws -> Reminder {
        return try await mutate(path: "/reminders/\(id)", method: "PATCH", body: updates)
    }

    func deleteReminder(id: Int) async throws {
        try await remove(path: "/reminders/\(id)")
    }
}
