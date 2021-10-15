//
//  ContentView.swift
//  AR Project
//
//  Created by Anh Tran on 9/30/21.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity


struct ContentView : View {
    @State private var isPlacementEnable = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?
     
        
    //var models: [String] = ["fender_stratocaster","hab_en","LunarRover_English","toy_biplane"]
    private var models: [Model] = {
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else {
            return []
        }
        
        var availableModels: [Model] = []
        for fname in files where
            fname.hasSuffix("usdz") {
            let modelName = fname.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
                availableModels.append(model)
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
    @Binding var modelConfirmedForPlacement: Model?
    func makeUIView(context: Context) -> ARView {
        
        let arView = CustomARView(frame: .zero)
       
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = self.modelConfirmedForPlacement{
            if let modelEntity = model.modelEntity{
                print("Debug: add model to the scene \(model.modelName)")
            
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                uiView.scene.addAnchor(anchorEntity)
            } else {
                print("Debug: Unable to load ModelEntity")
            }
            
            
        DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        
        }
    }
}

class CustomARView: ARView{
    let focusSquare = FocusEntity()
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        focusSquare.delegate = self
        focusSquare.setAutoUpdate(to: true)
        self.setupARView()
    }
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupARView() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic

        if
            ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }

        self.session.run(config)
    }
}


extension CustomARView: FocusEntityDelegate {
    func toTrackingState() {
        print("tracking")
    }
    func toInitializingState() {
        print("initialinzing")
    }
}

//##################################################

struct ModelPickerView: View {
    @Binding var isPlacementEnable: Bool
    @Binding var seletedModel: Model?
    var models: [Model]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count) {
                    index in
                    Button(action: {
                        print("DEBUG: seleted model with name \(self.models[index].modelName)")
                        self.seletedModel = self.models[index]
                        self.isPlacementEnable = true
                    }) {
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height: 60)
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
    @Binding var seletedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
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
                self.modelConfirmedForPlacement = self.seletedModel;
                self.resetPlacement()
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

