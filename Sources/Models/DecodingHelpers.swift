import Foundation

extension KeyedDecodingContainer {
    func decodeString(forKeys keys: [Key]) -> String? {
        for key in keys {
            if let value = try? decodeIfPresent(String.self, forKey: key), let value {
                return value
            }
        }
        return nil
    }

    func decodeInt(forKeys keys: [Key]) -> Int? {
        for key in keys {
            if let value = try? decodeIfPresent(Int.self, forKey: key), let value {
                return value
            }
            if let stringValue = try? decodeIfPresent(String.self, forKey: key),
               let stringValue,
               let value = Int(stringValue) {
                return value
            }
        }
        return nil
    }

    func decodeBool(forKeys keys: [Key]) -> Bool? {
        for key in keys {
            if let value = try? decodeIfPresent(Bool.self, forKey: key), let value {
                return value
            }
            if let stringValue = try? decodeIfPresent(String.self, forKey: key), let stringValue {
                switch stringValue.lowercased() {
                case "true", "1":
                    return true
                case "false", "0":
                    return false
                default:
                    break
                }
            }
        }
        return nil
    }

    func decodeStringArray(forKeys keys: [Key]) -> [String]? {
        for key in keys {
            if let value = try? decodeIfPresent([String].self, forKey: key), let value {
                return value
            }
        }
        return nil
    }

    func decodeURL(forKeys keys: [Key]) -> URL? {
        for key in keys {
            if let value = try? decodeIfPresent(URL.self, forKey: key), let value {
                return value
            }
            if let stringValue = try? decodeIfPresent(String.self, forKey: key),
               let stringValue,
               let url = URL(string: stringValue) {
                return url
            }
        }
        return nil
    }

    func decodeDate(forKeys keys: [Key]) -> Date? {
        for key in keys {
            if let value = try? decodeIfPresent(Date.self, forKey: key), let value {
                return value
            }
            if let stringValue = try? decodeIfPresent(String.self, forKey: key),
               let stringValue {
                if let date = ISO8601DateFormatter().date(from: stringValue) {
                    return date
                }
            }
        }
        return nil
    }

    func decodeValue<T: Decodable>(_ type: T.Type, forKeys keys: [Key]) -> T? {
        for key in keys {
            if let value = try? decodeIfPresent(type, forKey: key), let value {
                return value
            }
        }
        return nil
    }
}
