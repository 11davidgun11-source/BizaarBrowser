import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var downloadManager: DownloadManager
    @State private var showClearAlert = false
    @State private var showClearedToast = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $settings.convertWebMToMP4) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Convert WebM to MP4")
                                Text("Automatically convert downloaded WebM files")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "film")
                                .foregroundColor(.gold)
                        }
                    }

                    Toggle(isOn: $settings.loopAllAnimations) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Loop All Animations")
                                Text("Loop GIFs and videos continuously")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "repeat")
                                .foregroundColor(.gold)
                        }
                    }

                    Toggle(isOn: $settings.darkModeEnabled) {
                        Label {
                            Text("Dark Mode")
                        } icon: {
                            Image(systemName: settings.darkModeEnabled ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(.gold)
                        }
                    }
                } header: {
                    Text("Playback")
                }

                Section {
                    HStack {
                        Label("Total Files", systemImage: "doc.on.doc")
                        Spacer()
                        Text("\(downloadManager.downloadedFiles.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Storage Used", systemImage: "internaldrive")
                        Spacer()
                        Text(totalStorage)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Storage")
                }

                Section {
                    Button(role: .destructive) {
                        showClearAlert = true
                    } label: {
                        Label("Clear All Downloads", systemImage: "trash")
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("This will permanently delete all downloaded media files.")
                }

                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Bizaar Browser")
                                .font(.headline)
                                .foregroundColor(.gold)
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Clear All Downloads?", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete All", role: .destructive) {
                    downloadManager.deleteAll()
                    showClearedToast = true
                }
            } message: {
                Text("This will permanently delete all \(downloadManager.downloadedFiles.count) downloaded files. This cannot be undone.")
            }
            .overlay {
                if showClearedToast {
                    toast
                }
            }
        }
    }

    private var totalStorage: String {
        let total = downloadManager.downloadedFiles.reduce(Int64(0)) { $0 + $1.fileSize }
        return FileSizeFormatter.string(from: total)
    }

    private var toast: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("All downloads cleared")
                    .font(.subheadline.bold())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .cornerRadius(25)
            .padding(.bottom, 40)
        }
        .transition(.move(edge: .bottom))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { showClearedToast = false }
            }
        }
    }
}
