#TEST NAMES
ARTICLE_TAP_CONST = 0
ARTICLESWIPE_CONST = 1
SAVED_ARTICLE_CONST = 2
ARTICLE_LINK_GALLERY_CONST = 3
ARTICLE_LINK_VIDEO_CONST = 4
REFRESH_CONTENT_CONST = 5
SETTINGS_ACCT_MGT_CONST = 6
BREAKING_NEWS_ALERT_CONST = 7 
MENU_TAP_CONST = 8
WEATHER_LOCATIONS_CONST = 9
LAUNCHAPP_CONST = 10

CONTENT_TYPE = Array.new(12,0) #MAKE SURE THIS UPPER BOUND EQUALS THE CONSTANT COUNT
CONTENT_TYPE[LAUNCHAPP_CONST] = "SECTIONFRONT"
CONTENT_TYPE[ARTICLESWIPE_CONST] = "ARTICLE"
CONTENT_TYPE[SAVED_ARTICLE_CONST] = "ARTICLE"
CONTENT_TYPE[ARTICLE_LINK_GALLERY_CONST] = "GALLERIES"
CONTENT_TYPE[ARTICLE_LINK_VIDEO_CONST] = "VIDEO"
CONTENT_TYPE[REFRESH_CONTENT_CONST] = "SECTIONFRONT"
CONTENT_TYPE[BREAKING_NEWS_ALERT_CONST] = "SETTINGS"
CONTENT_TYPE[MENU_TAP_CONST] = "GALLERIES"
CONTENT_TYPE[WEATHER_LOCATIONS_CONST] = "WEATHER"
CONTENT_TYPE[ARTICLE_TAP_CONST] = "ARTICLE"
CONTENT_TYPE[SETTINGS_ACCT_MGT_CONST] = "SETTINGS"


class My3Array

  def initialize
    @store = [[[]]]
  end

  def []sizee
    if @store[a]==nil ||
       @store[a][b]==nil ||
       @store[a][b][c]==nil
      return nil
    else
      return @store[a][b][c].size
    end
  end

  def [](a,b,c)
    if @store[a]==nil ||
       @store[a][b]==nil ||
       @store[a][b][c]==nil
      return nil
    else
      return @store[a][b][c]
    end
  end

  def []=(a,b,c,x)
    @store[a] = [[]] if @store[a]==nil
    @store[a][b] = [] if @store[a][b]==nil
    @store[a][b][c] = x
  end

end









