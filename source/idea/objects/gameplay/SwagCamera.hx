package idea.objects.gameplay;

import flixel.FlxSprite;
import flixel.FlxG;
import openfl.geom.Matrix;
import flixel.math.FlxPoint;
import flixel.FlxCamera;

class SwagCamera extends FlxCamera {
	public var rotationOffset(default, set):FlxPoint = new FlxPoint(0.5, 0.5);
	var viewOffset:FlxPoint = FlxPoint.get();

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		fixRotatedView();
	}

	inline function set_rotationOffset(newValue:FlxPoint):FlxPoint {
		rotationOffset = newValue;
		fixRotatedView();
		return newValue;
	}

	public function fixRotatedView() {
		if (!ClientPrefs.data.lowQuality) {
			flashSprite.x -= _flashOffset.x;
			flashSprite.y -= _flashOffset.y;
			
			var matrix:Matrix = new Matrix();
			// matrix.concat(canvas.transform.matrix); // DON'T EVEN THINK ABOUT IT.
			matrix.translate(-width * rotationOffset.x, -height * rotationOffset.y);
			matrix.scale(scaleX, scaleY);
			matrix.rotate(angle * (Math.PI / 180));
			matrix.translate(width * rotationOffset.x, height * rotationOffset.y);
			matrix.translate(flashSprite.x, flashSprite.y);
			matrix.scale(FlxG.scaleMode.scale.x, FlxG.scaleMode.scale.y);
			canvas.transform.matrix = matrix;

			flashSprite.x = width * 0.5 * FlxG.scaleMode.scale.x;
			flashSprite.y = height * 0.5 * FlxG.scaleMode.scale.y;
			flashSprite.rotation = 0;
		}
	}

	override public function updateFollow():Void
	{
		// Either follow the object closely,
		// or double check our deadzone and update accordingly.
		if (deadzone == null)
		{
			target.getMidpoint(_point);
			_point.addPoint(targetOffset);
			focusOn(_point);
		}
		else
		{
			var edge:Float;
			var targetX:Float = target.x + targetOffset.x;
			var targetY:Float = target.y + targetOffset.y;

			if (style == SCREEN_BY_SCREEN)
			{
				if (targetX >= (scroll.x + width))
				{
					_scrollTarget.x += width;
				}
				else if (targetX < scroll.x)
				{
					_scrollTarget.x -= width;
				}

				if (targetY >= (scroll.y + height))
				{
					_scrollTarget.y += height;
				}
				else if (targetY < scroll.y)
				{
					_scrollTarget.y -= height;
				}
			}
			else
			{
				edge = targetX - deadzone.x;
				if (_scrollTarget.x > edge)
				{
					_scrollTarget.x = edge;
				}
				edge = targetX + target.width - deadzone.x - deadzone.width;
				if (_scrollTarget.x < edge)
				{
					_scrollTarget.x = edge;
				}

				edge = targetY - deadzone.y;
				if (_scrollTarget.y > edge)
				{
					_scrollTarget.y = edge;
				}
				edge = targetY + target.height - deadzone.y - deadzone.height;
				if (_scrollTarget.y < edge)
				{
					_scrollTarget.y = edge;
				}
			}

			if ((target is FlxSprite))
			{
				if (_lastTargetPosition == null)
				{
					_lastTargetPosition = FlxPoint.get(target.x, target.y); // Creates this point.
				}
				_scrollTarget.x += (target.x - _lastTargetPosition.x) * followLead.x;
				_scrollTarget.y += (target.y - _lastTargetPosition.y) * followLead.y;

				_lastTargetPosition.x = target.x;
				_lastTargetPosition.y = target.y;
			}

			if (followLerp >= 60 / FlxG.updateFramerate)
			{
				scroll.copyFrom(_scrollTarget); // no easing
			}
			else
			{
				// THIS THE PART THAT ACTUALLY MATTERS LOL
				scroll.x += (_scrollTarget.x - scroll.x) * camLerpShit(followLerp);
				scroll.y += (_scrollTarget.y - scroll.y) * camLerpShit(followLerp);
			}
		}
	}

	public static function camLerpShit(lerp:Float):Float
	{
		return lerp * (FlxG.elapsed / (1 / 60));
	}
}