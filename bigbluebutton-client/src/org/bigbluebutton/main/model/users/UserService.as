package org.bigbluebutton.main.model.users
{
	import com.asfusion.mate.events.Dispatcher;
	
	import flash.net.NetConnection;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import org.bigbluebutton.main.events.SuccessfulLoginEvent;
	import org.bigbluebutton.main.events.UserServicesEvent;
	import org.bigbluebutton.main.model.ConferenceParameters;
	import org.bigbluebutton.main.model.users.events.BroadcastStartedEvent;
	import org.bigbluebutton.main.model.users.events.BroadcastStoppedEvent;
	import org.bigbluebutton.main.model.users.events.ConferenceCreatedEvent;
	import org.bigbluebutton.main.model.users.events.KickUserEvent;
	import org.bigbluebutton.main.model.users.events.LowerHandEvent;
	import org.bigbluebutton.main.model.users.events.RaiseHandEvent;
	import org.bigbluebutton.main.model.users.events.UsersConnectionEvent;

	public class UserService
	{
		private var joinService:JoinService;
		private var _conference:Conference;
		private var _userSOService:UsersSOService;
		private var _conferenceParameters:ConferenceParameters;
		
		private var applicationURI:String;
		private var hostURI:String;
		
		private var connection:NetConnection;
		private var userId:Number;
		
		private var dispatcher:Dispatcher;
		
		public function UserService()
		{
			dispatcher = new Dispatcher();
		}
		
		public function startService(e:UserServicesEvent):void
		{
			applicationURI = e.applicationURI;
			hostURI = e.hostURI;
			
			joinService = new JoinService();
			joinService.addJoinResultListener(joinListener);
			joinService.load(e.hostURI);
		}
		
		private function joinListener(success:Boolean, result:Object):void
		{
			if (success)
			{
				_conference = new Conference();
				_conference.me.name = result.username;
				_conference.me.role = result.role;
				_conference.me.room = result.room;
				_conference.me.authToken = result.authToken;
				
				_conferenceParameters = new ConferenceParameters();
				_conferenceParameters.conference = result.conference;
				_conferenceParameters.username = _conference.me.name;
				_conferenceParameters.role = _conference.me.role;
				_conferenceParameters.room = _conference.me.room;
				_conferenceParameters.authToken = _conference.me.authToken;
				_conferenceParameters.mode = result.mode;
				_conferenceParameters.webvoiceconf = result.webvoiceconf;
				_conferenceParameters.voicebridge = result.voicebridge;
				_conferenceParameters.conferenceName = result.conferenceName;
				_conferenceParameters.welcome = result.welcome;
				_conferenceParameters.meetingID = result.meetingID;
				_conferenceParameters.externUserID = result.externUserID;
				_conferenceParameters.loadedModules = result.loadedModules;
				
				var e:ConferenceCreatedEvent = new ConferenceCreatedEvent(ConferenceCreatedEvent.CONFERENCE_CREATED_EVENT);
				e.conference = _conference;
				dispatcher.dispatchEvent(e);
				
				connect();
			}
		}
		
		private function connect():void
		{
			_userSOService = new UsersSOService(applicationURI, _conference);
			_userSOService.connect(_conferenceParameters);	
		}
		
		public function userLoggedIn(e:UsersConnectionEvent):void
		{
			_conference.me.userid = e.userid;
			_conferenceParameters.connection = e.connection;
			_conferenceParameters.userid = e.userid;
			
			_userSOService.join(e.userid, _conferenceParameters.room);
			
			var loadCommand:SuccessfulLoginEvent = new SuccessfulLoginEvent(SuccessfulLoginEvent.USER_LOGGED_IN);
			loadCommand.conferenceParameters = _conferenceParameters;
			dispatcher.dispatchEvent(loadCommand);		
		}
		
		public function logoutUser():void {
			_userSOService.disconnect(true);
		}
		
		public function disconnectTest():void{
			_userSOService.disconnect(false);
		}
		
		public function get me():BBBUser {
			return _conference.me;
		}
		
		public function isModerator():Boolean {
			if (me.role == "MODERATOR") {
				return true;
			}
			
			return false;
		}
		
		public function get participants():ArrayCollection {
			return _conference.users;
		}
		
		public function assignPresenter(assignTo:Number):void {
			_userSOService.assignPresenter(assignTo, me.userid);
		}
		
		public function addStream(e:BroadcastStartedEvent):void {
			_userSOService.addStream(e.userid, e.stream);
		}
		
		public function removeStream(e:BroadcastStoppedEvent):void {			
			_userSOService.removeStream(e.userid, e.stream);
		}
		
		public function raiseHand(e:RaiseHandEvent):void {
			var userid:Number = _conference.me.userid;
			_userSOService.raiseHand(userid, e.raised);
		}
		
		public function lowerHand(e:LowerHandEvent):void {
			if (this.isModerator()) _userSOService.raiseHand(e.userid, false);
		}
		
		public function kickUser(e:KickUserEvent):void{
			if (this.isModerator()) _userSOService.kickUser(e.userid);
		}
	}
}