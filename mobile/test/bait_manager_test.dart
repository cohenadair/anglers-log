import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockAppManager extends Mock implements AppManager {}
class MockDataManager extends Mock implements DataManager {}

void main() {
  MockAppManager appManager;
  MockDataManager dataManager;
  BaitManager baitManager;

  setUp(() async {
    appManager = MockAppManager();
    dataManager = MockDataManager();
    baitManager = BaitManager.get(appManager);

    when(appManager.dataManager).thenReturn(dataManager);
  });

  test("Bait exists", () {
    baitManager.baitExists(Bait(
      id: "bait_id",
      name: "Bait Name",
    ));
    List args = verify(dataManager.rawExists(captureAny, captureAny)).captured;

    expect(args[0], "SELECT COUNT(*) FROM bait "
        "WHERE category_id IS NULL "
        "AND name = ? "
        "AND color IS NULL "
        "AND model IS NULL "
        "AND type IS NULL "
        "AND min_dive_depth IS NULL "
        "AND max_dive_depth IS NULL "
        "AND id != ?"
    );
    expect(args[1], ["Bait Name", "bait_id"]);

    baitManager.baitExists(Bait(
      id: "bait_id",
      baitCategoryId: "bait_category_id",
      name: "Bait Name",
      color: "Green",
      model: "GX5",
      type: BaitType.live,
      minDiveDepth: 3.5,
      maxDiveDepth: 5.5,
    ));
    args = verify(dataManager.rawExists(captureAny, captureAny)).captured;

    expect(args[0], "SELECT COUNT(*) FROM bait "
        "WHERE category_id = ? "
        "AND name = ? "
        "AND color = ? "
        "AND model = ? "
        "AND type = ? "
        "AND min_dive_depth = ? "
        "AND max_dive_depth = ? "
        "AND id != ?"
    );
    expect(args[1], ["bait_category_id", "Bait Name", "Green", "GX5",
      BaitType.live, 3.5, 5.5, "bait_id"]);
  });
}