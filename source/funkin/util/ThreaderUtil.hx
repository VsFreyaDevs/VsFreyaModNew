package funkin.util;

import sys.thread.Lock;
import sys.thread.Thread;

class ThreaderUtil
{
  private static var threads:Int = 0;
  private static var lock:Lock = new Lock();

  public static function create(job:() -> Void):Thread
  {
    #if (target.threaded)
    var thread = Thread.create(() -> {
      job();
      lock.release();
    });
    threads++;
    return thread;
    #end job();
    return null;
  }

  public static function wait()
  {
    while (threads > 0)
    {
      lock.wait();
      threads--;
    }
  }
}
