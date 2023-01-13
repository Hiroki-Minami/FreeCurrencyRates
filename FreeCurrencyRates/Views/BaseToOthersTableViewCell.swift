//
//  BaseToOthersTableViewCell.swift
//  FreeCurrencyRates
//
//  Created by Hiroki Minami on 2023-01-13.
//

import UIKit

class BaseToOthersTableViewCell: UITableViewCell {
  
  @IBOutlet var currencyTextLabel: UILabel!
  @IBOutlet var rateTextLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
