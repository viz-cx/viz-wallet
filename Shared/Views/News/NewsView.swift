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
    
    private let placeholder: Image = {
        let size = CGSize(width: 320, height: 160)
        let uiImage = UIGraphicsImageRenderer(size: size)
            .image { $0.fill(CGRect(origin: .zero, size: size)) }
            .imageWithColor(tintColor: UIColor.gray)
        return Image(uiImage: uiImage)
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(state.posts, id: \.id) { post in
                    LazyVStack {
                        WebImage(url: URL(string: post._embedded?.wp_featuredmedia?.first?.source_url ?? ""))
                            .resizable()
                            .placeholder(placeholder)
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                        
                        Text(post.title.rendered.decodingHTMLEntities())
                            .foregroundColor(.white)
                            .padding([.leading, .trailing], 5)
                            .padding(.bottom, 10)
                    }
                    .background(Color.gray.opacity(0.9))
                    .cornerRadius(20.0)
                    .onTapGesture {
                        state.detailsPost = post
                    }
                    .sheet(isPresented: $state.isShowDetails, content: {
                        state.detailsView
                    })
                }
                if state.hasMorePosts {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .scaleEffect(1.5, anchor: .center)
                        .onAppear(perform: {
                            state.fetchNextPage()
                        })
                }
            }
            .listStyle(SidebarListStyle())
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            state.hasMorePosts = true
        }
    }
}

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView().environmentObject(NewsState())
    }
}
