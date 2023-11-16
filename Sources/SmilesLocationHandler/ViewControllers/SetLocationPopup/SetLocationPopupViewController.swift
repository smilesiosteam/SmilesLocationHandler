//
//  SetLocationPopupViewController.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import UIKit
import SmilesUtilities
import Combine

class SetLocationPopupViewController: UIViewController {

    // MARK: - OUTLETS -
    @IBOutlet weak var locationsCollectionView: UICollectionView!
    @IBOutlet weak var continueButton: UICustomButton!
    @IBOutlet weak var panDismissView: UIView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    
    // MARK: - PROPERTIES -
    private var input: PassthroughSubject<SetLocationViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private lazy var viewModel: SetLocationViewModel = {
        return SetLocationViewModel()
    }()
    private var dismissViewTranslation = CGPoint(x: 0, y: 0)
    private var citiesResponse: GetCitiesResponse?
    private var interItemSpacing: CGFloat = 8
    private var itemHeight: CGFloat = 40
    
    // MARK: - ACTIONS -
    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func continuePressed(_ sender: Any) {
    }
    
    // MARK: - METHODS -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        
        bind(to: viewModel)
        mainView.roundSpecifiCorners(corners: [.topLeft, .topRight], radius: 16)
        panDismissView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        panDismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        setupCollectionView()
        input.send(.getCities)
        
    }
    
    private func setupCollectionView() {
        
        locationsCollectionView.register(nib: UINib(nibName: "LocationTitleCollectionViewCell", bundle: .module), forCellWithClass: LocationTitleCollectionViewCell.self)
        locationsCollectionView.delegate = self
        locationsCollectionView.dataSource = self
        
    }
    
    private func setupCollectionViewHeight() {
        
        if let cities = citiesResponse?.cities {
            let rows = CGFloat(cities.count / 2).rounded(.up)
            let totalRowHeight = CGFloat(itemHeight * rows)
            let totalSpace = CGFloat(interItemSpacing * (rows - 1))
            collectionViewHeight.constant = CGFloat(totalRowHeight + totalSpace)
            locationsCollectionView.layoutIfNeeded()
        }
        
    }

}

// MARK: - GESTURES ACTION HANDLING -
extension SetLocationPopupViewController {
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            dismissViewTranslation = sender.translation(in: view)
            if dismissViewTranslation.y > 0 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.dismissViewTranslation.y)
                })
            }
        case .ended:
            if dismissViewTranslation.y < 150 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            }
            else {
                dismiss(animated: true)
            }
        default:
            break
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
}

// MARK: - VIEWMODEL BINDING -
extension SetLocationPopupViewController {
    
    func bind(to viewModel: SetLocationViewModel) {
        input = PassthroughSubject<SetLocationViewModel.Input, Never>()
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchCitiesDidSucceed(let response):
                    self?.citiesResponse = response
                    self?.setupCollectionViewHeight()
                    self?.locationsCollectionView.reloadData()
                case .fetchCitiesDidFail(let error):
                    print(error.localizedDescription)
                }
            }.store(in: &cancellables)
    }
    
}

// MARK: - UICOLLECTIONVIEW DELEGATE & DATASOURCE -
extension SetLocationPopupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return citiesResponse?.cities?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withClass: LocationTitleCollectionViewCell.self, for: indexPath)
        if let city = citiesResponse?.cities?[indexPath.item] {
            cell.setValues(city: city)
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cities = citiesResponse?.cities {
            for (index, city) in cities.enumerated() {
                city.isSelected = index == indexPath.item
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - interItemSpacing) / 2
        return CGSize(width: width, height: itemHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
}
