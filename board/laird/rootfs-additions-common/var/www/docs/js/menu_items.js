// items structure
// each item is the array of one or more properties:
// [text, link, settings, subitems ...]
// use the builder to export errors free structure if you experience problems with the syntax

var MENU_ITEMS = [
	['NEWS', 'http://www.summitdatacom.com/press_room.htm'],
	['<span class="menuBorder">|',''],
	['PRODUCTS', 'http://www.summitdatacom.com/product.htm', null,		
		['802.11a/g Modules', null, null,
			['SDC-CF10AG', 'http://www.summitdatacom.com/SDC-CF10AG.htm'],
			['SDC-PC10AG', 'http://www.summitdatacom.com/SDC-PC10AG.htm'],
			['SDC-MSD10AG', 'http://www.summitdatacom.com/SDC-MSD10AG.htm'],
			['SDC-MCF10AG', 'http://www.summitdatacom.com/SDC-MCF10AG.htm'],
			['SDC-MSD30AG', 'http://www.summitdatacom.com/SDC-MSD30AG.htm'],
			['SDC-SSD30AG', 'http://www.summitdatacom.com/SDC-SSD30AG.htm']
		],
		['802.11a/g Cards', null, null,
			['SDC-CF22AG', 'http://www.summitdatacom.com/SDC-CF22AG.htm'],
			['SDC-PC22AG', 'http://www.summitdatacom.com/SDC-PC22AG.htm']
		],
		['802.11g Modules', null, null,
			['SDC-CF10G', 'http://www.summitdatacom.com/SDC-CF10G.htm'],
			['SDC-PC10G', 'http://www.summitdatacom.com/SDC-PC10G.htm'],
			['SDC-MCF10G', 'http://www.summitdatacom.com/SDC-MCF10G.htm'],
			['SDC-MSD10G', 'http://www.summitdatacom.com/SDC-MSD10G.htm']
		],
		['802.11g Cards', null, null,
			['SDC-CF20G', 'http://www.summitdatacom.com/SDC-CF20G.htm'],
			['SDC-CF22G', 'http://www.summitdatacom.com/SDC-CF22G.htm'],
			['SDC-PC20G', 'http://www.summitdatacom.com/SDC-PC20G.htm']
		],
		['802.11n Modules', 'http://www.summitdatacom.com/SDC-PE15N.htm', null,
			['SDC-PE15N', 'http://www.summitdatacom.com/SDC-PE15N.htm'],
		],		
		['802.11n Cards', null, null,
			['SDC-EC15N', 'http://www.summitdatacom.com/SDC-EC15N.htm'],
			['SDC-EC25N', 'http://www.summitdatacom.com/SDC-EC25N.htm']
		],
		['Adapter Card', 'http://www.summitdatacom.com/SDC-PC2CF10_PCMCIA.htm', null],
		['Capabilities', 'http://www.summitdatacom.com/capabilities.htm']
		],
	['<span class="menuBorder">|',''],
	['SUPPORT', null, null,
		['Help', 'http://www.summitdatacom.com/support.htm'],
		['Software', 'http://www.summitdatacom.com/software_director.php'],
		['Documentation', 'http://www.summitdatacom.com/documentation.htm'],
		['Certifications', 'http://www.summitdatacom.com/certifications.htm']
		],
	['<span class="menuBorder">|',''],
	['RESOURCES', null, null,
		//['Our Company', 'http://www.summitdatacom.com/about.htm'],
		//['Partners', 'http://www.summitdatacom.com/partners.htm'],
		['News', 'http://www.summitdatacom.com/press_room.htm',null,
			['2010 News', 'http://www.summitdatacom.com/press_room.htm'],
			['2009 News', 'http://www.summitdatacom.com/press_room2009.htm'],
			['2008 News', 'http://www.summitdatacom.com/press_room2008.htm'],
			['2007 News', 'http://www.summitdatacom.com/press_room2007.htm'],
			['2006 News', 'http://www.summitdatacom.com/press_room2006.htm']
			],
		['Customers', 'http://www.summitdatacom.com/Customers.htm'],
		['Knowledge Center','http://www.summitdatacom.com/Documents/Glossary/index.html'],
		['White Papers', 'http://www.summitdatacom.com/whitepapers.htm'],
		['Webinars', 'http://www.summitdatacom.com/webinars.htm'],
		//['Contact Us', 'http://www.summitdatacom.com/contact.htm'],
		['Newsletter', 'http://www.summitdatacom.com/newsletter/']
		],
	['<span class="menuBorder">|',''],
	['HOW TO BUY', 'http://www.summitdatacom.com/how_to_buy.htm']
	
];
