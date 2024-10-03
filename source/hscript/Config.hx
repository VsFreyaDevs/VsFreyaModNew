package hscript;

package hscript;

class Config
{
  // Runs support for custom classes in these.
  public static final ALLOWED_CUSTOM_CLASSES = ["flixel", "funkin"];
  // Runs support for abstract support in these.
  public static final ALLOWED_ABSTRACT_AND_ENUM = ["flixel", "funkin", "openfl.display.BlendMode"];

  public static final DISALLOW_CUSTOM_CLASSES = ["funkin.play.scoring.Scoring", "funkin.util.InputUtil"];
  public static final DISALLOW_ABSTRACT_AND_ENUM = ["funkin.play.scoring.Scoring", "funkin.util.InputUtil"];
}
