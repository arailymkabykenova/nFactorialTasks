//
//  ActionButtonCell.swift
//  MyProfile
//
//  Created by Арайлым Кабыкенова on 09.06.2025.
//


import UIKit

class ActionButtonCell: UITableViewCell {

   
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("My Profile", for: .normal)
        button.setTitleColor(UIColor(red: 161/255, green: 89/255, blue: 216/255, alpha: 1.0), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 9
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        
        
        button.configuration = .plain()
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 60, bottom: 15, trailing: 60)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(actionButton)
        

        NSLayoutConstraint.activate([
            actionButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
