//
//  ProfileDetailViewController.swift
//  MyProfile
//
//  Created by Арайлым Кабыкенова on 09.06.2025.
//


import UIKit

class ProfileDetailViewController: UIViewController {
    
    let images = ["dog", "older", "me", "pudel", "young"]
    
   
   
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
   
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "your in LIFE2065"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, World! It is my page where I share with my live in Geneva. I love the universe and animals. SO It is my dog Fluff. Here will be story of my youth and daily life. I'm 60 soon, and my friends and I will celebrate on a yacht and there will be a vlog. Stay with me:)"
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        //перенос текста
        label.textAlignment = .center
        return label
    }()
  
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        let boldText = "Status: "
        let regularText = "Planning a trip to Mars"
        let boldAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16, weight: .bold)]
        let regularAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16)]
        let attributedString = NSMutableAttributedString(string: boldText, attributes: boldAttributes)
        attributedString.append(NSAttributedString(string: regularText, attributes: regularAttributes))
        label.attributedText = attributedString
        return label
    }()
    
    private let awardsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Achievements:"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let awardsListLabel: UILabel = {
        let label = UILabel()
        let awards = [
            "Launch of an app with 5 million users",
            "Launch of the \"New Era\" project",
            "Internship at Apple",
            "Collaboration for 50 million",
            "Starred in films",
            "Opened a charity fund for the sick",
            "Visited 20 countries"
        ]
        label.text = awards.map { "• \($0)" }.joined(separator: "\n")
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        return label
    }()
  
    private let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    // Стек для картинок внутри imageScrollView
    private let imageStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0 // Картинки вплотную
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    

    private lazy var homeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Home", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(UIColor(red: 246/255, green: 122/255, blue: 144/255, alpha: 1.0), for: .normal)
        button.addTarget(self, action: #selector(goHome), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupImageGallery()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .purple
    }
    
    private func setupLayout() {
      
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(bioLabel)
        
       
        contentStackView.addArrangedSubview(statusLabel)
        contentStackView.addArrangedSubview(awardsTitleLabel)
        contentStackView.addArrangedSubview(awardsListLabel)
        
  
        contentStackView.addArrangedSubview(imageScrollView)
        contentStackView.addArrangedSubview(homeButton)

        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
      
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            

            bioLabel.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 0.85),
            statusLabel.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 0.85),
            awardsTitleLabel.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 0.85),
            awardsListLabel.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 0.85),
            
         
            imageScrollView.heightAnchor.constraint(equalToConstant: 300),
            imageScrollView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor)
        ])
    }
    
    private func setupImageGallery() {
        imageScrollView.addSubview(imageStackView)
        
        NSLayoutConstraint.activate([
            
            imageStackView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor),
            imageStackView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor)
        ])
        
        for imageName in images {
            let imageView = UIImageView()
            imageView.image = UIImage(named: imageName)
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            
            imageStackView.addArrangedSubview(imageView)
            
    
            imageView.widthAnchor.constraint(equalTo: imageScrollView.widthAnchor, constant: -40).isActive = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
        }
        imageStackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        imageStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    @objc private func goHome() {
        navigationController?.popViewController(animated: true)
    }
}
