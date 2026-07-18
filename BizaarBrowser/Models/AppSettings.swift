import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("convertWebMToMP4") var convertWebMToMP4: Bool = false
    @AppStorage("loopAllAnimations") var loopAllAnimations: Bool = true
    @AppStorage("lastVisitedURL") var lastVisitedURL: String = ""
    @AppStorage("sortOption") var sortOptionRaw: String = SortOption.dateNewest.rawValue
    @AppStorage("filterType") var filterTypeRaw: String = MediaType.all.rawValue
    @AppStorage("darkModeEnabled") var darkModeEnabled: Bool = false

    @Published var isBrowserChromeHidden: Bool = false

    var sortOption: SortOption {
        get { SortOption(rawValue: sortOptionRaw) ?? .dateNewest }
        set { sortOptionRaw = newValue.rawValue }
    }

    var filterType: MediaType {
        get { MediaType(rawValue: filterTypeRaw) ?? .all }
        set { filterTypeRaw = newValue.rawValue }
    }

    var colorScheme: ColorScheme? {
        darkModeEnabled ? .dark : .light
    }

    private init() {}
}
