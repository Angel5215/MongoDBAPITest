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
	
	let BASE_URL = "http://192.168.1.76:8090/"
	var mapView: GMSMapView!
    var topicoActual : String?
	
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
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

