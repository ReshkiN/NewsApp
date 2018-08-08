//
//  ViewController.swift
//  NewsApp
//
//  Created by Dmitry Reshetnik on 8/4/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate, UISearchResultsUpdating {
    
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    var articles: [Article]?
    var refreshControl = UIRefreshControl()
    var currentPage: Int = 1
    var isLoadingList: Bool = false
    
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //RefreshControl
        self.tableView.delegate = self
        self.tableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        //SearchBar
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.largeTitleDisplayMode = .automatic
            searchController.searchResultsUpdater = self
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.sizeToFit()
        } else {
            // Fallback on earlier versions
            searchController.searchResultsUpdater = self
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.sizeToFit()
            self.tableView.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Search for articles"
        //Load data
        Article().fetchArticles(url: "news", completion: { articles in
            self.articles = articles
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Refresh
    
    @objc func refresh(_ sender: Any) {
        self.getListFromServer(1)
        self.refreshControl.endRefreshing()
    }
    
    //Search
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
        perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.75)
    }
    
    @objc func reload(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespaces) != "" else {
            return
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        Article().fetchArticles(url: searchController.searchBar.text!, completion: { articles in
            self.articles = articles
        })
        self.tableView.reloadData()
    }
    
    //Pagination
    
    func getListFromServer(_ pageNumber: Int){
        self.isLoadingList = false
        Article().fetchArticles(url: "news&page=\(pageNumber)", completion: { articles in
            self.articles = articles
        })
        self.tableView.reloadData()
    }
    
    func loadMoreItemsForList(){
        currentPage += 1
        getListFromServer(currentPage)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            self.isLoadingList = true
            self.loadMoreItemsForList()
        }
    }
    
    //Draw table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cellIdentifier = "ArticleTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ArticleTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ArticleTableViewCell.")
        }
        
        if articles?[indexPath.item].articleTitle != nil {
            cell.titleLabel.text = self.articles?[indexPath.item].articleTitle
        } else {
            cell.titleLabel.text = "No title"
        }
        if articles?[indexPath.item].articleDescription != nil {
            cell.descriptionLabel.text = self.articles?[indexPath.item].articleDescription
        } else {
            cell.descriptionLabel.text = "No discription"
        }
        if articles?[indexPath.item].articleAuthor != nil {
            cell.authorLabel.text = self.articles?[indexPath.item].articleAuthor
        } else {
            cell.authorLabel.text = "No author"
        }
        if articles?[indexPath.item].source != nil {
            cell.sourceLabel.text = self.articles?[indexPath.item].source
        } else {
            cell.sourceLabel.text = "No source"
        }
        if articles?[indexPath.item].urlToImage != nil {
            cell.urlToImageView.downloadImage(from: (articles?[indexPath.item].urlToImage!)!)
        } else {
            cell.urlToImageView.image = #imageLiteral(resourceName: "default")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.articles?[indexPath.item].url != nil {
            let webView = SFSafariViewController(url: URL(string: (self.articles?[indexPath.item].url)!)!)
            self.present(webView, animated: true, completion: nil)
            webView.delegate = self
        }
    }
    
    let menu = Menu()
    
    @IBAction func menuButtonSelected(_ sender: UIBarButtonItem) {
        menu.openMenu()
        menu.menuViewController = self
    }
    
}

//Load images

extension UIImageView {
    
    func downloadImage(from url: String){
        
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            
            guard error == nil else {
                print("returning error")
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}

