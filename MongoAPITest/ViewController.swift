//
//  ViewController.swift
//  MongoAPITest
//
//  Created by Angel Vázquez on 6/6/18.
//  Copyright © 2018 Angel Vázquez. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

class ViewController: UIViewController {
	
	let BASE_URL = "http://192.168.0.6:8090/"
	var mapView: GMSMapView!
	
	override func loadView() {
		// Create a GMSCameraPosition that tells the map to display the
		// coordinate -33.86,151.20 at zoom level 6.
		//	Getting started
		let camera = GMSCameraPosition.camera(withLatitude: 19.327226, longitude: -99.1815731, zoom: 20.0)
		mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
		mapView.isMyLocationEnabled = true
		view = mapView
		
		// Creates a marker in the center of the map.
		/*let marker = GMSMarker()
		marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
		marker.title = "Sydney"
		marker.snippet = "Australia"
		marker.map = mapView*/
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		let url = URL(string: BASE_URL)!
		let request = URLRequest(url: url)
		
		let task = URLSession.shared.dataTask(with: request) {
			(data, response, error) in
			
			guard let data = data, let response = response, let view = self.view as? GMSMapView, error == nil else {
				return
			}
			
			let geoJsonParser = GMUGeoJSONParser(data: data)
			geoJsonParser.parse()
			
			print("------------")
			print(geoJsonParser)
			print(geoJsonParser.features.description)
			geoJsonParser.features.first?.style = GMUStyle(styleID: "salon", stroke: UIColor.blue, fill: UIColor.black, width: 2.0, scale: 1.0, heading: 1.0, anchor: .zero, iconUrl: nil, title: "PROTECO 🐦👌", hasFill: true, hasStroke: true)
			print("------------")
			
			DispatchQueue.main.async {
				
				/*for feature in geoJsonParser.features {
					feature.style = GMUStyle(styleID: "salon", stroke: UIColor.blue, fill: UIColor.black, width: 2.0, scale: 1.0, heading: 1.0, anchor: .zero, iconUrl: nil, title: "PROTECO 🐦👌", hasFill: true, hasStroke: true)
					print(feature.geometry)
				}*/
				
				let renderer = GMUGeometryRenderer(map: view, geometries: geoJsonParser.features)
				renderer.render()
			}
			/*let renderer = GMUGeometryRenderer(map: self.mapView, geometries: geoJsonParser.features)
			
			renderer.render()*/
		}
		task.resume()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

