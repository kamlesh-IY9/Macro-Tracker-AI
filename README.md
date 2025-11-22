# MacroMate 🥑

**MacroMate** is a premium, AI-powered macro tracking application built with Flutter. It helps users track their nutrition, weight, and habits with a sleek, dark-mode interface.

## 🚀 Features

*   **AI Food Logging**: Snap a photo or type a description (e.g., "Oatmeal with blueberries") to get instant macro analysis using Google Gemini.
*   **Smart Dashboard**: Real-time tracking of Calories, Protein, Carbs, and Fat against your TDEE targets.
*   **Weight Tracker**: Log your weight and visualize trends over time.
*   **Meal Planner**: Plan your weekly meals (Breakfast, Lunch, Dinner, Snack).
*   **Shopping List**: Automatically generate a checklist of ingredients from your meal plan.
*   **Habit Tracking**: Track daily water intake with quick-add buttons.
*   **AI Coach**: Chat with an AI nutritionist for personalized advice.
*   **Barcode Scanner**: Scan food packages for quick logging (Mobile only).

## 🛠️ Tech Stack

*   **Framework**: Flutter (Dart)
*   **State Management**: Riverpod
*   **AI**: Google Gemini API (`google_generative_ai`)
*   **Charts**: `fl_chart`
*   **Storage**: `shared_preferences` (Local persistence)
*   **Navigation**: `go_router` (Planned/Partial)

## 📦 Installation

1.  **Prerequisites**: Ensure you have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
2.  **Clone/Download**: Get the source code.
3.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run the App**:
    ```bash
    flutter run
    ```
    *   Supports: Windows, Android, iOS, macOS, Linux, Web.

## 🔑 Configuration

To enable AI features, you need a Google Gemini API Key.

1.  Get a key from [Google AI Studio](https://aistudio.google.com/).
2.  Open the app and go to **Settings**.
3.  Enter your API Key and save.

## 📱 Screenshots

*(Add screenshots here)*

## 🤝 Contributing

Feel free to fork and submit Pull Requests!

## 📄 License

MIT License
