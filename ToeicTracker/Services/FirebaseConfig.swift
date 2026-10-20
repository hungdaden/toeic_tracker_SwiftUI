import Foundation

public struct FirebaseConfig {
    public static let shared = FirebaseConfig()

    public let projectId: String
    public let apiKey: String
    public let storageBucket: String
    public let clientId: String
    public let googleAppId: String

    private init() {
        var pId = "toeic-tracker-52828"
        var aKey = "AIzaSyDkk1fGvIf8FWSEYBlemQlsTQ6PuFzIy0w"
        var sBucket = "toeic-tracker-52828.firebasestorage.app"
        var cId = "865926846836-ol3m9s3605b02gt5tp3vdha4fainndtm.apps.googleusercontent.com"
        var appId = "1:865926846836:ios:8aa7a6acc1fa68f001b421"

        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let val = dict["PROJECT_ID"] as? String { pId = val }
            if let val = dict["API_KEY"] as? String { aKey = val }
            if let val = dict["STORAGE_BUCKET"] as? String { sBucket = val }
            if let val = dict["CLIENT_ID"] as? String { cId = val }
            if let val = dict["GOOGLE_APP_ID"] as? String { appId = val }
        }

        self.projectId = pId
        self.apiKey = aKey
        self.storageBucket = sBucket
        self.clientId = cId
        self.googleAppId = appId
    }

    public var firestoreBaseURL: String {
        "https://firestore.googleapis.com/v1/projects/\(projectId)/databases/(default)/documents"
    }

    public var authBaseURL: String {
        "https://identitytoolkit.googleapis.com/v1"
    }
}
