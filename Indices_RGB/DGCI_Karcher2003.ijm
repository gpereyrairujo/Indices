////////////////////////////////////////////////////////////////////////////////////////////////////////
// Indices RGB
// 
// Dark Green Color Index (DGCI)
//
// Autor: Gustavo Pereyra Irujo - pereyrairujo.gustavo@conicet.gov.ar
// Licencia GNU AFFERO GENERAL PUBLIC LICENSE Version 3
// https://github.com/gpereyrairujo/Indices_RGB
//

setBatchMode(true);

// chequeos generales para todos los índices
nombre = getTitle();

// chequear si es un stack de imágenes
if (nSlices>1) {

	// si el stack tiene 4 canales, eliminar el canal 4 (probablemenente el canal 'alpha')
	if (nSlices==4) {
		setSlice(4);
		run("Delete Slice", "delete=channel");		
	}

	// si el stack no tiene 3 o 4 canales, dar error
	if (nSlices!=3) {
		exit("La imagen no tiene 3 o 4 canales (RGB o RGBA)")
	}
	
	// si el stack tiene 3 canales, convertir a RGB para procesar
	if (nSlices==3) {
		run("RGB Color");
		rename("imagen_rgb");
	}
}

// si no es un stack de imágenes
else {
	
	// chequear si es una imagen RGB
	if (indexOf(getInfo(), "Bits per pixel: 32 (RGB)") < 0) {
		exit("La imagen no es RGB")
	}

	// si es una imagen RGB, hacer una copia para procesar
	run("Duplicate...", "title=imagen_rgb");
}


// cálculo del índice
// [(H - 60)/60 + (1 - S) + (1 - B)]/3

// convertir de RGB a HSB
run("HSB Stack");

// separar canales y convertir las imágenes a 32 bits
// escalar los valores a -180 a 179 (hue) y 0-1 (saturation y brightness)
run("Stack to Images");

selectWindow("Hue");
rename('_h');
run("32-bit");
run("Divide...", "value=255");
run("Multiply...", "value=359");
setThreshold(180, 360);
run("Create Selection");
run("Subtract...", "value=360");
run("Select None");
resetThreshold();

selectWindow("Saturation");
rename('_s');
run("32-bit");
run("Divide...", "value=255");

selectWindow("Brightness");
rename('_b');
run("32-bit");
run("Divide...", "value=255");

// calcular índice
selectWindow("_h");
run("Subtract...", "value=60");
run("Divide...", "value=60");

selectWindow("_s");
run("Multiply...", "value=-1");
run("Add...", "value=1");

selectWindow("_b");
run("Multiply...", "value=-1");
run("Add...", "value=1");

imageCalculator("Add create 32-bit", "_h", "_s");
rename("_h+s");
imageCalculator("Add create 32-bit", "_h+s", "_b");
rename("_h+s+b");
run("Divide...", "value=3");

// cerrar ventanas
selectWindow("_h");
close();
selectWindow("_s");
close();
selectWindow("_b");
close();
selectWindow("_h+s");
close();

// resultado
selectWindow("_h+s+b");
rename("DGCI_" + nombre);
run("Enhance Contrast", "saturated=0.35");
setBatchMode(false);
