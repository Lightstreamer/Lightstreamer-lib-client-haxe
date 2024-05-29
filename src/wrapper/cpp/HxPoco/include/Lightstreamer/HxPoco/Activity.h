#ifndef INCLUDED_Lightstreamer_HxPoco_Activity
#define INCLUDED_Lightstreamer_HxPoco_Activity

#include "Poco/Foundation.h"
#include "Poco/Event.h"
#include "Poco/Mutex.h"

namespace Lightstreamer {
namespace HxPoco {

/// This class is an adaptation of Poco::Activity by Applied Informatics Software Engineering GmbH.
///
/// An activity is a (typically longer running) method
/// that executes within its own thread. Activities can
/// be started automatically (upon object construction)
/// or manually at a later time. Activities can also
/// be stopped at any time. However, to make stopping
/// an activity work, the method implementing the
/// activity has to check periodically whether it
/// has been requested to stop, and if so, return.
/// Activities are stopped before the object they belong to is
/// destroyed.
///
/// To implement an activity, the programmer needs to extend this class 
/// and provide implementations for the `submit` and `run` methods.
class Activity
{
protected:

  Activity() : 
    _stopped(true),
    _running(false),
    _done(Poco::Event::EVENT_MANUALRESET)
  {}
  Activity(const Activity&) = delete;
  Activity& operator = (const Activity&) = delete;

  ~Activity()
  {
    try
    {
      stop();
      wait();
    }
    catch (...)
    {
      poco_unexpected();
    }
  }

  /// The method ought to initiate a dedicated thread tasked with executing the `doSubmit` method. 
  virtual void submit() = 0;
  /// The `run` method actually performs the activity. It is called by the `doSubmit` method.
  virtual void run() = 0;

  /// Starts the activity.
  /// This method calls the virtual method `submit`.
  void start()
  {
    Poco::FastMutex::ScopedLock lock(_mutex);

    if (!_running)
    {
      _done.reset();
      _stopped = false;
      _running = true;
      try
      {
        submit();
      }
      catch (...)
      {
        _running = false;
        throw;
      }
    }
  }

  void doSubmit()
  {
    try
    {
      run();
    }
    catch (...)
    {
      _done.set();
      throw;
    }
    _done.set();
  }

  /// Requests to stop the activity.
  void stop()
  {
    _stopped = true;
  }

  /// Waits for the activity to complete.
  void wait()
  {
    if (_running)
    {
      _done.wait();
      _running = false;
    }
  }

	/// Returns true if the activity has been requested to stop.
  bool isStopped() const
	{
		return _stopped;
	}

	/// Returns true if the activity is running.
	bool isRunning() const
	{
		return _running;
	}

  std::atomic<bool>   _stopped;
	std::atomic<bool>   _running;
	Poco::Event         _done;
	Poco::FastMutex     _mutex;
};

}}
#endif