function switchMenu(obj) {
		var el = document.getElementById(obj);
		if(el.style.display != "none") el.style.display = 'none';
		else el.style.display = '';
		for(var i=1;i<=7;i++){
			if("m"+i != obj){
				el = document.getElementById("m"+i);
				el.style.display = 'none';
				}
			}
		}