package funkin.data.charting;

import funkin.data.BaseClassRegistry;
import funkin.ui.debug.charting.util.GenerateChartOperator;

@:build(funkin.util.macro.ClassRegistryMacro.build())
class GenerateChartOperatorRegistry extends BaseClassRegistry<GenerateChartOperator>
{
  public function new()
  {
    super('generateChartOperatorRegistry');
  }
}
