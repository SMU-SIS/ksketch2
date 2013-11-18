package sg.edu.smu.ksketch2
{
	[Bindable]
	public class KSketch_User
	{
		//change to appropriate data types later
		public var status:String;
		public var u_realname:String;
		public var u_logincount:String;
		public var u_lastlogin:String;
		public var u_isadmin:String;
		public var id:String;
		public var g_hash:String;
		public var u_name:String;
		public var u_created:String;
		public var u_login:String;
		public var u_isactive:String;
		public var u_version:String;
		public var u_email:String;
		//{"status": "success", "u_realname": "Cammie Mo", "u_logincount": 10, "u_lastlogin": "07 Nov 2013 02:29:23", "u_isadmin": false, "id": 5444553947480064, 
		//"g_hash": "017aa2385f487263f51024a34656ada3", "u_name": "Cammie Mo", "u_created": "06 Nov 2013 09:09:37", "u_login": true, "u_isactive": true, "u_version": 1.0, "u_email": "mocammie@gmail.com"}

		
		public function KSketch_User(obj:Object)
		{
			if(obj.status.indexOf("success") >= 0)
			{
				this.status = obj.status;
				this.u_realname = obj.u_realname;
				this.u_logincount = obj.u_logincount;
				this.u_lastlogin = obj.u_lastlogin;
				this.u_isadmin = obj.u_isadmin;
				this.id = obj.id;
				this.g_hash = obj.g_hash;
				this.u_name = obj.u_name;
				this.u_created = obj.u_created;
				this.u_login = obj.u_login;
				this.u_isactive = obj.u_isactive;
				this.u_version = obj.u_version;
				this.u_email = obj.u_email;
			}
			else
			{
				this.status = obj.status;
				this.u_realname = "Anonymous";;
				this.u_logincount = "n.a";
				this.u_lastlogin = "n.a";
				this.u_isadmin = "n.a";
				this.id = "n.a";
				this.g_hash = "n.a";
				this.u_name = "Anonymous";;
				this.u_created = "n.a";
				this.u_login = obj.u_login;
				this.u_isactive = "n.a";
				this.u_version = "n.a";
				this.u_email = "n.a";
			}
		}	
		
	}
}