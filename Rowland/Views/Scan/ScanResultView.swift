import SwiftUI

// MARK: - Scan Result View
//
// Shown after a successful stamp identification.
// Displays the matched stamp with confidence indicator, key details, valuation (Pro),
// and options to add to collection or view full detail.

struct ScanResultView: View {
    let result: ScanResult
    @ObservedObject var viewModel: ScanViewModel
    @EnvironmentObject var appState: AppState
    @State private var showDetail = false
    @State private var showAddToCollection = false
    @State private var addedToCollection = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Confidence banner
                ConfidenceBanner(result: result)

                // Stamp card
                StampResultCard(stamp: result.stamp)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                // Valuation row (Pro feature)
                if let valuation = result.stamp.valuation {
                    ValuationRow(valuation: valuation)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                } else if appState.subscription == .free {
                    ProUpgradeTeaser()
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                }

                // Catalogue refs
                if !result.stamp.catalogueRefs.isEmpty {
                    CatalogueRefsRow(refs: result.stamp.catalogueRefs)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                }

                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        showDetail = true
                    } label: {
                        Label("View Full Details", systemImage: "info.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.stampCard)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.stampBorder))
                    }

                    Button {
                        showAddToCollection = true
                    } label: {
                        Label(
                            addedToCollection ? "Added to Collection ✓" : "Add to Collection",
                            systemImage: addedToCollection ? "checkmark.circle.fill" : "plus.circle"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(addedToCollection ? Color.stampGold.opacity(0.2) : Color.stampGold)
                        .foregroundColor(addedToCollection ? .stampGold : .black)
                        .cornerRadius(12)
                    }
                    .disabled(addedToCollection)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 40)

                // Alternative matches
                if result.topCandidates.count > 1 {
                    AlternativeMatchesSection(candidates: result.topCandidates, onSelect: { stamp in
                        // TODO: Replace result with the selected alternative
                    })
                    .padding(.horizontal, 20)
                }
            }
        }
        .background(Color.stampSurface)
        .navigationDestination(isPresented: $showDetail) {
            StampDetailView(stamp: result.stamp)
        }
        .sheet(isPresented: $showAddToCollection) {
            AddToCollectionSheet(stamp: result.stamp, onAdd: {
                addedToCollection = true
                showAddToCollection = false
            })
        }
    }
}

// MARK: - Subcomponents

private struct ConfidenceBanner: View {
    let result: ScanResult

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(result.confidenceColor)
                .frame(width: 8, height: 8)
            Text(result.confidenceLabel)
                .font(.caption).fontWeight(.semibold)
            Spacer()
            Text("\(Int(result.confidence * 100))% match")
                .font(.caption).foregroundColor(.stampMuted)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(result.confidenceColor.opacity(0.08))
    }
}

private struct StampResultCard: View {
    let stamp: Stamp

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Stamp image
                AsyncImage(url: stamp.primaryImageURL) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.stampCard)
                        .overlay(Image(systemName: "photo").foregroundColor(.stampMuted))
                }
                .frame(width: 100, height: 120)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text(stamp.displayName)
                        .font(.headline)
                        .lineLimit(3)

                    Label(stamp.issuer.name, systemImage: "flag")
                        .font(.caption)
                        .foregroundColor(.stampMuted)

                    Label(stamp.formattedDate, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.stampMuted)

                    Label(stamp.formattedDenomination, systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(.stampMuted)

                    if !stamp.colour.isEmpty {
                        Text(stamp.colour.joined(separator: ", ").capitalized)
                            .font(.caption)
                            .foregroundColor(.stampMuted)
                    }
                }
            }

            if let description = stamp.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.stampMuted)
                    .lineLimit(4)
            }

            Text(stamp.stampID)
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.stampGold.opacity(0.7))
        }
        .padding(16)
        .background(Color.stampCard)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.stampBorder))
    }
}

private struct ValuationRow: View {
    let valuation: StampValuation

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("MINT")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.stampMuted)
                Text(valuation.mintDisplayPrice)
                    .font(.title3).fontWeight(.bold).foregroundColor(.stampGold)
            }
            Spacer()
            VStack(alignment: .center, spacing: 4) {
                Text("USED")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.stampMuted)
                Text(valuation.usedDisplayPrice)
                    .font(.title3).fontWeight(.bold).foregroundColor(.stampGold)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("SOURCE")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.stampMuted)
                Text(valuation.sourceType == "auction_realised" ? "Auction" : "Catalogue")
                    .font(.caption).foregroundColor(.stampMuted)
            }
        }
        .padding(16)
        .background(Color.stampCard)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.stampBorder))
    }
}

private struct ProUpgradeTeaser: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .foregroundColor(.stampGold)
            VStack(alignment: .leading, spacing: 2) {
                Text("Unlock Valuations")
                    .font(.subheadline).fontWeight(.semibold)
                Text("See auction prices with Rowland Pro")
                    .font(.caption).foregroundColor(.stampMuted)
            }
            Spacer()
            Text("Pro")
                .font(.caption).fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.stampGold)
                .cornerRadius(6)
        }
        .padding(16)
        .background(Color.stampGold.opacity(0.06))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.stampGold.opacity(0.3)))
    }
}

private struct CatalogueRefsRow: View {
    let refs: [CatalogueRef]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CATALOGUE NUMBERS")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.stampMuted)
            FlowLayout(spacing: 8) {
                ForEach(refs) { ref in
                    HStack(spacing: 4) {
                        Text(ref.catalogueName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.stampMuted)
                        Text(ref.number)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.stampGold)
                        if ref.confirmed {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.stampCard)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.stampBorder))
                }
            }
        }
        .padding(16)
        .background(Color.stampCard)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.stampBorder))
    }
}

private struct AlternativeMatchesSection: View {
    let candidates: [(stamp: Stamp, score: Double)]
    let onSelect: (Stamp) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OTHER POSSIBLE MATCHES")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.stampMuted)
                .padding(.top, 8)

            ForEach(candidates.dropFirst(), id: \.stamp.id) { candidate in
                Button { onSelect(candidate.stamp) } label: {
                    HStack {
                        AsyncImage(url: candidate.stamp.thumbnailURL) { img in
                            img.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.stampCard
                        }
                        .frame(width: 44, height: 52)
                        .cornerRadius(4)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(candidate.stamp.displayName)
                                .font(.subheadline).foregroundColor(.text)
                                .lineLimit(2)
                            Text(candidate.stamp.issuer.name)
                                .font(.caption).foregroundColor(.stampMuted)
                        }
                        Spacer()
                        Text("\(Int(candidate.score * 100))%")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundColor(.stampMuted)
                    }
                    .padding(12)
                    .background(Color.stampCard)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.stampBorder))
                }
            }
        }
        .padding(.bottom, 32)
    }
}

// MARK: - Add to Collection Sheet

struct AddToCollectionSheet: View {
    let stamp: Stamp
    let onAdd: () -> Void
    @EnvironmentObject var appState: AppState
    @State private var condition: CollectionItem.Condition = .fine
    @State private var isUsed = false
    @State private var notes = ""
    @State private var isAdding = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Condition") {
                    Picker("Condition", selection: $condition) {
                        ForEach(CollectionItem.Condition.allCases, id: \.self) { c in
                            Text(c.displayName).tag(c)
                        }
                    }
                    .pickerStyle(.segmented)

                    Toggle("Used", isOn: $isUsed)
                }
                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onAdd() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            isAdding = true
                            // TODO: call appState.collectionStore.add(stamp, condition, isUsed, notes)
                            try? await Task.sleep(nanoseconds: 500_000_000) // simulated
                            onAdd()
                        }
                    }
                    .disabled(isAdding)
                }
            }
        }
    }
}
