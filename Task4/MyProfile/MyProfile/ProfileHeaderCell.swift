//
//  ProfileHeaderCell.swift
//  MyProfile
//
//  Created by Арайлым Кабыкенова on 09.06.2025.
//


import UIKit

class ProfileHeaderCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
  
    private let personIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
  
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Arailym Kabykenova"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
 
    private let dogImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dog")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 32
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private func createInfoColumn(text: String, systemImageName: String) -> UIStackView {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: systemImageName)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        
        let stackView = UIStackView(arrangedSubviews: [label, imageView])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        return stackView
    }

   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
   
        contentView.addSubview(containerView)
        
        let topStackView = UIStackView(arrangedSubviews: [personIcon, nameLabel, dogImageView])
        topStackView.axis = .horizontal
        topStackView.spacing = 10
        topStackView.alignment = .center
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let ageColumn = createInfoColumn(text: "age: 59", systemImageName: "number.square")
        let countryColumn = createInfoColumn(text: "Switzerland", systemImageName: "mountain.2")
        let followersColumn = createInfoColumn(text: "123 456", systemImageName: "person.3.sequence.fill")
        
        let bottomStackView = UIStackView(arrangedSubviews: [ageColumn, countryColumn, followersColumn])
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually // Равномерно распределяем
        bottomStackView.spacing = 20
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        

        let mainStackView = UIStackView(arrangedSubviews: [topStackView, bottomStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(mainStackView)
        

        NSLayoutConstraint.activate([
            // Контейнер с отступами от краев ячейки
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            
            personIcon.widthAnchor.constraint(equalToConstant: 40),
            personIcon.heightAnchor.constraint(equalToConstant: 40),
            
            
            dogImageView.widthAnchor.constraint(equalToConstant: 60),
            dogImageView.heightAnchor.constraint(equalToConstant: 60),
           
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15)
        ])
    }
}
