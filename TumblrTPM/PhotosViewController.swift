//
//  PhotosViewController.swift
//  TumblrTPM
//
//  Created by Pranaya Adhikari on 7/21/18.
//  Copyright © 2018 Pranaya Adhikari. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class PhotosViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var posts: [[String: Any]] = []
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 200
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector (PhotosViewController.didPullToRefresh(_:)), for: .valueChanged)
        
        // Initialize a UIRefreshControl
        tableView.addSubview(refreshControl)
        activityIndicator.startAnimating()
        fetchPosts()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func didPullToRefresh(_ refreshControl:UIRefreshControl){
        fetchPosts()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as? PhotoCell
       
        let post = posts[indexPath.row]
        if let photos = post["photos"] as? [[String:Any]]{
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
            let placeholderImage = UIImage(named: "placeholder")!
            let url = URL(string: urlString)
            let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
                size: (cell?.photoImageView.frame.size)!,
                radius: 20.0
            )
            
            cell?.photoImageView.af_setImage(
                withURL: url!,
                placeholderImage: placeholderImage,
                filter: filter,
                imageTransition: .crossDissolve(0.2)
            )
            // No color when the user selects cell
            //cell.selectionStyle = .none
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.lightGray
            cell?.selectedBackgroundView = backgroundView
        }
        return cell!
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    
    func fetchPosts(){
        // Network request snippet
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                self.showAlert()
                self.refreshControl.endRefreshing()
              self.activityIndicator.stopAnimating()
                self.fetchPosts()
                
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(dataDictionary)
                
                // TODO: Get the posts and store in posts property
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                
                self.posts = responseDictionary["posts"] as! [[String: Any]]
                
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                // Start the activity indicator
                self.activityIndicator.stopAnimating()
                
                // TODO: Reload the table view
            }
        }
        task.resume()
        
    }
    
    func showAlert(){
        let alertController = UIAlertController(title: "Can not Get Movies", message: "The internet connection appears to be offline", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Try Again", style: .default) { (action) in
            // handle response here.
        }
        // add the OK action to the alert controller
        alertController.addAction(OKAction)
        present(alertController, animated: true)
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
