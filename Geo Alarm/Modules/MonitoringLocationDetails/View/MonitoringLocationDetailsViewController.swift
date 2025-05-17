//
//  StopMonitoringLocationViewController.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-22.
//

import UIKit

class MonitoringLocationDetailsViewController: UIViewController {
    
    var presenter:MonitoringLocationDetailsPresenter!
    
    lazy var xmarkButton:UIButton = {
        $0.tintColor = .systemGray3
        $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        $0.addTarget(self, action: #selector(tapXmark), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var cancelAlarmButton:UIButton = {
        $0.setTitle("Cancel Alarm", for: .normal)
        $0.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.1757532656, alpha: 1)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        $0.tintColor = .white
        $0.layer.cornerRadius = 15
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        $0.addTarget(self, action: #selector(stopMonitoringLocation), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var pointLabel:UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "Alarm Location"
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
    }
}

extension MonitoringLocationDetailsViewController:MonitoringLocationDetailsViewProtocol {
    func present(lat: String, lon: String) {
        pointCoordinates.text = "\(lat),\(lon)"
    }
}

private extension MonitoringLocationDetailsViewController{
     func setupLayout(){
        let barButton = UIBarButtonItem(customView: xmarkButton)
        self.navigationItem.rightBarButtonItem = barButton
        view.backgroundColor = .white
        view.addSubview(pointLabel)
        view.addSubview(coordLabel)
        view.addSubview(cancelAlarmButton)
        view.addSubview(pointCoordinates)
        
        NSLayoutConstraint.activate([
            
            pointLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            pointLabel.topAnchor.constraint(equalTo: view.topAnchor,constant: 20),
            
            coordLabel.topAnchor.constraint(equalTo: pointLabel.bottomAnchor,constant: 10),
            coordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            
            cancelAlarmButton.topAnchor.constraint(equalTo: coordLabel.bottomAnchor,constant: 20),
            cancelAlarmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            cancelAlarmButton.heightAnchor.constraint(equalToConstant: 50),
            
            pointCoordinates.bottomAnchor.constraint(equalTo: coordLabel.bottomAnchor),
            pointCoordinates.leadingAnchor.constraint(equalTo: coordLabel.trailingAnchor,constant: 5),
        ])
    }
}

extension MonitoringLocationDetailsViewController {
    @objc
    func tapXmark(){
        self.dismiss(animated: true)
    }
    @objc
    func stopMonitoringLocation(){
        presenter.stopMonitoring()
        NotificationCenter.default.post(name: NSNotification.Name("addLongPress"), object: nil)
        self.dismiss(animated: true)
    }
}
