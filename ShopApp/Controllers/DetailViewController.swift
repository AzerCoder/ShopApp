//
//  DetailViewController.swift
//  ShopApp
//
//  Created by A'zamjon Abdumuxtorov on 21/03/24.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var artistNameLB: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var typeLB: UILabel!
    @IBOutlet weak var genreLB: UILabel!
    @IBOutlet weak var priceBtn: UIButton!
    @IBOutlet weak var popUpView: UIView!
    
    var searchResult: SearchResult!
    var downloadTask: URLSessionDownloadTask?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        closeView()
       
    }
    
    func initView(){
        popUpView.layer.cornerRadius = 20
        view.backgroundColor = UIColor.clear
        
        let gradientView = GradientView(frame: CGRect.zero)
        gradientView.frame = view.bounds
        view.insertSubview(gradientView, at: 0)
    }
    
    func closeView(){
        let gr = UIGestureRecognizer(target: self, action: #selector(gesture))
        gr.cancelsTouchesInView = false
        gr.delegate = self
        view.addGestureRecognizer(gr)
        
        if searchResult != nil{
            updateUI()
        }
    }
    
    func updateUI(){
        nameLb.text = searchResult.name
        typeLB.text = searchResult.kind
        genreLB.text = searchResult.genre
        
        if searchResult.artistName!.isEmpty{
            artistNameLB.text = "Unknown"
        }else{
            artistNameLB.text = searchResult.artistName
        }
        
        priceBtn.setTitle("$\(searchResult.trackPrice ?? 0.0)", for: .normal)
        
        if let largeUrl = URL(string: searchResult.imageLarge ?? ""){
            downloadTask = productImage.loadImage(url: largeUrl)
           
        }
    }
    
    @objc func gesture(){
        dismiss(animated: true)
    }
    @IBAction func closeBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func priceAction(_ sender: Any) {
        
    }
    
    deinit{
        downloadTask?.cancel()
    }
    
}

extension DetailViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRc:UIGestureRecognizer, shouldReceive touch:UITouch) ->Bool{
        return (touch.view === self.view)
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return BounceAnimation()
    }
    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return SlideOutAnimation()
    }
    
}
