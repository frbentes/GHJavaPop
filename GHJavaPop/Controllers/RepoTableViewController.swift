//
//  RepoTableViewController.swift
//  GHJavaPop
//
//  Created by Fredyson Costa Marques Bentes on 03/01/17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit
import SDWebImage

class RepoTableViewController: UITableViewController {
    
    @IBOutlet var tblRepo: UITableView!
    
    fileprivate var currentPage = 1
    fileprivate var numPages = 34
    fileprivate var repos = [Repo]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = UIColor.white
        setupTable()
    }
    
    fileprivate func setupTable() {
        tblRepo.tableFooterView = UIView()
        tblRepo.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        tblRepo.infiniteScrollIndicatorMargin = 40
        tblRepo.infiniteScrollTriggerOffset = 500
        tblRepo.addInfiniteScroll { [weak self] (tableView) -> Void in
            self?.performFetch {
                tableView.finishInfiniteScroll()
            }
        }
        tblRepo.setShouldShowInfiniteScrollHandler { [weak self] (tblRepo) -> Bool in
            return ((self?.currentPage)! < 20);
        }
        tblRepo.beginInfiniteScroll(true)
    }
    
    fileprivate func performFetch(_ completionHandler: ((Void) -> Void)?) {
        fetchData { (fetchResult) in
            do {
                let (newRepos, pageCount, nextPage) = try fetchResult()
                
                // create new index paths
                let repoCount = self.repos.count
                let (start, end) = (repoCount, newRepos.count + repoCount)
                let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }
                
                // update data source
                self.repos.append(contentsOf: newRepos)
                self.numPages = pageCount
                self.currentPage = nextPage
                
                // update table view
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: indexPaths, with: .automatic)
                self.tableView.endUpdates()
            } catch {
                self.showAlertWithError(error)
            }
            
            completionHandler?()
        }
    }
    
    fileprivate func showAlertWithError(_ error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("tableView.errorAlert.title", comment: ""),
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("tableView.errorAlert.dismiss", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("tableView.errorAlert.retry", comment: ""),
                                      style: .default,
                                      handler: { _ in self.performFetch(nil) }))
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func refresh(_ sender: UIBarButtonItem) {
        tblRepo.beginInfiniteScroll(true)
    }
   
}

// MARK: - Table view data source

extension RepoTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoCell", for: indexPath) as! RepoCell
        
        let repo = repos[indexPath.row]
        cell.lblName.text = repo.name?.description.capitalized
        cell.lblDescription.text = repo.description?.description
        cell.lblNumForks.text = repo.forks?.description
        cell.lblNumStars.text = repo.stars?.description
        
        let authorName = repo.owner["login"] as? String
        let authorUrlPhoto = repo.owner["avatar_url"] as? String
        let url = URL(string: authorUrlPhoto!)
        
        cell.lblAuthorName.text = authorName?.description
        cell.imgPhoto.sd_setImage(with: url, placeholderImage: UIImage(named: "ic_person_48pt.png"))
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePull" {
            let indexPath = tblRepo.indexPathForSelectedRow!
            let destViewController = segue.destination as! PullTableViewController
            destViewController.repoFullName = repos[indexPath.row].fullName ?? ""
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    
}
    
// MARK: - API
    
fileprivate enum ResponseError: Error {
    case load
    case noData
    case deserialization
}
    
extension ResponseError: LocalizedError {
        
    var errorDescription: String? {
        switch self {
        case .load:
            return NSLocalizedString("responseError.load", comment: "")
        case .deserialization:
            return NSLocalizedString("responseError.deserialization", comment: "")
        case .noData:
            return NSLocalizedString("responseError.noData", comment: "")
        }
    }
        
}
    
typealias FetchResult = (Void) throws -> ([Repo], Int, Int)
    
extension RepoTableViewController {
        
    fileprivate func apiURL(_ page: Int) -> URL {
        let stringUrl = "https://api.github.com/search/repositories?q=language:Java&sort=stars&page=\(page)"
        let url = URL(string: stringUrl)
            
        return url!
    }
        
    fileprivate func fetchData(_ handler: @escaping ((FetchResult) -> Void)) {
        let requestURL = apiURL(currentPage)
        
        let task = URLSession.shared.dataTask(with: requestURL, completionHandler: {
            (data, _, error) -> Void in
            DispatchQueue.main.async {
                handler({ (Void) -> ([Repo], Int, Int) in
                    return try self.handleResponse(data, error: error)
                })
                    
                UIApplication.shared.stopNetworkActivity()
            }
        })
            
        UIApplication.shared.startNetworkActivity()
        
        let delay = (repos.count == 0 ? 0 : 5)
            
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            task.resume()
        })
    }
        
    fileprivate func handleResponse(_ data: Data?, error: Error?) throws -> ([Repo], Int, Int) {
        let resultsKey = "items"
        let pageCount = 34
            
        if error != nil { throw ResponseError.load }
            
        guard let data = data else { throw ResponseError.noData }
        let raw = try? JSONSerialization.jsonObject(with: data, options: [])
            
        guard let response = raw as? [String: AnyObject],
            let entries = response[resultsKey] as? [[String: AnyObject]] else { throw ResponseError.deserialization }
            
        let newRepos = entries.flatMap { return Repo($0) }
            
        return (newRepos, pageCount, currentPage + 1)
    }

}
