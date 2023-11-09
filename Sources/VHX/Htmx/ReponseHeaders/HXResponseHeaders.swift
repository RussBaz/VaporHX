import Vapor

public struct HXResponseHeaders {
    public var location: HXLocationHeader?
    public var pushUrl: HXPushUrlHeader?
    public var redirect: HXRedirectHeader?
    public var refresh: HXRefreshHeader?
    public var replaceUrl: HXReplaceUrlHeader?
    public var reselect: HXReselectHeader?
    public var reswap: HXReswapHeader?
    public var retarget: HXRetargetHeader?
    public var trigger: HXTriggerHeader?
    public var triggerAfterSettle: HXTriggerAfterSettleHeader?
    public var triggerAfterSwap: HXTriggerAfterSwapHeader?

    public func add(to resp: Response) {
        location.map { $0.add(to: resp) }
        pushUrl.map { $0.add(to: resp) }
        redirect.map { $0.add(to: resp) }
        refresh.map { $0.add(to: resp) }
        replaceUrl.map { $0.add(to: resp) }
        reselect.map { $0.add(to: resp) }
        reswap.map { $0.add(to: resp) }
        retarget.map { $0.add(to: resp) }
        trigger.map { $0.add(to: resp) }
        triggerAfterSettle.map { $0.add(to: resp) }
        triggerAfterSwap.map { $0.add(to: resp) }
    }
}
