//
//  MRAllMangaTableViewController.swift
//  MangaRock
//
//  Created by Vien Tran on 2/16/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage


class MRAllMangaTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    private let mangaManager: MangaManager? = Bootstrap.sharedInstance?.mangaManager
    private var mangaList: [MangaViewModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mangaManager?.delegate = self
        mangaList = mangaManager?.requestMangas() ?? []
        mangaManager?.syncIfNeeded(completion: nil) // show indicator if needed
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mangaList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MRMangaTableViewCell.self), for: indexPath) as! MRMangaTableViewCell
        let manga = mangaList[indexPath.row]
        configureCell(cell, withManga: manga)
        return cell
    }
    
    func configureCell(_ cell: MRMangaTableViewCell, withManga manga: MangaViewModel) {
        
        cell.nameLabel.text = manga.name
        cell.authorLabel.text = manga.authorName
        
        cell.thumbnailImageView.sd_setImage(with: URL(string: manga.thumbnailImage), completed: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender else { fatalError() }
        if let indexPath = tableView.indexPath(for: cell as! UITableViewCell) {
            let destination = segue.destination as! MRMangaInfoViewController
            destination.manga = mangaList[indexPath.row]
        }
        
    }
    // MARK: - Fetched results controller
}

extension MRAllMangaTableViewController: MangaManagerDelegate {
    func mangaManageDidSyncNewData(manager: MangaManager) {
        mangaList = mangaManager?.requestMangas() ?? []
    }
}
