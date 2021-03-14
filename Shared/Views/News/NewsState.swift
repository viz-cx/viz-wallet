//
//  NewsState.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 14.03.2021.
//

import Foundation
import WordpressKit

final class NewsState: ObservableObject {
    @Published var posts: [WordpressPost] = []
    @Published var hasMorePosts = true
    private var page = 0
    private var fetching = false
    
    var detailsPost: WordpressPost? = nil {
        didSet {
            let imageUrl = detailsPost?._embedded?.wp_featuredmedia?.first?.source_url ?? ""
            let title = detailsPost?.title.rendered.decodingHTMLEntities() ?? ""
            let content = detailsPost?.content.rendered.decodingHTMLEntities() ?? ""
            detailsView = NewsDetailView(imageUrl: imageUrl, title: title, content: content)
            isShowDetails = self.detailsPost != nil
        }
    }
    @Published var isShowDetails = false
    private(set) var detailsView = NewsDetailView(imageUrl: "", title: "", content: "")
    
    func fetchNextPage() {
        if hasMorePosts && !fetching {
            page += 1
            print("fetching \(page) page")
            fetchPosts(page: page)
        }
    }
    
    private func fetchPosts(page: Int) {
        fetching = true
        DispatchQueue.global(qos: .background).async {
            // https://viz.media/wp-json/wp/v2/tags?per_page=100
            var tagCodes: String {
                switch Locales.current {
                case .russian:
                    return "84"
                case .english:
                    return "85"
                case .spanish:
                    return "155"
                }
            }
            Wordpress(route: "https://viz.media/wp-json", namespace: .wp(v: .v2))
                .get(endpoint: .posts)
                .query(key: .page, value: "\(page)")
                .query(key: .per_page, value: "10")
                .query(key: .tags, value: tagCodes)
                .embed()
                .decode(type: [WordpressPost].self) { [unowned self] (result) in
                    if let error = result.error {
                        DispatchQueue.main.async { [unowned self] in
                            self.hasMorePosts = false
                        }
                        if self.page > 0 {
                            self.page -= 1
                        }
                        print(error)
                    } else {
                        guard let values = result.value else {
                            return
                        }
                        let dateFormatter = ISO8601DateFormatter()
                        let newPosts = self.posts + values
                            .filter { value in
                                return !self.posts.contains(where: { $0.id == value.id })
                            }
                            .sorted(by: { (lhs, rhs) -> Bool in
                                let lhsDate = dateFormatter.date(from: lhs.date_gmt) ?? Date()
                                let rhsDate = dateFormatter.date(from: rhs.date_gmt) ?? Date()
                                return lhsDate > rhsDate
                            })
                        DispatchQueue.main.async { [unowned self] in
                            if newPosts.count > 0 {
                                posts = newPosts
                            } else {
                                hasMorePosts = false
                            }
                        }
                    }
                    DispatchQueue.main.async { [unowned self] in
                        fetching = false
                    }
                }
        }
    }
}
