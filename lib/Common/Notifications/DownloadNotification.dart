enum DownloadState {
  nope,
  waiting,
  downloading,
  downloaded,
  error,
}

class DownloadNotification {
  String id;
  DownloadState state;

  DownloadNotification(this.id, this.state);
}