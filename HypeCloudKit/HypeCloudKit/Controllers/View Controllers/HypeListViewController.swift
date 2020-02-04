//
//  HypeListViewController.swift
//  HypeCloudKit
//
//  Created by Devin Singh on 2/4/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import UIKit

class HypeListViewController: UIViewController  {

    @IBOutlet weak var hypeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        loadData()
    }
    
    // MARK: - Private functions
    
    private func setUpViews() {
        hypeTableView.dataSource = self
        hypeTableView.delegate = self
    }
    
    private func updateViews() {
        DispatchQueue.main.async {
            self.hypeTableView.reloadData()
        }
    }
    
    private func loadData() {
        HypeController.shared.fetchAllHypes { (result) in
            switch result {
            case .success(let hypes):
                HypeController.shared.hypes = hypes
                self.updateViews()
            case .failure(let error):
                print(error.errorDescription ?? "Unable to display error.")
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func composeButtonTapped(_ sender: Any) {
        presentAddHypeAlert()
    }
    

}

extension HypeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HypeController.shared.hypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath)
        
        let hype = HypeController.shared.hypes[indexPath.row]
        cell.textLabel?.text = hype.body
        cell.detailTextLabel?.text = hype.timestamp.formatToString()
        
        return cell
    }
}

// MARK: - Alert Controller

extension HypeListViewController {
    func presentAddHypeAlert() {
        let alertController = UIAlertController(title: "Get Hype!", message: "What is Hype may never die", preferredStyle: .alert)
        alertController.addTextField { (textfield) in
            textfield.delegate = self
            textfield.placeholder = "What is hype today?"
        }
        
        let addHypeAction = UIAlertAction(title: "Send", style: .default) { (_) in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
            HypeController.shared.saveHype(with: text) { (result) in
                switch result {
                case .success(let hype):
                    guard let hype = hype else { return }
                    HypeController.shared.hypes.insert(hype, at: 0)
                    self.updateViews()
                case .failure(let error):
                    print(error.errorDescription ?? "Unable to display error")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addHypeAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
}

extension HypeListViewController: UITextFieldDelegate {
    
}
