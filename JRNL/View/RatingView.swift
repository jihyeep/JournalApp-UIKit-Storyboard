//
//  RatingView.swift
//  JRNL
//
//  Created by 박지혜 on 5/16/24.
//

import UIKit

class RatingView: UIStackView {
    private var ratingButtons = [UIButton()]
    var rating = 0
    private let buttonSize = CGSize(width: 44.0, height: 44.0)
    private let buttonCount = 5
    
    // MARK: - Initialization
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Private Methods
    private func setupButtons() {
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        let filledStar = UIImage(systemName: "star.fill")
        let emptyStar = UIImage(systemName: "star")
        let highlightedStar = UIImage(systemName: "star.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        
        for _ in 0..<buttonCount {
            let button = UIButton()
            // 누르기 전
            button.setImage(emptyStar, for: .normal)
            // 누른 후
            button.setImage(filledStar, for: .selected)
            // 누르는 중
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: buttonSize.width).isActive = true // 이전에는 배열에 넣어줌
            button.heightAnchor.constraint(equalToConstant: buttonSize.height).isActive = true
            addArrangedSubview(button)
            ratingButtons.append(button)
        }
    }
}
