package sg.edu.smu.ksketch.model.geom
{
	public class K3DVector
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public function K3DVector(givenX:Number=0, givenY:Number=0, givenZ:Number=0)
		{
			x = givenX;
			y = givenY;
			z = givenZ;
		}
		
		public function clone():K3DVector
		{
			return new K3DVector(x,y,z);
		}
	}
}