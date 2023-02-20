//
//  ViewController.swift
//  Weather App
//
//  Created by Nuha Alharbi on 20/02/2023.
//

import UIKit
import Kingfisher
import CoreLocation

class WeatherAppViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var hourlyDailyCV: UICollectionView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Vars
    
    var hourlyWeather : [HourlyWeatherModal] = []
    var dailyWeather : [DailyWeatherModal] = []
    var weatherManager = WeatherManger()
    var locationManager = CLLocationManager()
    
    // MARK: - App LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherManager.delegate = self
        enableLocation()
        setUpCollectionViews()
    }
    
    // MARK: - Functions
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, _) -> NSCollectionLayoutSection? in
            let inset: CGFloat = 2.5
            
            if sectionIndex == 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 6), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1 / 2))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
               
                return section
            } else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 2), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1 / 2))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            }
        })
    }
    
    private func setUpCollectionViews() {
        hourlyDailyCV.collectionViewLayout = compositionalLayout()
    }
    
    func enableLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
}

// MARK: - CollectionViewDataSource

extension WeatherAppViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 1 ? dailyWeather.count : hourlyWeather.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourlyCell", for: indexPath) as? HourlyCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.time.text = hourlyWeather[indexPath.row].time
            cell.tempDgree.text =  "\(hourlyWeather[indexPath.row].tempretuare)°C"
            cell.layer.cornerRadius = 12
            
            return cell
            
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dailyCell", for: indexPath) as? DailyCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.dayLabel.text = dailyWeather[indexPath.row].day
            cell.descriptionLabel.text = dailyWeather[indexPath.row].description
            cell.weatherIcon.kf.setImage(with: dailyWeather[indexPath.row].iconURL)
            cell.maxTemp.text =  "\(dailyWeather[indexPath.row].highTemp)°C ↑"
            cell.minTemp.text = "\(dailyWeather[indexPath.row].lowTemp)°C ↓"
            cell.layer.cornerRadius = 12
            
            return cell
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension WeatherAppViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    return
                }
                
                if let city = placemarks?.first?.locality {
                    self.cityNameLabel.text = city
                }
            })
            weatherManager.featchWeatherData(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            enableLocation()
        } else {
            print("Unauthorized access")
        }
    }
}

//MARK: - WeatherMangerDelegate

extension WeatherAppViewController : WeatherMangerDelegate {
    
    func didUpdateWeather(_ manager: WeatherManger, weatherModal: WeatherModal) {
        DispatchQueue.main.async {
            self.currentTempLabel.text = "\(String(format: "%.1f", weatherModal.currentTemp))°"
            self.maxTempLabel.text = "H: \(weatherModal.highTemp)°"
            self.minTempLabel.text = "L: \(weatherModal.lowTemp)°"
            self.descriptionLabel.text = weatherModal.description
            self.hourlyWeather = weatherModal.hourly
            self.dailyWeather = weatherModal.daily
            
            self.hourlyDailyCV.reloadData()
        }
    }
    func didFailError(error: Error) {
        print(error)
    }
}
