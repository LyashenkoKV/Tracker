//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 11.08.2024.
//

import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelect(_ days: [DayOfTheWeek])
}

final class ScheduleViewController: BaseTrackerViewController {
    
    weak var delegate: ScheduleSelectionDelegate?
    
    private lazy var addDoneButton = UIButton(
        title: NSLocalizedString(
            "done_category_button",
            comment: "Готово"
        ),
        backgroundColor: .ypBlack,
        titleColor: .ypBackground,
        cornerRadius: 20,
        font: UIFont.systemFont(ofSize: 16, weight: .medium),
        target: self,
        action: #selector(addDoneButtonAction)
    )
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [tableView, addDoneButton])
        stack.axis = .vertical
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addDoneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureScheduleCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.reuseIdentifier,
            for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        
        let day = DayOfTheWeek.allCases[indexPath.row]
        let isDaySelected = selectedDays.contains(day)
        
        cell.configure(with: day.localized(), showSwitch: true, isSwitchOn: isDaySelected)
        
        cell.toggleSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        ConfigureTableViewCellsHelper.configureBaseCell(cell, at: indexPath, totalRows: DayOfTheWeek.allCases.count)
        ConfigureTableViewCellsHelper.configureSeparator(cell, isLastRow: indexPath.row == DayOfTheWeek.allCases.count - 1)
        
        return cell
    }
    
    @objc func switchChanged(sender: UISwitch) {
        guard let cell = sender.superview(of: ScheduleCell.self),
              let indexPath = tableView.indexPath(for: cell) else {
            Logger.shared.log(
                .error,
                message: "Не удалось найти ячейку или indexPath для свича"
            )
            return
        }

        let selectedDay = DayOfTheWeek.allCases[indexPath.row]

        if sender.isOn {
            if !selectedDays.contains(selectedDay) {
                selectedDays.append(selectedDay)
            }
        } else {
            selectedDays.removeAll { $0 == selectedDay }
        }
    }
    
    @objc private func addDoneButtonAction() {
        delegate?.didSelect(selectedDays)
        dismiss(animated: true)
    }
}

// MARK: - cellForRowAt
extension ScheduleViewController {
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            switch trackerViewControllerType {
            case .schedule:
                return configureScheduleCell(at: indexPath)
            default:
                return UITableViewCell()
            }
        }
}
