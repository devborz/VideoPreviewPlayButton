//
//  ViewController.swift
//  VideoPreviewPlayButton
//
//  Created by Usman Turkaev on 31.01.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var videoButton: VideoPreviewPlayButton!
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoButton.delegate = self
//        videoButton.currentState = .play
    }

}

extension ViewController: VideoPreviewPlayButtonDelegate {
    func didStartDownloading(_ button: VideoPreviewPlayButton) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] _ in
            self?.videoButton.downloadProgress += 0.1
        })
    }
    
    func didCancelDownloading(_ button: VideoPreviewPlayButton) {
        timer?.invalidate()
    }
    
    func didTapPlayButton(_ button: VideoPreviewPlayButton) {
        print("Play button tapped")
    }
}
