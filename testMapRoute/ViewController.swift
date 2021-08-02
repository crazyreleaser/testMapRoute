//
//  ViewController.swift
//  testMapRoute
//
//  Created by admin on 30.07.2021.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    let mapView : MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let addAdressButton : UIButton = {
        let button = UIButton()
        button.setTitle("addAdress", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let routeButton : UIButton = {
        let button = UIButton()
        button.setTitle("route", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let resetButton : UIButton = {
        let button = UIButton()
        button.setTitle("reset", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    var annotionsArray = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // Do any additional setup after loading the view.
        setConstraits()
        addAdressButton.addTarget(self, action: #selector(addAdressButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    @objc func addAdressButtonTapped(){
        alertAddAdress(title: "Добавить", placeholde: "Введите адресс") { [self] (text) in
            setupPlacemark(adressPlace: text)
        }
    }
    @objc func routeButtonTapped(){
        for index in 0...annotionsArray.count-2 {
            createDirectionRequest(startCoordinate: annotionsArray[index].coordinate, destinationCoordinate: annotionsArray[index+1].coordinate)
        }
        mapView.showAnnotations(annotionsArray, animated: true)
    }
    @objc func resetButtonTapped(){
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotionsArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }
    
    private func setupPlacemark(adressPlace: String){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlace) { [self] (placemark, error) in
            if let error = error {
                print(error)
                alertError(title: "Ошибка", message: "Сервер недоступен. Попробуйте еще раз.")
                return
            }
            guard let placemarks = placemark else {return}
            let placemark = placemarks.first
            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace)"
            guard let placemarklocation = placemark?.location else {return}
            annotation.coordinate = placemarklocation.coordinate
            annotionsArray.append(annotation)
            if annotionsArray.count > 2 {
                routeButton.isHidden = false
                resetButton.isHidden = false
            }
            mapView.showAnnotations(annotionsArray, animated: true)
        }
    }
    
    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D){
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        let diraction = MKDirections(request: request)
        diraction.calculate{(responce, error) in
            if let error = error {
                print(error)
                return
            }
            guard let responce = responce else {
                self.alertError(title: "Ошибка", message: "Маршрут недоступен")
                return
            }
            var minRoute = responce.routes[0]
            for route in responce.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        return renderer
    }
}

extension ViewController {
    func setConstraits() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        mapView.addSubview(addAdressButton)
        NSLayoutConstraint.activate([
            addAdressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAdressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            addAdressButton.heightAnchor.constraint(equalToConstant: 70),
            addAdressButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            routeButton.heightAnchor.constraint(equalToConstant: 70),
            routeButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            resetButton.heightAnchor.constraint(equalToConstant: 70),
            resetButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}
