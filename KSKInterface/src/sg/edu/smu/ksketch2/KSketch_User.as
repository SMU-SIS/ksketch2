/**
 * Copyright 2010-2015 Singapore Management University
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
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