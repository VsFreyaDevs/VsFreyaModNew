package funkin.ui.debug.charting.util;

/**
 * A script that can be tied to a GenerateChartOperator.
 * Create a scripted class that extends GenerateChartOperator to use this.
 * then call `super('id', 'name')` in the constructor to use this.
 */
@:hscriptClass
class ScriptedGenerateChartOperator extends GenerateChartOperator implements polymod.hscript.HScriptedClass {}
