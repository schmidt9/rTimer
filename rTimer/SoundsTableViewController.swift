//
//  SoundsTableViewController.swift
//  rTimer
//
//  Created by Alexander Kormanovsky on 18.12.2022.
//

import UIKit
import AVFoundation


protocol SoundsTableViewControllerDelegate: AnyObject {
    
    func soundsTableViewControllerDidSelectSound(_ viewController: SoundsTableViewController, soundName: String)
    
}


class SoundsTableViewController: UITableViewController {
    
    struct Sound {
        var name: String
        var url: URL
    }
    
    private var sounds = [Sound]()
    
    private var selectedSound: Sound?
    
    private var player: AVPlayer!
    
    public var soundName = ""
    
    public weak var delegate: SoundsTableViewControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        
        loadSounds()
    }
    
    func loadSounds() {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil) else {
            return
        }
        
        sounds = urls.map { url in
            Sound(name: url.lastPathComponent, url: url)
        }
        
        tableView.reloadData()
        
        if let selectedIndex = (sounds.firstIndex { $0.name == soundName }) {
            tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .top)
        }
        
    }
    
    func playSound(_ sound: Sound) {
        player = AVPlayer(url: sound.url)
        player.play()
    }

}

extension SoundsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sounds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = sounds[indexPath.row].name

        return cell
    }
    
}

extension SoundsTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSound = sounds[indexPath.row]
        playSound(selectedSound!)
        
        delegate?.soundsTableViewControllerDidSelectSound(self, soundName: selectedSound!.name)
    }
    
}
