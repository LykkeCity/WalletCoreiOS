//
//  MenuTableViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/8/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import KYDrawerController
import WalletCore
import FirebaseAnalytics

class MenuTableViewController: UITableViewController {

    let selectedCellBGColor = UIColor.red
    let notSelectedCellBGColor = UIColor.clear
    static let commingSoonColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.4)
    
    private struct MenuItem {
        
        let title: String
        let image: UIImage?
        let color: UIColor?
        let storyboardName: String?
        let viewControllerIdentifier: String?
        let onSelect: ((_ viewController: UIViewController) -> ())?
        
        init(title: String, image: UIImage? = nil, viewControllerIdentifier: String? = nil, storyboardName: String? = nil,
             color: UIColor? = nil, onSelect: ((_ viewController: UIViewController) -> ())? = nil) {
            
            self.title = title
            self.image = image
            self.storyboardName = storyboardName
            self.viewControllerIdentifier = viewControllerIdentifier
            self.color = color
            self.onSelect = onSelect
        }
    }
    
    private var items : [MenuItem] = [
        MenuItem(title: Localize("menu.newDesign.addMoney"), image: #imageLiteral(resourceName: "ADD MONEY"), storyboardName: "AddMoney"),
        MenuItem(title: Localize("menu.newDesign.buy"), image: #imageLiteral(resourceName: "BUY"), storyboardName: "Buy") {viewController in
            guard let viewController = viewController as? BuyOptimizedViewController else { return }
            viewController.tradeType = .buy
        },
        MenuItem(title: Localize("menu.newDesign.sell"), image: #imageLiteral(resourceName: "SELL"), storyboardName: "Buy") {viewController in
            guard let viewController = viewController as? BuyOptimizedViewController else { return }
            viewController.tradeType = .sell
        },
        MenuItem(title: Localize("menu.newDesign.cashOut"), image: #imageLiteral(resourceName: "CASH OUT"), storyboardName: "CashOut"),
        MenuItem(title: Localize("menu.newDesign.checkPrices"), image: #imageLiteral(resourceName: "CHECK PRICES"),
                 viewControllerIdentifier: "commingSoonVC", storyboardName: "Main", color: MenuTableViewController.commingSoonColor),
        MenuItem(title: Localize("menu.newDesign.internalTransfer"), image: #imageLiteral(resourceName: "INTERNAL TRANSFER"),
                 viewControllerIdentifier: "commingSoonVC", storyboardName: "Main", color: MenuTableViewController.commingSoonColor),
        MenuItem(title: Localize("menu.newDesign.portfolio"), image: #imageLiteral(resourceName: "PORTFOLIO"), viewControllerIdentifier: "Portfolio"),
        MenuItem(title: Localize("menu.newDesign.settings"), image: #imageLiteral(resourceName: "SETTINGS"), storyboardName: "Settings"),
        MenuItem(title: Localize("menu.newDesign.transactions"), image: #imageLiteral(resourceName: "TRANSACTIONS"), storyboardName: "Transactions"),
        MenuItem(title: Localize("menu.newDesign.logout"), image: #imageLiteral(resourceName: "LogoutIcon"), viewControllerIdentifier: nil, color: nil,
                 onSelect: MenuTableViewController.logout)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(MenuTableViewController.longPressGestureRecognized(_:)))
        tableView.addGestureRecognizer(longpress)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTableViewCell
        
        let item = items[indexPath.row]
        if let menuNameLabelColor = item.color {
            cell.menuNameLabel.textColor = menuNameLabelColor
        }
        
        cell.menuNameLabel.text = item.title
        cell.menuImageView.image = item.image

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCell = tableView.cellForRow(at: indexPath as IndexPath) {
            selectedCell.isSelected = false
        }
        
        let item = items[indexPath.row]
        Analytics.logEvent("select_menu_item", parameters: [
                "name" : item.title
            ])
        guard let viewController = instantiateViewController(byMenuItem: item),
            let drawerController = self.drawerController,
            let rootViewController = drawerController.mainViewController as? RootViewController
        else {
            item.onSelect?(self)
            return
        }
        
        item.onSelect?(viewController)
        
        rootViewController.embed(viewController: viewController, animated: true)
        drawerController.setDrawerState(.closed, animated: true)
    }
    
    // MARK: - Private
    
    private var cellSnapshot: UIView?
    private var cellIsAnimating = false
    private var cellNeedToShow = false
    private var initialIndexPath: IndexPath?
    
    @objc private func longPressGestureRecognized(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let locationInView = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        switch gestureRecognizer.state {
        case UIGestureRecognizerState.began:
            guard let indexPath = indexPath,
                let cell = tableView.cellForRow(at: indexPath)
            else {
                return
            }
            initialIndexPath = indexPath
            cellSnapshot  = snapshotOfCell(cell)
            
            var center = cell.center
            cellSnapshot!.center = center
            cellSnapshot!.alpha = 0.0
            tableView.addSubview(cellSnapshot!)
            center.y = locationInView.y
            self.cellIsAnimating = true

            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.cellSnapshot?.center = center
                self.cellSnapshot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.cellSnapshot?.alpha = 0.98
                cell.alpha = 0.0
            }, completion: { (finished) -> Void in
                guard finished else {
                    return
                }
                self.cellIsAnimating = false
                if self.cellNeedToShow {
                    
                    self.cellNeedToShow = false
                    UIView.animate(withDuration: 0.25, animations: { () -> Void in
                        cell.alpha = 1
                    })
                } else {
                    cell.isHidden = true
                }
            })
            
        case UIGestureRecognizerState.changed:
            guard let cellSnapshot = cellSnapshot else {
                return
            }
            var center = cellSnapshot.center
            center.y = locationInView.y
            cellSnapshot.center = center
            
            if ((indexPath != nil) && (indexPath != initialIndexPath)) {
                items.swapAt(initialIndexPath!.row, indexPath!.row)
                tableView.moveRow(at: initialIndexPath!, to: indexPath!)
                initialIndexPath = indexPath
            }
            
        default:
            guard let indexPath = initialIndexPath, let cell = tableView.cellForRow(at: indexPath) else {
                return
            }
            if cellIsAnimating {
                cellNeedToShow = true
            } else {
                cell.isHidden = false
                cell.alpha = 0.0
            }
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.cellSnapshot?.center = cell.center
                self.cellSnapshot?.transform = CGAffineTransform.identity
                self.cellSnapshot?.alpha = 0.0
                cell.alpha = 1.0
                
            }, completion: { (finished) -> Void in
                if finished {
                    self.initialIndexPath = nil
                    self.cellSnapshot?.removeFromSuperview()
                    self.cellSnapshot = nil
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    private func snapshotOfCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }

    
    private func instantiateViewController(byMenuItem menuItem: MenuItem) -> UIViewController? {
        if menuItem.storyboardName == nil, menuItem.viewControllerIdentifier == nil {
            return nil
        }
        let storyboard: UIStoryboard
        if let storyboardName = menuItem.storyboardName {
            storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        }
        else {
            storyboard = self.storyboard!
        }
        if let identifier = menuItem.viewControllerIdentifier {
            return storyboard.instantiateViewController(withIdentifier: identifier)
        }
        else {
            return storyboard.instantiateInitialViewController()
        }
    }
    
    static func logout(_ viewController: UIViewController) {
        
        UserDefaults.standard.isLoggedIn = false
        UserDefaults.standard.synchronize()
        
        if LWKeychainManager.instance().isAuthenticated {
           LWAuthManager.instance().requestLogout()
        }
        
        LWKeychainManager.instance().clear()
        LWPrivateKeyManager.shared().logoutUser()
        LWKYCDocumentsModel.shared().logout()
        LWEthereumTransactionsManager.shared().logout()
        LWMarginalWalletsDataManager.stop()
        
        viewController.presentLoginController()
//        LWPrivateWalletsManager.shared().logout()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
