//
//  GlobalConstants.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 22.09.2024.
//

import Foundation

enum GlobalConstants {
    static let appMetricaApiKey = "apiKey"
    static let logSubsystem = "ru.yandex.practicum.Tracker"
    static let logCategory = "network"
}

enum LocalizationKey: String {
    // TrackerStore
    case pinnedCategory = "pinned_category"
    
    // Onboarding
    case onboardingFirstPage = "onboarding_fir_page"
    case onboardingSecondPage = "onboarding_sec_page"
    case onboardingButton = "onboarding_button"
    
    // BaseVC & MainVC (TabBar)
    case trackersTabTitle = "trackers_tab_title"
    case statisticsTabTitle = "statistics_tab_title"
    
    // DayOfTheWeek
    case monday = "monday"
    case tuesday = "tuesday"
    case wednesday = "wednesday"
    case thursday = "thursday"
    case friday = "friday"
    case saturday = "saturday"
    case sunday = "sunday"
    
    // TrackersVC
    case searchPlaceholder = "search_placeholder"
    case trackersPlaceholder = "trackers_placeholder"
    case notFoundSearchPlaceholder = "notfound_search_placholder"
    case searchCancel = "search_cancel"
    case filtersButton = "filters_button"
    
    // FilterViewController
    case filtersTitle = "filtets_title"
    case filtersAllTrackers = "filters_all_trackers"
    case filtersOnToday = "filters_on_today"
    case filtersComplete = "filters_complete"
    case filtersNotComplete = "filters+not_complete"
    
    // TrackerVCDelegate & ContextMenuHelper
    case pin = "pin"
    case unpin = "unpin"
    case delete = "delete"
    case edit = "edit"
    case alertCancel = "alert_cancel"
    case deleteConfirmationMessage = "delete_confirmation_message"
    
    // ConfigureTableViewCellsHelper & HandleActionsHelper
    case habit = "habit"
    case irregularEvent = "irregular_event"
    case editCategory = "edit_category"
    case enterCategoryName = "enter_cat_name"
    case newCategory = "new_category"
    
    case category = "category"
    case schedule = "schedule"
    
    // BaseTrackerViewController
    case creatingTracker = "creating_tracker"
    case newHabit = "new_habit"
    case editHabit = "edit_habit"
    case creatingHabit = "creating_habit"
    
    // CreatingTrackerViewController
    case everyDay = "every_day"
    
    case mondayShort = "monday_short"
    case tuesdayShort = "tuesday_short"
    case wednesdayShort = "wednesday_short"
    case thursdayShort = "thursday_short"
    case fridayShort = "friday_short"
    case saturdayShort = "saturday_short"
    case sundayShort = "sunday_short"
    
    // TrackerSection
    case emojiHeader = "emoji_header"
    case colorHeader = "color_header"
    case limitChar = "limit_char"
    
    // TextViewCell
    case textViewPlaceholder = "textView_placeholder"
    
    // CreateButtonsViewCell
    case saveTracker = "save_tracker"
    case createNewTracker = "create_new_tracker"
    case cancelCreateNewTracker = "cancel_create_new_tracker"
    
    // CategoryViewController & ScheduleViewController
    case categoryPlaceholder = "category_placeholder"
    case addCategory = "add_category"
    case doneCategoryButton = "done_category_button"
    
    // StatisticsViewController
    case statisticsPlaceholder = "statistics_placeholder"
    case bestPeriod = "best_period"
    case idealDays = "ideal_days"
    case completedTrackers = "completed_trackers"
    case averageValue = "average_value"
    case notAvailable = "n_a"
    
    // Method to get localized string
    func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
