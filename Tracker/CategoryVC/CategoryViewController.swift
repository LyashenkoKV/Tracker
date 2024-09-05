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
    private var viewModel: CategoryViewModel?
    
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
        titleColor: .ypBackground,
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
        
        viewModel = CategoryViewModel(
            trackerCategoryStore: TrackerCategoryStore(
                persistentContainer: CoreDataStack.shared.persistentContainer)
        )
        
        dataProvider = viewModel
        
        setupBindings()
        setupUI()
        viewModel?.loadCategories()
        dismissKeyboard(view: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.loadCategories()
        print(categories)
    }
    
    private func setupBindings() {
        guard let viewModel else { return }
        
        viewModel.onCategoriesUpdated = { [weak self] categories in
            print("Обновляем категории в таблице: \(categories.map { $0.title })")
            self?.tableView.reloadData()
        }
        
        viewModel.onAddCategoryButtonStateUpdated = { [weak self] isEnabled in
            self?.addCategoryButton.isEnabled = isEnabled
            self?.addCategoryButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
        }
        
        viewModel.onPlaceholderStateUpdated = { [weak self] isVisible in
            self?.placeholder.view.isHidden = !isVisible
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
        guard let viewModel = viewModel else { return }
        viewModel.deleteCategory(at: indexPath.row)
        tableView.reloadData()
    }

    // MARK: - Actions
    @objc private func addCategoryButtonAction() {
        guard let viewModel else { return }
        if isAddingCategory {
            let categoryName = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextViewCell)?.getText().text ?? ""
            print("Пытаемся добавить категорию с именем: \(categoryName)")
            viewModel.addCategory(named: categoryName)
            isAddingCategory = false
        } else {
            isAddingCategory.toggle()
        }
        viewModel.updateAddCategoryButtonState(isEnabled: !isAddingCategory)
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
    
    override func textViewCellDidEndEditing(_ cell: TextViewCell, text: String?) {
        cell.getText().resignFirstResponder()
    }
    
    private func loadCategories() {
        viewModel?.loadCategories()

        // Убедитесь, что данные загружены перед перезагрузкой таблицы
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let categories = self.viewModel?.categories, !categories.isEmpty {
                print("Данные загружены: \(categories.map { $0.title })")
                self.tableView.reloadData()
            } else {
                print("Категории не загружены.")
            }
        }
    }
}

// MARK: - UITableVIewDelegate
extension CategoryViewController {
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
            if !isAddingCategory {
                guard let selectedCategoryTitle = dataProvider?.item(at: indexPath.row) else { return }
                
                if let selectedCategory = viewModel?.categories.first(where: { $0.title == selectedCategoryTitle }) {
                    self.selectedCategory = selectedCategory
                    delegate?.didSelectCategory(selectedCategory)
                }
                
                tableView.reloadData()
                dismissOrCancel()
            }
        }
}

