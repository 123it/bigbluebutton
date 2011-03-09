/**
* BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
*
* Copyright (c) 2010 BigBlueButton Inc. and by respective authors (see below).
*
* This program is free software; you can redistribute it and/or modify it under the
* terms of the GNU Lesser General Public License as published by the Free Software
* Foundation; either version 2.1 of the License, or (at your option) any later
* version.
*
* BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
* WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
* PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License along
* with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
* 
*/

package org.bigbluebutton.modules.phone.managers
{
	import com.asfusion.mate.events.Dispatcher;
	
	import mx.controls.Alert;
	import flash.external.*;
	
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.modules.phone.events.CallConnectedEvent;
	import org.bigbluebutton.modules.phone.events.JoinVoiceConferenceEvent;
	import org.bigbluebutton.modules.phone.events.cPHONE_JoinVoiceConfInfoEvent;
	
	public class PhoneManager {
		
		private var connectionManager:ConnectionManager;
		private var streamManager:StreamManager;
		private var onCall:Boolean = false;
		private var attributes:Object;
		
		public function PhoneManager() {
			connectionManager = new ConnectionManager();
			streamManager = new StreamManager();
		}

		public function setModuleAttributes(attributes:Object):void {
			this.attributes = attributes;
			LogUtil.debug("Attributes Set... webvoiceconf:" + attributes.webvoiceconf);

			if (attributes.autoJoin == "true") joinVoice(true);
		}
				
		private function setupMic(useMic:Boolean):void {
			if (useMic)
				streamManager.initMicrophone();
			else
				streamManager.initWithNoMicrophone();
		}
		
		private function setupConnection():void {
			streamManager.setConnection(connectionManager.getConnection());
		}
		
		public function join(e:JoinVoiceConferenceEvent):void {
			joinVoice(e.useMicrophone);
		}
		
		/*****************************************************************************
		 ;  joinVoice
		 ;----------------------------------------------------------------------------
		 ; DESCRIPTION
		 ;   This routine is use to handle participant join the voice conferece.
		 ;
		 ; RETURNS : N/A
		 ;
		 ; INTERFACE NOTES
		 ;   INPUT
		 ;           - autoJoint : Boolean the status
		 ;
		 ; IMPLEMENTATION
		 ;  	call startSIPApplet to execute bbb SIP applet
		 ;
		 ; HISTORY
		 ; __date__ :        PTS:  			Description
		 ; 2011-3-02                       Improve VoIP
		 ;
		 ******************************************************************************/
		public function joinVoice(autoJoin:Boolean):void {
			var voiceConfId:String	= attributes.webvoiceconf;
			var domainName:String	= attributes.uri.split("/")[2];
			var uname:String		= attributes.username;
			if (true == ExternalInterface.available) 
			{
				// call external javascript 'handleNewUser'
				LogUtil.debug("Dialing...." + attributes.webvoiceconf + ".... via BBB SIP Applet");
				ExternalInterface.call("startSIPApplet", domainName, voiceConfId, uname);
			}
            onCall = true ;
		}/** END Function: joinVoice */
				
		public function dialConference():void {
			LogUtil.debug("Dialing...." + attributes.webvoiceconf + "...." + attributes.externUserID);
			connectionManager.doCall(attributes.webvoiceconf);
		}
		
		public function callConnected(event:CallConnectedEvent):void {
			LogUtil.debug("Call connected...");
			setupConnection();
			LogUtil.debug("callConnected: Connection Setup");
			streamManager.callConnected(event.playStreamName, event.publishStreamName, event.codec);
			LogUtil.debug("callConnected::onCall set");
			onCall = true;
		}
		
		/*****************************************************************************
		 ;  hangup
		 ;----------------------------------------------------------------------------
		 ; DESCRIPTION
		 ;   This routine is use to handle participant hangup the vice conference
		 ;
		 ; RETURNS : N/A
		 ;
		 ; INTERFACE NOTES : N/A
		 ;
		 ; IMPLEMENTATION
		 ;  	call startSIPApplet to stop bbb SIP applet
		 ;
		 ; HISTORY
		 ; __date__ :        PTS:  			Description
		 ; 2011-3-02                       Improve VoIP
		 ;
		 ******************************************************************************/
		public function hangup():void {
			LogUtil.debug("PhoneManager hangup");
            if (true == onCall){
                if (true == ExternalInterface.available) 
                {
                    // call external javascript 'handleNewUser'
                    ExternalInterface.call("stopSIPApplet");
                }
                onCall = false ;
            }
		}/** END Function: hangup */
	}
}
