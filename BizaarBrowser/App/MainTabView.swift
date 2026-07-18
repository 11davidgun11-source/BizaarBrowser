import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            BrowserView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Browser", systemImage: "globe")
                }
                .tag(0)
                .toolbar(settings.isBrowserChromeHidden ? .hidden : .automatic, for: .tabBar)

            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "square.grid.2x2")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
        .accentColor(.gold)
    }
}
