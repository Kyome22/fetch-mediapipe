enum MediaPipeTaskType: String, CustomStringConvertible {
    case common = "MediaPipeTasksCommon"
    case commonGroup = "MediaPipeTasksCommonGraph"
    case vision = "MediaPipeTasksVision"

    var description: String {
        rawValue
    }
}
