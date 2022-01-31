//
//  VideoPreviewPlayButton.swift
//  VideoPreviewPlayButton
//
//  Created by Usman Turkaev on 31.01.2022.
//

import UIKit

protocol VideoPreviewPlayButtonDelegate: AnyObject {
    
    func didTapPlayButton(_ button: VideoPreviewPlayButton)
    
    func didCancelDownloading(_ button: VideoPreviewPlayButton)
    
    func didStartDownloading(_ button: VideoPreviewPlayButton)
    
}

class VideoPreviewPlayButton: UIView, CAAnimationDelegate {
    
    weak var delegate: VideoPreviewPlayButtonDelegate?
    
    enum ButtonState {
        case download
        case downloading
        case play
        
        func image(_ pointSize: CGFloat) -> UIImage? {
            var imageName: String
            switch self {
            case .download:
                imageName = "arrow.down"
            case .downloading:
                imageName = "stop.fill"
            case .play:
                imageName = "play.fill"
            }
            return UIImage(systemName: imageName,
                           withConfiguration:
                            UIImage.SymbolConfiguration.init(pointSize: pointSize,
                                                             weight: .semibold))
        }
        
        func backgroundColor() -> UIColor {
            switch self {
            case .download:
                return .systemGray6
            case .downloading:
                return .systemGray6
            case .play:
                return .systemBlue
            }
        }
        
        func tintColor() -> UIColor {
            switch self {
            case .download:
                return .label
            case .downloading:
                return .label
            case .play:
                return .white
            }
        }
    }

    private let buttonView = UIView()
    
    private let imageView = UIImageView()
    
    private var strokeLayer: CAShapeLayer!
    
    private var currentAnimation: CABasicAnimation?
    
    var downloadProgress: CGFloat = 0 {
        didSet {
            if currentState == .downloading {
                strokeLayer?.strokeEnd = downloadProgress
                if downloadProgress >= 1 {
                    currentState = .play
                    timer?.invalidate()
                    removeStroke()
                }
            }
        }
    }
    
    var currentState: ButtonState = .download {
        didSet {
            imageView.image = currentState.image(imageView.bounds.width * 0.6)
            imageView.tintColor = currentState.tintColor()
            imageView.backgroundColor = currentState.backgroundColor()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
//        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    private func setup() {
        imageView.removeFromSuperview()
        imageView.frame = bounds
        addSubview(imageView)
        isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .center
        imageView.frame = CGRect(x: 10, y: 10,
                                 width: bounds.width - 20,
                                 height: bounds.height - 20)
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.clipsToBounds = true
        
        let state = currentState
        currentState = state
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(gesture)
    }
    
    func addStroke() {
        downloadProgress = 0
        strokeLayer = CAShapeLayer()
        strokeLayer.removeFromSuperlayer()
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: bounds.width / 2 - 5, startAngle: -0.5 * CGFloat.pi,
                                      endAngle: 1.5 * CGFloat.pi, clockwise: true)
        strokeLayer.path = circlePath.cgPath
        strokeLayer.strokeColor = UIColor.label.cgColor
        strokeLayer.lineWidth = 5
        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.lineCap = CAShapeLayerLineCap.round
        strokeLayer.strokeEnd = 0
        layer.addSublayer(strokeLayer)
    }
    
    func removeStroke() {
        strokeLayer?.strokeEnd = 0
        strokeLayer?.removeFromSuperlayer()
    }
    
    var timer: Timer?
    
    @objc
    private func handleTap(_ gesture: UITapGestureRecognizer) {
        switch currentState {
        case .download:
            addStroke()
            currentState = .downloading
            delegate?.didStartDownloading(self)
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.downloadProgress += 0.1
            }
        case .downloading:
            removeStroke()
            currentState = .download
            delegate?.didCancelDownloading(self)
            strokeLayer.removeAllAnimations()
        case .play:
            removeStroke()
            delegate?.didTapPlayButton(self)
        }
    }
}
