#include "../utils/shutdown_aware_messenger.h"

#include <cassert>
#include <iostream>
#include <memory>

using flutter_inappwebview_plugin::ShutdownAwareMessenger;

class TestMessenger : public flutter::BinaryMessenger {
public:
  mutable int sends = 0;
  int registrations = 0;
  flutter::BinaryMessageHandler handler;

  void Send(const std::string& channel, const uint8_t* message, size_t size,
    flutter::BinaryReply reply) const override
  {
    assert(channel == "test");
    assert(size == 1 && *message == 42);
    ++sends;
    if (reply) reply(message, size);
  }

  void SetMessageHandler(const std::string& channel,
    flutter::BinaryMessageHandler value) override
  {
    assert(channel == "test");
    ++registrations;
    handler = std::move(value);
  }
};

int main()
{
  auto engine = std::make_unique<TestMessenger>();
  ShutdownAwareMessenger messenger(engine.get());
  const uint8_t payload = 42;
  bool replied = false;
  messenger.Send("test", &payload, 1, [&](const uint8_t* data, size_t size) {
    replied = size == 1 && *data == payload;
  });
  assert(replied && engine->sends == 1);

  bool received = false;
  messenger.SetMessageHandler("test", [&](const uint8_t*, size_t, flutter::BinaryReply) {
    received = true;
  });
  assert(engine->registrations == 1 && engine->handler);
  engine->handler(nullptr, 0, nullptr);
  assert(received);
  messenger.SetMessageHandler("test", nullptr);
  assert(engine->registrations == 2 && !engine->handler);

  messenger.Shutdown();
  messenger.Shutdown(); // Repeated shutdown is harmless.
  messenger.SetMessageHandler("test", nullptr);
  messenger.SetMessageHandler("test", [](const uint8_t*, size_t, flutter::BinaryReply) {});
  messenger.Send("test", &payload, 1);
  assert(engine->registrations == 2 && engine->sends == 1);

  // Model nested channel destructors after the engine messenger is gone.
  engine.reset();
  messenger.SetMessageHandler("test", nullptr);
  messenger.Send("test", &payload, 1, [](const uint8_t*, size_t) {
    assert(false && "Shutdown must not invoke callbacks into disposed WebViews");
  });
  std::cout << "ShutdownAwareMessenger: all lifecycle checks passed" << std::endl;
}