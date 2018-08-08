//
//  Menu.swift
//  NewsApp
//
//  Created by Dmitry Reshetnik on 8/7/18.
//  Copyright © 2018 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class Menu: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    let menuView = UIView()
    let menuTableView = UITableView()
    let sections: Array<String> = ["Category", "Country", "Source"]
    let itemsInSections: Array<Array<String>> = [["Business", "Entertainment", "General", "Health", "Science", "Sports", "Technology"], ["United States", "England", "Germany", "Ukraine", "Russia"], ["ABC News", "Aftenposten", "Al Jazeera English", "BBC News", "BBC Sport", "Bloomberg", "Business Insider", "CNN", "Daily Mail", "Entertainment Weekly", "Financial Times", "Fox News", "Google News", "Hacker News", "IGN", "MTV News", "National Geographic", "Reuters", "TechCrunch", "TechRadar", "USA Today", "Wired"]]
    /*
    let sources = ["ABC News", "Aftenposten", "Al Jazeera English", "BBC News", "BBC Sport", "Bloomberg", "Business Insider", "CNN", "Daily Mail", "Entertainment Weekly", "Financial Times", "Fox News", "Google News", "Hacker News", "IGN", "MTV News", "National Geographic", "Reuters", "TechCrunch", "TechRadar", "USA Today", "Wired"]
    let categories = ["business", "entertainment", "general", "health", "science", "sports", "technology"]
    let countries = ["United States": "us", "England": "en", "Germany": "de", "Ukraine": "ua", "Russia": "ru"]
    */
    var menuViewController: ViewController?
    
    public func openMenu() {
        if let window = UIApplication.shared.keyWindow {
            menuView.frame = window.frame
            menuView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            menuView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.closeMenu)))
            
            let height: CGFloat = 264
            let y = window.frame.height - height
            
            menuTableView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            window.addSubview(menuView)
            window.addSubview(menuTableView)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.menuView.alpha = 1
                self.menuTableView.frame.origin.y = y
            })
        }
    }
    
    @objc public func closeMenu() {
        UIView.animate(withDuration: 0.5, animations: {
            self.menuView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                self.menuTableView.frame.origin.y = window.frame.height
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsInSections[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = self.itemsInSections[indexPath.section][indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if menuViewController != nil {
            let url = self.itemsInSections[indexPath.section][indexPath.row].lowercased()
            //viewController.source = self.itemsInSections[indexPath.section][indexPath.row].lowercased()
            Article().fetchArticles(url: url.replacingOccurrences(of: " ", with: "-") , completion: { articles in
            })
            closeMenu()
        }
    }
    
    
    
    override init() {
        super.init()
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.bounces = false
        
        menuTableView.register(MenuTableViewCell.classForCoder(), forCellReuseIdentifier: "MenuCell")
    }

}
