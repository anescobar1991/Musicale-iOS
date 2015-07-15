import UIKit


class EventTableViewCell: UITableViewCell {
  
  @IBOutlet weak var eventImage: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var whenWhereLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    
    eventImage.layer.cornerRadius = 33.0
    eventImage.clipsToBounds = true
    separatorInset = UIEdgeInsetsZero
    preservesSuperviewLayoutMargins = false
    layoutMargins = UIEdgeInsetsZero
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}