User Manuel: Package for analysis the release of synaptic vesicles.
This is a bundle of software packages to analyse data derived from distinct experimental approaches to measure the size or fraction of synaptic vesicle pools. Thereby the blabla BEschreibung 
Basically the software packages comprises following general steps
1)	Loading of data
2)	Image segmentation to select synapses as region of interest (ROI)
3)	Calculation of raw fluorescence traces represented as the mean value from the intensity values within the individual ROIs
4)	Background subtraction
5)	Bleaching correction
6)	Analysis of the mean curve derived by calculating the average over  individual synapses
7)	Analysis of individual synapses
8)	Data storage
1	ANAYSIS FOR EXPERIMENTS WITH A DECREASING FLUORESCENCE AND UNDER THE APPLICATION OF AN INHIBITOR OF VESICULAR PROTON PUMP
In this experimental design synaptic vesicles are rendered fluorescent due to their acidic milieu. In the case of vesicle release the change of pH changes depletes fluorescence signal. The inhibition of proton pump prevents reacidification and a recovery of the fluorescence signal. Depending on the stimulation the decay in the fluorescence signal is a measure for the size of a particular vesicle pool.
Note: in our laboratory we usually use CypHer attached to and bafilomycin as an inhibitor for ATP-pump
1.1	CY_PHER ANALYSIS: EXPERIMENTS WITH MULTIPLE STIMULATION
A representative curve is shown in Fig.: 
1.1.1	DATA PREPROCESSING
Data segmentation
Background determination and Subtraction
Bleaching Correction
To correct the curves for bleaching two approaches are possible. First, a blank curve is recorded without any interventions and then used to calculate bleaching parameters. Second, an intrinsic bleaching curve is created from the raw experimental data. Therefore the algorithm detects the start and end positions of the signal according the procedure described in 1.1.2.
Normalization
1.1.2	DESCRIPTION OF THE BASIC ALGORITHM FOR DETERMINE ∆F
The algorithm uses the 1° derivative and the 2nd derivative calculated from the mean fluorescence curve (averaged over all traces derived from ROIs) to recognize the stimulation time points and the end of corresponding fluorescence signals. Figuratively speaking the algorithm detects the edges of the ‘stairs’ in the curve. Thereby the 1°derivative can be used to get the points with the steepest decline in the curve indicating a rough position of a signal. Indicating the points with the ‘highest’ change in slope, the maxima in the 2°derivative give the edges. 
Note: The same algorithm is used to create a bleaching curve from the raw experimental data when the ‘intrinsic’ bleaching correction mode is applied. Detected start-stop pairs are used also for further calculations after bleaching correction.
1.1.3	PROCEDURE FOR SIGNAL DETECTION IN CYPHER ANALYSIS (GETEDGES)
[starts, stops, dF,trace_cut,nStim,cuttingWin] = getEdges(trace,gradFilt,SE,cuttingWin,nStim,firstStim)
INPUT	
trace:	1xn double array containing the data of the curve
gradFilt:	1xn double array containing the positions of events detected in individual curve
startAV:	1xn double array containing the start positions of the signals in the average curve
stopAV:	1xn double array containing the stop positions of the signals in the average curve
OUTPUT	
listOfStim	1xn logical TRUE indicates event next to a stimulus
Data is smoothed in a first step, using the inbuild function smooth (mooving average). The gradient filter is applied for the first time resulting in an estimation of the first derivative. Afterward the gradient filter is applied a second time resulting in an estimation for the second derivative. Next all extrema in the second derivative are detected since representing the points with the highest change in slope (=edges). For that absolute values are calculated. Maxima in the resulting curve are found by calculating the dilation of the 2° derivative using SE as mask and subtract from each other:
filtered_2_inv = abs(filtered_2);
dil = imdilate(filtered_2_inv,SE);
[…]
locMin = dil - filtered_cut2;

True local exprema are given by  
val_pos = find(locMin == 0);
Due to noisy data resulting in roughness in smoothed data besides the edges in the fluorescence signal caused by stimulation also others might be detected as artifacts. The smaller extrema should therefore be removed. The algorithm selects a defined number of highest extrema. The number is defined the number of expected edges according to the number of stimulations: 
number = nStim * 2 + 4
Note: the number is adjusted if number > length(detected extrema)
Next the algorithm assigns  extrema to signal start (maxima in 2°derivative   right bend) and signal stop (minima in 2°derivative  left bend) respectively. 


Detection of ∆F in individual synapses:
The algorithm loops through the calculated traces from all ROIs. In a first step start and stop values are calculated analogously to the procedure for the averaged cure.
[~,startIndiv,stopIndiv] = analyseTrace(trace,gradFilt,SE,cuttingWin);
The signal derived from the individual synapses is very noisy so there are some subsequent procedures added to ensure result’s reliability. Thereby the stimulations derived from the average curve serve as a template. First condition that is checked is the presence of a decline in the adjacencies of each stimulation position. A logical vector indicates which stimulus leads to a decline in fluorescence signal of the individual curve. Second, out of the list of start and stop candidates of the individual trace, the candidates most closely to the start-stop values from the signal on the average curve are detected. Afterwards just the start-stop pairs are stored that met the first condition, that means only if there is a decline between start-stop candidates, candidates are confirmed as signals.
1)	 Check if the individual events are next to the stimulations from the average curve 
listOfStim=getIndivResponders(positionAv,steepest,startAV, stopAV);
INPUT	
positionAV:	1xn double array containing the positions of stimulations from the average curve
steepest:	1xn double array containing the positions of events detected in individual curve
startAV:	1xn double array containing the start positions of the signals in the average curve
stopAV:	1xn double array containing the stop positions of the signals in the average curve
OUTPUT	
listOfStim	1xn logical TRUE indicates event next to a stimulus
 The algorithm checks if there has been a decline detected in the individual curve (steepest) that lies within a defined area around each stimulation derived from average curve (positionAV). The range of the area is calculated according to the range between start and stop positions from the average curve. 
2)	Get start and stop events from the individual curve that are nearest to start and stop signals in the averaged curve
[startStim,stopStim] = getNearestNeighbor(startIndiv,startAV,stopIndiv,stopAV);
INPUT	
startIndiv:	1xn double array containing start positions of events in individual curve
startAV:	1xn double array containing start positions of signals detected in average curve
stopIndiv:	1xn double array containing stop positions of events in individual curve
stopAV:	1xn double array containing stop positions of signals detected in average curve
OUTPUT	
startStim	1xn double array containing start positions of events from individual curve next to start positions of stimulations detected in average curve
stopStim	1xn double array containing start positions of events from individual curve next to stop positions of stimulations detected in average curve

3)	The fluorescence values belonging to the start and stop positions in the individual curve are represented as the mean fluorescence value of the respective frame and the one frame before and after: [startStim-1:startStim+1];  [stopStim-1:stopStim+1];  
4)	∆F is just stored for start-stop pairs that are  
 
1.1.4	INSTRUCTIONS FOR APPLICALTIONS

The concerning code routines are written to analyze CypHer Experiments with multiple stimulations;
For one stimulation experiments use Cypher_OneStimulation_multipage;
For analyzing synaptic vesicle pools with cypher use Cypher_SVPool;
Referring Version from 05.04.2019;
Current Update: depending of your source data, you can now select between:
(1) Cypher_AnalysationTool: for Image Sequences: You have your data stored as single tiff images in a folder;
(2) Cypher_AnalysationTool_multipage: for multipage tiff files: you can save the .nd sequence file as a multipage tiff file by Fiji with save as  tiff. Advantage: files need much less amount of memory compared to (1).
5)	Open Matlab
6)	Set Path:  Add the directory, where the Tool is stored, to the Matlab Path:
a.	Sets the correct directory, that MATLAB will find the functions that are necessary for the calculation
b.	Adjust the directory of the folder containing the CyPher_multiStim_package in the Current Folder section (see figure) 
c.	Right mouse click on folder CyPher_multiStim_package move the cursor on “add to path” (not click)  select  “Selected folders and subfolders”  
7)	
8)	
1.	To start the tool alternatively, you can just press the play bottom. But then, just the first output variable is returned, and it’s named “ans”;
2.	Next, the program will lead you through everything, just follow the instructions
a.	Window ‘select experiments’: (1) select the folders, where one folder contains the image sequence as tiff of one experiment. You can select multiple folders/experiments. 
9)	(2) Select the multipage tiff file. You can select multiple folders/experiments. 
10)	
b.	User interface pops up: ‘Load Lambda for bleaching correction’
 
o	You will be ask, if you want to load already calculated parameters for the bleaching calculations (this will accelerate the performance);  Select Yes, and then select the file that contains the parameters.
o	If you have no parameters for bleaching correction already stored, you have to insert the directory of the bleaching correction experiments. Multiselection is possible, here the program averages the results;
 
o	If you let the program calculate the parameters for bleaching correction, you will be asked, if you want to store them. Select the directory and put in a name;
c.	Window ‘select directory to save your files’: Enter directory and name to save the results as mat file: the software will name the created file automatically with the name of the selected data file. If you enter a name here, it is used as a prefix, so u can specify the name a bit more. For example you could enter a date;
d.	Window ‘Name Report File’: Specify name and directory of the excel export file; naming procedure is aquivalent to the former step;
e.	User Interface pops up ‘Enter frame number for signal detection’: specify the frame range within the signal detection should be performed equal to the range within the stimulations are applied
11)	
3.	You receive a data struct as result containing the following:
a.	Fields: individual Synapsis
b.	Location: location of the starting points of an event, referred to the parsed Curve (referred to curve take the value + cuttingWindow – 1);
c.	endPoints: location of the end points of an event;
d.	curve: restorated curve (BG subtracted, normalized, corrected for bleaching);
e.	parsed Curve: curve segment for signal detection, aligned by baseline correction;
f.	cuttingWindow: number of frames that were discarded from the beginning of the trace 
g.	rawData: the read out data, without any restoration;
