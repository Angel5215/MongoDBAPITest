//
//  ConexionMongo.swift
//  MongoAPITest
//
//  Created by Josue Quiñones on 08/06/18.
//  Copyright © 2018 Angel Vázquez. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Conexion {
    static func obtenerJSON(URLBase: String, topico: String) -> [JSON] {
        let url = URL(string: URLBase + topico)!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard let data = data, let response = response, error == nil else {
                return
            }
            
            guard let json = try? JSON(data: data), let jsonArray = json.array else { return }
           
            DispatchQueue.main.async {
                return jsonArray
            }
            /* DispatchQueue.main.async {
                for element in jsonArray {
                    //print(element["geometry"]["coordinates"][0].double)
                    let latitud = element["geometry"]["coordinates"][1].double!
                    let longitud = element["geometry"]["coordinates"][0].double!
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
                    marker.title = element["properties"]["Name"].string!
                    marker.snippet = element["properties"]["description"].string!
                    marker.map = self.mapView
                }
            }*/
            
        }
        task.resume()
        
    }
}
