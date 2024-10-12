package funkin.ui.debug.charting.util;

/**
 * A script that can be tied to a GenerateDifficultyOperator.
 * Create a scripted class that extends GenerateDifficultyOperator to use this.
 * then call `super('id', 'name')` in the constructor to use this.
 */
@:hscriptClass
class ScriptedGenerateDifficultyOperator extends GenerateDifficultyOperator implements polymod.hscript.HScriptedClass {}
