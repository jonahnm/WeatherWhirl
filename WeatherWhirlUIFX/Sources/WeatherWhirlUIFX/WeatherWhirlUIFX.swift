#if os(iOS)
import SwiftUI
import Vortex
import UIKit
struct RainView : View {
    var SPEED: Double
    var pos: SIMD2<Double>
    var imgHeightPlusWidth: SIMD2<Double>
    var body : some View {
        VortexView(createRain()) {

            Rectangle()
                .fill(.blue)
                .opacity(0.5)
                .frame(width: 1, height: 15)
                .tag("raindrop")
        }
    }
    func createRain() -> VortexSystem {
        let system = VortexSystem(tags: ["raindrop"])
        system.position = pos
        system.speed = SPEED
        system.speedVariation = 0.75
        system.lifespan = 10000
        system.shape = .box(width: imgHeightPlusWidth.y, height: imgHeightPlusWidth.x)
        system.angle = .degrees(180)
        system.angleRange = .degrees(0)
        system.size = 1
        system.sizeVariation = 0.75
        return system
    }
}
@objc public class RainFactory: NSObject {
    @objc public static func create(speed: CDouble, pos: CGPoint,imgHeightWithWidth: CGSize) ->
    UIViewController {
        let CloudView = RainView(SPEED: speed, pos: SIMD2.init(pos.x,pos.y),imgHeightPlusWidth: SIMD2.init(imgHeightWithWidth.height,imgHeightWithWidth.width))
        let hostingController = UIHostingController(rootView: CloudView)
        return hostingController
    }
}
#endif
