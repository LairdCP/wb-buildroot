// level scope settins structure
var MENU_TPL = [
// root level configuration (level 0)
{
	// item sizes
	'height':20,
	'width': 110,//100
	// absolute position of the menu on the page (in pixels)
	// with centered content use Tigra Menu PRO or Tigra Menu GOLD
	'block_top':  -10,
	'block_left': -23, 
	
	

	// offsets between items of the same level (in pixels)
	'top': 0,
	'left': 91,
	// time delay before menu is hidden after cursor left the menu (in milliseconds)
	'hide_delay': 400,
	// submenu expand delay after the rollover of the parent 
	'expd_delay': 200,
	// names of the CSS classes for the menu elements in different states
	// tag: [normal, hover, mousedown]
	'css' : {
		'outer' : ['m0l0oout', 'm0l0oover'],
		'inner' : ['m0l0iout', 'm0l0iover']
	}
},
// sub-menus configuration (level 1)
// any omitted parameters are inherited from parent level
{
	'height': 24,
	'width': 181,
	// position of the submenu relative to top left corner of the parent item
	'block_top': 25,
	'block_left': -29,
	'top': 23,
	'left': 0,
	'css' : {
		'outer' : ['m0l1oout', 'm0l1oover'],
		'inner' : ['m0l1iout', 'm0l1iover']
	}
},
// sub-sub-menus configuration (level 2)
{
	'height': 23,
	'width': 181,
	'block_top': 0,
	'block_left': 182,
	'css': {
		'outer': ['m0l2oout', 'm0l2oover'],
		'inner': ['m0l1iout', 'm0l2iover']
	}
},

// sub-sub-menus configuration (level 3)
{
	'height': 28,
	'width': 200,
	'block_top': 5,
	'block_left': 150
}

// the depth of the menu is not limited
// make sure there is no comma after the last element
];
