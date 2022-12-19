//
//  SoundsTableViewController.swift
//  rTimer
//
//  Created by Alexander Kormanovsky on 18.12.2022.
//

import UIKit
import AVFoundation


protocol SoundsTableViewControllerDelegate: AnyObject {
    
    func soundsTableViewControllerDidSelectSound(_ viewController: SoundsTableViewController, sound: Sound)
    
}


class SoundsTableViewController: UITableViewController {
    
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func loadSounds() {
        sounds = SoundsManager.sounds
        
        tableView.reloadData()
        
        if let selectedIndex = (sounds.firstIndex { $0.name == soundName }) {
            tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .top)
        }
        
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
        SoundPlayer.play(selectedSound!)
        
        delegate?.soundsTableViewControllerDidSelectSound(self, sound: selectedSound!)
    }
    
}
