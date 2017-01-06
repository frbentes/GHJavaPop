//
//  PullTableViewController.swift
//  GHJavaPop
//
//  Created by Fredyson Costa Marques Bentes on 03/01/17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD
import Alamofire
import AlamofireObjectMapper

class PullTableViewController: UITableViewController {

    @IBOutlet var tblPull: UITableView!
    
    var pulls: [Pull] = []
    var repoFullName: String = ""
    var loading: MBProgressHUD = MBProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parts = repoFullName.components(separatedBy: "/")
        self.navigationItem.title = parts[1].capitalized
        self.navigationItem.backBarButtonItem?.title = "Voltar"
        
        tblPull.tableFooterView = UIView()
        loadPulls()
    }

    func loadPulls() {
        let apiURL = "https://api.github.com/repos/" + repoFullName + "/pulls"
        showLoading()
        Alamofire.request(apiURL).responseArray { (response: DataResponse<[Pull]>) in
            self.hideLoading()
            self.pulls = response.result.value!
            if self.pulls.count > 0 {
                self.tblPull.reloadData()
            } else {
                self.showNotFoundAlert()
            }
        }
    }
    
    func showLoading() {
        loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.mode = MBProgressHUDMode.indeterminate
        loading.label.text = "Carregando..."
    }
    
    func hideLoading() {
        loading.hide(animated: true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pulls.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PullCell", for: indexPath) as! PullCell

        let pull = pulls[indexPath.row]
        cell.lblPullTitle.text = pull.title?.description
        cell.lblPullBody.text = pull.body?.description
        cell.lblPullDate.text = "criado em: " + adjustDate(strDate: (pull.creationDate?.description)!)
        cell.lblAuthorName.text = pull.user?.username
        cell.imgAuthor.sd_setImage(with: URL(string: (pull.user?.urlPhoto)!), placeholderImage: UIImage(named: "ic_person_48pt.png"))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: pulls[indexPath.row].url!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url);
            }
        }
    }
    
    func adjustDate(strDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: strDate)
        
        let brFormatter = DateFormatter()
        brFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMyyyy", options: 0, locale: NSLocale(localeIdentifier: "pt-BR") as Locale)
        let brDayString = brFormatter.string(from: date!)
        
        return brDayString
    }
    
    func showNotFoundAlert() {
        let alert = UIAlertController(title: NSLocalizedString("tableView.notFoundAlert.title", comment: ""),
                                      message: NSLocalizedString("tableView.notFoundAlert.message", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("tableView.errorAlert.dismiss", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
