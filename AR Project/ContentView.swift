//
//  ContentView.swift
//  AR Project
//
//  Created by Anh Tran on 9/30/21.
//

import SwiftUI
import RealityKit
import ARKit


struct ContentView : View {
    @State private var isPlacementEnable = false
    @State private var selectedModel: String?
    @State private var modelConfirmedForPlacement: String?
     
        
    //var models: [String] = ["fender_stratocaster","hab_en","LunarRover_English","toy_biplane"]
    private var models: [String] = {
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else {
            return []
        }
        
        var availableModels: [String] = []
        for fname in files where
            fname.hasSuffix("usdz") {
            let modelName = fname.replacingOccurrences(of: ".usdz", with: "")
                availableModels.append(modelName)
            }
        
//        for fname in files where
//            fname.hasSuffix("reality") {
//            let modelName = fname.replacingOccurrences(of: ".reality", with: "")
//                availableModels.append(modelName)
//            }
        
        return availableModels
            
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
           
            if isPlacementEnable {
                PlacementButtonView(isPlacementEnable: self.$isPlacementEnable, seletedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            } else {
                ModelPickerView(isPlacementEnable: self.$isPlacementEnable, seletedModel: self.$selectedModel, models: self.models)
            }
        }
    }
}
struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: String?
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if
            ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let modelName = self.modelConfirmedForPlacement{
             print("add model to the scene \(modelName)")
        
        let filename = modelName + ".usdz"
        let modelEntity = try!
            ModelEntity.loadModel(named: filename)
            let anchorEntity = AnchorEntity(plane: .any)
            anchorEntity.addChild(modelEntity)
            uiView.scene.addAnchor(anchorEntity)
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        
        }
    }
}


//##################################################

struct ModelPickerView: View {
    @Binding var isPlacementEnable: Bool
    @Binding var seletedModel: String?
    var models: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count) {
                    index in
                    Button(action: {
                        print("DEBUG: seleted model with name \(self.models[index])")
                        self.seletedModel = self.models[index]
                        self.isPlacementEnable = true
                    }) {
                        Image(uiImage: UIImage(named: self.models[index])!)
                            .resizable()
                            .frame(height: 100)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                        .buttonStyle(PlainButtonStyle())
                    
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}

struct PlacementButtonView: View {
    @Binding var isPlacementEnable: Bool
    @Binding var seletedModel: String?
    @Binding var modelConfirmedForPlacement: String?
    var body: some View {
        
        HStack {
            //Cancel button
            Button(action: {
                print("Debug: Cancel button")
                self.resetPlacement()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            //Confirm button
            Button(action: {
                print("Debug: Confirm button")
                self.resetPlacement()
                self.modelConfirmedForPlacement = self.seletedModel
            }) {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    func resetPlacement() {
        self.isPlacementEnable = false
        self.seletedModel = nil
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

