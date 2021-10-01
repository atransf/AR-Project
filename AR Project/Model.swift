//
//  Model.swift
//  AR Project
//
//  Created by Anh Tran on 10/1/21.
//

//import UIKit
//import RealityKit
//import Combine
//
//class Model {
//    var modelName: String
//    var image: UIImage
//    var modelEntity: ModelEntity?
//    
//    private var cancellable: AnyCancellable? = nil
//    
//    init(modelName: String) {
//        self.modelName = modelName
//        
//        self.image = UIImage(named: modelName)!
//        
//        let filename = modelName + ".usdz"
//        self.cancellable = ModelEntity.loadModelAsync(named: filename)
//            .sink(receiveCompletion: { loadCompletion in
//                print ("Unable to load modelEnity for \(self.modelName)")
//            }, receiveValue: { modelEntity in
//                self.modelEntity = modelEntity
//                print("Succesful load modelEntity for \(self.modelName)")
//            })
//    }
//}
