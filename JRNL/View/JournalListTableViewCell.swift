//
//  JournalListTableViewCell.swift
//  JRNL
//
//  Created by 박지혜 on 5/10/24.
//

import UIKit

class JournalListTableViewCell: UITableViewCell {
    
    // 데이터 연결
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
