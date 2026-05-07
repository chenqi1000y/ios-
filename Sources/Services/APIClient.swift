import Foundation

enum APIError: LocalizedError {
    case invalidResponse
    case invalidStatusCode(Int, String)
    case uploadEncodingFailed
    case invalidImageData
    case timeout
    case pollingTimeout
    case message(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "服务端返回了无法识别的响应。"
        case let .invalidStatusCode(code, message):
            return "请求失败（\(code)）：\(message)"
        case .uploadEncodingFailed:
            return "图片上传参数编码失败。"
        case .invalidImageData:
            return "图片处理失败，请重新选择一张清晰的图片。"
        case .timeout:
            return "请求超时，请稍后重试。"
        case .pollingTimeout:
            return "生成等待时间较长，请稍后重试。"
        case let .message(message):
            return message
        }
    }
}

struct APIClient {
    let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        self.encoder = encoder
    }

    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Data? = nil,
        contentType: String? = "application/json"
    ) async throws -> T {
        var request = URLRequest(url: makeURL(path: path))
        request.httpMethod = method
        request.httpBody = body
        request.timeoutInterval = 30

        if let contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await send(request: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw try decodeAPIError(data: data, statusCode: httpResponse.statusCode)
        }

        return try decoder.decode(T.self, from: data)
    }

    func uploadMultipart<T: Decodable>(
        path: String,
        fileData: Data,
        fileName: String,
        mimeType: String
    ) async throws -> T {
        let boundary = "Boundary-\(UUID().uuidString)"
        let body = try makeMultipartBody(
            boundary: boundary,
            fieldName: "file",
            fileName: fileName,
            mimeType: mimeType,
            fileData: fileData
        )

        return try await request(
            path: path,
            method: "POST",
            body: body,
            contentType: "multipart/form-data; boundary=\(boundary)"
        )
    }

    func encode<T: Encodable>(_ value: T) throws -> Data {
        try encoder.encode(value)
    }

    private func makeURL(path: String) -> URL {
        let normalizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return baseURL.appending(path: normalizedPath)
    }

    private func send(request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            if let urlError = error as? URLError, urlError.code == .timedOut {
                throw APIError.timeout
            }
            throw error
        }
    }

    private func makeMultipartBody(
        boundary: String,
        fieldName: String,
        fileName: String,
        mimeType: String,
        fileData: Data
    ) throws -> Data {
        var body = Data()
        let lineBreak = "\r\n"

        guard let partHeader = """
        --\(boundary)\(lineBreak)\
        Content-Disposition: form-data; name="\(fieldName)"; filename="\(fileName)"\(lineBreak)\
        Content-Type: \(mimeType)\(lineBreak)\(lineBreak)
        """.data(using: .utf8),
        let footer = "\(lineBreak)--\(boundary)--\(lineBreak)".data(using: .utf8) else {
            throw APIError.uploadEncodingFailed
        }

        body.append(partHeader)
        body.append(fileData)
        body.append(footer)
        return body
    }

    private func decodeAPIError(data: Data, statusCode: Int) throws -> APIError {
        if let payload = try? decoder.decode(APIErrorEnvelope.self, from: data) {
            return .invalidStatusCode(statusCode, payload.error.message)
        }
        return .invalidStatusCode(statusCode, "服务端返回了错误。")
    }
}

private struct APIErrorEnvelope: Decodable {
    struct APIErrorBody: Decodable {
        let code: String?
        let message: String
    }

    let error: APIErrorBody
}
