-- cancels auctions with less than 12 hours left
function AuctionCancel()
    DEFAULT_CHAT_FRAME:AddMessage("Processing Auctions to be cancelled");
	local o="owner";
    local p=GetNumAuctionItems(o);
    local i=p;
    local count = 0;
    while (i>0) do
        local _,_,c,_,_,_,_,_,_,b,_,_=GetAuctionItemInfo(o,i); 
        local t=GetAuctionItemTimeLeft(o,i);
        if((c>0)and(b==0)and(t<4))then 
            CancelAuction(i);
            count = count+ 1;
        end;
        i=i-1;
    end;
    DEFAULT_CHAT_FRAME:AddMessage(count .. " Auctions cancelled");
    return true;
end

function initialize()
-- List of commands
	SlashCmdList["acancel"] = accommand();
	auction_cancel = "/acancel";
    DEFAULT_CHAT_FRAME:AddMessage("acancel commands loaded");
end

function accommand(msg)
    if (msg == "ac") then
        AuctionCancel();
    end
end

initialize();