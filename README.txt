Notes on using the Fly Protocol Designer software so far:




START-UP



- Before running, open the G4_Protocol_Designer_Settings.m file and check the path to your panel configuration file. If this path is incorrect, you'll get an error.



- To run the designer, open the "script.m" file and run in matlab. To run the conductor separately, run the file called "run_conductor.m".
	
	- Note: If you get an error regarding "findjobj" when you run the script file, check to make sure findjobj, a folder inside the project folder with everything else, 		is on your matlab path. Let me know if this happens, because it shouldn't.
 

- In the designer you can use the clear all button to clear out data between designing experiments. 

THE CONDUCTOR

- Please note when running the conductor there is no button to clear out your data. However if one experiment is loaded in the conductor and you'd like to run a different one, simply open the new experiment and it will replace the old.  



- The conductor has fields for a lot of metadata right now, but the only thing required is the fly name, so it can save the results.

I have made it so you cannot edit the experiment name in the conductor, only in the designer.

- There are two ways you can open the conductor - separately from the designer, by running "run_conductor.m," or as a child of the designer by hitting the "Run" button on the designer. There IS a difference between these two modes, though slight. 

- If you have opened the conductor by way of the run trials button, then the conductor and the designer are sharing the same underlying data. If you then change any parameters in the designer, it will also change those parameters for the conductor. If you change the experiment name in the designer, it will now also update the experiment name on the conductor so you can easily see which experiment the conductor is running. 

- If you have opened the conductor by way of the "run_conductor.m" file, then the conductor and designer are separate and what you do on one will not affect the other. 

- When you open an experiment in the conductor, it will automatically update the config file to match the settings for that experiment, but you still must make sure the path in G4_Protocol_Designer_Settings.m is correct!





IMPORTING:


- Please make sure to select the appropriate screen size BEFORE importing. If you import 
pattern files which do not match the selected screen size, you will get an error and the patterns will not import. However, any position or AO functions in the folder will import as normal. Once a folder has been 
imported, the screen size option will become uneditable, meaning if you need to change screen size, you will 
need to exit the application and restart it.


- You can import any combination of files and folders. It attempts to find the associated .pat/pfn/afn file when you import a file, but if it can't find one, it will let you know, and you'll need to move that file manually.
 


- Autopopulate will not work until you have imported patterns, functions, and ao functions. When you autopopulate, if any pattern spots are left blank, that means the pattern did not match your screen size. This should not ever happen because patterns that don't match the screen size shouldn't import in the first place. If position fuction spaces are left blank, it means that position function did not match the dimensions of the pattern it was paired with.
 
- .pat files, it turns out, are much easier to work with on this end when they follow the naming convention pat0001.pat. The program can open either convention, but I have set it up to save them as pat#.pat when you save an experiment.
 



- Right now, if you have already opened another .g4p file or autopopulated an imported folder, you cannot open another .g4p file. Use the "clear all" button to clear out the current data. 

ENTERING DATA:


- If you erase the "Mode" cell of a trial, it will clear the entire trial and treat it as though it 
does not exist (if for example you don't have a pre or post trial in this particular experiment).



- Cells 2-7 (Pattern Name, Position Function, AO 1-4) take a filename, minus the extension, as a string. To make this easier, 
once you have imported, clicking one of these cells while empty will provide you a list of imported files to choose from.

	

- Note that if you use the "Set To" method in the File menu to fill out the values of a trial, 
	you will not have a list of files to choose from. When using "Set To" it may be easiest to fill out all numbers, leaving filenames blank, and then add the filenames after you have finished with the "Set To" window by clicking the empty cells. 



- If you check a trial in the main block and then hit "Add Trial," the trial added to the bottom will be a copy of the selected trial. If 
no trial is selected, then a copy of the last trial in the block will be added. 



- If you note that the "Select all" checkbox stays selected even after you have unchecked some items, don't worry. It is a bug 
to be fixed but will not affect functionality.



- Selecting a cell with a Pattern name will immediately display a preview of that pattern library in the preview panel. You can move 
forward and backward through the library one frame at a time, or hit play which will play through the library in sequential order. 
Position functions are simply graphed, and a red vertical line marks the duration you currently have set for that trial. If the red vertical 
line does not line up with the end of the position graph, note that your graph's x-axis time and the duration you have entered do not match. 
AO functions are displayed as static graphs. 



- To view a cohesive preview of a selected trial, hit the "Preview" button toward the bottom right. 



- When you change the mode of a trial, fields that are changeable in this mode will fill with default values, and those that are not
 used in this mode will clear out. You should get an error if you try to edit a field that's not appropriate for the mode.



- Note that I have NOT yet included error checking which will tell you if you enter a value outside of the bounds for that 
parameter. (I.e. if you enter 0 for frame rate or something) So double check your values! This feature will be forthcoming.



- If you autopopulate and note that it left some position functions blank, this means they did not match dimensions with
their associated pattern functions. They are still imported. Similarly, if some Pattern cells are left blank, it means 
that pattern did not match the screen size. 



SAVING:



- Please make sure you change the experiment name before saving. If it is the first time you have saved this experiment, use
"Save As" under the file menu. Similarly, use "Save as" if you have previously saved this experiment, but want to save it again under a new name.



- When naming a file, please do not use any "-" characters. Use underscores instead. This is because the program must remove any old time stamp from the name 
and add an updated one, and uses dashes as the delimiter to find the time stamp. If you have any dashes in your filename, you'll
 lose the text after the first dash. 



- Opening a previously saved .g4p file will automatically import the Experiment folder in which it is located. You may use "Save" to replace the 
.g4p file and its Experiment folder with the updated file and a new export using the updated information. Remember that using "Save" will ALWAYS
 update the current file rather than creating a new one. 



- When you use "Save as" the program will automatically put a time stamp on the end of your experiment name and save it under that name. 
In the save dialog box, you can erase this time stamp, but be careful of accidentally saving over something else if you do!



NOTES ON RUNNING AN EXPERIMENT



- The dry run button will display the currently checked trial. It does not activate any AO channels. 



- The "Run Trials" button opens up a smaller GUI with a large "Run" button among other things. Please make sure you enter
 a fly name before hitting Run. For right now, the "Experiment Type" drop down box and associated button does not do anything. Note that if you change anything in designer at this point, that information will change in the conductor as well.


-The intertrial should not play before the first block trial or after the last. 



- Each should run for the duration specified in the trial. If something is not 
behaving as you would expect, please let me know so I can adjust this.  



- Please note that the progress bar shows Rep # of Reps, Trial # of Trials, and condition #. This includes the inter-trial, Ie 
Trial 3 of 5 means it is currently playing intertrial number 3 then trial number 3. The progress bar updates before
the intertrial starts, so it changes to Trial 3 of 5 right before starting the third inter-trial followed by the third block trial.
