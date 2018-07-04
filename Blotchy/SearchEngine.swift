import Foundation

@objc(SearchEngine)
open class SearchEngine: _SearchEngine {
    func url(for searchTerms: String) -> URL? {
        guard let encoded = searchTerms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        let string = template
            .replacingOccurrences(of: "{searchTerms}", with: encoded)
            .replacingOccurrences(of: "{inputEncoding?}", with: "UTF-8")
            .replacingOccurrences(of: "{outputEncoding?}", with: "UTF-8")

        return URL(string: string)
    }
}
