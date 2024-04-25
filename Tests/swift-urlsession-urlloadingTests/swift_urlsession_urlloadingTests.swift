import XCTest
@testable import swift_urlsession_urlloading

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class TestURLProtocol: URLProtocol {
    static var canInitRequest: (() -> Void)?
    static var canInitTask: (() -> Void)?

    override class func canInit(with request: URLRequest) -> Bool {
        print(">>>> canInitRequest: \(String(describing: request.url))")
        canInitRequest?()
        return true
    }

    override class func canInit(with task: URLSessionTask) -> Bool {
        print(">>>> canInitTask: \(String(describing: task.originalRequest?.url))")
        canInitTask?()
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        stopLoading()
    }

    override func stopLoading() {
    }
}

final class swift_urlsession_urlloadingTests: XCTestCase {
    private enum Constants {
        static let expectationTimeout: TimeInterval = 1.0
    }

    override func setUp() {
        let registered = URLProtocol.registerClass(TestURLProtocol.self)
        XCTAssertTrue(registered)
    }

    override func tearDown() {
        TestURLProtocol.canInitRequest = nil
        TestURLProtocol.canInitTask = nil

        URLProtocol.unregisterClass(TestURLProtocol.self)
    }

    func testProtocolIsCalled_defaultSession() throws {
        let request = URLRequest(url: try XCTUnwrap(URL(string: "https://default-session.net")))
        let task = URLSession.shared.dataTask(with: request)

        let expectation = expectation(description: "defaultSession")
        expectation.assertForOverFulfill = false

        let callback = {
            expectation.fulfillOnMainThread()
        }

        TestURLProtocol.canInitRequest = callback

        task.resume()

        wait(for: [expectation], timeout: Constants.expectationTimeout)
    }

    func testProtocolIsCalled_nonDefaultSession_defaultConfiguration() throws {
        let request = URLRequest(url: try XCTUnwrap(URL(string: "https://non-default-session-default-configuration.net")))
        let configuration = URLSessionConfiguration.default
        let task = URLSession(configuration: configuration).dataTask(with: request)

        let expectation = expectation(description: "defaultSession - ephemeral configuration expectation")
        expectation.assertForOverFulfill = false

        let callback = {
            expectation.fulfillOnMainThread()
        }

        TestURLProtocol.canInitRequest = callback

        task.resume()

        wait(for: [expectation], timeout: Constants.expectationTimeout)
    }

    func testProtocolIsCalled_nonDefaultSession_ephemeralConfiguration() throws {
        let request = URLRequest(url: try XCTUnwrap(URL(string: "https://non-default-session-ephemeral-configuration.net")))
        let configuration = URLSessionConfiguration.ephemeral
        let task = URLSession(configuration: configuration).dataTask(with: request)

        let expectation = expectation(description: "nonDefaultSession - ephemeral configuration expectation")
        expectation.assertForOverFulfill = false

        let callback = {
            expectation.fulfillOnMainThread()
        }

        TestURLProtocol.canInitRequest = callback

        task.resume()

        wait(for: [expectation], timeout: Constants.expectationTimeout)
    }
}

extension XCTestExpectation {
    func fulfillOnMainThread() {
        if Thread.isMainThread {
            fulfill()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.fulfill()
            }
        }
    }
}
