//
//  AddMonitoringLocationViewController.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-16.
//

import UIKit

class AddMonitoringLocationViewController: UIViewController {
    
    var presenter:AddMonitoringLocationPresenter!
    
    lazy var xmarkButton:UIButton = {
        $0.tintColor = .systemGray3
        $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        $0.addTarget(self, action: #selector(tapXmark), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var addLocationButton:UIButton = {
        $0.setTitle("Add Monitoring Zone", for: .normal)
        $0.backgroundColor = #colorLiteral(red: 0.09206429869, green: 0.4222652912, blue: 0.9932720065, alpha: 1)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        $0.tintColor = .white
        $0.layer.cornerRadius = 15
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(addMonitoringLocation), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var pointLabel:UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "Point on map"
        $0.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        return $0
    }(UILabel())
    
    lazy var coordLabel:UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .systemGray2
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.text = "Coordinates:"
        return $0
    }(UILabel())
    
    lazy var pointCoordinates:UILabel = {
        $0.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(dismissSheet), name: NSNotification.Name("dismissBottomSheet"), object: nil)
    }
}

extension AddMonitoringLocationViewController{
    private func setupLayout(){
        let barButton = UIBarButtonItem(customView: xmarkButton)
        self.navigationItem.rightBarButtonItem = barButton
        view.backgroundColor = .white
        view.addSubview(pointLabel)
        view.addSubview(coordLabel)
        view.addSubview(addLocationButton)
        view.addSubview(pointCoordinates)
        
        NSLayoutConstraint.activate([
            
            pointLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            pointLabel.topAnchor.constraint(equalTo: view.topAnchor,constant: 20),
            
            coordLabel.topAnchor.constraint(equalTo: pointLabel.bottomAnchor,constant: 10),
            coordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            
            addLocationButton.topAnchor.constraint(equalTo: coordLabel.bottomAnchor,constant: 20),
            addLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            addLocationButton.heightAnchor.constraint(equalToConstant: 50),
            
            pointCoordinates.bottomAnchor.constraint(equalTo: coordLabel.bottomAnchor),
            pointCoordinates.leadingAnchor.constraint(equalTo: coordLabel.trailingAnchor,constant: 5),
        ])
    }
}

extension AddMonitoringLocationViewController:AddMonitoringLocationViewProtocol {
    func present(lat: String, lon: String) {
        pointCoordinates.text = "\(lat),\(lon)"
    }
    func dismissView() {
        self.dismiss(animated: true)
    }
}

extension AddMonitoringLocationViewController{
    @objc
    func tapXmark(){
        presenter.removeMonitoring()
    }
    @objc
    func dismissSheet(){
        self.dismiss(animated: true)
    }
    @objc
    func addMonitoringLocation(){
        presenter.addMonitoring()
    }
}
