//
//  UserProfileController.swift
//  havr
//
//  Created by Agon Miftari on 4/21/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import UIScrollView_InfiniteScroll
import MBProgressHUD

class UserProfileController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    //MARK: - VARIABLES
    var unfilteredPosts: [Post] = []
    var filteredPosts: [Post] = []
    var dataSource: [Post] = []{
        didSet{
            collectionView.reloadData()
        }
    }
    
    var isFromBroadcastVC : Bool = false
    var isFromMessagesVC : Bool = false
    var didFetchProfile = false
    
    var unfilteredPagination = Pagination()
    var filteredPagination = Pagination()
    var user: User!
    var lastSelectedInterest: Int? = nil
    fileprivate var selectedInterest: InterestContent? = nil
    
    let darkBlueColor = UIColor(red255: 71, green255: 103, blue255: 141)
    let textConnectedColor = UIColor(red255: 70, green255: 70, blue255: 70)
    let profileWaterfallFlowLayout = CollectionViewWaterfallLayout()
    var headerView : UserProfileReusableCollectionView!
    
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
    lazy var privateProfile: EmptyProfileView = {
        let v = EmptyProfileView.createForPrivateProfile()
        //v.frame = self.view.frame
        v.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: 195)
        return v
    }()
    
    lazy var noInterentConnection: EmptyProfileView = {
        let v = EmptyProfileView.createForNoInternet()
        //v.frame = self.view.frame
        v.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: 195)
        return v
    }()
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        getProfile()
        collectionInit()
        setupInitialLayout()
        setupInfiniteScrolling()
        noPostInInterest.hide()
        privateProfile.hide()
        noInterentConnection.hide()
        //        updateViewForPrivateProfileChecked()
        
        //        navigationController?.navigationBar.barStyle = . default
        //        navigationController?.navigationBar.barTintColor = .white
        //        navigationController?.navigationBar.backgroundColor = UIColor(red255: 251, green255: 250, blue255: 250)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Other's Profile")
        
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    func collectionInit() {
        collectionView.registerFocusImageCollectionCell()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "HomeProfileReusableView", bundle: nil), forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionHeader, withReuseIdentifier: "HomeProfileReusableView")
        self.collectionView.addSubview(pullRefresh)
        self.collectionView.reloadData()
    }
    func setupInitialLayout() {
        profileWaterfallFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        profileWaterfallFlowLayout.minimumColumnSpacing = 1
        profileWaterfallFlowLayout.minimumInteritemSpacing = 1
        
        collectionView.collectionViewLayout = profileWaterfallFlowLayout
    }
    
    func updateViewForPrivateProfileChecked(){
        if user.isPublic {
            getPosts()
            self.privateProfile.hide()
        } else {
            delay(delay: 0.1, closure: {
                self.privateProfile.show(to: self.collectionView)
                self.privateProfile.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
                print("Posts private")
                self.hideHud()
            })
        }
    }
    
    func getPosts() {
        if self.unfilteredPosts.count == 0{
            showHud()
        }
        guard let user =  user else {
            hideHud()
            return
        }
        PostsAPI.get(page: unfilteredPagination.nextPage, for: user.id, in: nil) { (posts, pagination, error) in
            delay(delay: 0, closure: {
                self.pullRefresh.endRefreshing()
                self.collectionView.finishInfiniteScroll()
                self.hideHud()
            })
            if let posts = posts, let pagination = pagination {
                if self.unfilteredPagination.currentPage == 0{
                    self.unfilteredPosts = []
                }
                self.unfilteredPagination = pagination
                
                self.unfilteredPosts += posts
                self.dataSource = self.unfilteredPosts
                
                //someone handle if user has no posts
                //show no posts view
            }
            if let error = error {
                print(error.message)
            }
        }
    }
    
    func getPostsBy(interestId: Int, collectionView: UICollectionView? = nil){
        if !user.isPublic {
            return
        }
        if self.filteredPosts.count == 0{
            showHud()
        }
        PostsAPI.getPostsBy(interest: interestId, page: filteredPagination.nextPage, for: user!.id) { (posts, pagination, error) in
            
            delay(delay: 0, closure: { 
                self.pullRefresh.endRefreshing()
                self.collectionView.finishInfiniteScroll()
                collectionView?.isUserInteractionEnabled = true
                self.hideHud()
            })
            
            if let posts = posts, let pagination = pagination {
                if self.filteredPagination.currentPage == 0{
                    self.filteredPosts = []
                }
                self.filteredPagination = pagination
                
                self.filteredPosts += posts
                self.dataSource = self.filteredPosts
                
                if self.dataSource.count < 1 {
                    delay(delay: 0.1, closure: {
                        collectionView?.isUserInteractionEnabled = true
                        self.noPostInInterest.show(to: self.collectionView)
                        self.noPostInInterest.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
                    })
                }else {
                    self.noPostInInterest.hide()
                }
            }
            if let error = error {
                print(error.message)
            }
            collectionView?.isUserInteractionEnabled = true
        }
    }
    
    func getProfile() {
        if let user = self.user, let _ = headerView{
            headerView.publicUser = user
            if !didFetchProfile{
                headerView.fetchProfile()
                didFetchProfile = true
            }
        }
    }
    func pullRefreshReload(sender: UIRefreshControl){
        didFetchProfile = false
        if user.isPublic {
            fetchPosts()
        } else {
            print("Posts private")
        }
        headerView.fetchProfile()
    }
    
    func fetchPosts(){
        if let selected = lastSelectedInterest{
            filteredPagination = Pagination()
            getPostsBy(interestId: selected)
        }else{
            unfilteredPagination = Pagination()
            getPosts()
        }
    }
    func cellSize(post: Post) -> CGSize {
        
        let width = (collectionView.frame.width ) / 3
        let postRatio = CGFloat(post.media.height) / CGFloat(post.media.width)
        
        if postRatio <= CGFloat(1) {
            return CGSize(width: width, height: width)
        }else {
            return CGSize(width: width + 1, height: width * 1.286)
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
    
    //MARK: - ACTIONS
    @IBAction func leftBarButtonPressed(_ sender: UIBarButtonItem) {
        self.pop()
    }
}

extension UserProfileController {
    static func create(for user: User) -> UserProfileController{
        let u =  UIStoryboard.profile.instantiateViewController(withIdentifier: "UserProfileController") as! UserProfileController
        u.user = user
        return u
    }
}

extension UserProfileController: UICollectionViewDelegate, UICollectionViewDataSource, CollectionViewWaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueFocusImageCollectionCell(indexpath: indexPath)
        let post = dataSource[indexPath.item]
        cell.productHomeImageView.kf.setImage(with: post.getImageUrl())
        cell.contentView.backgroundColor = Apperance.E5E5E5Color
        cell.videoImageIcon.isHidden = !post.isVideo()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let post = dataSource[indexPath.item]
        return cellSize(post: post)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedInteres = selectedInterest {
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
//                detailsVC.delegate = self
                self.push(detailsVC)
            }
        } else {
            let detailsVC = PostDetailController.create()
            detailsVC.post = dataSource[indexPath.item]
            detailsVC.isFromBroadcastVC = isFromBroadcastVC
            detailsVC.isFromMessageVC = isFromMessagesVC
            self.push(detailsVC)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeProfileReusableView", for: indexPath) as! UserProfileReusableCollectionView
        headerView.publicUser = user
        if !didFetchProfile{
            headerView.fetchProfile()
            didFetchProfile = true
        }
        headerView.updateView()
        headerView.delegate = self
        headerView.interestsView.delegate = self
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.size.width
        return CGSize(width: width, height: 334)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> Float {
        return 340
    }
}
extension UserProfileController : UserProfileDelegate {
    
    func userProfile(_ sender: UserProfileReusableCollectionView, didTapEditButton: UIButton?) {
        
    }
    
    func userProfile(_ sender: UserProfileReusableCollectionView, showConnections: UIView) {
        let connectionsVC = ConnectionsController.create()
        connectionsVC.navTitle = "Connections"
        connectionsVC.user = user
        self.push(connectionsVC)
    }
    
    func userProfile(_ sender: UserProfileReusableCollectionView, didTapFollowersButton: UIButton?) {
        let connectionsVC = ConnectionsController.create()
        connectionsVC.navTitle = "Followers"
        connectionsVC.user = user
        self.push(connectionsVC)
    }
    
    func userProfile(_ sender: UserProfileReusableCollectionView, didStartLoadUser: Bool) {
        showHud()
    }
    
    func userProfile(_ sender: UserProfileReusableCollectionView, didTapConnections: UIButton) {
        let connectionsVC = ConnectionsController.create()
        connectionsVC.navTitle = "Connections"
        connectionsVC.user = user
        self.push(connectionsVC)
    }
    
    func homeProfile(sender: UserProfileReusableCollectionView, selectPostsButton button: UIButton) {
        
    }
    
    func userProfile(_ sender: UserProfileReusableCollectionView, didFetchProfile: User) {
        pullRefresh.endRefreshing()
        collectionView.finishInfiniteScroll()
        self.user = didFetchProfile
        updateViewForPrivateProfileChecked()
        hideHud()
    }
    
    var userUpdate: User? {
        return self.user
    }
    
    func userProfile(sender: UserProfileCollectionReusableView, selectPostsButton button: UIButton) {
        let postsVC = PostsController.create()
        postsVC.user = user
        self.push(postsVC)
    }
    func userProfile(sender: UserProfileCollectionReusableView, selectConnectionsButton button: UIButton) {
        let connectionsVC = ConnectionsController.create()
        connectionsVC.navTitle = "Connections"
        connectionsVC.user = user
        self.push(connectionsVC)
    }
    
    func userProfile(_ sender: UserProfileReusableCollectionView, didPressConnectButton button: UIButton) {
        let type = user.getConnectionActionType()
        switch type {
        case .remove:
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to disconnect this user?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                ConnectionsAPI.makeAction(with: type, userId: self.user.id) { (success, error) in
                    if success{
                        self.user.setStatus(with: type)
                        self.collectionView.reloadData()
                    }else{
                        
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in }))
            
            alert.view.tintColor = Apperance.appBlueColor
            self.present(alert, animated: true, completion: nil)
            alert.view.tintColor = Apperance.appBlueColor
            
            break
        default:
            ConnectionsAPI.makeAction(with: type, userId: user.id) { (success, error) in
                if success{
                    self.user.setStatus(with: type)
                    self.collectionView.reloadData()
                }else{
                    
                }
            }
        }
    }
    
    func userProfileDidFetchProfile(sender: UserProfileCollectionReusableView, user: User) {
        pullRefresh.endRefreshing()
        collectionView.finishInfiniteScroll()
        self.user = user
        updateViewForPrivateProfileChecked()
        hideHud()
    }
}

extension UserProfileController {
    func savedInteres(intersesId: Int, collectionView: UICollectionView) {
        if !user.isPublic {
            return
        }
        if self.filteredPosts.count == 0{
            showHud()
        }
        
        PostsAPI.savedPosts(for: self.user.id, interestId: intersesId) { (post, pagination, error) in
            if let posts = post, let pagination = pagination {
                if self.filteredPagination.currentPage == 0{
                    self.filteredPosts = []
                }
                self.filteredPagination = pagination
                
                self.filteredPosts += posts
                self.dataSource = self.filteredPosts.sorted(by: { $0.0.id > $0.1.id })
                
                if self.dataSource.count < 1 {
                    delay(delay: 0.1, closure: {
                        self.noPostInInterest.show(to: self.collectionView)
                        self.noPostInInterest.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
                    })
                }else {
                    self.noPostInInterest.hide()
                }
            }
            if let error = error {
                print(error.message)
            }
            delay(delay: 0, closure: {
                self.pullRefresh.endRefreshing()
                collectionView.isUserInteractionEnabled = true
                self.collectionView.finishInfiniteScroll()
                self.hideHud()
            })
        }
    }
}


extension UserProfileController: InterestViewDelegate {
    func didSelect(contentType: InterestContent, interest: UserInterest?, in collectionCiew: UICollectionView, at indexPath: IndexPath) {
        print("didSelect contentType: \(contentType) in file: \(#file)")
        selectedInterest = contentType
        switch contentType {
        case .save(id: let id):
            print("did tap save button")
            lastSelectedInterest = id
            dataSource = [Post]()
            if self.dataSource.count == 0 {
                self.noPostInInterest.show(to: self.collectionView)
                self.noPostInInterest.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
            }else {
                self.noPostInInterest.hide()
            }
            filteredPagination = Pagination()
            self.savedInteres(intersesId: id, collectionView: collectionCiew)
        case .interest(name: let name , imageUrl: let url, isSeen: let isSeen, id: let id):
            guard let isSeen = isSeen else { return }
            guard isSeen else {
                lastSelectedInterest = nil
                dataSource = unfilteredPosts
                if self.dataSource.count == 0 {
                    self.noPostInInterest.show(to: self.collectionView)
                }else {
                    self.noPostInInterest.hide()
                }
                collectionCiew.isUserInteractionEnabled = true
                return
            }
            lastSelectedInterest = id
            filteredPagination = Pagination()
            getPostsBy(interestId: lastSelectedInterest!, collectionView: collectionCiew)
        case .last24Hour(isSeen: let isSeen):
            print("IsSeen taped")
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
            collectionCiew.isUserInteractionEnabled = true
            //insert this in function to get mometns
            self.pullRefresh.endRefreshing()
            self.collectionView.finishInfiniteScroll()
            self.hideHud()
        default:
            collectionCiew.isUserInteractionEnabled = true
        }
    }
    
    func sendMessage() {
        ChatManager.shared.getConversation(user: self.user.id) { (conversation, error) in
            if let conversation = conversation {
                conversation.user = self.user
                let conversationVC = ConversationController.create(conversation: conversation)
                conversationVC.isFromBroadcastVC = self.isFromBroadcastVC
                self.push(conversationVC)
            }
            
            if let error = error {
                Helper.show(alert: error.message)
            }
        }
    }
    
    func blockUser() {
        let userStore = UserDefaults.standard
        if isBlockedUser(userId: self.user.id) {
            var array = userStore.value(forKey: "blockked_id_key") as? [Int] ?? [Int]()
            if let index = array.index(where: {$0 == self.user.id}) {
                array.remove(at: index)
                userStore.set(array, forKey: "blockked_id_key")
            }
            blockAction(param: .unblock, forUser: self.user.id)
        } else {
            var array = userStore.value(forKey: "blockked_id_key") as? [Int] ?? [Int]()
            array.append(self.user.id)
            userStore.set(array, forKey: "blockked_id_key")
            blockAction(param: .block, forUser: self.user.id)
        }
    }
    
    func blockAction(param: ConnectionActionType, forUser id: Int) {
        let progress = MBProgressHUD.showIndicator(view: self.view)
        progress.show(animated: true)
        ConnectionsAPI.blockUser(with: param, userId: id) { (success, error) in
            guard success else {
                Helper.show(alert: "Error perform action on user")
                progress.hide(animated: true)
                return
            }
            progress.hide(animated: true)
            let message = param == .block ? "User was blocked" : "User was unblocked"
            Helper.show(alert: message)
        }
    }
    
    func isBlockedUser(userId: Int ) -> Bool {
        let userStore = UserDefaults.standard
        let array = userStore.value(forKey: "blockked_id_key") as? [Int] ?? [Int]()
        return array.contains(userId)
    }
    
    func report() {
        Helper.show(alert: "backend create method for report on the user")
    }
    
    func didSave(sender: InterestView) {
        //
    }
    
    func didSelect(interest: UserInterest, at index: IndexPath) {
        if !user.isPublic {
            return
        }
        if interest.isSelected {
            lastSelectedInterest = interest.item!.id
            filteredPagination = Pagination()
            getPostsBy(interestId: lastSelectedInterest!)
            headerView.interestsView.interestCollection.reloadItems(at: [index])
            //            headerView.interestView.getInterests(for: user.id)
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

extension UserProfileController {
    @IBAction func showMoreActions(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Choose action", message: nil, preferredStyle: .actionSheet)
        let messageAction = UIAlertAction(title: "Message", style: .default, handler: { _1 in
            self.sendMessage()
        })
        let blokckAction = UIAlertAction(title: self.isBlockedUser(userId: self.user.id) ? "Unblock" : "Block", style: .destructive, handler: { _ in
            self.blockUser()
        })
        let report = UIAlertAction(title: "Report", style: .destructive, handler: { _ in
            self.report()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(messageAction)
        alertController.addAction(blokckAction)
        alertController.addAction(report)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
