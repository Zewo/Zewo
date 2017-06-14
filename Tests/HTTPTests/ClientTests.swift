import XCTest
import Media
import HTTP

let jsonCoder = JSONCoder(fieldNamingPolicy: .snakeCase)
let defaultCoders = Coders(jsonCoder)

struct Resources : Renderable {
    static var coders: Coders = defaultCoders
    
    let currentUserURL: String
    let currentUserAuthorizationsHtmlURL: String
    let authorizationsURL: String
    let codeSearchURL: String
    let commitSearchURL: String
    let emailsURL: String
    let emojisURL: String
    let eventsURL: String
    let feedsURL: String
    let followersURL: String
    let followingURL: String
    let gistsURL: String
    let hubURL: String
    let issueSearchURL: String
    let issuesURL: String
    let keysURL: String
    let notificationsURL: String
    let organizationRepositoriesURL: String
    let organizationURL: String
    let publicGistsURL: String
    let rateLimitURL: String
    let repositoryURL: String
    let currentUserRepositoriesURL: String
    let starredURL: String
    let starredGistsURL: String
    let teamURL: String
    let userURL: String
    let userOrganizationsURL: String
    let userRepositoriesURL: String
    let userSearchURL: String
}

public class ClientTests: XCTestCase {
    func testClient() throws {
        do {
            let client = try Client(uri: "https://api.github.com")
            let request = try Request(method: .get, uri: "/")
            let response = try client.send(request)
            let resources: Resources = try response.content()
            
            XCTAssertEqual(resources.currentUserURL, "https://api.github.com/user")
            XCTAssertEqual(resources.currentUserAuthorizationsHtmlURL, "https://github.com/settings/connections/applications{/client_id}")
            XCTAssertEqual(resources.authorizationsURL, "https://api.github.com/authorizations")
            XCTAssertEqual(resources.codeSearchURL, "https://api.github.com/search/code?q={query}{&page,per_page,sort,order}")
            XCTAssertEqual(resources.commitSearchURL, "https://api.github.com/search/commits?q={query}{&page,per_page,sort,order}")
            XCTAssertEqual(resources.emailsURL, "https://api.github.com/user/emails")
            XCTAssertEqual(resources.emojisURL, "https://api.github.com/emojis")
            XCTAssertEqual(resources.eventsURL, "https://api.github.com/events")
            XCTAssertEqual(resources.feedsURL, "https://api.github.com/feeds")
            XCTAssertEqual(resources.followersURL, "https://api.github.com/user/followers")
            XCTAssertEqual(resources.followingURL, "https://api.github.com/user/following{/target}")
            XCTAssertEqual(resources.gistsURL, "https://api.github.com/gists{/gist_id}")
            XCTAssertEqual(resources.hubURL, "https://api.github.com/hub")
            XCTAssertEqual(resources.issueSearchURL, "https://api.github.com/search/issues?q={query}{&page,per_page,sort,order}")
            XCTAssertEqual(resources.issuesURL, "https://api.github.com/issues")
            XCTAssertEqual(resources.keysURL, "https://api.github.com/user/keys")
            XCTAssertEqual(resources.notificationsURL, "https://api.github.com/notifications")
            XCTAssertEqual(resources.organizationRepositoriesURL, "https://api.github.com/orgs/{org}/repos{?type,page,per_page,sort}")
            XCTAssertEqual(resources.organizationURL, "https://api.github.com/orgs/{org}")
            XCTAssertEqual(resources.publicGistsURL, "https://api.github.com/gists/public")
            XCTAssertEqual(resources.rateLimitURL, "https://api.github.com/rate_limit")
            XCTAssertEqual(resources.repositoryURL, "https://api.github.com/repos/{owner}/{repo}")
            XCTAssertEqual(resources.currentUserRepositoriesURL, "https://api.github.com/user/repos{?type,page,per_page,sort}")
            XCTAssertEqual(resources.starredURL, "https://api.github.com/user/starred{/owner}{/repo}")
            XCTAssertEqual(resources.starredGistsURL, "https://api.github.com/gists/starred")
            XCTAssertEqual(resources.teamURL, "https://api.github.com/teams")
            XCTAssertEqual(resources.userURL, "https://api.github.com/users/{user}")
            XCTAssertEqual(resources.userOrganizationsURL, "https://api.github.com/user/orgs")
            XCTAssertEqual(resources.userRepositoriesURL, "https://api.github.com/users/{user}/repos{?type,page,per_page,sort}")
            XCTAssertEqual(resources.userSearchURL, "https://api.github.com/search/users?q={query}{&page,per_page,sort,order}")
        } catch {
            print(error)
        }
    }
}

extension ClientTests {
    public static var allTests: [(String, (ClientTests) -> () throws -> Void)] {
        return [
            ("testClient", testClient),
        ]
    }
}
