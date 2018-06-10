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
import GameplayKit

class ViewController: UIViewController, GMSMapViewDelegate {
	
	let BASE_URL = "http://192.168.1.76:8090/"
	var mapView: GMSMapView!
    var topicoActual : String!
    var dimension : Int!
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        //print(coordinate)
        
        guard dimension == 0 else {
            return
        }
        
        let latitud = coordinate.latitude
        let longitud = coordinate.longitude
        var postString = "latitud=\(latitud)&longitud=\(longitud)"
        
        //Alerta para realizar buffer
        let alerta = UIAlertController(title: "Encuentra que hay cerca de ti", message: "¿Cuantos metros estas dispuesto a caminar?", preferredStyle: .alert)
        let calcular = UIAlertAction(title: "Dale", style: .default){
            action in
            guard let textField = alerta.textFields?.first, let dato = textField.text, let metros = Double(dato) else {
                self.mapView.clear()
                return
            }
            textField.keyboardType = .decimalPad
            self.mapView.clear()
            //Dibujar circulo
            let circleCenter = coordinate
            let circ = GMSCircle(position: circleCenter, radius: metros)
            
            circ.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.3)
            circ.strokeColor = .red
            circ.strokeWidth = 5
            circ.map = mapView
            
            postString += "&metros=\(metros)"
            
            self.bufferTopico(postString: postString)
        }
        let cancelar = UIAlertAction(title: "Ño", style: .cancel){
            _ in
            return
        }
        
        alerta.addTextField(configurationHandler: nil)
        alerta.addAction(calcular)
        alerta.addAction(cancelar)
        
        present(alerta, animated: true, completion: nil)
        
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        guard dimension == 0 else { return }
        
        let latitud = coordinate.latitude
        let longitud = coordinate.longitude
        var postString = "latitud=\(latitud)&longitud=\(longitud)"
        
        let alerta = UIAlertController(title: "Agregar un punto en \(topicoActual!)", message: "Rellena los datos", preferredStyle: .alert)
        let añadir = UIAlertAction(title: "Añadir", style: .default){
            _ in
            
            guard let textFields = alerta.textFields, textFields.count == 2, let titulo = textFields[0].text, let descripcion = textFields[1].text, titulo.count > 0, descripcion.count > 0 else {
                return
            }
            
            //Enviar datos a Kitten
            postString += "&titulo=\(titulo)&descripcion=\(descripcion)"
            self.agregarPunto(postString: postString)
            
        }
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel){
            _ in
            return
        }
        
        alerta.addTextField {
            textField in
            textField.placeholder = "Titulo"
        }
        alerta.addTextField {
            textField in
            textField.placeholder = "Descripcion"
        }
        alerta.addAction(añadir)
        alerta.addAction(cancelar)
        
        present(alerta, animated: true, completion: nil)
        
    }
   
    private func agregarPunto(postString: String){
        
        let url = URL(string: BASE_URL + "insert/" + topicoActual)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let data = data, let response = response, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let alerta = UIAlertController(title: "Ok!", message: "Tu insercion se realizó", preferredStyle: .alert)
                
                let aceptar = UIAlertAction(title: "Aceptar", style: .default)
            
                alerta.addAction(aceptar)
                self.present(alerta, animated: true)
                self.reload()
            }
            
            
        }
        task.resume()
        
    }
	
	override func loadView() {
		// Create a GMSCameraPosition that tells the map to display the
		// coordinate -33.86,151.20 at zoom level 6.
		//	Getting started
		let camera = GMSCameraPosition.camera(withLatitude: 19.327226, longitude: -99.1815731, zoom: 17.0)
		mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
		mapView.isMyLocationEnabled = true
		view = mapView
        
        mapView.delegate = self
		
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
        
        //Configuracion boton
        navigationItem.title = topicoActual.uppercased()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(ViewController.reload))
        
        cargarMapa()
	}
    
    private func cargarMapa() {
        if dimension != 3 {
            
            Conexion.obtenerJSON(URLBase: BASE_URL, topico: topicoActual){
                jsonArray in
                DispatchQueue.main.async {
                    switch self.dimension {
                    case 0:
                        self.punto(datos: jsonArray, nombreIcono: self.topicoActual)
                        
                    case 1:
                        self.polilinea(datos: jsonArray)
                        
                    case 2:
                        self.poligono(datos: jsonArray)
                        
                    default:
                        
                        break
                    }
                }
            }
        } else {
            mostrarTodos()
        }
    }
    
    @objc
    private func reload() {
        mapView.clear()
        cargarMapa()
    }
    
    private func bufferTopico(postString: String) {
        
        let url = URL(string: BASE_URL + "buffer/" + topicoActual)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let data = data, let response = response, error == nil else {
                return
            }
            
            guard let json = try? JSON(data: data), let jsonArray = json.array else {
                print("no funciono")
                return
            }
            
            print(jsonArray)
            DispatchQueue.main.async {
                self.punto(datos: jsonArray, nombreIcono: self.topicoActual)
            }
            
            
        }
        task.resume()
       
    }
    
    private func mostrarTodos() {
        let topicos = [("estacionamiento",0), ("actividad",0), ("comida",0), ("facultad",0), ("representativo",2), ("ruta",1)]
        
        for topico in topicos {
            Conexion.obtenerJSON(URLBase: BASE_URL, topico: topico.0){
                jsonArray in
                print(":v")
                DispatchQueue.main.async {
                    switch topico.1 {
                    case 0:
                        self.punto(datos: jsonArray, nombreIcono: topico.0)
                        
                    case 1:
                        self.polilinea(datos: jsonArray)
                        
                    case 2:
                        self.poligono(datos: jsonArray)
                        
                    default:
                        print("default")
                        break
                    }
                }
            }
        }
    }
    
    private func punto(datos: [JSON], nombreIcono: String) {
        for element in datos {
            //print(element["geometry"]["coordinates"][0].double)
            let latitud = element["geometry"]["coordinates"][1].double!
            let longitud = element["geometry"]["coordinates"][0].double!
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
            marker.title = element["properties"]["Name"].string!
            marker.snippet = element["properties"]["description"].string ?? "Sin descripcion"
            marker.icon = UIImage(named: nombreIcono)
            marker.map = self.mapView
        }
    }
    
    private func polilinea(datos: [JSON]) {
        
        for element in datos {
            let path = GMSMutablePath()
            for i in element["geometry"]["coordinates"].array! {
                path.add(CLLocationCoordinate2D(latitude: i[1].double!, longitude: i[0].double!))
            }
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 4
            polyline.strokeColor = getRandomColor()
            polyline.geodesic = true
            polyline.map = self.mapView
        }
        
    }
    
    private func getRandomColor(alpha: CGFloat = 1.0) -> UIColor {
        let random = GKRandomSource.sharedRandom()
        let red = CGFloat(random.nextUniform())
        let green = CGFloat(random.nextUniform())
        let blue = CGFloat(random.nextUniform())
        return UIColor(displayP3Red: red, green: green, blue: blue, alpha: alpha)
    }
    
    private func poligono(datos: [JSON]) {
        
        for element in datos {
            let contorno = GMSMutablePath()
            for i in element["geometry"]["coordinates"][0].array! {
                contorno.add(CLLocationCoordinate2D(latitude: i[1].double!, longitude: i[0].double!))
            }
            let poligono = GMSPolygon(path: contorno)
            poligono.strokeWidth = 2
            poligono.strokeColor = getRandomColor()
            poligono.fillColor = getRandomColor(alpha: 0.28)
            poligono.geodesic = true
            poligono.map = self.mapView
        }
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

