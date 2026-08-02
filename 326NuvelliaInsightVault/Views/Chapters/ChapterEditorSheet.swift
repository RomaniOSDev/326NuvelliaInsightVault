import SwiftUI

struct ChapterEditorSheet: View {
    let chapter: StoryChapter?
    let onSave: (StoryChapter) -> Void
    let onCancel: () -> Void

    @EnvironmentObject private var store: AppStore
    @Environment(\.vaultTheme) private var theme

    @State private var title = ""
    @State private var icon = "📖"
    @State private var chapterDescription = ""
    @State private var useSymbol = false
    @State private var symbolName = "book.fill"
    @State private var imageFileName: String?
    @State private var isPinned = false

    private let emojiSuggestions = ["📖", "🎬", "📸", "✨", "🌅", "🎭", "🖼️", "📰"]
    private let symbolSuggestions = ["book.fill", "photo.fill", "film.fill", "sparkles", "camera.fill", "text.book.closed.fill"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    TextField(
                        "",
                        text: $title,
                        prompt: Text("Title").foregroundColor(Color("AppTextSecondary"))
                    )
                    .textFieldStyle(.plain)
                    .padding(14)
                    .background(Color("AppSurface"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .tint(theme.accent)

                    Toggle("Pin chapter", isOn: $isPinned)
                        .tint(theme.primary)
                        .foregroundStyle(Color("AppTextPrimary"))

                    Toggle("Use SF Symbol", isOn: $useSymbol)
                        .tint(theme.primary)
                        .foregroundStyle(Color("AppTextPrimary"))

                    if useSymbol {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 52))], spacing: 10) {
                            ForEach(symbolSuggestions, id: \.self) { name in
                                Button {
                                    symbolName = name
                                    icon = "sf:\(name)"
                                    HapticFeedback.selection()
                                } label: {
                                    Image(systemName: name)
                                        .font(.title2)
                                        .frame(width: 52, height: 52)
                                        .background(
                                            symbolName == name
                                                ? theme.primary.opacity(0.35)
                                                : Color("AppSurface")
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } else {
                        Text("Choose an emoji")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color("AppTextSecondary"))
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 52))], spacing: 10) {
                            ForEach(emojiSuggestions, id: \.self) { emoji in
                                Button {
                                    icon = emoji
                                    HapticFeedback.selection()
                                } label: {
                                    Text(emoji)
                                        .font(.largeTitle)
                                        .frame(width: 52, height: 52)
                                        .background(
                                            icon == emoji
                                                ? theme.primary.opacity(0.35)
                                                : Color("AppSurface")
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Text("Description")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    TextField(
                        "",
                        text: $chapterDescription,
                        prompt: Text("Describe this chapter").foregroundColor(Color("AppTextSecondary")),
                        axis: .vertical
                    )
                    .lineLimit(4...8)
                    .padding(14)
                    .background(Color("AppSurface"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .tint(theme.accent)

                    PhotoAttachControl(imageFileName: $imageFileName) { image in
                        store.saveImage(image)
                    }
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .storybookBackground()
            .vaultNavigationChrome()
            .navigationTitle(chapter == nil ? "New Chapter" : "Edit Chapter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChapter()
                    }
                    .foregroundStyle(theme.accent)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            if let chapter {
                title = chapter.title
                icon = chapter.icon
                chapterDescription = chapter.chapterDescription
                imageFileName = chapter.imageFileName
                isPinned = chapter.isPinned
                if icon.hasPrefix("sf:") {
                    useSymbol = true
                    symbolName = String(icon.dropFirst(3))
                }
            }
        }
    }

    private func saveChapter() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = chapterDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        let resolvedIcon: String
        if useSymbol {
            resolvedIcon = "sf:\(symbolName)"
        } else {
            resolvedIcon = icon.isEmpty ? "📖" : icon
        }
        if let chapter {
            var updated = chapter
            updated.title = trimmedTitle
            updated.icon = resolvedIcon
            updated.chapterDescription = trimmedDescription
            updated.isPinned = isPinned
            updated.imageFileName = imageFileName
            onSave(updated)
        } else {
            onSave(
                StoryChapter(
                    title: trimmedTitle,
                    icon: resolvedIcon,
                    chapterDescription: trimmedDescription,
                    isPinned: isPinned,
                    imageFileName: imageFileName
                )
            )
        }
    }
}
