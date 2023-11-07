import Vapor

public struct HXResponseHeaders {
    var location: HXLocationHeader?
    var pushUrl: HXPushUrlHeader?
    var redirect: HXRedirectHeader?
    var refresh: HXRefreshHeader?
    var replaceUrl: HXReplaceUrlHeader?
    var reselect: HXReselectHeader?
    var reswap: HXReswapHeader?
    var retarget: HXRetargetHeader?
    var trigger: HXTriggerHeader?
    var triggerAfterSettle: HXTriggerAfterSettleHeader?
    var triggerAfterSwap: HXTriggerAfterSwapHeader?

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
