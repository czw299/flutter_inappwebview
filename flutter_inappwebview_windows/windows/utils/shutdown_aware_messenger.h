#pragma once

#include <flutter/binary_messenger.h>
#include <utility>

namespace flutter_inappwebview_plugin
{
  // Used on the platform thread, like the plugin's channels and teardown.
  // Must outlive every channel created by the plugin.
  class ShutdownAwareMessenger : public flutter::BinaryMessenger {
  public:
    explicit ShutdownAwareMessenger(flutter::BinaryMessenger* messenger)
      : messenger_(messenger) {}

    // Registrar destruction may run after the engine stopped accepting channel
    // registrations. Do not call into it, even to unregister a handler.
    void Shutdown() { messenger_ = nullptr; }

    void Send(const std::string& channel, const uint8_t* message,
      size_t message_size, flutter::BinaryReply reply = nullptr) const override
    {
      if (messenger_) {
        messenger_->Send(channel, message, message_size, std::move(reply));
      }
    }

    void SetMessageHandler(const std::string& channel,
      flutter::BinaryMessageHandler handler) override
    {
      if (messenger_) {
        messenger_->SetMessageHandler(channel, std::move(handler));
      }
    }

  private:
    flutter::BinaryMessenger* messenger_;
  };
}