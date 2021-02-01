//
//  UIView+MyHabits.swift
//  MyHabits
//
//  Created by Egor Badaev on 07.12.2020.
//

import UIKit

extension UIView {
    func setupScrollSubview(_ scrollView: UIScrollView, withContentView contentView: UIView) {

        self.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints { (scrollView) in
            scrollView.edges.equalTo(self.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { (contentView) in
            contentView.edges.equalTo(scrollView)
            contentView.width.equalTo(scrollView)
        }

    }
}
