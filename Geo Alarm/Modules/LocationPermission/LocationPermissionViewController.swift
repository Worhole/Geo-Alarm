//
//  GoToSettingsViewController.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-13.
//

import UIKit

class LocationPermissionViewController: UIViewController {
    
    lazy var locationAccessTitleLabel:UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "set your location access to always for geo alarm"
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 25, weight: .bold)
        return $0
    }(UILabel())
    
    lazy var locationAccessDescriptionLabel:UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "without “Always” access, geo-based alarms may not trigger properly when the app is in the background or closed"
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        return $0
    }(UILabel())
    
    lazy var imageLocationSetting: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(named: "location settings")
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        return $0
    }(UIImageView())
    
    lazy var goToSettingsButton:UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("GO TO SETTINGS", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 17
        $0.backgroundColor = .orange
        $0.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
    
        $0.layer.borderColor = UIColor.orange.cgColor
        $0.layer.borderWidth = 1.5
        $0.setTitleColor(.orange, for: .normal)
        $0.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
        
        return $0
    }(UIButton(type: .system))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVCLayout()
    }
}

extension LocationPermissionViewController {
    func setupVCLayout(){
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        view.addSubview(imageLocationSetting)
        view.addSubview(goToSettingsButton)
        view.addSubview(locationAccessTitleLabel)
        view.addSubview(locationAccessDescriptionLabel)
    
        NSLayoutConstraint.activate([
            locationAccessTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            locationAccessTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            locationAccessTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            
            locationAccessDescriptionLabel.topAnchor.constraint(equalTo: locationAccessTitleLabel.bottomAnchor, constant:10),
            locationAccessDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            locationAccessDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            
            imageLocationSetting.topAnchor.constraint(equalTo: locationAccessDescriptionLabel.bottomAnchor, constant: 30),
            imageLocationSetting.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            imageLocationSetting.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            imageLocationSetting.bottomAnchor.constraint(equalTo: goToSettingsButton.topAnchor, constant: -30),
            
            goToSettingsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            goToSettingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            goToSettingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            goToSettingsButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension LocationPermissionViewController {
    @objc
    func goToSettings(){
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
           
        }
    }
//    func dismissPermissionVC(){
//        self.dismiss(animated: true)
//    }
}
