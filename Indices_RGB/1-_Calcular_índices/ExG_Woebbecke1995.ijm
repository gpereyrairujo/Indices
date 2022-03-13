////////////////////////////////////////////////////////////////////////////////////////////////////////
// Indices RGB
// 
// Excess Green (ExG) (Woebbecke et al. 1995)
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

// separar canales y convertir las imágenes a 32 bits
run("Split Channels");
selectWindow("imagen_rgb (red)");
rename('_r');
run("32-bit");
selectWindow("imagen_rgb (green)");
rename('_g');
run("32-bit");
selectWindow("imagen_rgb (blue)");
rename('_b');
run("32-bit");

// normalizar los valores por la suma de todos los canales
imageCalculator("Add create 32-bit", "_r", "_g");
rename("_r+g");
imageCalculator("Add create 32-bit", "_r+g", "_g");
rename("_r+g+b");
imageCalculator("Divide create 32-bit", "_r", "_r+g+b");
rename("_rn");
imageCalculator("Divide create 32-bit", "_g", "_r+g+b");
rename("_gn");
imageCalculator("Divide create 32-bit", "_b", "_r+g+b");
rename("_bn");

// calcular índice
selectWindow("_gn");
run("Multiply...", "value=2");
rename("_2gn");
imageCalculator("Subtract create 32-bit", "_2gn", "_rn");
rename("_2gn-rn");
imageCalculator("Subtract create 32-bit", "_2gn-rn", "_bn");
rename("_2gn-rn-bn");

// mostrar nuevamente imagen original
selectWindow(nombre);
setBatchMode("show");

// resultado
selectWindow("_2gn-rn-bn");
rename("ExG_" + nombre);
run("Enhance Contrast", "saturated=0.35");
setBatchMode("show");
