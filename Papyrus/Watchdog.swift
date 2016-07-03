import Foundation

@objc public class Watchdog: NSObject {
    
    /*
    The number of seconds that must pass to consider the main thread blocked
    */
    private var threshold: Double
    
    private var runLoop: CFRunLoop = CFRunLoopGetMain()
    private var observer: CFRunLoopObserver!
    private var startTime: UInt64 = 0
    private var handler: ((Double) -> ())? = nil
    
    public init(threshold: Double = 0.2, handler: ((Double) -> ())? = nil) {
        
        self.threshold = threshold
        self.handler = handler
        super.init()
        
        var timebase: mach_timebase_info_data_t = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&timebase)
        let secondsPerMachine: TimeInterval = TimeInterval(Double(timebase.numer) / Double(timebase.denom) / Double(1e9))
        
        observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault,
            CFRunLoopActivity.allActivities.rawValue,
            true,
            0) { [weak self] (observer, activity) in
                
                guard let weakSelf = self else {
                    return
                }
                
                switch(activity) {

                case CFRunLoopActivity.entry, CFRunLoopActivity.beforeTimers,
                CFRunLoopActivity.afterWaiting, CFRunLoopActivity.beforeSources:
                    
                    if weakSelf.startTime == 0 {
                        weakSelf.startTime = mach_absolute_time()
                    }
                    
                case CFRunLoopActivity.beforeWaiting, CFRunLoopActivity.exit:
                    
                    let elapsed = mach_absolute_time() - weakSelf.startTime
                    let duration: TimeInterval = TimeInterval(elapsed) * secondsPerMachine
                    
                    if duration > weakSelf.threshold {
                        if let handler = weakSelf.handler {
                            handler(duration)
                        } else {
                            print("👮 Main thread was blocked for " + String(format:"%.2f", duration) + "s 👮")
                        }
                    }
                    
                    weakSelf.startTime = 0
                    
                default: ()
                }
        }
        
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer!, CFRunLoopMode.commonModes)
    }
    
    deinit {
        CFRunLoopObserverInvalidate(observer!)
    }
}
