//
//  RepoCell.swift
//  GHJavaPop
//
//  Created by Fredyson Costa Marques Bentes on 04/01/17.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit

class RepoCell: UITableViewCell {

    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var lblNumForks: UILabel!
    @IBOutlet var lblNumStars: UILabel!
    @IBOutlet var imgPhoto: UIImageView!
    @IBOutlet var lblAuthorName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
