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

import QtQuick 2.0
import MuseScore 3.0

MuseScore {
	menuPath: "Plugins.NewRetrograde"
	description: "Takes a selection of notes and reverses them."
	version: "1.1"
	
	function retrogradeSelection() {
		var cursor = curScore.newCursor(); // get the selection
		cursor.rewind(2); // go to the end of the selection
		
		if(!cursor.segment) { // if nothing selected
			console.log('nothing selected'); // say "nothing selected"
			Qt.quit(); // then quit
		} else {
			var endTick = cursor.tick; // mark the selection end tick
			cursor.rewind(1); // go to the beginning of the selection
			var startTick = cursor.tick; // mark the selection start tick
		}
		
		var selectionArray = []; // create a blank array
		
		while(cursor.segment && cursor.tick < endTick) { // while in the selection
			var e = cursor.element; // put current element into variable e
			if(e) { // if e exists
				if(e.type == Element.CHORD) { // if e is a note or chord
					var pitches = []; // put the note pitches of each chord into an array
					var tones = []; // put tpc values into an array
					var notes = e.notes; // get all the notes of the chord
					for(var i = 0; i < notes.length; i++) { // iterate through each note in chord
						var note = notes[i]; // get the note pitch number
						pitches.push(note.pitch); // push pitch number into array
						tones.push(note.tpc); // push tpc value into array
					}
				}
				
				if(e.type == Element.REST) { // if e is a rest
					var pitches = 'REST'; // "REST" as pitch
				}
				
				var numer = e.duration.numerator; // numerator of duration
				var denom = e.duration.denominator; // denominator of duration
				
				selectionArray.push([pitches, tones, numer, denom]);
			} else {
				console.log('nothing happened');
				Qt.quit();
			}
			cursor.next(); // move to next tick
		}
		
		selectionArray.reverse(); // this does the retrograde (reverse array)
		cursor.rewind(1); // go back to beginning of selection
		
		// this section rewrites the selection with the reversed array
		for(var i = 0; i < selectionArray.length; i++) {
			var selection = selectionArray[i];
			var pitches = selection[0]; // get note and chord pitches
			var tones = selection[1]; // get tpc values
			var numer = selection[2]; // duration numerator
			var denom = selection[3]; // duration denominator
			
			// set the duration
			cursor.setDuration(numer, denom); // set duration of note, chord, rest
			
			// if there is only a single note
			/* no longer need single note code as it is handled in the chord code below
			if(pitches.length == 1) {
				cursor.addNote(pitches[0]); // add note and advance cursor
				// the following is the convoluted way of setting the tpc value of a note
				cursor.prev(); // rewind the cursor by one element
				var note = cursor.element.notes[0]; // put the note just created into a new 'note' variable
				note.pitch = pitches[0]; // reset the pitch just because
				note.tpc = tones[0]; // set the tpc to get the correct accidental
				cursor.next(); // advance the cursor by one element
			}*/
			
			// if there is a chord or rest
			//if(pitches.length > 1) {
			
			// if rest
			if(pitches === 'REST') {
				cursor.addRest () // add rest and advance cursor
			} else { // if note or chord
				for(var j = 0; j < pitches.length; j++) {
					if(j == 0) { // loop through each pitch array
						cursor.addNote(pitches[0]); // write note with pitch
						cursor.prev(); // rewind cursor one element
						var note = cursor.element.notes[0];
						note.pitch = pitches[0]; // fix pitch
						note.tpc = tones[0]; // set tpc
						cursor.next();
						if(pitches.length > 1) { // if multiple pitches (i.e. a chord)
							cursor.prev();
							//console.log(chordNote);
							for(var k = 1; k < pitches.length; k++) { // loop through remaining pitches
								var chordNote = newElement(Element.NOTE); // create a new note object
								chordNote.pitch = pitches[k]; // define the pitch
								chordNote.tpc = tones[k]; // define the tpc (it will be ignored)
								var curChord = cursor.element; // get the existing note at the current cursor position
								curChord.add(chordNote); // add the new note to the chord root note
								curChord.notes[k].tpc = tones[k]; // set the tpc of the new chord note
								cursor.next(); // move to the next element
								
								//cursor.addNote(pitches[k], cursor); // 'cursor' keeps the cursor in place for adding notes to the chord
							}
						}
					}
				}
			}
		} // end for
	}
	
	// do the thing
	onRun: {
		retrogradeSelection();
		Qt.quit()
	}
}