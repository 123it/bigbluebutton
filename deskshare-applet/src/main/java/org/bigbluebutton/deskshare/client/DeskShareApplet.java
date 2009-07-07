package org.bigbluebutton.deskshare.client;

import java.awt.image.BufferedImage;

import javax.swing.JApplet;

public class DeskShareApplet extends JApplet implements IScreenCaptureListener {

	private static final long serialVersionUID = 1L;
	private ScreenCaptureTaker captureTaker;
	private ScreenCapture capture;
	private Thread captureTakerThread;
	private IScreenCaptureSender captureSender;
	
	private int screenWidth = 800;
	private int screenHeight = 600;
	private int x = 0;
	private int y = 0;
	private boolean httpTunnel = true;
	
	private String room = "test-room";
	private String host = "192.168.0.136";
	
	public void init(){
		screenWidth = Integer.parseInt(getParameter("CAPTURE_WIDTH"));
		screenHeight = Integer.parseInt(getParameter("CAPTURE_HEIGHT"));
		x = Integer.parseInt(getParameter("X"));
		y = Integer.parseInt(getParameter("Y"));
		room = getParameter("ROOM");
		host = getParameter("IP");
		httpTunnel = Boolean.getBoolean(getParameter("TUNNEL"));
	}
	
	public void stop(){
		
	}
	
	public void start(){
		System.out.println("RunnerApplet start()");
		capture = new ScreenCapture(x, y, screenWidth, screenHeight);
		captureTaker = new ScreenCaptureTaker(capture);
		
		if (httpTunnel) {
			//captureSender = new FileUploadSender();
			//captureSender = new TestHttpSender();
			captureSender = new HttpScreenCaptureSender();
			captureSender.connect(host, room, capture.getVideoWidth(),
					capture.getVideoHeight(), capture.getProperFrameRate());
		} else {
			captureSender = new SocketScreenCaptureSender();

			captureSender.connect(host, room, capture.getVideoWidth(),
					capture.getVideoHeight(), capture.getProperFrameRate());
		}

		captureTaker.addListener(this);
		captureTaker.setCapture(true);
		
		captureTakerThread = new Thread(captureTaker);
		captureTakerThread.start();
	}
	
	/**
	 * This method is called when the user closes the browser window containing the applet
	 * It is very important that the connection to the server is closed at this point. That way the server knows to
	 * close the stream.
	 */
	public void destroy(){
		captureTaker.setCapture(false);
		if (!httpTunnel) {
			captureSender.disconnect();
		}
	}
	
	public void setScreenCoordinates(int x, int y){
		capture.setX(x);
		capture.setY(y);
	}
	
	static public void main (String argv[]) {
	    final JApplet applet = new DeskShareApplet();

	    applet.start();
	}

	public void onScreenCaptured(BufferedImage screen) {
		captureSender.send(screen);
	}

}