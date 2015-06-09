//
//  EventTableViewCell.swift
//  musicale
//
//  Created by Andres Escobar on 4/14/15.
//  Copyright (c) 2015 Andres Escobar. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
  
  @IBOutlet weak var eventImage: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var whenWhereLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}