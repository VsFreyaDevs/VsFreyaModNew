package funkin.ui.debug.charting.components;

import funkin.ui.debug.charting.ChartEditorState;
import funkin.ui.debug.charting.util.ChartEditorDropdowns;
import funkin.ui.debug.charting.util.GenerateDifficultyOperator;
import funkin.data.charting.GenerateDifficultyOperatorRegistry;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;
import haxe.ui.containers.ScrollView;

/**
 * The component which contains the difficulty data item for the difficulty generator.
 * This is in a separate component so it can be positioned independently.
 */
@:build(haxe.ui.ComponentBuilder.build("assets/exclude/data/ui/chart-editor/components/difficulty-item.xml"))
@:access(funkin.ui.debug.charting.ChartEditorState)
class ChartEditorDifficultyItem extends HBox
{
  public var algorithm(default, null):GenerateDifficultyOperator;

  var view:ScrollView;

  public function new(state:ChartEditorState, view:ScrollView)
  {
    super();

    this.view = view;

    createButton.onClick = function(_) {
      plusBox.hidden = true;
      difficultyFrame.hidden = false;
      this.view.addComponent(new ChartEditorDifficultyItem(state, this.view));
    }

    destroyButton.onClick = function(_) {
      plusBox.hidden = false;
      difficultyFrame.hidden = true;
      this.view.removeComponent(this);
    }

    difficultyDropdown.dataSource.clear();
    for (difficulty in state.availableDifficulties)
    {
      if (difficulty == state.selectedDifficulty)
      {
        continue;
      }
      difficultyDropdown.dataSource.add({text: difficulty.toTitleCase(), value: difficulty});
    }
    difficultyDropdown.value = difficultyDropdown.dataSource.get(0);

    ChartEditorDropdowns.populateDropdownWithGenerateDifficultyOperators(algorithmDropdown, 'defaultOperator');
    algorithmDropdown.onChange = function(_) {
      algorithmBox.removeComponentAt(0);
      buildAlgorithmParams();
    }
    buildAlgorithmParams();
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (difficultyDropdown.value != null)
    {
      difficultyFrame.text = difficultyDropdown.value.text;
    }
    else
    {
      difficultyFrame.text = "Difficulty";
    }
  }

  function buildAlgorithmParams():Void
  {
    var vbox:VBox = new VBox();
    vbox.percentWidth = 100;

    algorithm?.destroy();
    algorithm = GenerateDifficultyOperatorRegistry.instance.createInstanceOf(algorithmDropdown.value.id);
    algorithm?.buildUI(vbox);

    algorithmBox.addComponent(vbox);
  }
}
