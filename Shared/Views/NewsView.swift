//
//  NewsView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 12.03.2021.
//

import SwiftUI
import WordpressKit
import SDWebImageSwiftUI

extension WordpressPost: Identifiable {
    public typealias ID = Int
}

struct NewsView: View {
    @EnvironmentObject private var state: NewsState
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(state.posts, id: \.id) { post in
                    VStack {
                        WebImage(url: URL(string: post._embedded?.wp_featuredmedia?.first?.source_url ?? ""))
                            .resizable()
                            .indicator(.activity)
                            .transition(.fade(duration: 0.5))
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                        //                            .frame(maxWidth: .infinity, minHeight: 0, maxHeight: 100, alignment: .center)
                        
                        Text(post.title.rendered.decodingHTMLEntities())
                            .padding([.leading, .trailing], 5)
                            .padding(.bottom, 10)
                    }
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(20.0)
                    .onTapGesture {
                        state.detailsPost = post
                    }
                    .sheet(isPresented: $state.isShowDetails, content: {
                        state.detailsView
                    })
                }
                if state.hasMorePosts {
                    Text("Fetching posts...".localized())
                        .onAppear(perform: {
                            state.fetchNextPage()
                        })
                }
            }
            .listStyle(SidebarListStyle())
        }
        .onAppear {
            state.fetchNextPage()
        }
    }
}


class NewsState: ObservableObject {
    @Published var posts: [WordpressPost] = []
    @Published var hasMorePosts = true
    private var page = 0
    private var fetching = false
    
    var detailsPost: WordpressPost? = nil {
        didSet {
            let imageUrl = detailsPost?._embedded?.wp_featuredmedia?.first?.source_url ?? ""
            let title = detailsPost?.title.rendered.decodingHTMLEntities() ?? ""
            var content = NSAttributedString()
            let data = Data((detailsPost?.content.rendered ?? "").utf8)
            DispatchQueue.main.async { [unowned self] in
                if let attributedString = try? NSAttributedString(
                    data: data,
                    options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ],
                    documentAttributes: nil) {
                    content = attributedString
                }
                detailsView = NewsDetailView(imageUrl: imageUrl, title: title, content: content)
                isShowDetails = self.detailsPost != nil
            }
        }
    }
    @Published var isShowDetails = false
    private(set) var detailsView = NewsDetailView(imageUrl: "", title: "", content: NSAttributedString())
    
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
                            hasMorePosts = false
                            print(error)
                        }
                    } else {
                        guard let values = result.value else {
                            return
                        }
                        let dateFormatter = ISO8601DateFormatter()
                        let newPosts = posts + values
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

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView().environmentObject(NewsState())
    }
}
