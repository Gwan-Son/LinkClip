//
//  ColorPaletteView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/12/25.
//

import SwiftUI

struct ColorPaletteView: View {
    let colorPalette: [String] = [
        "FF6B6B", // 빨강
        "4ECDC4", // 청록
        "45B7D1", // 파랑
        "96CEB4", // 민트
        "FFEAA7", // 노랑
        "DDA0DD", // 자주
        "98D8C8", // 연두
        "F7DC6F", // 금색
        "BB8FCE", // 보라
        "85C1E9", // 하늘
        "F8C471", // 주황
        "82E0AA", // 라임
        "E74C3C", // 진한 빨강
        "3498DB", // 진한 파랑
        "2ECC71", // 초록
        "F39C12", // 주황
        "9B59B6", // 보라
        "1ABC9C", // 터키즈
        "E67E22", // 당근
        "34495E", // 검정에 가까운 파랑
        "95A5A6", // 회색
        "F1C40F", // 밝은 노랑
        "EC7063", // 연한 빨강
        "AED6F1", // 연한 파랑
    ]

    let columns = [GridItem(.adaptive(minimum: 50, maximum: 60), spacing: 12)]

    @Binding var selectedColor: String
    var onColorSelected: ((String) -> Void)?

    @State private var showCustomColorPicker: Bool = false
    @State private var customColor: Color = .blue

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("색상 선택")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                // 현재 선택된 색상 표시
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(hex: selectedColor))
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                    Text("#\(selectedColor)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .monospaced()
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: columns, spacing: 12) {
                    // 커스텀 색상 선택 (무지개색)
                    ColorCircle(
                        systemIcon: "paintpalette",
                        backgroundColor: Color(hex: selectedColor),
                        isSelected: !colorPalette.contains(selectedColor) && selectedColor != "",
                        showRainbow: true
                    ) {
                        showCustomColorPicker = true
                    }
                    .popover(isPresented: $showCustomColorPicker) {
                        VStack(spacing: 16) {
                            Text("커스텀 색상 선택")
                                .font(.headline)

                            ColorPicker("색상 선택", selection: $customColor)
                                .padding(.horizontal)

                            HStack {
                                Button("취소") {
                                    showCustomColorPicker = false
                                }
                                .foregroundColor(.secondary)

                                Spacer()

                                Button("확인") {
                                    let hexString = customColor.toHex()
                                    selectedColor = hexString ?? "FF6B6B"
                                    onColorSelected?(selectedColor)
                                    showCustomColorPicker = false
                                }
                                .fontWeight(.semibold)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                        .padding()
                        .frame(width: 280)
                        .presentationDetents([.height(200)])
                    }

                    // 미리 정의된 색상들
                    ForEach(colorPalette, id: \.self) { colorHex in
                        ColorCircle(
                            colorHex: colorHex,
                            isSelected: selectedColor == colorHex
                        ) {
                            selectedColor = colorHex
                            onColorSelected?(colorHex)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct ColorCircle: View {
    let colorHex: String?
    let systemIcon: String?
    let backgroundColor: Color?
    let isSelected: Bool
    let showRainbow: Bool
    let action: () -> Void

    // 기본 이니셜라이저 (색상 HEX 사용)
    init(colorHex: String, isSelected: Bool, action: @escaping () -> Void) {
        self.colorHex = colorHex
        self.systemIcon = nil
        self.backgroundColor = nil
        self.isSelected = isSelected
        self.showRainbow = false
        self.action = action
    }

    // 시스템 아이콘 사용 이니셜라이저
    init(systemIcon: String, backgroundColor: Color? = nil, isSelected: Bool, showRainbow: Bool = false, action: @escaping () -> Void) {
        self.colorHex = nil
        self.systemIcon = systemIcon
        self.backgroundColor = backgroundColor
        self.isSelected = isSelected
        self.showRainbow = showRainbow
        self.action = action
    }

    private var fillColor: Color {
        if let colorHex = colorHex {
            return Color(hex: colorHex)
        } else if let backgroundColor = backgroundColor {
            return backgroundColor
        } else {
            return Color.gray.opacity(0.3)
        }
    }

    private var rainbowGradient: some View {
        Circle()
            .fill(
                AngularGradient(
                    gradient: Gradient(colors: [
                        .red, .orange, .yellow, .green, .blue, .purple, .pink
                    ]),
                    center: .center
                )
            )
            .overlay(
                Circle()
                    .fill(Color.white.opacity(0.3))
            )
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                if showRainbow {
                    rainbowGradient
                        .frame(width: 45, height: 45)
                } else {
                    Circle()
                        .fill(fillColor)
                        .frame(width: 45, height: 45)
                }

                Circle()
                    .stroke(isSelected ? Color.white : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)

                if let systemIcon = systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 0)
                } else if isSelected && colorHex != nil {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 0)
                }
            }
            .frame(width: 45, height: 45)
            .shadow(color: isSelected ? fillColor.opacity(0.4) : Color.clear, radius: 4, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ColorPaletteView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ColorPaletteView(selectedColor: .constant("FF6B6B"))
            Spacer()
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

// MARK: - ColorCircle 미리보기
struct ColorCircle_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            VStack {
                Text("일반 색상").font(.caption)
                ColorCircle(colorHex: "FF6B6B", isSelected: false) {}
                ColorCircle(colorHex: "4ECDC4", isSelected: true) {}
            }

            VStack {
                Text("커스텀 색상").font(.caption)
                ColorCircle(systemIcon: "paintpalette", backgroundColor: .purple, isSelected: false, showRainbow: true) {}
                ColorCircle(systemIcon: "plus", isSelected: true) {}
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
