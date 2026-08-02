import SwiftUI

struct JournalEditorSheet: View {
    let entry: JournalEntry?
    let onSave: (JournalEntry) -> Void
    let onCancel: () -> Void

    @EnvironmentObject private var store: AppStore
    @Environment(\.vaultTheme) private var theme
    @State private var caption = ""
    @State private var date = Date()
    @State private var selectedChapterId: UUID?
    @State private var linkToChapter = false
    @State private var mood: MoodTag?
    @State private var imageFileName: String?
    @State private var activePrompt = WritingPrompts.random()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    promptCard

                    TextField(
                        "",
                        text: $caption,
                        prompt: Text("Caption").foregroundColor(Color("AppTextSecondary")),
                        axis: .vertical
                    )
                    .lineLimit(3...8)
                    .padding(14)
                    .background(Color("AppSurface"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .tint(theme.accent)

                    Text("Mood")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(MoodTag.allCases) { tag in
                                Button {
                                    mood = mood == tag ? nil : tag
                                    HapticFeedback.selection()
                                } label: {
                                    Label(tag.title, systemImage: tag.symbol)
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                        .background(mood == tag ? theme.primary.opacity(0.45) : Color("AppSurface"))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .tint(theme.primary)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .colorScheme(.dark)

                    Toggle("Link to chapter", isOn: $linkToChapter)
                        .tint(theme.primary)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .onChange(of: linkToChapter) { enabled in
                            if !enabled {
                                selectedChapterId = nil
                            } else if selectedChapterId == nil {
                                selectedChapterId = store.chapters.first?.id
                            }
                        }

                    if linkToChapter {
                        if store.chapters.isEmpty {
                            Text("Create a chapter first to link narratives.")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        } else {
                            Picker("Chapter", selection: $selectedChapterId) {
                                ForEach(store.sortedChapters) { chapter in
                                    Text(chapter.title).tag(Optional(chapter.id))
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(theme.accent)
                        }
                    }

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
            .navigationTitle(entry == nil ? "New Narrative" : "Edit Narrative")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .foregroundStyle(theme.accent)
                    .disabled(caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            if let entry {
                caption = entry.caption
                date = entry.date
                selectedChapterId = entry.chapterId
                linkToChapter = entry.chapterId != nil
                mood = entry.moodTag
                imageFileName = entry.imageFileName
            }
        }
    }

    private var promptCard: some View {
        EditorialCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Writing prompt")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.accent)
                Text(activePrompt)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack {
                    Button("Use prompt") {
                        if caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            caption = activePrompt
                        } else {
                            caption += "\n\n" + activePrompt
                        }
                        HapticFeedback.lightTap()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.accent)
                    Spacer()
                    Button("Shuffle") {
                        activePrompt = WritingPrompts.random()
                        HapticFeedback.selection()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }

    private func saveEntry() {
        let trimmed = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let chapterId = linkToChapter ? selectedChapterId : nil
        if let entry {
            var updated = entry
            updated.caption = trimmed
            updated.date = date
            updated.chapterId = chapterId
            updated.mood = mood?.rawValue
            updated.imageFileName = imageFileName
            onSave(updated)
        } else {
            onSave(
                JournalEntry(
                    caption: trimmed,
                    date: date,
                    chapterId: chapterId,
                    mood: mood?.rawValue,
                    imageFileName: imageFileName
                )
            )
        }
    }
}
