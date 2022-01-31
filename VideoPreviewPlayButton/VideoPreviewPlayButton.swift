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
            switch currentState {
            case .download:
                removeStroke()
            case .downloading:
                addStroke()
            case .play:
                removeStroke()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
    
    private func addStroke() {
        downloadProgress = 0
        strokeLayer = CAShapeLayer()
        strokeLayer.removeFromSuperlayer()
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: bounds.width / 2 - 5, startAngle: -0.5 * CGFloat.pi,
                                      endAngle: 1.5 * CGFloat.pi, clockwise: true)
        strokeLayer.path = circlePath.cgPath
        strokeLayer.strokeColor = UIColor.label.cgColor
        strokeLayer.lineWidth = 6
        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.lineCap = CAShapeLayerLineCap.round
        strokeLayer.strokeEnd = 0
        layer.addSublayer(strokeLayer)
    }
    
    private func removeStroke() {
        strokeLayer?.strokeEnd = 0
        strokeLayer?.removeFromSuperlayer()
    }
    
    @objc
    private func handleTap(_ gesture: UITapGestureRecognizer) {
        switch currentState {
        case .download:
            currentState = .downloading
            delegate?.didStartDownloading(self)
        case .downloading:
            currentState = .download
            delegate?.didCancelDownloading(self)
        case .play:
            delegate?.didTapPlayButton(self)
            let animation1 = CABasicAnimation(keyPath: "transform.scale")
            animation1.toValue = 1.05
            animation1.autoreverses = true
            animation1.duration = 0.1
            animation1.repeatCount = 1
            animation1.isRemovedOnCompletion = true
            layer.add(animation1, forKey: "transform")
        }
    }
}
