//
//  ViewController.swift
//  CodingTest
//
//  Created by Ye Keyon on 2024/12/29.
//

import UIKit

class ViewController: UIViewController {

    var page = 1
    let pageSize = 20
    var list: [ListModel] = []
    let client = Client(baseURL: URL(string: "https://www.arcblock.io"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configSubView()
        configData(isRefresh: true)
    }
    
    private func configData(isRefresh: Bool) {
        Task { @MainActor in
            do {
                let page = isRefresh ? 1 : self.page + 1
                let response:BaseResponse<[ListModel]> = try await client.send(request: Request(url: "/blog/api/blogs", query: ["page": "\(page)", "size": "\(pageSize)", "locale": "zh"]))
                self.page = page
                if isRefresh {
                    self.list = response.data
                } else {
                    self.list.append(contentsOf: response.data)
                }
                self.collectionView.reloadData()
                self.collectionView.endRefreshing()
            } catch {
                debugPrint(error)
            }
        }
    }
    
    private func configSubView() {
        navigationItem.title = "博客"
        view.backgroundColor = .white
        [collectionView].forEach { view.addSubview($0) }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = WaterFlowLayout()
        layout.scrollDirection = .vertical
        layout.numberOfColumns = 2
        let view = UICollectionView.init(frame: view.bounds, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .white
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.register(ListCell.self, forCellWithReuseIdentifier: "ListCell")
        view.setHeader { [weak self] in
            self?.configData(isRefresh: true)
        }
        view.setFooter { [weak self] in
            self?.configData(isRefresh: false)
        }
        return view
    }()
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as! ListCell
        cell.update(model: list[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: list[indexPath.item].getHeight())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DetailController(model: list[indexPath.item])
        navigationController?.pushViewController(vc, animated: true)
    }
}
