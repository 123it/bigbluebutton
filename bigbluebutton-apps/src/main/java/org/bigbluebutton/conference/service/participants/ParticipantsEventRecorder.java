/*
 * BigBlueButton - http://www.bigbluebutton.org
 * 
 * Copyright (c) 2008-2009 by respective authors (see below). All rights reserved.
 * 
 * BigBlueButton is free software; you can redistribute it and/or modify it under the 
 * terms of the GNU Lesser General Public License as published by the Free Software 
 * Foundation; either version 3 of the License, or (at your option) any later 
 * version. 
 * 
 * BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY 
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License along 
 * with BigBlueButton; if not, If not, see <http://www.gnu.org/licenses/>.
 *
 * $Id: $
 */

package org.bigbluebutton.conference.service.participants;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.bigbluebutton.conference.service.recorder.IEventRecorder;
import org.bigbluebutton.conference.service.recorder.IRecorder;
import org.bigbluebutton.conference.IRoomListener;
import org.red5.server.api.so.ISharedObject;
import org.bigbluebutton.conference.Participant;
import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

public class ParticipantsEventRecorder implements IEventRecorder, IRoomListener {

	private static Logger log = Red5LoggerFactory.getLogger( ParticipantsEventRecorder.class, "bigbluebutton" );
	
	IRecorder recorder;
	private ISharedObject so;
	private final Boolean record;
	
	String name = "PARTICIPANT";
	
	private final String RECORD_EVENT_JOIN="join";
	private final String RECORD_EVENT_LEAVE="leave";
	private final String RECORD_EVENT_STATUS_CHANGE="status_change";
	private final String RECORD_EVENT_LEAVE_ALL="leave_all";
	
	
	public ParticipantsEventRecorder(ISharedObject so, Boolean record) {
		this.so = so; 
		this.record = record;
	}
	
	@Override
	public void acceptRecorder(IRecorder recorder) {
		log.debug("Accepting IRecorder");
		this.recorder = recorder;
	}

	@Override
	public String getName() {
		return name;
	}

	@Override
	public void recordEvent(String message) {
		if (record) {
			recorder.recordEvent(message);
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void endAndKickAll() {
		so.sendMessage("logout", new ArrayList());
		recordEvent(parseParticipantsToJSON(new ArrayList(), this.RECORD_EVENT_LEAVE_ALL));
	}
	
	/* 
	* Pass the "cmd" of the "moduleCommand" API call method 
	* to the Bigbluebutton CLient through the participants SO
	* this method is called by incoming JMS requests
	* input parameters: a string that represents the command we 	* want to pass to the Bigbluebutton client (i.e. start, stop, 	* etc). For more details see documentaion.
	*/

	@SuppressWarnings("unchecked")
	@Override
	public void moduleCommand(String cmd)
	{
		log.debug("moduleCommand received & pass to Client through SO: " + cmd);
		ArrayList args = new ArrayList();
		args.add(cmd);
		so.sendMessage("moduleCommand", args);
	}

	@SuppressWarnings("unchecked")
	@Override
	public void participantJoined(Participant p) {
		log.debug("A participant has joined {}.",p.getUserid());
		ArrayList args = new ArrayList();
		args.add(p.toMap());
		log.debug("Sending participantJoined {} to client.",p.getUserid());
		so.sendMessage("participantJoined", args);
		recordEvent(parseParticipantsToJSON(args, this.RECORD_EVENT_JOIN));
	}

	@SuppressWarnings("unchecked")
	@Override
	public void participantLeft(Long userid) {
		ArrayList args = new ArrayList();
		args.add(userid);
		so.sendMessage("participantLeft", args);
		recordEvent(parseParticipantsToJSON(args, this.RECORD_EVENT_LEAVE));
	}

	@SuppressWarnings("unchecked")
	@Override
	public void participantStatusChange(Long userid, String status, Object value) {
		log.debug("A participant's status has changed "+userid+" "+status+" "+value);
		ArrayList args = new ArrayList();
		args.add(userid);
		args.add(status);
		args.add(value);
		so.sendMessage("participantStatusChange", args);
		recordEvent(parseParticipantsToJSON(args, this.RECORD_EVENT_STATUS_CHANGE));
	}
	
	/****** parse method ********/
	private String parseParticipantsToJSON(ArrayList list, String type){
		String json="{ ";
		
		json+="\"module\":\"participants\", ";
		if(type.equalsIgnoreCase(this.RECORD_EVENT_STATUS_CHANGE)){
			json+="\"event\":\""+this.RECORD_EVENT_STATUS_CHANGE+"\", ";
			json+="\"userid\":\""+list.get(0)+"\", ";
			json+="\"status\":\""+list.get(1)+"\", ";
			json+="\"value\":\""+list.get(2)+"\" ";
		}
		else if(type.equalsIgnoreCase(this.RECORD_EVENT_JOIN)){
			Map map=(Map) list.get(0);
			json+="\"event\":\""+this.RECORD_EVENT_JOIN+"\", ";
			json+="\"userid\":\""+map.get("userid")+"\", ";
			json+="\"name\":\""+map.get("name")+"\", ";
			json+="\"role\":\""+map.get("role")+"\" ";
		}
		else if(type.equalsIgnoreCase(this.RECORD_EVENT_LEAVE)){
			json+="\"event\":\""+this.RECORD_EVENT_LEAVE+"\", ";
			json+="\"userid\":\""+list.get(0)+"\" ";
		}
		else if(type.equalsIgnoreCase(this.RECORD_EVENT_LEAVE_ALL)){
			json+="\"event\":\""+this.RECORD_EVENT_LEAVE_ALL+"\" ";			
		}
		json+="}";
		return json;
	}
}
