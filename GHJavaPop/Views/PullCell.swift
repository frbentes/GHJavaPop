//
//  PullCell.swift
//  GHJavaPop
//
//  Created by Fredyson Costa Marques Bentes on 04/01/17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit

class PullCell: UITableViewCell {

    @IBOutlet var lblPullTitle: UILabel!
    @IBOutlet var lblPullBody: UILabel!
    @IBOutlet var imgAuthor: UIImageView!
    @IBOutlet var lblAuthorName: UILabel!
    @IBOutlet var lblPullDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
