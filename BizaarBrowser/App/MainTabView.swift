import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            BrowserView()
                .tabItem {
                    Label("Browser", systemImage: "globe")
                }
                .tag(0)

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
        .toolbar(settings.isBrowserChromeHidden && selectedTab == 0 ? .hidden : .automatic, for: .tabBar)
        .animation(.easeOut(duration: 0.25), value: settings.isBrowserChromeHidden)
    }
}
