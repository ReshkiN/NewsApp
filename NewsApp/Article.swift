//
//  Article.swift
//  NewsApp
//
//  Created by Dmitry Reshetnik on 8/4/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class Article: NSObject {
    
    //MARK: Properties
    var articleAuthor: String?
    var articleTitle: String?
    var articleDescription: String?
    var source: String?
    var url: String?
    var urlToImage: String?
    
    //Fetch data from web
    
    public func fetchArticles(url: String, completion: @escaping ([Article]?)->()) {
        let urlRequest = URLRequest(url: URL(string: "https://newsapi.org/v2/everything?q=\(url)&sortBy=publishedAt&apiKey=4cffbd8c3c9143a38b58ed3d477fa716")!)
        let task = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            
            guard error == nil else {
                print("returning error")
                return
            }
            
            var articles: [Article]? = []
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                
                if let articlesJSON = json["articles"] as? [[String : AnyObject]] {
                    for item in articlesJSON {
                        let article = Article()
                        if let title = item["title"] as? String, let description = item["description"] as? String, let author = item["author"] as? String, let source = item["source"] as? [String : AnyObject], let url = item["url"] as? String, let urlToImage = item["urlToImage"] as? String {
                            
                            article.articleTitle = title
                            article.articleDescription = description
                            article.articleAuthor = author
                            article.source = source["name"] as? String
                            article.url = url
                            article.urlToImage = urlToImage
                        }
                        articles?.append(article)
                    }
                }
            } catch let error {
                print(error)
            }
            completion(articles)
        }
        task.resume()
    }
}
