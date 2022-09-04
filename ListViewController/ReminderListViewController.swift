//
//  ViewController.swift
//  Today
//
//  Created by MacPro on 08.04.2022.
//

import UIKit
import EventKit

class ReminderListViewController: UICollectionViewController {
            
    var dataSource: DataSource!
    var reminders: [Reminder] = []
    var filtredReminders: [Reminder] {
        return reminders.filter { listStyle.shouldInclude(date: $0.dueDate) }.sorted { $0.dueDate < $1.dueDate }
    }
    var listStyle: ReminderListStyle = .today
    let listStyleSegmentedControll = UISegmentedControl(items: [ReminderListStyle.today.name, ReminderListStyle.future.name, ReminderListStyle.all.name])
    var headerView: ProgressHeaderView?
    
    var progress: CGFloat {
        let chunkSize = 1.0 / CGFloat(filtredReminders.count)
        let progress = filtredReminders.reduce(0.0) {
            //$0 = 0.0, $1 = filtredReminders[i]
            let chunk = $1.isComplete ? chunkSize : 0
            return $0 + Double(chunk)
        }
        return CGFloat(progress)
    }
    
    @objc func storeChanged() {
        prepareReminderStore()
        updateSnapshot()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged), name: .EKEventStoreChanged, object: nil)
        
        collectionView.backgroundColor = .todayGradientFutureBegin
        
        collectionView.collectionViewLayout = listLayout()
        
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Reminder.ID) -> UICollectionViewCell? in
                        
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration(elementKind: ProgressHeaderView.elementKind, handler: supplementaryRegistrationHandler)
        
        dataSource.supplementaryViewProvider = { supplementaryView, elementKind, indexPath in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAddButton(_:)))
        addButton.accessibilityLabel = NSLocalizedString("Add reminder", comment: "Add button accessibility label")
        navigationItem.rightBarButtonItem = addButton
                
        listStyleSegmentedControll.selectedSegmentIndex = listStyle.rawValue
        listStyleSegmentedControll.addTarget(self, action: #selector(didChangeListStyle(_:)), for: .valueChanged)
        navigationItem.titleView = listStyleSegmentedControll
        
        updateSnapshot()
        
        collectionView.dataSource = dataSource
        
        prepareReminderStore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshBackground()
    }
    
    func refreshBackground() {
        //collectionView.backgroundColor = nil
        let backgroundView = UIView()
        let gradientLayer = CAGradientLayer.gradientLayer(for: listStyle, in: collectionView.frame)
        backgroundView.layer.addSublayer(gradientLayer)
        collectionView.backgroundView = backgroundView
    }
    
    // MARK: - Navigation
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let id = filtredReminders[indexPath.item].id
        showDetail(for: id)
        return false
    }
    
    func showDetail(for id: Reminder.ID) {
        let reminder = remindr(for: id)
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            self?.update(reminder, with: reminder.id)
            self?.updateSnapshot(reloading: [reminder.id])
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard elementKind == ProgressHeaderView.elementKind, let progressView = view as? ProgressHeaderView else {
            return
        }
        progressView.progress = progress
    }
    
    func showError(_ error: Error) {
        let alertTitle = NSLocalizedString("Error", comment: "Error")
        let alert = UIAlertController(title: alertTitle, message: error.localizedDescription, preferredStyle: .alert)
        let actionTitle = NSLocalizedString("OK", comment: "OK")
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }
    
    // MARK: - Layout in collection view
    private func listLayout() -> UICollectionViewCompositionalLayout {
//________
//        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
//        listConfiguration.headerMode = .supplementary
//        listConfiguration.showsSeparators = false
//        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
//        listConfiguration.backgroundColor = .clear
//        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
//________
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            if sectionIndex == 0 {
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = .supplementary
                config.backgroundColor = .clear
                config.trailingSwipeActionsConfigurationProvider = self.makeSwipeActions
                let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnviroment)
                return section
            }
            return nil
        }

        return layout
//________
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
//
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
//
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
//
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
//        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
//
//        let section = NSCollectionLayoutSection(group: group)
//        section.boundarySupplementaryItems = [header]
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        return layout
//________
//        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
//        listConfiguration.headerMode = .supplementary
//        listConfiguration.showsSeparators = true
//        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
//        listConfiguration.backgroundColor = .clear
//        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    // MARK: - Swipe
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath, let id = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionTitle) { [weak self] (_, _, completion) in
            
            self?.deleteReminder(with: id)
            self?.updateSnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Progress view
    private func supplementaryRegistrationHandler(progressView: ProgressHeaderView, elementKind: String, indexPath: IndexPath) {
        headerView = progressView
    }
}

