import SwiftUI
import UIKit
@preconcurrency import AVFoundation
import Vision

// MARK: - HandTrackingManager
// @MainActor @Observable — same pattern as AppState / PuzzleState.
// CaptureDelegate is a separate NSObject subclass to avoid the
// @Observable + NSObject macro conflict in Swift 6.

@Observable @MainActor
final class HandTrackingManager {

    var pinchPoint: CGPoint? = nil
    var isPinching: Bool = false
    var handVisible: Bool = false
    var cameraPermissionDenied: Bool = false

    // @ObservationIgnored + nonisolated(unsafe): exempt from @Observable macro
    // synthesis so CaptureDelegate can read them from the capture queue safely.
    @ObservationIgnored nonisolated(unsafe) let session = AVCaptureSession()
    @ObservationIgnored nonisolated(unsafe) var viewSize: CGSize = .zero

    private var captureDelegate: CaptureDelegate?

    func start() {
        Task { @MainActor in
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            guard granted else {
                self.cameraPermissionDenied = true
                return
            }
            let d = CaptureDelegate(manager: self)
            self.captureDelegate = d
            self.configureSession(delegate: d)
            Task.detached(priority: .userInitiated) { [weak self] in
                self?.nonisolatedStart()
            }
        }
    }

    func stop() {
        Task.detached(priority: .utility) { [weak self] in
            self?.nonisolatedStop()
        }
    }

    nonisolated func nonisolatedStart() { session.startRunning() }
    nonisolated func nonisolatedStop()  { session.stopRunning()  }

    nonisolated func receive(pinchPoint: CGPoint?, isPinching: Bool, handVisible: Bool) {
        Task { @MainActor [self] in
            self.pinchPoint  = pinchPoint
            self.isPinching  = isPinching
            self.handVisible = handVisible
        }
    }

    private func configureSession(delegate: CaptureDelegate) {
        guard !session.isRunning else { return }
        session.beginConfiguration()
        session.sessionPreset = .medium

        let device: AVCaptureDevice? =
            AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            ?? AVCaptureDevice.default(for: .video)

        guard let device,
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(delegate, queue: delegate.captureQueue)

        if session.canAddOutput(output) { session.addOutput(output) }
        session.commitConfiguration()
    }
}

// MARK: - CaptureDelegate

private final class CaptureDelegate: NSObject, @unchecked Sendable {
    weak var manager: HandTrackingManager?
    let captureQueue = DispatchQueue(label: "com.sanjays.handtracking", qos: .userInteractive)
    private let sequenceHandler = VNSequenceRequestHandler()

    init(manager: HandTrackingManager) { self.manager = manager }
}

extension CaptureDelegate: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let manager else { return }

        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1

        do {
            try sequenceHandler.perform([request], on: sampleBuffer, orientation: .up)
        } catch {
            manager.receive(pinchPoint: nil, isPinching: false, handVisible: false)
            return
        }

        guard let observation = request.results?.first else {
            manager.receive(pinchPoint: nil, isPinching: false, handVisible: false)
            return
        }

        guard let indexTip = try? observation.recognizedPoint(.indexTip),
              let thumbTip = try? observation.recognizedPoint(.thumbTip),
              indexTip.confidence > 0.3,
              thumbTip.confidence > 0.3 else {
            manager.receive(pinchPoint: nil, isPinching: false, handVisible: true)
            return
        }

        let size = manager.viewSize
        let iPt = CGPoint(x: (1 - indexTip.location.x) * size.width,
                          y: (1 - indexTip.location.y) * size.height)
        let tPt = CGPoint(x: (1 - thumbTip.location.x) * size.width,
                          y: (1 - thumbTip.location.y) * size.height)
        let mid = CGPoint(x: (iPt.x + tPt.x) / 2, y: (iPt.y + tPt.y) / 2)
        let dist = sqrt(pow(iPt.x - tPt.x, 2) + pow(iPt.y - tPt.y, 2))

        manager.receive(pinchPoint: mid, isPinching: dist < 40, handVisible: true)
    }
}

// MARK: - CameraFeedView

struct CameraFeedView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let v = CameraPreviewUIView()
        v.previewLayer.session = session
        v.previewLayer.videoGravity = .resizeAspectFill
        return v
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {}
}

final class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}
