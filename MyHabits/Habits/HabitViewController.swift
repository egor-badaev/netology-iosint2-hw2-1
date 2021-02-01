//
//  HabitViewController.swift
//  MyHabits
//
//  Created by Egor Badaev on 07.12.2020.
//

import UIKit
import SnapKit

class HabitViewController: UIViewController {
    
    // MARK: - Properties
    
    var completion: (() -> Void)?
    private var habit: Habit?
    private var actionType: StyleHelper.ActionType = .create
    private var habitTitle: String?
    private var habitColor: UIColor = StyleHelper.Defaults.habitColor {
        didSet {
            colorIndicator.backgroundColor = habitColor
            titleTextField.textColor = habitColor
        }
    }
    private var habitTime: Date? {
        didSet {
            
            guard let habitTime = habitTime else { return }
            
            let formatter = DateFormatter()
            
            formatter.dateStyle = .none
            formatter.timeStyle = .short

            timeIndicatorLabel.text = formatter.string(from: habitTime)
        }
    }
    
    // MARK: - Subviews

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel.titleFor(input: "Название")
    private let colorLabel = UILabel.titleFor(input: "Цвет")
    private let timeLabel = UILabel.titleFor(input: "Время")
    private var deleteButtonPrimaryBottomConstraint: Constraint? = nil
    private var deleteButtonSecondaryBottomConstraint: Constraint? = nil

    private lazy var titleTextField: UITextField = {
        let titleTextField = UITextField()
        
        titleTextField.placeholder = "Бегать по утрам, спать 8 часов и т.п."
        titleTextField.textColor = habitColor
        titleTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        titleTextField.addTarget(self, action: #selector(textFieldEditindDidBegin(_:)), for: .editingDidBegin)
        titleTextField.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        
        return titleTextField
    }()
    
    private lazy var colorIndicator: UIView = {
        let colorIndicator = UIView()
        
        colorIndicator.clipsToBounds = true
        colorIndicator.layer.cornerRadius = StyleHelper.Size.habitColorIndicator / 2
        
        colorIndicator.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapColor(_:)))
        colorIndicator.addGestureRecognizer(tapGestureRecognizer)
        
        return colorIndicator
    }()
    
    private let timeIndicatorPrefix: UILabel = {
        let timeIndicatorPrefix = UILabel()
        
        timeIndicatorPrefix.text = "Каждый день в "
        timeIndicatorPrefix.font = StyleHelper.Font.body
        
        return timeIndicatorPrefix
    }()
    
    private let timeIndicatorLabel: UILabel = {
        let timeIndicatorLabel = UILabel()
        
        timeIndicatorLabel.textColor = StyleHelper.Color.accent
        timeIndicatorLabel.font = StyleHelper.Font.body
        
        return timeIndicatorLabel
    }()
    
    private lazy var timePicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        
        timePicker.addTarget(self, action: #selector(pickerSet(sender:)), for: .valueChanged)
        
        setTime(from: timePicker)
        
        return timePicker
    }()
    
    private lazy var colorPickerVc: UIColorPickerViewController = {
        let colorPickerVc = UIColorPickerViewController()
        
        colorPickerVc.delegate = self
        colorPickerVc.supportsAlpha = false
        
        return colorPickerVc
    }()
    
    private lazy var deleteButton: UIButton = {
        let deleteButton = UIButton(type: .system)
        
        deleteButton.setTitle("Удалить привычку", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        
        deleteButton.addTarget(self, action: #selector(deleteHabit(_:)), for: .touchUpInside)
        
        return deleteButton
    }()
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    
    // MARK: - Keyboard life cycle
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            switch actionType {
            case .create:
                scrollView.contentInset.bottom = keyboardSize.height
                scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            case .edit:
                deleteButtonPrimaryBottomConstraint?.deactivate()
                deleteButton.snp.makeConstraints { (deleteButton) in
                    self.deleteButtonSecondaryBottomConstraint = deleteButton.bottom.equalTo(self.view).inset(StyleHelper.Margin.normal / 2).constraint
                }
                deleteButtonSecondaryBottomConstraint?.activate()
                deleteButtonSecondaryBottomConstraint?.update(inset: keyboardSize.height)
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutSubviews()
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        switch actionType {
        case .create:
            scrollView.contentInset.bottom = .zero //insetAdjustment
            scrollView.verticalScrollIndicatorInsets = .zero //UIEdgeInsets(top: 0, left: 0, bottom: insetAdjustment, right: 0)
        case .edit:
            deleteButtonSecondaryBottomConstraint?.deactivate()
            deleteButtonPrimaryBottomConstraint?.activate()
        }
    }
    
    // MARK: - Text Fiels life cycle
    
    @objc private func textFieldEditindDidBegin(_ sender: Any) {
        titleTextField.font = StyleHelper.Font.body
    }
    
    @objc private func textFieldEditingDidEnd(_ sender: Any) {
        if let habitTitle = habitTitle,
           habitTitle.count > 0 {
            titleTextField.font = StyleHelper.Font.headline
        } else {
            titleTextField.font = StyleHelper.Font.body
        }
    }

    // MARK: - Public methods
    
    /**
     Switch vc to edit mode and load habit to edit
     
     - parameters:
        - habit: a `Habit` object to be edited
     
     Do not call this function for habit creation
     */
    
    func configure(with habit: Habit) {
        actionType = .edit
        self.habit = habit
        habitTitle = habit.name
        habitTime = habit.date
        habitColor = habit.color
        
        titleTextField.text = habit.name
        titleTextField.font = StyleHelper.Font.headline
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(close(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveHabit(_:)))
        
        switch actionType {
        case .create:
            title = "Создать"
        case .edit:
            title = "Править"
        }
        
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleTextField)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorIndicator)
        contentView.addSubview(timeLabel)
        contentView.addSubview(timeIndicatorPrefix)
        contentView.addSubview(timeIndicatorLabel)
        contentView.addSubview(timePicker)
        
        scrollView.snp.makeConstraints { (scrollView) in
            scrollView.top.equalTo(view.safeAreaLayoutGuide)
            scrollView.leading.equalTo(view.safeAreaLayoutGuide)
            scrollView.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { (contentView) in
            contentView.edges.equalTo(scrollView)
            contentView.width.equalTo(scrollView)
        }
        
        titleLabel.snp.makeConstraints { (titleLabel) in
            titleLabel.top.equalTo(contentView).inset(StyleHelper.Margin.large)
            titleLabel.leading.equalTo(contentView).inset(StyleHelper.Margin.normal)
            titleLabel.trailing.equalTo(contentView).inset(StyleHelper.Margin.normal)
        }
        
        titleTextField.snp.makeConstraints { (titleTextField) in
            titleTextField.top.equalTo(titleLabel.snp.bottom).offset(StyleHelper.Spacing.small)
            titleTextField.leading.equalTo(titleLabel)
            titleTextField.trailing.equalTo(titleLabel)
        }
        
        colorLabel.snp.makeConstraints { (colorLabel) in
            colorLabel.top.equalTo(titleTextField.snp.bottom).offset(StyleHelper.Spacing.large)
            colorLabel.leading.equalTo(titleLabel)
            colorLabel.trailing.equalTo(titleLabel)
        }
        
        colorIndicator.snp.makeConstraints { (colorIndicator) in
            colorIndicator.top.equalTo(colorLabel.snp.bottom).offset(StyleHelper.Spacing.small)
            colorIndicator.leading.equalTo(titleLabel)
            colorIndicator.size.equalTo(StyleHelper.Size.habitColorIndicator)
        }
        
        timeLabel.snp.makeConstraints { (timeLabel) in
            timeLabel.top.equalTo(colorIndicator.snp.bottom).offset(StyleHelper.Spacing.large)
            timeLabel.leading.equalTo(titleLabel)
            timeLabel.trailing.equalTo(titleLabel)
        }
        
        timeIndicatorPrefix.snp.makeConstraints { (timeIndicatorPrefix) in
            timeIndicatorPrefix.top.equalTo(timeLabel.snp.bottom).offset(StyleHelper.Spacing.small)
            timeIndicatorPrefix.leading.equalTo(titleLabel)
        }
        
        timeIndicatorLabel.snp.makeConstraints { (timeIndicatorLabel) in
            timeIndicatorLabel.top.equalTo(timeIndicatorPrefix)
            timeIndicatorLabel.leading.equalTo(timeIndicatorPrefix.snp.trailing)
            timeIndicatorLabel.trailing.equalTo(titleLabel)
        }
        
        timePicker.snp.makeConstraints { (timePicker) in
            timePicker.top.equalTo(timeIndicatorPrefix.snp.bottom).offset(StyleHelper.Margin.large)
            timePicker.leading.equalTo(contentView)
            timePicker.trailing.equalTo(contentView)
            timePicker.bottom.equalTo(contentView)
        }

        switch actionType {
        
        case .create:
            scrollView.snp.makeConstraints { (scrollView) in
                scrollView.bottom.equalTo(view.safeAreaLayoutGuide)
            }
            
        case .edit:
            view.addSubview(deleteButton)
            deleteButton.snp.makeConstraints { (deleteButton) in
                deleteButton.top.equalTo(scrollView.snp.bottom)
                deleteButton.centerX.equalTo(view)
                self.deleteButtonPrimaryBottomConstraint = deleteButton.bottom.equalTo(view.safeAreaLayoutGuide).inset(StyleHelper.Margin.normal / 2).constraint
            }
        }
        
        colorIndicator.backgroundColor = habitColor
    }
    
    // MARK: - Actions
    
    @objc private func pickerSet(sender: UIDatePicker) {
        self.setTime(from: sender)
    }
    
    private func setTime(from datePicker: UIDatePicker) {
        habitTime = datePicker.date
    }
    
    @objc private func saveHabit(_ sender: Any) {
        
        guard let habitTitle = habitTitle,
              !habitTitle.isEmpty,
              let habitTime = habitTime else {
            
            let alertVC = UIAlertController(title: "Невозможно сохранить привычку!", message: "Для сохранения проивычки все поля должны быть заполнены", preferredStyle: .alert)
            let alertOkAction = UIAlertAction(title: "Понятно", style: .default, handler: nil)
            alertVC.addAction(alertOkAction)
            navigationController?.present(alertVC, animated: true, completion: nil)
            
            return
        }
        let newHabit = Habit(name: habitTitle,
                             date: habitTime,
                             color: habitColor)

        switch actionType {
        case .create:
            let store = HabitsStore.shared
            store.habits.append(newHabit)
        case .edit:
            guard let oldHabit = habit else {
                print("Возникла ошибка при редактировании привычки")
                return
            }
            
            if(oldHabit != newHabit) {
                oldHabit.name = habitTitle
                oldHabit.date = habitTime
                oldHabit.color = habitColor
                HabitsStore.shared.save()
            }
        }
        
        self.close(sender)
    }
    
    @objc private func deleteHabit(_ sender: Any) {
        guard let habit = habit else { return }
        let alertVC = UIAlertController(title: "Удалить привычку", message: "Вы хотите удалить привычку \"\(habit.name)\"?", preferredStyle: .alert)
        let alertDeleteAction = UIAlertAction(title: "Удалить", style: .destructive) { action in
            guard let index = HabitsStore.shared.habits.firstIndex(of: habit) else {
                print("Возникла ошибка при редактировании привычки")
                return
            }
            
            HabitsStore.shared.habits.remove(at: index)
            
            self.close(sender)
        
        }
        let alertCancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertVC.addAction(alertCancelAction)
        alertVC.addAction(alertDeleteAction)
        navigationController?.present(alertVC, animated: true, completion: nil)
    }
    
    @objc private func close(_ sender: Any) {
        self.dismiss(animated: true, completion: completion)
    }
    
    @objc private func tapColor(_ sender: Any) {
        colorPickerVc.selectedColor = habitColor
        navigationController?.present(colorPickerVc, animated: true, completion: nil)
    }
    
    @objc private func textFieldEditingChanged(_ sender: Any) {
        guard let textField = sender as? UITextField else { return }
        habitTitle = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension HabitViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        habitColor = viewController.selectedColor
    }
}
