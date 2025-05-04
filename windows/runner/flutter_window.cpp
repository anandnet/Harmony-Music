#include "flutter_window.h"

#include <dwmapi.h>
#include <windowsx.h>

#include <flutter/standard_method_codec.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/encodable_value.h>

#include <memory>
#include <optional>
#include <map>
#include <string>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  // platform channel for titlebar color
  auto messenger = flutter_controller_->engine()->messenger();
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger,
      "win_titlebar_color",
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [hwnd = GetHandle()](const flutter::MethodCall<flutter::EncodableValue>& call,
                           std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "setTitleBarColor") {
          const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
          if (!args) {
            result->Error("INVALID_ARGUMENTS", "Expected map with RGB values");
            return;
          }

          int r = std::get<int>(args->at(flutter::EncodableValue("r")));
          int g = std::get<int>(args->at(flutter::EncodableValue("g")));
          int b = std::get<int>(args->at(flutter::EncodableValue("b")));
          COLORREF color = RGB(r, g, b);

          // 35 is DWMWA_CAPTION_COLOR in recent Windows 10+ SDKs
          HRESULT hr = DwmSetWindowAttribute(hwnd, 35, &color, sizeof(color));
          if (SUCCEEDED(hr)) {
            result->Success();
          } else {
            result->Error("DWM_ERROR", "Failed to set title bar color");
          }
        } else {
          result->NotImplemented();
        }
      });

  method_channel_ = std::move(channel);

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
