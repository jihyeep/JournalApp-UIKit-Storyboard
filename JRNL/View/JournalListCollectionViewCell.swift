//
//  JournalListTableViewCell.swift
//  JRNL
//
//  Created by 박지혜 on 5/10/24.
//

import UIKit

class JournalListCollectionViewCell: UICollectionViewCell {
    
    // 데이터 연결
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
