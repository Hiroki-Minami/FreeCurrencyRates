//
//  CurrenciesTableViewCell.swift
//  FreeCurrencyRates
//
//  Created by Hiroki Minami on 2023-01-13.
//

import UIKit

class CurrenciesTableViewCell: UITableViewCell {
  
  @IBOutlet var shortNameTextLabel: UILabel!
  @IBOutlet var fullNameTextLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
