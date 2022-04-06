import 'package:holomusic/Common/Player/Song.dart';
import 'package:holomusic/Common/Player/SongStateManager.dart';
import 'package:test/test.dart';

void main() {
  group('SongState manager:', () {
    test("Check song state", () async {
      SongStateManager.init();
      const songId = "123";
      SongStateManager.setSongState(songId, SongState.downloading);
      final state = SongStateManager.getSongState(songId);
      expect(state.value,SongState.downloading);
      SongStateManager.setSongState(songId, SongState.offline);
      expect(SongStateManager.getSongState(songId).value,SongState.offline);
      SongStateManager.dismiss();
    });
    test("Check uninitialized state", () async {
      SongStateManager.init();
      expect(SongStateManager.getSongState("123").value,SongState.online);
      SongStateManager.dismiss();
    });
  });
}