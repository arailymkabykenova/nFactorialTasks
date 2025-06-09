//
//  ProfileSummaryViewController.swift
//  MyProfile
//
//  Created by Арайлым Кабыкенова on 09.06.2025.
//


import UIKit


class ProfileSummaryViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.separatorStyle = .none
      
        table.register(ProfileHeaderCell.self, forCellReuseIdentifier: "ProfileHeaderCell")
        table.register(ActionButtonCell.self, forCellReuseIdentifier: "ActionButtonCell")
        
        table.translatesAutoresizingMaskIntoConstraints = false
        // сами указывем расположение
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    private func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.blue.cgColor,
            UIColor.purple.cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func goToMyProfile() {
        let profileDetailVC = ProfileDetailViewController()
        navigationController?.pushViewController(profileDetailVC, animated: true)
    }
}

extension ProfileSummaryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderCell", for: indexPath) as? ProfileHeaderCell else {
                return UITableViewCell()
            }
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionButtonCell", for: indexPath) as? ActionButtonCell else {
                return UITableViewCell()
            }
            cell.actionButton.addTarget(self, action: #selector(goToMyProfile), for: .touchUpInside)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200 
        } else {
            return 100 
        }
    }
}
