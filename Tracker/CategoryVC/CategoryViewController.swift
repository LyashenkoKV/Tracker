//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 07.08.2024.
//

import UIKit
// MARK: - Protocol
protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
    func startEditingCategory(at indexPath: IndexPath)
    func deleteCategory(at indexPath: IndexPath)
}

// MARK: - Object
final class CategoryViewController: BaseTrackerViewController {
    
    weak var delegate: CategorySelectionDelegate?
    
    private let trackerCategoryStore = TrackerCategoryStore(persistentContainer: CoreDataStack.shared.persistentContainer)
    
    // MARK: - UI Elements
    private lazy var placeholder: Placeholder = {
        let placeholder = Placeholder(
            image: UIImage(named: "Error"),
            text: "Привычки и события можно\nобъединить по смыслу"
        )
        return placeholder
    }()
    
    private lazy var addCategoryButton = UIButton(
        title: "Добавить категорию",
        backgroundColor: .ypBlack,
        titleColor: .ypWhite,
        cornerRadius: 20,
        font: UIFont.systemFont(
            ofSize: 16,
            weight: .medium
        ),
        target: self,
        action: #selector(addCategoryButtonAction)
    )
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            tableView,
            addCategoryButton
        ])
        stack.axis = .vertical
        return stack
    }()
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCategories()
        updatePlaceholder()
        //dismissKeyboard(view: self.view) Надо подумать, из за метода не правильно отрабатывает кнопка
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        trackerCategoryStore.didUpdateData = { [weak self] in
            DispatchQueue.main.async {
                self?.loadCategories()
                self?.updatePlaceholder()
                self?.updateUI()
            }
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        [stack, placeholder.view].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
       
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            placeholder.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    override func deleteCategory(at indexPath: IndexPath) {
        let deletedCategory = categories[indexPath.row]
        categories.remove(at: indexPath.row)
        
        if selectedCategory?.title == deletedCategory.title {
            selectedCategory = nil
        }
        
        do {
            try trackerCategoryStore.deleteCategory(deletedCategory)
        } catch {
            Logger.shared.log(
                .error,
                message: "Ошибка при удалении категории \(deletedCategory.title): \(error.localizedDescription)"
            )
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Actions
    @objc private func addCategoryButtonAction() {
        if isAddingCategory {
            if let categoryName = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextViewCell)?.getText().text, !categoryName.isEmpty {
                do {
                    try trackerCategoryStore.addCategory(TrackerCategory(title: categoryName, trackers: []))
                    Logger.shared.log(.info, message: "Категория успешно добавлена: \(categoryName)")
                } catch {
                    Logger.shared.log(.error, message: "Ошибка при добавлении категории: \(error.localizedDescription)")
                }
            }
            isAddingCategory = false
        } else {
            isAddingCategory.toggle()
        }
        updateUI()
    }
    
    // MARK: - Overriding updateUI
    override func updateUI() {
        super.updateUI()

        addCategoryButton.isEnabled = !isAddingCategory
        addCategoryButton.backgroundColor = isAddingCategory ? .ypGray : .ypBlack
        addCategoryButton.setTitle(isAddingCategory ? "Готово" : "Добавить категорию", for: .normal)

        tableView.reloadData()
    }
    
    private func updatePlaceholder() {
        placeholder.view.isHidden = !categories.isEmpty || isAddingCategory
    }

    override func textViewCellDidChange(_ cell: TextViewCell) {
        super.textViewCellDidChange(cell)
        guard let text = cell.getText().text else { return }
        addCategoryButton.isEnabled = !text.isEmpty
        addCategoryButton.backgroundColor = text.isEmpty ? .ypGray : .ypBlack
    }
    
    private func loadCategories() {
        categories = trackerCategoryStore.fetchCategories()
        Logger.shared.log(.info, message: "Категории загружены: \(categories.count)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableVIewDelegate
extension CategoryViewController {
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
            if !isAddingCategory {
                let selectedCategory = categories[indexPath.row]
                self.selectedCategory = selectedCategory
                delegate?.didSelectCategory(selectedCategory)
                
                tableView.reloadData()
                dismissOrCancel()
            }
        }
}
