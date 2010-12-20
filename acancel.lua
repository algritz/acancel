-- cancels auctions corresponding to certains critera
-- 1.0 : cancel auctions with less than 12 hours left
function AuctionCancel()
    DEFAULT_CHAT_FRAME:AddMessage("Processing Auctions to be cancelled");
	local o="owner";
    local p=GetNumAuctionItems(o);
    local i=p;
    local count = 0;
    local messageCache = "";
    local messageCacheCount = 1;
    local messageCacheCompetition = "";
    local messageCacheCountCompetition = 1;
    
    while (i>0) do
        local name,_,c,_,_,_,_,_,bo,b,d,_,s=GetAuctionItemInfo(o,i); 
        local t=GetAuctionItemTimeLeft(o,i);
        local itemLink = GetAuctionItemLink(o, i);
        
        boFormatted = formatValue(bo);
        
        -- returns the current market value
        local itemMarketValue = AucAdvanced.API.GetMarketValue(itemLink);
        local itemMarketValueFormatted = formatValue(itemMarketValue);
        
        -- fetches the undercut array information
        local undercutType = AucAdvanced.Modules.Match.Undercut.GetMatchArray(itemLink, itemMarketValue);
        local undercutTypeString = undercutType.returnstring;
        local competitionValue = undercutType.value;
        local competitionValueFormatted = formatValue(competitionValue);
        local numberOfCompetitor = undercutType.competing
        local currentMessage = "";
        local currentMessageCompetition = "";
        local differenceInPrice = 0;
        local differencePercentage = 0;
        
        undercutTypeString = string.lower(undercutTypeString);
        if ((strfind(undercutTypeString, "%f[%w]".. "can not" .. "%f[%W]") or strfind(undercutTypeString, "%f[%w]".. "cannot" .. "%f[%W]"))) then
            
            -- Since we can't undercut, we check if its worth to repost at an higher price
            differenceInPrice = competitionValue - bo;
            differencePercentage = differenceInPrice / bo;
            if differencePercentage >= 0.10 then
                -- we've been undercut too low to cancel, we're just giving an information
                currentMessage = "Undercut on : " .. name .. " but at a too low value to keep at current price, so cancelling x " ;
                CancelAuction(i);
                count = count+ 1;
            else
                -- we've been undercut too low to cancel, we're just giving an information
                currentMessage = "Undercut on : " .. name .. " but at a too low value to undercut, but too close to current price to repost x " ;
            end
                    
            -- caches the messages sent to avoid spam
            if currentMessage ~= messageCache then
                DEFAULT_CHAT_FRAME:AddMessage(messageCache .. messageCacheCount);
                messageCacheCount = 1;
                messageCache = currentMessage;
            else
                messageCacheCount = messageCacheCount + 1;
            end
            
        else
            -- now that we have eliminated auctions that cannot be undercut, we proceed to find those that could be cancelled to be reposted at an higher price
            
            -- finds auctions that we've been undercut
            if bo > competitionValue and numberOfCompetitor > 1 then
                -- checks if auction has a bid on it
                if b == 0 then
                    currentMessageCompetition = "There seems to be competition on : " .. name .. " at : " .. competitionValueFormatted .. " x "
                    CancelAuction(i);
                    count = count+ 1;
                else
                    currentMessageCompetition = "Did not cancel auction of : " .. name .. "because there is a bid on it"
                end
                -- caches the messages sent to avoid spam
                if currentMessageCompetition ~= messageCacheCompetition then
                    DEFAULT_CHAT_FRAME:AddMessage(currentMessageCompetition .. messageCacheCountCompetition);
                    messageCacheCountCompetition = 1;
                    messageCacheCompetition = currentMessageCompetition;
                else
                    messageCacheCountCompetition = messageCacheCountCompetition + 1;
                end
            else
                if numberOfCompetitor == 1 and bo < competitionValue then
                    -- check if onlyone to post item and if we can drive the price up by reposting
                    differenceInPrice = competitionValue - bo;
                    differencePercentage = differenceInPrice / bo;
                    if differencePercentage >= 0.02 then
                        DEFAULT_CHAT_FRAME:AddMessage("You are the only one posting " .. name .. " resposting at an higher value");
                        CancelAuction(i);
                        count = count+ 1;
                    else
                        DEFAULT_CHAT_FRAME:AddMessage("You are the only one posting " .. name .. " didn't repost as new price as too close to previous price");
                    end
                else
                    if numberOfCompetitor == 1 then
                        -- check if onlyone to post item and if we can drive the price up by reposting
                        DEFAULT_CHAT_FRAME:AddMessage("You are the only one posting " .. name .. " your price is currently the highest value");
                    else
                        -- There is more than 1 competitor, but the current price is the best price we can "offer"
                        DEFAULT_CHAT_FRAME:AddMessage("There is more than one competitor on " .. name .. " your price is currently the best deal (assuming you are withing undercut range)");
                    end
                end
            end
        end
        -- cancels auction with less than 12 hours left
        if((c>0)and(b==0)and(t<4))then 
            CancelAuction(i);
            -- number of cancelled auctions
            count = count+ 1;
        end;
        i=i-1;
    end;
    -- output the number of cancelled auctions
    DEFAULT_CHAT_FRAME:AddMessage(count .. " Auctions cancelled");
    return true;
end


-- this function will return a price in a human-readble format
function formatValue(itemValue)
    local gold = itemValue / 10000;
    gold = math.floor(gold);
    local remainder = itemValue % 10000;
    local silver = remainder / 100;
    silver = math.floor(silver);
    remainder = remainder % 100;
    local copper = remainder;
    copper = math.floor(copper);
    
    local itemValueFormatted = gold .. "g" .. silver .. "s" .. copper .. "c";
    
    return itemValueFormatted
end
