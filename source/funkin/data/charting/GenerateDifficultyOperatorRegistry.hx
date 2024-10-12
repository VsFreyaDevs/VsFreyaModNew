package funkin.data.charting;

import funkin.data.BaseClassRegistry;
import funkin.ui.debug.charting.util.GenerateDifficultyOperator;

@:build(funkin.util.macro.ClassRegistryMacro.build())
class GenerateDifficultyOperatorRegistry extends BaseClassRegistry<GenerateDifficultyOperator>
{
  public function new()
  {
    super('generateDifficultyOperatorRegistry');
  }
}
