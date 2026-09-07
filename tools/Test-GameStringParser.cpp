#include "../src/red4ext/GameStringParser.hpp"
#include <array>
#include <cassert>
#include <string>
#include <cstring>

using namespace ModSettings::Interop;
struct Text {
  std::string value;
  const char* c_str() const { return value.c_str(); }
  uint32_t Length() const { return static_cast<uint32_t>(value.size()); }
};
struct FakeType { const uintptr_t* vtable; };
const char* expectedData;
uint32_t expectedSize;
bool Parse(const void*, void* out, const StringBuffer& text) {
  assert(text.data == expectedData);
  assert(text.size == expectedSize);
  assert(text.alignment == 8);
  assert(text.allocator[0] == 0 && text.allocator[1] == 0);
  *static_cast<int*>(out) = 17;
  return std::string(text.data, text.size) != "invalid";
}

int main() {
  std::array<uintptr_t, 15> vtable{};
  vtable[14] = reinterpret_cast<uintptr_t>(&Parse);
  FakeType type{vtable.data()};
  // Includes the actual crash-triggering short enum default and heap-sized text.
  for (auto value : {std::string("BufferSize.Auto"), std::string("auto"),
                     std::string(128, 'x'), std::string(""), std::string("invalid")}) {
    Text text{value};
    expectedData = text.c_str();
    expectedSize = text.Length();
    int output = 42;
    const bool success = ReadValue(&type, &output, text);
    assert(success == (value != "invalid"));
    assert(output == (success ? 17 : 42));
    assert(text.value == value); // Borrowed storage is intact.
  }
  int output = 42;
  assert(!FromString(nullptr, &output, "x", 1));
  assert(!FromString(&type, nullptr, "x", 1));
  assert(!FromString(&type, &output, nullptr, 0));
  vtable[14] = 0;
  assert(!FromString(&type, &output, "x", 1));
}
