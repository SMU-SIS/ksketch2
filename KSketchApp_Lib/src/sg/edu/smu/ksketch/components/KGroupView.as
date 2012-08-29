package sg.edu.smu.ksketch.components
{	
	import sg.edu.smu.ksketch.model.KGroup;
	import sg.edu.smu.ksketch.utilities.KAppState;
	
	public class KGroupView extends KObjectView
	{
		public function KGroupView(appState:KAppState, group:KGroup)
		{
			super(appState,group);
			this.mouseEnabled = false;
			updateVisibility(group.getVisibility(time));
			updateTransform(group.getFullMatrix(group.createdTime));
		}		
	}
}