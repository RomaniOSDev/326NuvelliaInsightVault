import PhotosUI
import SwiftUI
import UIKit

struct PhotoAttachControl: View {
    @Binding var imageFileName: String?
    let onSaveImage: (UIImage) -> String?

    @State private var pickerItem: PhotosPickerItem?
    @State private var preview: UIImage?
    @State private var showPicker = false
    @State private var showDeniedAlert = false

    @Environment(\.vaultTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Photo")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))

            if let preview {
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            HStack(spacing: 12) {
                Button {
                    PhotoPermission.requestAccess { granted in
                        if granted {
                            showPicker = true
                            HapticFeedback.selection()
                        } else {
                            showDeniedAlert = true
                            HapticFeedback.warning()
                        }
                    }
                } label: {
                    Label(preview == nil ? "Add Photo" : "Replace", systemImage: "photo")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(theme.primary.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .photosPicker(isPresented: $showPicker, selection: $pickerItem, matching: .images)

                if preview != nil {
                    Button("Remove") {
                        PhotoStorage.delete(imageFileName)
                        imageFileName = nil
                        preview = nil
                        HapticFeedback.warning()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.accent)
                }
            }
        }
        .onAppear {
            preview = PhotoStorage.load(imageFileName)
        }
        .onChange(of: pickerItem) { item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let saved = onSaveImage(image) {
                    await MainActor.run {
                        if let previous = imageFileName, previous != saved {
                            PhotoStorage.delete(previous)
                        }
                        imageFileName = saved
                        preview = image
                        HapticFeedback.success()
                    }
                }
            }
        }
        .alert("Photo Access Needed", isPresented: $showDeniedAlert) {
            Button("Open Settings", action: PhotoPermission.openSettings)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Allow photo access in Settings to attach images to chapters and narratives.")
        }
    }
}
