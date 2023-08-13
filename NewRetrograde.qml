//===========================================================================
// New Retrograde
// https://github.com/ellejohara/newretrograde
// 
// Copyright (C) 2020 Astrid Lydia Johannsen (ellejohara)
// 
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 3
//  as published by the Free Software Foundation and appearing in
//  the file LICENSE
//===========================================================================

import QtQuick 2.9
import MuseScore 3.0

MuseScore {
	menuPath: "Plugins.NewRetrograde"
	description: "Takes a selection of notes and reverses them."
	version: "3.0"
	
	//** utility functions **//
	// a more precise cursor positioning function (from the boilerplate)
	function setCursorToTick(cursor, tick) {
		cursor.rewind(0);
		while (cursor.segment) {
			var curTick = cursor.tick;
			if (curTick >= tick) return true;
			cursor.next();
		}
		cursor.rewind(0);
		return false;
	}
	
	// return start and end ticks and staffIdx
	function startEnd(cursor) {
		cursor.rewind(1); // set cursor to beginning of selection to avoid the 'select all' last measure bug
		if(!cursor.segment) return false;
		cursor.rewind(2);
		var endTick = cursor.tick;
		if (cursor.tick == 0) endTick = curScore.lastSegment.tick;
		var lastStaff = cursor.staffIdx;
		cursor.rewind(1);
		var startTick = cursor.tick;
		var firstStaff = cursor.staffIdx;
		if (firstStaff == lastStaff) lastStaff++; // fix to enable selecting lower staves only
		var result = [startTick, endTick, firstStaff, lastStaff];
		return result;
	}
	
	// return active tracks
	function activeTracks() {
		var tracks = [];
		for (var i = 0; i < curScore.selection.elements.length; i++) {
			var e = curScore.selection.elements[i];
			if (i == 0) {
				tracks.push(e.track);
				var previousTrack = e.track;
			}
			if (i > 0) {
				if (e.track != previousTrack) {
					tracks.push(e.track);
					previousTrack = e.track;
				}
			}
		}
		return tracks;
	}
	
	//** the retrograde function **//
	function doTheRetrograde() {
		// setup
		var retro = [];
		var cursor = curScore.newCursor();
		var waypoints = startEnd(cursor);
		var startTick = waypoints[0];
		var endTick = waypoints[1];
		var firstStaff = waypoints[2];
		var lastStaff = waypoints[3];
		var tracks = activeTracks();
		var tup = 0;
		
		// put the selection into the retrograde array
		for (var trackNum in tracks) {
			setCursorToTick(cursor, startTick);
			cursor.track = tracks[trackNum];
			while (cursor.segment && cursor.tick < endTick) {
				retro.push(cursor.element);
				cursor.next();
			}
		}
		
		// remove existing elements from selection (delete notes)
		for (var trackNum in tracks) {
			setCursorToTick(cursor, startTick);
			cursor.track = tracks[trackNum];
			while (cursor.segment && cursor.tick < endTick) {
				var e = cursor.element;
				if (e.type == Element.CHORD || e.type == Element.NOTE) {
					if (e.tuplet) {
						cursor.setDuration(e.tuplet.duration.numerator, e.tuplet.duration.denominator);
						removeElement(e.tuplet);
					} else {
						cursor.setDuration(e.duration.numerator,e.duration.denominator);
						removeElement(e);
					}
                    cursor.next();
				}
				if (e.type == Element.REST) cursor.next();
			}
		}
		
		// do the retrograde
		retro.reverse();
		
		for (var trackNum in tracks) {
			setCursorToTick(cursor, startTick);
			cursor.track = tracks[trackNum];
			var tupReset = 1;
			for (var i in retro) {
				var curTick = cursor.tick; // remember the current tick to rewind to it later instead of using cursor.prev()
				if (retro[i].track == tracks[trackNum]) {
					// first thing to get is the element duration for everything except tuplets
					if (!(retro[i].tuplet)) { // reject tuplets for now
						// set the element duration
						cursor.setDuration(
							retro[i].duration.numerator,
							retro[i].duration.denominator
						);
						// if the element is a note or chord, add the note
						if (retro[i].type == Element.CHORD) {
							cursor.addNote(retro[i].notes[0].pitch); // advances the cursor
						}
						// if the element is a rest
						if (retro[i].type == Element.REST) {
							cursor.addRest(); // advances the cursor
						}
                        cursor.rewindToTick(curTick); // rewindToTick works if selection includes last measure of score
					}
				
					//** SO BEGINS THE TUPLET SECTION **//
                    // get the tuplet ratio and duration
					if (retro[i].tuplet) {
						var numer = retro[i].tuplet.actualNotes;
						var denom = retro[i].tuplet.normalNotes;
						var durN = retro[i].tuplet.duration.numerator;
						var durD = retro[i].tuplet.duration.denominator;
					}

                    // set the duration and add the first note or rest
					if (retro[i].tuplet && tupReset == 1) {
						cursor.setDuration(durN, durD);
						if (retro[i].type == Element.CHORD) {
							cursor.addNote(retro[i].notes[0].pitch); // advances the cursor
						}
						if (retro[i].type == Element.REST) {
							cursor.addRest(); // advances the cursor
						}
                        cursor.prev(); // go back one
						cursor.addTuplet(fraction(numer, denom), fraction(durN, durD)); // convert to tuplet
					}

                    // add additional tuplet notes or rests
					if (retro[i].tuplet && tupReset > 1) {
						if (retro[i].type == Element.CHORD) {
							cursor.addNote(retro[i].notes[0].pitch); // advances the cursor
						}
						if (retro[i].type == Element.REST) {
							cursor.addRest(); // advances the cursor
						}
                        cursor.prev(); // go back one
					}

                    // update the tuplet counter, or reset when counter equals number of tuplets
					if (retro[i].tuplet) {
							if (tupReset == numer) { // numer = tuplet.actualNotes (line 142)
							tupReset = 1;
						} else {
							tupReset++;
						}
					}
					//** SO ENDS THE TUPLET SECTION **//

                    // add tpc information to the notes
                    if (retro[i].type == Element.CHORD) {
						// adding notes[0] to the cursor.element sets the tpc correctly
                        cursor.element.notes[0].tpc = retro[i].notes[0].tpc;
						cursor.element.notes[0].tpc1 = retro[i].notes[0].tpc1;
						cursor.element.notes[0].tpc2 = retro[i].notes[0].tpc2;
                    }
				
					// time to add additional notes and tpcs if it's an actual chord
					if (retro[i].type == Element.CHORD && retro[i].notes.length > 0) {
						var chord = retro[i].notes;
						for (var j = 1; j < chord.length; j++) {
							cursor.addNote(retro[i].notes[j].pitch, true);
							cursor.rewindToTick(curTick); // rewindToTick works if selection includes last measure of score
							// adding notes[j] to the cursor.element sets the tpc correctly
							cursor.element.notes[j].tpc = retro[i].notes[j].tpc;
							cursor.element.notes[j].tpc1 = retro[i].notes[j].tpc1;
							cursor.element.notes[j].tpc2 = retro[i].notes[j].tpc2;
						}
					}
					cursor.next();
				}
			}
		}
		curScore.selection.selectRange(startTick, endTick, firstStaff, lastStaff + 1); // keep selection selected
	}
	
	onRun: {
		doTheRetrograde();
		Qt.quit();
	}
}