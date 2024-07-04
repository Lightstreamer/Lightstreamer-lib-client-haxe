#include <mutex>
#include <condition_variable>

class Semaphore {
  std::mutex mutex_;
  std::condition_variable condition_;
  unsigned long count_ = 0; // Initialized as locked.

public:
  Semaphore() {}
  Semaphore(const Semaphore&) = delete;
  Semaphore(Semaphore&&) = delete;
  Semaphore& operator=(const Semaphore&) = delete;
  Semaphore& operator=(Semaphore&&) = delete;

  void set() {
    std::lock_guard<decltype(mutex_)> lock(mutex_);
    ++count_;
    condition_.notify_one();
  }

  void wait() {
    std::unique_lock<decltype(mutex_)> lock(mutex_);
    while(!count_) // Handle spurious wake-ups.
        condition_.wait(lock);
    --count_;
  }

  void wait(long ms) {
    std::unique_lock<decltype(mutex_)> lock(mutex_);
    auto now = std::chrono::system_clock::now();
    auto timeout_time = now + std::chrono::milliseconds(ms);
    while(!count_) // Handle spurious wake-ups.
      if (condition_.wait_until(lock, timeout_time) == std::cv_status::timeout)
        throw std::runtime_error("TimeoutException");
    --count_;
  }
};