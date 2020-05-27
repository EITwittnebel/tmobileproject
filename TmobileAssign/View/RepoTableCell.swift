//
//  repoTableCell.swift
//  TmobileAssign
//
//  Created by Field Employee on 5/26/20.
//  Copyright © 2020 Field Employee. All rights reserved.
//

import Foundation
import UIKit

class RepoTableCell: UITableViewCell {
  
  @IBOutlet weak var repoNameLabel: UILabel!
  @IBOutlet weak var numForksLabel: UILabel!
  @IBOutlet weak var numStarsLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
}
