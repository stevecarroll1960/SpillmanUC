application = 
{
	content = 
	{ 
		width = 320,
		height = 480,
		scale = "none",
		fps = 30,
		
		--imageSuffix = {
		--	["@2x"] = 2,
		--}
	},

	notification =
    {
        google = 
        { 
        	projectNumber = "819373458497" 
        },
        
        iphone =
        {
            types =
            {
                "badge", "sound", "alert"
            }
        }
    }
}