// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import SwiftUI
import Shared

struct CreditCardSettingsEmptyView: View {
    @Environment(\.themeType) private var themeVal

    @State private var titleTextColor: Color = .clear
    @State private var subTextColor: Color = .clear
    @State private var toggleTextColor: Color = .clear

    @ObservedObject var toggleModel: ToggleModel

    var body: some View {
        ZStack {
            UIColor.clear.color
                .edgesIgnoringSafeArea(.all)
            GeometryReader { proxy in
                ScrollView {
                    VStack {
                        CreditCardAutofillToggle(
                            textColor: toggleTextColor,
                            model: toggleModel)
                        Spacer()
                        Image(ImageIdentifiers.creditCardPlaceholder)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .aspectRatio(contentMode: .fit)
                            .fixedSize()
                            .padding([.top], 10)
                            .accessibility(hidden: true)
                        Text(String.CreditCard.Settings.EmptyListTitle)
                            .preferredBodyFont(size: 22)
                            .foregroundColor(titleTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                        Text(String.CreditCard.Settings.EmptyListDescription)
                            .preferredBodyFont(size: 16)
                            .foregroundColor(subTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding([.top], -5)
                        Spacer()
                    }
                    .onAppear(perform: {
                        applyTheme(theme: themeVal.theme)
                    })
                    .onChange(of: themeVal, perform: { updatedTheme in
                        applyTheme(theme: updatedTheme.theme)
                    })
                    .frame(minHeight: proxy.size.height)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

extension CreditCardSettingsEmptyView: ThemeApplicable {
    func applyTheme(theme: Shared.Theme) {
        let color = theme.colors
        titleTextColor = Color(color.textPrimary)
        subTextColor = Color(color.textSecondary)
        toggleTextColor = Color(color.actionPrimary)
    }
}

struct CreditCardSettingsEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        let toggleModel = ToggleModel(isEnabled: true)
        CreditCardSettingsEmptyView(toggleModel: toggleModel)
    }
}
