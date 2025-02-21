Dialog.create(" ");
Dialog.addMessage("Assembling and analysing average image of multiple stereocillia", 30, "Red");
Dialog.addMessage("                                      Jan Wisniewski", 30, "Blue");
Dialog.addMessage("      Experimental Immunology Branch, NCI, NIH, Bethesda, MD, USA", 24, "Blue");
Dialog.show();


Dialog.create("");
Dialog.addRadioButtonGroup("Choose:", newArray("Averaging cillia and Montage", "Extracting brightness profiles"), 2, 1, "Averaging cillia and Montage");
Dialog.show();
act=Dialog.getRadioButton();

res=getDirectory("Choose/create folder to store results and temporary files/subfolders");

if(act=="Averaging cillia and Montage") {
inpt=getDirectory("Select folder containing STEDYCON images converted to multichannel tiff");
lst=getFileList(inpt);
for (k = 0; k < lst.length; k++) {open(inpt + lst[k]);
rename("x");
getPixelSize(unit, pixelWidth, pixelHeight);
print(lst[k], "pixel=", round(1000*pixelWidth), "x", round(1000*pixelHeight), "nm");
res=round(200*pixelWidth);
run("Set Scale...", "distance=1 known=1 unit=pixel");
run("Split Channels");
close("C1-x");
close("C2-x");
close("C3-x");
close("C4-x");
selectWindow("C6-x");
run("Grays");
resetMinAndMax;
run("Enhance Contrast", "saturated=0.35");
selectWindow("C5-x");
run("Grays");
resetMinAndMax;
run("Enhance Contrast", "saturated=0.35");
run("Tile");

Dialog.createNonBlocking("");
Dialog.addNumber("How many well oriented flat cillia are visible in this image?", 0);
Dialog.show();
chk=Dialog.getNumber();

if(chk==0) {close("C5-x");
close("C6-x");	}

else {run("Merge Channels...", "c1=C5-x c2=C6-x create ignore");	
run("Scale...", "x=res y=res z=1.0 depth=2 interpolation=Bicubic average create");
close("Composite");
rename("x");
run("Gaussian Blur...", "sigma=2");
run("Invert");
getDimensions(width, height, channels, slices, frames);
wdt=width;
hgt=height;
if(hgt>wdt) {nhgt=hgt+1000;
run("Canvas Size...", "width=wdt height=nhgt position=Center");		}
else {nwdt=wdt+1000;
run("Canvas Size...", "width=nwdt height=hgt position=Center");		}
getDimensions(width, height, channels, slices, frames);
xdt=width;
xgt=height;
run("Split Channels");
//wlst=getList("image.titles");
for (i = 1; i < 3; i++) {selectWindow("C"+i+"-x");
run("Grays");
vmax=getValue("Max");
doWand(1, 1);
run("Add...", "value=[vmax]");
doWand(xdt-2, xgt-2);
run("Add...", "value=[vmax]");
run("Select None");
resetMinAndMax;
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");		}

selectImage("C1-x");
run("Invert");
imageCalculator("Average create", "C1-x","C2-x");
rename("R");
resetMinAndMax;
run("Enhance Contrast", "saturated=0.35");
selectImage("C1-x");
run("Invert");

setTool("point");
for (j = 1; j < chk+1; j++) {selectWindow("R");
//selectWindow("C2-x");
if(j>1) {makeLine(xA, yA, xB, yB);		}
waitForUser("For cillium " + j + " of " + chk + " select 1st reference point - cillium apex");
xA=getValue("X");
yA=getValue("Y");
waitForUser("Select 2nd reference point - center of cillium free end\nor anywhere on cillium axis");
xB=getValue("X");
yB=getValue("Y");
ang=180*atan2((yB-yA), (xB-xA))/PI;
rot=-ang;
makeRectangle(xA-500, yA-500, 1000, 1000);
run("Select None");

selectWindow("C1-x");
run("Restore Selection");
run("Duplicate...", " ");
rename("A_" + k+1 + "_" + j);
run("Rotate... ", "angle=[rot] grid=1 interpolation=Bicubic");

selectWindow("C2-x");
run("Restore Selection");
run("Duplicate...", " ");
rename("B_" + k+1 + "_" + j);		
run("Rotate... ", "angle=[rot] grid=1 interpolation=Bicubic");		}		

close("R");
close("C1-x");
close("C2-x");		}		}   **
run("Images to Stack", "use");		
saveAs("Tif", res + "Stack");

makeRectangle(375, 438, 625, 124);
run("Crop");
rename("Sub_1");
run("Make Substack...");
rename("Sub_2");

selectImage("Sub_1");
run("Z Project...", "projection=[Average Intensity]");
run("Invert");
run("Magenta");
resetMinAndMax;
run("Enhance Contrast", "saturated=0.35");
run("Bandpass Filter...", "filter_large=625 filter_small=15 suppress=None tolerance=5");
run("Unsharp Mask...", "radius=15 mask=0.60");
resetMinAndMax;
run("Enhance Contrast", "saturated=0.35");
rename("cillium");
close("Sub_1");

selectImage("Sub_2");
run("Z Project...", "projection=[Average Intensity]");
run("Invert");
run("Green");
resetMinAndMax;
run("Enhance Contrast", "saturated=0.35");
run("Bandpass Filter...", "filter_large=625 filter_small=7 suppress=None tolerance=5");
run("Unsharp Mask...", "radius=15 mask=0.60");
resetMinAndMax;
run("Enhance Contrast", "saturated=0.35");
rename("funnel");
close("Sub_2");

run("Merge Channels...", "c1=funnel c2=cillium create");
run("Rotate 90 Degrees Left");
saveAs("Tif", res + "Composite");
run("Duplicate...", "duplicate");
run("Split Channels");
lst=getList("image.titles");
for (i = 0; i < lst.length; i++) {selectWindow(lst[i]);
run("RGB Color");		}
run("Images to Stack", "use");
run("Stack Sorter");
waitForUser("Reorder slices if needed");
run("Make Montage...", "columns=3 rows=1 scale=1 border=4");
run("Set Scale...", "distance=1 known=5 unit=nm");
run("Scale Bar...", "width=500 height=200 font=20 horizontal bold serif");
saveAs("Tif", res + "Cillium_Montage");
imlst=getList("image.titles");
for (i = 0; i < imlst.length; i++) {close(imlst[i]);	}		}


if(act=="Extracting brightness profiles") {open(res + "Composite.tif");
rename("x");
run("Split Channels");
run("Tile");

title1 = "Data"; 
title2 = "["+title1+"]"; 
f=title2; 
run("New... ", "name="+title2+" type=Table"); 
print(f,"\\Headings:Length\tAcross\tFunnel\tCilium"); 


for (j = 5; j < 18; j++) {H=j*30;
print(f,H);	
for (i = 0; i < 62; i++) {selectWindow("C1-x");
makeRectangle(i*2, H, 2, 10);
avr1=getValue("Mean");
selectWindow("C2-x");
makeRectangle(i*2, H, 2, 10);
avr2=getValue("Mean");
print(f,""+"\t"+(i*10+5)-310+"\t"+avr1+"\t"+avr2);	}	}

selectWindow("Data");
saveAs("Text", res + "Data.csv");
close("Data");	
imlst=getList("image.titles");
for (i = 0; i < imlst.length; i++) {close(imlst[i]);	}
showMessage("Make normalized graphs in Excell");		}



