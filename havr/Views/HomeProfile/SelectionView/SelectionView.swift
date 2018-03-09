//
//  SelectionView.swift
//  havr
//
//  Created by Agon Miftari on 4/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol SelectionViewDelegate :class {
    func didSelect(interest: Interest, at index: Int)
}

class SelectionView: UIView {

    @IBOutlet weak var selectionInterestCollection: UICollectionView!
    
    var view: UIView!
    
    var activeInterests: [UserInterest] {
        return ResourcesManager.activeInterests
    }
    var datasource: [InterestContent] = [] {
        didSet {
            datasource.insert(InterestContent.save(id: 0), at: 0)
            datasource.insert(InterestContent.last24Hour(isSeen: true), at: 1)
            if datasource.count < 5 {
                datasource.insert(InterestContent.addNew, at: datasource.count)
            }
            selectionInterestCollection.reloadData()
        }
    }
    weak var delegate : SelectionViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        datasource = activeInterests.map({ (interes) -> InterestContent in
            return InterestContent.interest(name: interes.item?.name, imageUrl: interes.item?.getUrl(), isSeen: interes.item?.isSeen, id: (interes.item?.id)!)
        })
        commonInit()
    }
    
    
    func commonInit() {
        selectionInterestCollection.delegate = self
        selectionInterestCollection.dataSource = self
        selectionInterestCollection.registerInterestCollectionCell()

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        return UINib(nibName: "SelectionView", bundle: bundle).instantiate(withOwner: self, options: nil)[0] as! UIView
    }


}

extension SelectionView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueInterestCollectionCell(indexpath: indexPath)
        let interest = datasource[indexPath.item]
        cell.bindInterestImageWithoutRoundedView()
        cell.update(with: interest)
        
        
//        if indexPath.item < activeInterests.count {
//
//        } else {
//            cell.bindAddInterestWithoutRoundedView()
//            cell.interestName.text = nil
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.width - 80) / 5
        let height = collectionView.frame.size.height
        
        let size = CGSize(width: width, height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.didSelect(interest: Interest(), at: indexPath.item)
    }
}

