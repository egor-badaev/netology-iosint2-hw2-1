//
//  HabitCollectionViewCell.swift
//  MyHabits
//
//  Created by Egor Badaev on 09.12.2020.
//

import UIKit

class HabitCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "HabitCollectionViewCell"
    
    var trackCompletion: (() -> Void)?
    
    private var habit: Habit? {
        didSet {
            guard let habit = habit else { return }
            habitColor = habit.color
            isTracked = habit.isAlreadyTakenToday
            
            setupTick()
            
            habitTitleLabel.text = habit.name
            habitTimeLabel.text = habit.dateString

            guard let streakText = streakText() else { return }
            habitRepeatLabel.text = streakText
        }
    }
    
    private var isTracked: Bool = false

    private var habitColor: UIColor? {
        didSet {
            guard let habitColor = habitColor else { return }
            habitTitleLabel.textColor = habitColor
            habitTrackTick.layer.borderColor = habitColor.cgColor

            if isTracked {
                habitTrackTick.backgroundColor = habitColor
            }
        }
    }
    
    // MARK: - Subviews
    
    private let habitTitleLabel: UILabel = {
        let habitTitleLabel = UILabel()
        
        habitTitleLabel.font = StyleHelper.Font.headline
        habitTitleLabel.numberOfLines = 2
        
        return habitTitleLabel
    }()
    
    private let habitTimeLabel: UILabel = {
        let habitTimeLabel = UILabel()
        
        habitTimeLabel.textColor = StyleHelper.Color.gray
        habitTimeLabel.font = StyleHelper.Font.caption
        
        return habitTimeLabel
    }()
    
    private let habitRepeatLabel: UILabel = {
        let habitRepeatLabel = UILabel()
        
        habitRepeatLabel.textColor = StyleHelper.Color.darkGray
        habitRepeatLabel.font = StyleHelper.Font.footnote
        
        return habitRepeatLabel
    }()
    
    private lazy var habitTrackTick: UIView = {
        let habitTrackTick = UIView()
        
        habitTrackTick.clipsToBounds = true
        habitTrackTick.layer.cornerRadius = StyleHelper.Size.habitTrackTickSize / 2
        
        habitTrackTick.isUserInteractionEnabled = true
        
        let tickImageView = UIImageView()
        tickImageView.image = #imageLiteral(resourceName: "tick_icon")
        tickImageView.backgroundColor = .clear
        
        habitTrackTick.addSubview(tickImageView)
        
        tickImageView.snp.makeConstraints { (tickImageView) in
            tickImageView.center.equalTo(habitTrackTick)
            tickImageView.size.equalTo(15)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapTick(_:)))
        habitTrackTick.addGestureRecognizer(tapGestureRecognizer)
        
        return habitTrackTick
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
    
    func configure(with habit: Habit) {
        self.habit = habit
    }
    
    // MARK: - Private methods

    private func streakText() -> String? {
        guard let habit = habit else { return nil }
        return "Подряд: \(habit.trackDates.count)"
    }
    
    private func setupTick() {
        if isTracked {
            habitTrackTick.backgroundColor = habitColor
            habitTrackTick.layer.borderWidth = .zero
        } else {
            habitTrackTick.backgroundColor = .white
            habitTrackTick.layer.borderWidth = StyleHelper.Size.habitTrackTickBorder
        }

    }

    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = StyleHelper.Radius.large
        
        contentView.addSubview(habitTitleLabel)
        contentView.addSubview(habitTimeLabel)
        contentView.addSubview(habitRepeatLabel)
        contentView.addSubview(habitTrackTick)
        
        habitTitleLabel.snp.makeConstraints { (titleLabel) in
            titleLabel.top.equalTo(contentView).inset(StyleHelper.Margin.Habit.normal)
            titleLabel.leading.equalTo(contentView).inset(StyleHelper.Margin.Habit.normal)
        }
        
        habitTimeLabel.snp.makeConstraints { (timeLabel) in
            timeLabel.top.equalTo(habitTitleLabel.snp.bottom).offset(StyleHelper.Spacing.smallest)
            timeLabel.leading.equalTo(habitTitleLabel)
            timeLabel.trailing.equalTo(habitTitleLabel)
        }
        
        habitRepeatLabel.snp.makeConstraints { (repeatLabel) in
            repeatLabel.leading.equalTo(habitTitleLabel)
            repeatLabel.trailing.equalTo(habitTitleLabel)
            repeatLabel.bottom.equalTo(contentView).inset(StyleHelper.Margin.Habit.normal)
        }
        
        habitTrackTick.snp.makeConstraints { (trackTick) in
            trackTick.trailing.equalTo(contentView).inset(StyleHelper.Margin.large)
            trackTick.centerY.equalTo(contentView)
            trackTick.size.equalTo(StyleHelper.Size.habitTrackTickSize)
            trackTick.leading.greaterThanOrEqualTo(habitTitleLabel.snp.trailing).offset(StyleHelper.Margin.Habit.giant)
        }
    }
    
    // MARK: - Actions
    
    @objc private func tapTick(_ sender: Any) {
        
        guard !isTracked else { return }
        
        isTracked = true
        
        habitTrackTick.backgroundColor = habitColor?.withAlphaComponent(0)
        UIView.animate(withDuration: 0.2) {
            self.habitTrackTick.backgroundColor = self.habitColor?.withAlphaComponent(1)
            self.habitTrackTick.layer.borderWidth = .zero
        }

        
        guard let habit = habit else { return }
        HabitsStore.shared.track(habit)

        guard let streakText = streakText() else { return }
        habitRepeatLabel.setText(streakText, animated: true)

        trackCompletion?()
    }
}
