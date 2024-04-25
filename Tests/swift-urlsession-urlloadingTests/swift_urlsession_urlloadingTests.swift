import XCTest
@testable import swift_urlsession_urlloading

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class TestURLProtocol: URLProtocol {
    static var canInitRequest: (() -> Void)?
    static var canInitTask: (() -> Void)?

    override class func canInit(with request: URLRequest) -> Bool {
        canInitRequest?()
        return true
    }

    override class func canInit(with task: URLSessionTask) -> Bool {
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
    override func setUp() {
        let registered = URLProtocol.registerClass(TestURLProtocol.self)
        XCTAssertTrue(registered)
    }

    override func tearDown() {
        TestURLProtocol.canInitRequest = nil
        TestURLProtocol.canInitTask = nil

        URLProtocol.unregisterClass(TestURLProtocol.self)

        print("Cleaning up!")
    }

    func testProtocolIsCalled_defaultSession() throws {
        let request = URLRequest(url: try XCTUnwrap(URL(string: "https://arc.net")))
        let task = URLSession.shared.dataTask(with: request)

        let expectation = expectation(description: "did call protocol init")
        expectation.assertForOverFulfill = false

        let callback = {
            DispatchQueue.main.sync {
                expectation.fulfill()
            }
        }

        TestURLProtocol.canInitRequest = callback

        task.resume()

        wait(for: [expectation], timeout: 0.5)
    }

    func testProtocolIsCalled_nonDefaultSession_defaultConfiguration() throws {
        let request = URLRequest(url: try XCTUnwrap(URL(string: "https://arc.net")))
        let configuration = URLSessionConfiguration.default
        let task = URLSession(configuration: configuration).dataTask(with: request)

        let expectation = expectation(description: "did call protocol init")
        expectation.assertForOverFulfill = false

        let callback = {
            DispatchQueue.main.sync {
                expectation.fulfill()
            }
        }

        TestURLProtocol.canInitRequest = callback

        task.resume()

        wait(for: [expectation], timeout: 0.5)
    }

    func testProtocolIsCalled_nonDefaultSession_ephemeralConfiguration() throws {
        let request = URLRequest(url: try XCTUnwrap(URL(string: "https://arc.net")))
        let configuration = URLSessionConfiguration.ephemeral
        let task = URLSession(configuration: configuration).dataTask(with: request)

        let expectation = expectation(description: "did call protocol init")
        expectation.assertForOverFulfill = false

        let callback = {
            DispatchQueue.main.sync {
                expectation.fulfill()
            }
        }

        TestURLProtocol.canInitRequest = callback

        task.resume()

        wait(for: [expectation], timeout: 0.5)
    }
}
