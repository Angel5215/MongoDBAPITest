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
    static func obtenerJSON(URLBase: String, topico: String, completionHandler: @escaping ([JSON]) -> ()) {
        let url = URL(string: URLBase + topico)!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard let data = data, let response = response, error == nil else {
                return
            }
            
            guard let json = try? JSON(data: data), let jsonArray = json.array else { return }
           
            completionHandler(jsonArray)
            
            
        }
        task.resume()
        
    }
}
