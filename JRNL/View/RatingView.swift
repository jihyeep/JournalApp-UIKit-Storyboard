//
//  RatingView.swift
//  JRNL
//
//  Created by 박지혜 on 5/16/24.
//

import UIKit

class RatingView: UIStackView {
    private var ratingButtons = [UIButton()]
    var rating = 0 {
        // 프로퍼티 옵저버: 상태 업데이트될 때마다 실행
        didSet {
            updateButtonSelectionState()
        }
    }
    
    private let buttonSize = CGSize(width: 44.0, height: 44.0)
    private let buttonCount = 5
    
    // MARK: - Initialization
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: - Private Methods
    private func setupButtons() {
        // 기존 버튼 제거
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview() // 메모리 해제 시점이 맞지 않아 제거되지 않을 수 있으므로 명확하게 제거하기 위해 작성
        }
        ratingButtons.removeAll()
        
        // 별 이미지 설정
        let filledStar = UIImage(systemName: "star.fill")
        let emptyStar = UIImage(systemName: "star")
        let highlightedStar = UIImage(systemName: "star.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        
        // 버튼 생성 및 설정
        for _ in 0..<buttonCount {
            let button = UIButton()
            // 누르기 전
            button.setImage(emptyStar, for: .normal)
            // 누른 후
            button.setImage(filledStar, for: .selected)
            // 누르는 중
            button.setImage(highlightedStar, for: .highlighted)
            // 눌려진 상태에서 누르는 중
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.widthAnchor.constraint(equalToConstant: buttonSize.width).isActive = true // 이전에는 배열에 넣어줌
//            button.heightAnchor.constraint(equalToConstant: buttonSize.height).isActive = true // 활성화해줌
            // 나의 이벤트에 메서드를 등록함
            button.addTarget(self, action: #selector(ratingButtonTapped(button: )), for: .touchUpInside)
            
            addArrangedSubview(button)
            ratingButtons.append(button)
        }
    }
    
    // 별점에 따른 버튼 상태 업데이트
    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
    // 별점 변경 액션
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        let selectedRating = index + 1
        // 변경사항이 있을 때만 저장
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
}
