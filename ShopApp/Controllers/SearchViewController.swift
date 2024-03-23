//
//  ViewController.swift
//  ShopApp
//
//  Created by A'zamjon Abdumuxtorov on 14/03/24.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentCont: UISegmentedControl!
    
    var hasSearched = false
    var searchResults = [SearchResult]()
    var isLoading = false
    var dataTask: URLSessionDataTask?
    var indexRow = 0
    var downloadTask: URLSessionDownloadTask?
    var landScapeVc: LandScapeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        // Do any additional setup after loading the view.
        initView()
        
    }
    
    func initView(){
        let nothingCellNib = UINib(nibName: Constants.shared.nothingFoundCell, bundle: nil)
        tableView.register(nothingCellNib, forCellReuseIdentifier: Constants.shared.nothingFoundCell)
        
        let searchCellNib = UINib(nibName: Constants.shared.searchResultCell, bundle: nil)
        tableView.register(searchCellNib, forCellReuseIdentifier: Constants.shared.searchResultCell)
        
        let loadingCellNib = UINib(nibName: Constants.shared.loadingCell, bundle: nil)
        tableView.register(loadingCellNib, forCellReuseIdentifier: Constants.shared.loadingCell)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass{
        case .compact:
            showLandScape(with: coordinator)
        case .regular, .unspecified:
            hideLandScape(with: coordinator)
        default:
            break
        }
    }
    
    func showLandScape(with coordinator: UIViewControllerTransitionCoordinator){
        
        guard  landScapeVc == nil else {
            return
        }
        
        landScapeVc = storyboard?.instantiateViewController(identifier: "LandScapeViewController") as? LandScapeViewController
        guard let controller = landScapeVc else {return}
        
        controller.view.frame = view.bounds
        controller.view.alpha = 0
        controller.searchResults = searchResults
        view.addSubview(controller.view)
        addChild(controller)
        
        coordinator.animate { _ in
            controller.view.alpha = 1
            self.searchBar.resignFirstResponder()
            
            if self.presentedViewController != nil{
                self.dismiss(animated: true)
            }
        } completion: { _ in
            controller.didMove(toParent: self)
        }

    }
    
    func hideLandScape(with coordinator: UIViewControllerTransitionCoordinator){
        guard let controller = landScapeVc else {
            return
        }
        
        controller.willMove(toParent: nil)
        coordinator.animate { _ in
            controller.view.alpha = 0
        } completion: { _ in
            controller.view.removeFromSuperview()
            controller.removeFromParent()
            self.landScapeVc = nil
        }

        
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        performSearch()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let detailVC = segue.destination as! DetailViewController
//            let indexPath = sender as! IndexPath
            let searchResult = searchResults[indexRow]
            detailVC.searchResult = searchResult
        }
    }
    func iTunesURL(searchTxt:String,categoryIdx:Int) -> URL{
        
        let kind: String
        switch categoryIdx{
        case 1: kind = "musicTrack"
        case 2: kind = "software"
        case 3: kind = "ebook"
        default: kind = ""
        }
        let encodedTxt = searchTxt.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let urlString = String("http://itunes.apple.com/search?term=\(encodedTxt!)&limit=200&entity=\(kind)")
        //String(format: "http://itunes.apple.com/search?term=%@", encodedTxt!)
        let url = URL(string: urlString)
        return url!
    }
    
    func parse(data: Data) -> [SearchResult]{
        do{
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results ?? []
        } catch{
            print("Error Json")
            return []
        }
    }

    func performStoreRequest(with url:URL) ->Data?{
        do{
            return try Data(contentsOf: url)
        }catch{
            showNetworkError()
           
        }
        return nil
    }
    
    func showNetworkError(){
        let alert = UIAlertController(title: "Ooops!!!", message: "There was a network error ", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }

}

extension SearchViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if isLoading{
            return 1
        }else if !hasSearched{
            return 0
        }else if searchResults.count == 0{
            return 1
        }else{
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.shared.loadingCell, for: indexPath) as! LoadingCell
            
            return cell
        }else if searchResults.count == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.shared.nothingFoundCell, for: indexPath) as! NothingFoundCell
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.shared.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
           
            cell.titleLabel?.text = searchResult.name
            cell.bodyLabel?.text = searchResult.artistName 
            return cell
        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        indexRow = indexPath.row
        performSegue(withIdentifier: "ShowDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if searchResults.count == 0 || isLoading{
            return nil
        }else{
            return indexPath
        }
    }
    
    
}

extension SearchViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("SearchBar text \(searchBar.text!)")
        performSearch()
    }
    
    func performSearch(){
        if !(searchBar.text?.isEmpty ?? true){
            searchBar.resignFirstResponder()
            
            dataTask?.cancel()
            isLoading = true
            tableView.reloadData()
            hasSearched = true
            
            let url = iTunesURL(searchTxt: searchBar.text!, categoryIdx: segmentCont.selectedSegmentIndex)
            let session = URLSession.shared
            
            dataTask = session.dataTask(with: url,completionHandler: { data, response, error in
                print("\(data!)")
                if let _ = error{
                    return
                }else if let  httpResponse = response as? HTTPURLResponse,httpResponse.statusCode == 200{
                    if let data = data{
                        self.searchResults = self.parse(data: data)
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                            
                        }
                        return
                    }
                }else{
                    print("Error")
                }
                
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                    
                }
                
            })
            dataTask?.resume()
        }
    }
}

