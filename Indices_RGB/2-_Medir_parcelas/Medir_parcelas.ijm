var intersectionx=1;
var intersectiony=1;

macro "Parcelas" {

run("Set Measurements...", "area mean standard centroid median min max display redirect=None decimal=3");

columns=4;
rows=3;
xborder=0.25;
yborder=0.25;

do {

	Dialog.createNonBlocking("Delimitar parcelas");
		Dialog.addMessage("Con la herramienta Multi-point seleccione los 4 vértices\ncomenzando arriba a la izquierda y en sentido horario");
		Dialog.addNumber("Columnas", columns, 0, 5,"");
		Dialog.addNumber("Filas", rows, 0, 5,"");
		Dialog.addNumber("Bordura columnas", xborder, 2, 5,"");
		Dialog.addNumber("Bordura filas", yborder, 2, 5,"");
		Dialog.show();

	getSelectionCoordinates(xcoord, ycoord);
	if(lengthOf(xcoord)!=4) exit("Error: se requieren 4 puntos");
	
	columns=Dialog.getNumber();
	rows=Dialog.getNumber();
	xborder=Dialog.getNumber();
	yborder=Dialog.getNumber();
	
	plots(xcoord, ycoord, false);
	
	correct = getBoolean("¿Es correcta la delimitación de las parcelas?");

} while (!correct);

plots(xcoord, ycoord, true);

//for (i=0;i<4;i++) {
//	setResult("Vert X", nResults, xcoord[i]);
//	setResult("Vert Y", nResults-1, ycoord[i]);
//	updateResults();
//	}

}

function plots(xcoord, ycoord, measure) {

	Overlay.remove;
	
	xtopleft=xcoord[0];
	ytopleft=ycoord[0];
	xtopright=xcoord[1];
	ytopright=ycoord[1];
	xbottomright=xcoord[2];
	ybottomright=ycoord[2];
	xbottomleft=xcoord[3];
	ybottomleft=ycoord[3];
	
	xoffset_top=(xtopright-xtopleft)/columns;
	xoffset_right=(xbottomright-xtopright)/rows;
	xoffset_bottom=(xbottomright-xbottomleft)/columns;
	xoffset_left=(xbottomleft-xtopleft)/rows;
	
	yoffset_top=(ytopright-ytopleft)/columns;
	yoffset_right=(ybottomright-ytopright)/rows;
	yoffset_bottom=(ybottomright-ybottomleft)/columns;
	yoffset_left=(ybottomleft-ytopleft)/rows;

	font_size = (abs(xoffset_top)+abs(xoffset_right)+abs(xoffset_bottom)+abs(xoffset_left)+abs(yoffset_top)+abs(yoffset_right)+abs(yoffset_bottom)+abs(yoffset_left))/8/5;
	
	for(i=0; i<columns+1; i++) {
		Overlay.drawLine(xtopleft+xoffset_top*i, ytopleft+yoffset_top*i, xbottomleft+xoffset_bottom*i, ybottomleft+yoffset_bottom*i);
		Overlay.add;
		}
	
	for(i=0; i<rows+1; i++) {
		Overlay.drawLine(xtopright+xoffset_right*i, ytopright+yoffset_right*i, xtopleft+xoffset_left*i, ytopleft+yoffset_left*i);
		Overlay.add;
		}
	
	for(j=0; j<rows; j++) {
		for(i=0; i<columns; i++) {
			plot_left=i+xborder;
			plot_right=i+1-xborder;
			plot_top=j+yborder;
			plot_bottom=j+1-yborder;
	
			intersection(xtopleft+xoffset_top*plot_left, ytopleft+yoffset_top*plot_left, xbottomleft+xoffset_bottom*plot_left, ybottomleft+yoffset_bottom*plot_left,xtopright+xoffset_right*plot_top, ytopright+yoffset_right*plot_top, xtopleft+xoffset_left*plot_top, ytopleft+yoffset_left*plot_top);
			pxtopleft= intersectionx;
			pytopleft= intersectiony;
	
			intersection(xtopleft+xoffset_top*plot_left, ytopleft+yoffset_top*plot_left, xbottomleft+xoffset_bottom*plot_left, ybottomleft+yoffset_bottom*plot_left,xtopright+xoffset_right*plot_bottom, ytopright+yoffset_right*plot_bottom, xtopleft+xoffset_left*plot_bottom, ytopleft+yoffset_left*plot_bottom);
			pxtopright= intersectionx;
			pytopright= intersectiony;
	
				
			intersection(xtopleft+xoffset_top*plot_right, ytopleft+yoffset_top*plot_right, xbottomleft+xoffset_bottom*plot_right, ybottomleft+yoffset_bottom*plot_right,xtopright+xoffset_right*plot_bottom, ytopright+yoffset_right*plot_bottom, xtopleft+xoffset_left*plot_bottom, ytopleft+yoffset_left*plot_bottom);
			pxbottomright= intersectionx;
			pybottomright= intersectiony;
					
			intersection(xtopleft+xoffset_top*plot_right, ytopleft+yoffset_top*plot_right, xbottomleft+xoffset_bottom*plot_right, ybottomleft+yoffset_bottom*plot_right,xtopright+xoffset_right*plot_top, ytopright+yoffset_right*plot_top, xtopleft+xoffset_left*plot_top, ytopleft+yoffset_left*plot_top);
			pxbottomleft= intersectionx;
			pybottomleft= intersectiony;
	
			Overlay.drawLine(pxtopleft,pytopleft,pxtopright,pytopright);
			Overlay.add;
			Overlay.drawLine(pxtopright,pytopright,pxbottomright,pybottomright);
			Overlay.add;
			Overlay.drawLine(pxbottomright,pybottomright,pxbottomleft,pybottomleft);
			Overlay.add;
			Overlay.drawLine(pxbottomleft,pybottomleft,pxtopleft,pytopleft);
			Overlay.add;
			makePolygon(pxtopleft, pytopleft, pxtopright, pytopright, pxbottomright, pybottomright, pxbottomleft, pybottomleft);

			plot = ""+j+1+"-"+i+1;
			xcenter = (pxtopleft+pxbottomright)/2;
			ycenter = (pytopleft+pybottomright)/2;
			setFont("SanSerif", font_size, "antialiased");
  			setColor("blue");
			Overlay.drawString(plot, xcenter, ycenter);
			Overlay.add;
			
			if (measure) {
				run("Measure");
				setResult("Fila", nResults-1, j+1);
				setResult("Columna", nResults-1, i+1);
				setResult("Parcela", nResults-1, plot);
				updateResults();
				}
	
			}
		}
	Overlay.show;
	
	makeSelection("point", xcoord, ycoord);

}


function intersection(xa,ya,xb,yb,xc,yc,xd,yd) {

	slope_ab=(yb-ya)/(xb-xa);
	intercept_ab=ya-slope_ab*xa;
	slope_cd=(yd-yc)/(xd-xc);
	intercept_cd=yc-slope_cd*xc;
	x=(intercept_cd-intercept_ab)/(slope_ab-slope_cd);
	y=intercept_ab+slope_ab*x;
	intersectionx=x;
	intersectiony=y;
	}

