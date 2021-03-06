//
//  ProgressCollectionViewCell.swift
//  MyHabits
//
//  Created by Egor Badaev on 09.12.2020.
//

import UIKit

class ProgressCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    
    static let reuseIdentifier = "ProgressCollectionViewCell"
    
    // MARK: - Subviews
    
    private let motivationLabel: UILabel = {
        let motivationLabel = UILabel()
        
        motivationLabel.toAutoLayout()
        
        motivationLabel.font = StyleHelper.Font.footnoteStatus
        motivationLabel.textColor = StyleHelper.Color.darkGray
        
        return motivationLabel
    }()

    private let progressLabel: UILabel = {
        let progressLabel = UILabel()
        
        progressLabel.toAutoLayout()
        
        progressLabel.font = StyleHelper.Font.footnoteStatus
        progressLabel.textColor = StyleHelper.Color.darkGray
        
        return progressLabel
    }()
    
    private let progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        
        progressBar.toAutoLayout()
        progressBar.clipsToBounds = true
        progressBar.layer.cornerRadius = StyleHelper.Radius.small
        progressBar.backgroundColor = StyleHelper.Color.lightGray
        
        return progressBar
    }()

    // MARK: - Life cycle
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    // MARK: - Public methods
    func configure(with progress: Float) {
        
        motivationLabel.text = motivationalText(for: progress)
        progressBar.progress = progress
        progressLabel.text = progressLabelText(for: progress)
    }
    
    func resetProgress(with progress: Float) {
        
        let oldProgress = progressBar.progress

        if oldProgress == 0 || progress == 1 {
            motivationLabel.setText(motivationalText(for: progress), animated: true)
        }
        
        progressLabel.setText(progressLabelText(for: progress), animated: true)
        progressBar.setProgress(progress, animated: true)
    }
    
    // MARK: - Private methods
    
    private func motivationalText(for progress: Float) -> String {
        if progress == 0 {
            return StyleHelper.MotivationalSpeeches.start
        } else if progress < 1 {
            return StyleHelper.MotivationalSpeeches.inProgress
        } else {
            return StyleHelper.MotivationalSpeeches.finished
        }
    }
    
    private func progressLabelText(for progress: Float) -> String {
        return "\(Int(progress * 100))%"
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = StyleHelper.Radius.large
        
        contentView.addSubview(motivationLabel)
        contentView.addSubview(progressLabel)
        contentView.addSubview(progressBar)
        
        let constraints = [
            motivationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: StyleHelper.Margin.Inner.small),
            motivationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: StyleHelper.Margin.Inner.normal),
            progressLabel.topAnchor.constraint(equalTo: motivationLabel.topAnchor),
            progressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -StyleHelper.Margin.Inner.normal),
            progressBar.topAnchor.constraint(equalTo: motivationLabel.bottomAnchor, constant: StyleHelper.Margin.Inner.small),
            progressBar.leadingAnchor.constraint(equalTo: motivationLabel.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: progressLabel.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: StyleHelper.Size.progressBarHeight)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
