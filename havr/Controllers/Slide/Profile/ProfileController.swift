//
//  ProfileController.swift
//  havr
//
//  Created by Agon Miftari on 4/21/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import UIScrollView_InfiniteScroll
import MBProgressHUD

class ProfileController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //MARK: - VARIABLES
    var user = AccountManager.currentUser{
        didSet{
            headerView?.updateView()
        }
    }
    
    var isFromMessagesVC : Bool = false
    fileprivate var selectedInteres: InterestContent?
    var unfilteredPosts: [Post] = []
    var filteredPosts: [Post] = []
    var dataSource: [Post]{
        get{
            if lastSelectedInterest != nil{
                return filteredPosts
            }else{
                return unfilteredPosts
            }
        }
        set{
            if lastSelectedInterest != nil{
                filteredPosts = newValue
            }else{
                unfilteredPosts = newValue
            }
            delay(delay: 0) {
                self.collectionView.reloadData()
            }
        }
    }
    var openedFromPush: Bool = false
    
    var unfilteredPagination = Pagination()
    var filteredPagination = Pagination()
    var lastSelectedInterest: Int? = nil
    
    var headerView : UserProfileReusableCollectionView? = nil
    let profileWaterfallFlowLayout = CollectionViewWaterfallLayout()
    
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    lazy var noPostInInterest: EmptyProfileView = {
        let v = EmptyProfileView.createForNoPostsInInterest()
        //v.frame = self.view.frame
        v.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: 195)
        return v
    }()
    
    lazy var noInternetConnection: EmptyProfileView = {
        let v = EmptyProfileView.createForNoInternet()
        //v.frame = self.view.frame
        v.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: 195)
        return v
    }()
    
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionInit()
        commonInit()
        setupInitialLayout()
        setupInfiniteScrolling()
        getPosts()
        fetchProfile()
        navigationItem.backBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back_icon_upd"), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        GA.TrackScreen(name: "Profile")
        headerView?.updateView()
        collectionView.reloadData()
        
        
//        navigationController?.navigationBar.barTintColor = .white
//        navigationController?.navigationBar.backgroundColor = .white

//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func pullRefreshReload(sender: UIRefreshControl){
        if let selected = lastSelectedInterest{
            filteredPagination = Pagination()
            getPostsBy(interestId: selected)
            fetchProfile()
        }else{
            unfilteredPagination = Pagination()
            getPosts()
            fetchProfile()
        }
    }
    
    func collectionInit() {
        collectionView.registerFocusImageCollectionCell()
    }
    
    func commonInit() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "HomeProfileReusableView", bundle: nil), forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionHeader, withReuseIdentifier: "HomeProfileReusableView")
        self.collectionView.addSubview(pullRefresh)
        
        if openedFromPush {
            rightBarButton.image = UIImage.init()
            leftBarButton.image = UIImage.init(named: "back icon")
        }
        self.noPostInInterest.hide()
        
        //        if let user = user {
        //            let username = "\(user.username)"
        //            self.navigationItem.setNavBarWithBlack(title: user.fullName, subTitle: username)
        //        }
    }
    
    func fetchProfile() {
        UsersAPI.getMyUser { (user, error) in
            if let user = user{
                AccountManager.currentUser = user
                AccountManager.currentUser?.store()
                self.headerView?.updateView()
            }
        }
    }
    func setupInfiniteScrolling() {
        self.collectionView.addInfiniteScroll {[unowned self] (collection) in
            if let selected = self.lastSelectedInterest{
                self.getPostsBy(interestId: selected)
            }else{
                self.getPosts()
            }
        }
        self.collectionView.infiniteScrollTriggerOffset = 120
        
        self.collectionView.setShouldShowInfiniteScrollHandler {[unowned self] _ in
            if self.lastSelectedInterest != nil{
                return self.filteredPagination.hasNext
            }else{
                return self.unfilteredPagination.hasNext
            }
        }
    }
    
    func setupInitialLayout() {
        profileWaterfallFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        profileWaterfallFlowLayout.minimumColumnSpacing = 1
        profileWaterfallFlowLayout.minimumInteritemSpacing = 1
        
        collectionView.collectionViewLayout = profileWaterfallFlowLayout
    }
    
    func getPosts() {
        if self.unfilteredPosts.count == 0{
            showHud()
        }
        PostsAPI.get(page: unfilteredPagination.nextPage, for: user!.id, in: nil) { (posts, pagination, error) in
            self.pullRefresh.endRefreshing()
            self.collectionView.finishInfiniteScroll()
            self.hideHud()
            if let posts = posts, let pagination = pagination {
                if self.unfilteredPagination.currentPage == 0{
                    self.unfilteredPosts = []
                }
                self.unfilteredPagination = pagination
                
                self.unfilteredPosts += posts
                self.dataSource = self.unfilteredPosts
            }
            
            if let error = error {
                self.noInternetConnection.show(to: self.collectionView)
                self.noInternetConnection.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
                print(error.message)
            }
            else {
                self.noInternetConnection.hide()
            }
        }
    }
    
    func getPostsBy(interestId: Int, collectionView: UICollectionView? = nil){
        PostsAPI.getPostsBy(interest: interestId, page: filteredPagination.nextPage, for: user!.id) { (posts, pagination, error) in
            self.pullRefresh.endRefreshing()
            self.collectionView.finishInfiniteScroll()
            self.hideHud()
            if let posts = posts, let pagination = pagination {
                if self.filteredPagination.currentPage == 0{
                    self.filteredPosts = []
                }
                self.filteredPagination = pagination
                
                self.filteredPosts += posts
                self.dataSource = self.filteredPosts
                
                //someone handle if user has no posts
                //show no posts view
                if self.dataSource.count < 1 {
                    self.noPostInInterest.show(to: self.collectionView)
                    self.noPostInInterest.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
                }else {
                    self.noPostInInterest.hide()
                }
            }
            
            if let error = error {
                self.noInternetConnection.show(to: self.collectionView)
                self.noInternetConnection.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
                print(error.message)
            }
            else {
                self.noInternetConnection.hide()
            }
            collectionView?.isUserInteractionEnabled = true
        }
    }
    
    func cellSize(post: Post) -> CGSize {
        var postHeigt = post.media.height
        let width = (collectionView.frame.width) / 3
        if postHeigt <= 0 {
            postHeigt = 1
        }
        let postRatio = CGFloat(postHeigt) / CGFloat(post.media.width)
        
        if postRatio <= CGFloat(1) {
            return CGSize(width: width, height: width)
        }else {
            return CGSize(width: width + 1, height: width * 1.286)
        }
    }
    
    
    //MARK: - ACTIONS
    @IBAction func leftBarButtonPressed(_ sender: UIBarButtonItem) {
        if openedFromPush{
            self.pop()
        }else{
            let settingsVC = SettingsTableController.create()
            //            let nav = UINavigationController(rootViewController: settingsVC)
            //            self.showModal(nav)
            self.showModal(settingsVC)
        }
    }
}

extension ProfileController {
    
    static func create() -> ProfileController{
        return UIStoryboard.profile.instantiateViewController(withIdentifier: "HomeController") as! ProfileController
    }
    
    func createPost() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (handler) in
            // push to Camera Controller
            //            let kanvasNavigation = KanvasNavigationController()
            //            kanvasNavigation.cameraDelegate = self
            //            self.showModal(kanvasNavigation)
        })
        
        let cameraRollAction = UIAlertAction(title: "Camera Roll", style: .default, handler: { (handler) in
            
            self.openPhotoLibraryButton(self)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(cameraRollAction)
        alert.addAction(cancel)
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor
    }
    
}

extension ProfileController: UICollectionViewDelegate, UICollectionViewDataSource, CollectionViewWaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return 40
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueFocusImageCollectionCell(indexpath: indexPath)
        cell.contentView.backgroundColor = Apperance.E5E5E5Color
        
        if indexPath.item > dataSource.count {
            return cell
        }
        let post = dataSource[indexPath.item]
        cell.productHomeImageView.kf.setImage(with: post.getImageUrl())
        cell.videoImageIcon.isHidden = !post.isVideo()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let post = dataSource[indexPath.item]
        return cellSize(post: post)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedInteres = selectedInteres {
            switch selectedInteres {
            case .save:
                let post = dataSource[indexPath.item]
                let controller = PreviewImageController.create(post: post)
                let navigation = UINavigationController(rootViewController: controller)
                navigation.isNavigationBarHidden = true
                self.showModal(navigation)
            default:
                let detailsVC = PostDetailController.create()
                detailsVC.post = dataSource[indexPath.item]
                detailsVC.isFromBroadcastVC = true
                detailsVC.delegate = self
                self.push(detailsVC)
            }
        } else {
            let detailsVC = PostDetailController.create()
            detailsVC.post = dataSource[indexPath.item]
            detailsVC.isFromBroadcastVC = true
            detailsVC.delegate = self
            self.push(detailsVC)
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        headerView = (collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeProfileReusableView", for: indexPath) as! UserProfileReusableCollectionView)
        headerView?.delegate = self
        headerView?.interestsView.delegate = self
        headerView?.updateView()
        return headerView!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.size.width
        return CGSize(width: width, height: 334)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> Float {
        return 340
    }
}

extension ProfileController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func openPhotoLibraryButton(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
}

extension ProfileController : UserProfileDelegate {
    var userUpdate: User? {
        return self.user
    }
    
    func userProfile(_ sender: UserProfileReusableCollectionView, didFetchProfile: User) {
        
    }
    
    func userProfile(_ sender: UserProfileReusableCollectionView, showConnections: UIView) {
        let connectionsVC = ConnectionsController.create()
        connectionsVC.navTitle = "Connections"
        connectionsVC.user = self.user!
        self.push(connectionsVC)
    }
    
    func userProfile(_ sender: UserProfileReusableCollectionView, didStartLoadUser: Bool) {
        showHud()
    }
    
    func homeProfile(sender: UserProfileReusableCollectionView, selectPostsButton button: UIButton) {
        let postsVC = PostsController.create()
        postsVC.isFromProfileVC = true
        postsVC.user = user
        self.push(postsVC)
    }
    
    func userProfile(_ sender: UserProfileReusableCollectionView, didTapEditButton: UIButton?) {
        let editProfile = EditProfileController.create()
        editProfile.user = AccountManager.currentUser
        let navController = UINavigationController(rootViewController: editProfile)
        navController.navigationBar.backgroundColor = .white
        self.showModal(navController)
    }
    
    func userProfile(_ sender: UserProfileReusableCollectionView, didTapFollowersButton: UIButton?) {
        print("GET /api/accounts/current/connections/outgoing/ - show this mayby and rewrite ConnectionsController for differrent type of information")
    }
    
    func userProfile(_ sender: UserProfileReusableCollectionView, didTapConnections: UIButton) {
        let connectionsVC = ConnectionsController.create()
        connectionsVC.navTitle = "Connections"
        connectionsVC.user = self.user!
        self.push(connectionsVC)
    }
}

extension ProfileController {
    func getSavedPost(collectionView: UICollectionView? = nil) {
        PostsAPI.savedPosts { (posts, pagination, error) in
            self.pullRefresh.endRefreshing()
            self.collectionView.finishInfiniteScroll()
            self.hideHud()
            if let posts = posts, let pagination = pagination {
                if self.filteredPagination.currentPage == 0{
                    self.filteredPosts = []
                }
                self.filteredPagination = pagination
                
                self.filteredPosts += posts
                self.dataSource = self.filteredPosts.sorted(by: { (post, otherPost) -> Bool in
                    return post.id > otherPost.id
                })
                //someone handle if user has no posts
                //show no posts view
                if self.dataSource.count < 1 {
                    self.noPostInInterest.show(to: self.collectionView)
                    self.noPostInInterest.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
                }else {
                    self.noPostInInterest.hide()
                }
            }
            
            if let error = error {
                self.noInternetConnection.show(to: self.collectionView)
                self.noInternetConnection.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
                print(error.message)
            }
            else {
                self.noInternetConnection.hide()
            }
            collectionView?.isUserInteractionEnabled = true
        }
    }
}

extension ProfileController: InterestViewDelegate{
    func didSelect(contentType: InterestContent, interest: UserInterest?, in collectionCiew: UICollectionView, at indexPath: IndexPath) {
        print("DidSelect interes with type: \(contentType) in file:\(#file)")
        switch contentType {
        case .save(id: let id):
            selectedInteres = contentType
            if self.dataSource.count == 0 {
                self.hideHud()
                self.noPostInInterest.show(to: self.collectionView)
                self.noPostInInterest.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
            } else {
                self.noPostInInterest.hide()
            }
            lastSelectedInterest = id
            filteredPagination = Pagination()
            showHud()
            getSavedPost(collectionView: collectionCiew)
        case .addNew:
            let interest = InterestController.create()
            collectionCiew.isUserInteractionEnabled = true
            self.push(interest)
            break
        case .interest(_, _, let isSeen, let id):
            selectedInteres = contentType
            guard let isSeen = isSeen else { return }
            guard isSeen else {
                lastSelectedInterest = nil
                dataSource = unfilteredPosts
                collectionCiew.isUserInteractionEnabled = true
                if self.dataSource.count == 0 {
                    self.hideHud()
                    self.noPostInInterest.show(to: self.collectionView)
                    self.noPostInInterest.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
                }else {
                    self.noPostInInterest.hide()
                }
                return
            }
            showHud()
            lastSelectedInterest = id
            filteredPagination = Pagination()
            getPostsBy(interestId: lastSelectedInterest!, collectionView: collectionCiew)
        case .last24Hour(let isSeen):
            selectedInteres = contentType
            guard let isSeen = isSeen else { return }
            guard !isSeen else { return }
            showHud()
            lastSelectedInterest = nil
            dataSource = [Post]()
            if self.dataSource.count == 0 {
                self.hideHud()
                self.noPostInInterest.show(to: self.collectionView)
                self.noPostInInterest.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
            }else {
                self.noPostInInterest.hide()
            }
            //insert this in function to get mometns
            collectionCiew.isUserInteractionEnabled = true
            self.pullRefresh.endRefreshing()
            self.collectionView.finishInfiniteScroll()
            self.hideHud()
        }
    }
    
    func didSave(sender: InterestView) {
        print("did save \(#file)")
        
    }
    
    
    func didSelect(interest: UserInterest, at index: IndexPath) {
        if interest.isSelected {
            lastSelectedInterest = interest.item!.id
            filteredPagination = Pagination()
            getPostsBy(interestId: lastSelectedInterest!)
        }else{
            lastSelectedInterest = nil
            dataSource = unfilteredPosts
            if self.dataSource.count == 0 {
                self.noPostInInterest.show(to: self.collectionView)
            }else {
                self.noPostInInterest.hide()
            }
        }
    }
    
    func didUpload(media: Media?, error: ErrorMessage?, at index: Int) {
        
    }
}


extension ProfileController: PostDetailsControllerDelegate {
    func didDelete(post: Post) {
        for p in unfilteredPosts {
            if p == post {
                _ = unfilteredPosts.delete(p)
                break
            }
        }
        
        for p in filteredPosts {
            if p == post {
                _ = filteredPosts.delete(p)
                break
            }
        }
        collectionView.reloadData()
    }
}
