Vue.directive('focus', {
  // When the bound element is inserted into the DOM...
  inserted: function (el) {
    // Focus the element
    onInputLoaded(el);
  }
})
new Vue({
	el: '#app',
	data:   {
		inputedText: ' ',
		cacheText: '',
		addingText: '',
		active:false,
		opacity:0,
		x:0,
		y:0,
		width:600,
		height:60,
		maxlength:20,
		object:null,
		debug:false
	},
	mounted () {
		window.setDisplay = this.setDisplay;    // 方法赋值给window
		window.Debug = this.Debug;
		window.setIMEPos = this.setIMEPos;
		window.setMaxLength = this.setMaxLength;
		window.setOpacity = this.setOpacity;
		window.onInputLoaded = this.onInputLoaded;
		window.updateText = this.updateText;
		window.backSpaceText = this.backSpaceText;
		window.clear = this.clear;
		window.updateFocus = this.updateFocus;
	},
	methods:{
		setDisplay (bool) {
			this.active = bool;
		},
		updateFocus() {
			if (this.object != null){this.object.focus();};
		},
		Debug () {
			this.width = 600;
			this.height = 60;
			this.debug = true;
			this.opacity = 100;
			this.x = 0.1*100;
			this.y = 0.1*100;
		},
		setIMEPos(x,y){
			this.x = x*100;
			this.y = y*100;
		},
		setMaxLength(length){
			this.maxlength = length;
		},
		setOpacity(val){
			this.opacity = val;	
		},
		clear(){
			this.inputedText = ' ';//'';
			if (this.object != null){this.object.focus();};
			
		},
		onInputLoaded(obj){
			let id = obj.id;
			this.object = obj;
			if (this.object != null){this.object.focus();};
			$("#"+id).css('ime-mode','auto');
		},
		updateText(txt){
			var t = this.addingText + txt
			if (t.length <= this.maxlength){
				this.addingText = this.addingText + txt;
			}
			this.clear();
			if (this.object != null){this.object.focus();};
		},
		backSpaceText(){
			
			this.addingText = this.addingText.substr(0,this.addingText.length - 1);
			if (this.object != null){this.object.focus();};
		},
		checkSelect (event) {
			$.post("https://nb-dialog/clear", JSON.stringify({string: this.inputedText.substr(1,this.inputedText.length )}));
			this.clear();
			this.addingText = '';
			if (this.object != null){this.object.focus();};
			let target = this.object ; //event.currentTarget;
			let targetId = target.id;
			target.focus();
			var len = $("#"+targetId).val().length;
			target.setSelectionRange(len,len);
			$("#"+targetId).val($("#"+targetId).val());
		},
		checkEnter (event) {
			let target = event.currentTarget;
			let targetId = target.id;
			$("#"+targetId).css('ime-mode','disabled');
			$.post("https://nb-dialog/enter", JSON.stringify({string: this.addingText }));
			onAction('closeInput');
			this.clear();
			this.addingText = '';
			
		},
		checkDelete (event) {
			this.backSpaceText();
			$.post("https://nb-dialog/delete", JSON.stringify({string: this.addingText }));
		}
	},
	watch:  {
		inputedText: function (txt) { 
			if(this.active) { 
				$.post("https://nb-dialog/update", 
				JSON.stringify({
					length: txt.length-1,
					string: txt.substr(1,txt.length),
					fullstring: this.addingText
				}));
				this.updateText(txt.substr(1,txt.length));
			};
		}
	}
})
function onAction(action,data)
{
    switch(action){
		
        case 'displayInput' : 
		{
            setDisplay(true);
            if ( data.debug ){
				Debug();
			}
            break;
        };
        case 'closeInput' : 
		{
            setDisplay(false);
            clear();
            break;
        };
        case 'setIMEPos' : 
		{
            setIMEPos(data.x,data.y);
            break;
        };
		case 'setMaxLength' : 
		{
            setMaxLength(data.maxlength);
            break;
        };
		case 'updateFocus' :
		{
			updateFocus();
			break;
		}
        default : break;
    }
}
window.onload = function(e){
window.addEventListener('message', (event) => {
    onAction(event.data.action,event.data);
    });
};