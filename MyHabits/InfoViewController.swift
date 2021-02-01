//
//  InfoViewController.swift
//  MyHabits
//
//  Created by Egor Badaev on 07.12.2020.
//

import UIKit

class InfoViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {

        $0.font = StyleHelper.Font.title3
        $0.text = "Привычка за 21 день"
        return $0
        
    }(UILabel())
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = StyleHelper.Font.body
        
        descriptionLabel.text = """
        Прохождение этапов, за которые за 21 день вырабатывается привычка, подчиняется следующему алгоритму:
        
        1. Провести 1 день без обращения к старым привычкам, стараться вести себя так, как будто цель, загаданная в перспективу, находится на расстоянии шага.

        2. Выдержать 2 дня в прежнем состоянии самоконтроля.
        
        3. Отметить в дневнике первую неделю изменений и подвести первые итоги — что оказалось тяжело, что — легче, с чем еще предстоит серьезно бороться.

        4. Поздравить себя с прохождением первого серьезного порога в 21 день. За это время отказ от дурных наклонностей уже примет форму осознанного преодоления и человек сможет больше работать в сторону принятия положительных качеств.

        5. Держать планку 40 дней. Практикующий методику уже чувствует себя освободившимся от прошлого негатива и двигается в нужном направлении с хорошей динамикой.

        6. На 90-й день соблюдения техники все лишнее из «прошлой жизни» перестает напоминать о себе, и человек, оглянувшись назад, осознает себя полностью обновившимся.

        Источник: psychbook.ru
        """
        
        return descriptionLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        title = "Информация"
        
        view.setupScrollSubview(scrollView, withContentView: contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        titleLabel.snp.makeConstraints { (titleLabel) in
            titleLabel.top.equalTo(contentView).inset(StyleHelper.Margin.large)
            titleLabel.leading.equalTo(contentView).inset(StyleHelper.Margin.normal)
            titleLabel.trailing.equalTo(contentView).inset(StyleHelper.Margin.normal)
        }
        
        descriptionLabel.snp.makeConstraints { (descriptionLabel) in
            descriptionLabel.top.equalTo(titleLabel.snp.bottom).offset(StyleHelper.Margin.large)
            descriptionLabel.leading.equalTo(titleLabel)
            descriptionLabel.trailing.equalTo(titleLabel)
            descriptionLabel.bottom.equalTo(contentView).inset(StyleHelper.Margin.large)
        }

    }

}
