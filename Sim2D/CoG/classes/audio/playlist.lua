PLAYLIST					= const("PLAYLIST", "" ,  true);
PLAYLIST.SORT				= const("PLAYLIST.SORT", "" ,  true);
PLAYLIST.SORT.ALPHABETICAL	= "alphabetical";
PLAYLIST.SORT.RANDOM		= "random";
PLAYLIST.DEFAULT_NAME		= "Default";

local tPlaylist = {
	CurrentTrackIndex 	= {--set to zero in order to allow for fist incrementation
		[MUSIC.TYPE.GAME] = 0,
		[MUSIC.TYPE.MENU] = 0,
	},
};
local tPlaylists = {};

class "playlist" {

	__construct = function(this, sPlaylist, sMusicType, sSortMode)

		tPlaylists[this] = {
			CurrentIndex 	= 0,
			Name 			= (type(sPlaylist) == "string" and sPlaylist:gsub("%s", "") ~= "") and sPlaylist or PLAYLIST.DEFAULT_NAME,
			Order 			= {},
			SortMode		= PLAYLIST.SORT.isMyConst(sSortMode) and sSortMode or PLAYLIST.DEFAULT.SORT,
			Tracks 			= {},
			Type			= PLAYLIST.TYPE.isMyConst(sMusicType) and sMusicType or MUSIC.TYPE.GAME,
		};

	end,


	Add = function(this, sTrack, bSkipSort)
		local oPlaylist = tPlaylists[this];

		if (Music.TrackIsLoaded(oPlaylist.Type, sTrack) and not oPlaylist:TrackExists(sTrack)) then
			oPlaylist.Tracks[#oPlaylist.Tracks + 1] = sTrack;
		end

		if (not bSkipSort) then
			oPlaylist:Sort();
		end

	end,


	GetName = function(this)
		return tPlaylists[this].Name;
	end,


	GetNextTrack = function()
		local oPlaylist = tPlaylists[this];

		oPlaylist.CurrentIndex = oPlaylist.CurrentIndex + 1;

		if (oPlaylist.CurrentIndex > #oPlaylist.Order) then
			oPlaylist.CurrentIndex = 1;
		end

		return oPlaylist.Tracks[oPlaylist.Order[oPlaylist.CurrentIndex]];
	end,


	Remove = function(this)
	end,


	SetSortMode = function(this, sSortMode)

		if (MUSIC.SORT.isMyConst(sSortMode)) then
			tPlaylists[this].SortMode = sSortMode;
		end

	end,


	Sort = function(this)
		local oPlaylist = tPlaylists[this];

		if (oPlaylist.SortMode == MUSIC.SORT.ALPHABETICAL) then
			oPlaylist.Order = {};

			for nIndex, sTrack in pairs(#oPlaylist.Tracks) do
				oPlaylist.Order[#oPlaylist.Order + 1] = sTrack;
			end

		elseif (oPlaylist.SortMode == MUSIC.SORT.RANDOM) then
			oPlaylist.Order = {};

			for nIndex, sTrack in pairs(#oPlaylist.Tracks) do
				oPlaylist.Order[#oPlaylist.Order + 1] = sTrack;
			end

		end

	end,


	TrackExists = function(this, sTrack)
		local oPlaylist = tPlaylists[this];
		local bRet = false;

		for nIndex, sExistingTrack in pairs(oPlaylist.Tracks) do

			if (sTrack == sExistingTrack) then
				bRet = true;
				break;
			end

		end

		return bRet;
	end,
};
