#!/bin/sh

USER=""
USERID=$(id -u $USER)
DEVICE='alsa_output.platform-hkdk-snd-max98090.analog-stereo'

ACTIVE_SINK=$(su $USER -c "export PULSE_RUNTIME_PATH=/run/user/$USERID/pulse/ ; pacmd list-sinks" | grep 'active port' | awk '{ print $2 }')

#Checking if pulseaudio is up and running as expected
if [ -z "$ACTIVE_SINK" ]; then
	echo "Something wrong... no active sink found."
	exit 1
fi

#Checking if mpd is up and running
mpc > /dev/null

if [ $? -eq 1 ]; then
	echo "Something wrong... mpd not running."
	exit 1
fi

#Set to HDMI output by default
su $USER -c "export PULSE_RUNTIME_PATH=/run/user/$USERID/pulse/ ; pacmd set-sink-port $DEVICE analog-output-speaker > /dev/null"

while true; do
	#This call blocks until some event change (stop/pause/play) happens in mpd	
	CURRENT=$(mpc current --wait)
	
	if [ -n "$CURRENT" ]; then
		#mpd is playing something, change to analog output
               	su $USER -c "export PULSE_RUNTIME_PATH=/run/user/$USERID/pulse/ ; pacmd set-sink-port $DEVICE analog-output-headphones > /dev/null"
	else
		#mpd is not playing anything, change to hdmi output
		su $USER -c "export PULSE_RUNTIME_PATH=/run/user/$USERID/pulse/ ; pacmd set-sink-port $DEVICE analog-output-speaker > /dev/null"
	fi
done

exit 0
