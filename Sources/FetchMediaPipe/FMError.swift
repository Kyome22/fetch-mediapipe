public enum FMError: Error {
    case failedToFetchPodArchive
    case failedToCopyStaticLibraries
    case failedToCopyXCFramework(name: String)
    case notFoundIntoPlist
    case failedToDeleteDerivedData
    case failedToBuildFramework(tag: String)
    case failedToMoveXCFramework
}
