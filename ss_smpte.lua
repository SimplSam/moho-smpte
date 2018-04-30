--[[

  SS_SMPTE - Graphical SMPTE Timecode overlay for Moho Animations
  
	version: MH12 02.00.000 #480430.01       -- by Sam Cogheil (SimplSam)
	release: v2.0.0
  
]]

--[[ 

	***** Licence & Warranty *****

	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License
	Please see: http://creativecommons.org/licenses/by-sa/4.0

	Copyright (C) 2018 SimplSam

	You are free to use this code and software Under the following terms & conditions:

	    Use (as-is) Freely
	    Adapt remix, transform, and build upon the material for any purpose, even commercially
	    Share copy and redistribute the material in any medium or format

	    Attribution — You must give appropriate credit, provide a link to the CC license, and
	    indicate if changes were made. You may do so in any reasonable manner, but not in any
	    way that suggests the licensor endorses you or your use.

	    ShareAlike — If you remix, transform, or build upon the material, you must distribute
	    your contributions under the same license as the original.

	    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	    SOFTWARE.

]]

--[[

    ***** How To Use *****

    This is a MOHO (Anime Studio) Layer script

    Supported platforms: Moho 12 Pro, AS11 Pro, AS10 Pro. This has not been tested on any other versions.
        
	To install/use:

	  (00) - Save the 'SS_SMPTE.lua' file to your computer file system
	  (01) - In Moho on a VECTOR Layer use Layer Settings and Select [General] > [Embedded script file] and select the Saved 'SS_SMPTE.lua' file
	   .. You will now be presented with a Style dialog for the look and feel of the SMPTE overlay text. Set your preferences and click OK
	  (99) - On your timeline Press 'Play' -- Sit back and Enjoy the magic!


    Sizing/Orientation:

        You can set the Size, Position, Orientation of the SMPTE overlay by setting Transforming the SMPTE Layer (Transform Layer tool) @ Frame 0
        To increase styling options, place the SMPTE Layer inside a Group layer, and manipulate the Group Layer as usual, or add additional background layers etc.
        To edit the current Style (Colour etc) -- Create a Marker (empty/any text) on the SMPTE Layer at Frame 0. Or simply remove and then re-add the layer script (the current settings will be preserved).

	Known issues:

	    Jumpy Text moho buglet: Text will be slightly jumpy (even with a Fixed font) -- unless the SMPTE text is postfixed with a non-whitespace character
	    - To work around jumpiness, try adding some spaces and a trailing dot '    .' postfix, and then position the SMPTE Layer such that the dot is offscreen, or enclose with preferred prefix '[' & postfix ']' (for example)
	    - Alternatively - you can use group layer masking to hide the dot (or other postfix character)
]]

--[[

	***** SPECIAL THANKS to:

	*    Stan: MOHO Scripting -- http://mohoscripting.com
	*    The friendly faces @ Lost Marble Moho forum -- http://www.lostmarble.com/forum/

	*****

]]

-- **************************************************
-- Let the Party begin!
-- **************************************************

-- **************************************************************************
-- Globally accessible (global) variables
-- **************************************************************************
gSS_SMPTE = {}
gSS_SMPTE.gFrm = {}

-- **************************************************************************
-- Globally accessible (local) variables
-- **************************************************************************
local SS_SMPTE = {} --Local

SS_SMPTE.popFrame = 0
SS_SMPTE.isDialogVisible = false
SS_SMPTE.showDialog = false

-- SMPTE Display Defaults
SS_SMPTE.postfix = " "
SS_SMPTE.prefix = " "
SS_SMPTE.fontname = "Verdana Regular"
SS_SMPTE.fillcol = LM.rgb_color:new_local()
SS_SMPTE.fillcol.r = 54
SS_SMPTE.fillcol.g = 54
SS_SMPTE.fillcol.b = 54
SS_SMPTE.fillcol.a = 54
SS_SMPTE.linecol = LM.rgb_color:new_local()
SS_SMPTE.linecol.r = 54
SS_SMPTE.linecol.g = 54
SS_SMPTE.linecol.b = 54
SS_SMPTE.linecol.a = 255
SS_SMPTE.linewid = 4
SS_SMPTE.nameoverlay = true
SS_SMPTE.firstframe0 = true
SS_SMPTE.chkfillcol = true
SS_SMPTE.chklinecol = true

local firstRun =false  --< Is this instance invocation the first run?
local hasRun = false   --< Has this instance ever run?
local didoSettings = false

-- **************************************************
-- Define Settings Dialog
-- **************************************************

local SS_SMPTE_Dialog = {}

SS_SMPTE_Dialog.UPDATE = MOHO.MSG_BASE
SS_SMPTE_Dialog.UPDATE_CHK = MOHO.MSG_BASE+1

function SS_SMPTE_Dialog:new(moho)
    local d = LM.GUI.SimpleDialog("SMPTE Display Properties", SS_SMPTE_Dialog)
    local l = d:GetLayout()

    d.moho = moho
    l:PushH()
        l:PushV()
            l:PushH()
                l:PushV()
                    l:AddChild(LM.GUI.StaticText("Prefix text"), LM.GUI.ALIGN_LEFT)
                    l:AddChild(LM.GUI.StaticText("Postfix text"), LM.GUI.ALIGN_LEFT)
                    d.chkfillcol = LM.GUI.CheckBox("Fill", self.UPDATE_CHK)
                    l:AddChild(d.chkfillcol, LM.GUI.ALIGN_LEFT)
                    d.chklinecol = LM.GUI.CheckBox("Stroke", self.UPDATE_CHK)
                    l:AddChild(d.chklinecol, LM.GUI.ALIGN_LEFT)
                    l:AddChild(LM.GUI.StaticText("Width"), LM.GUI.ALIGN_LEFT)
                l:Pop()
                l:PushV()
                    d.prefix = LM.GUI.TextControl(40, "  ", self.UPDATE, LM.GUI.FIELD_TEXT)
                    l:AddChild(d.prefix, LM.GUI.ALIGN_LEFT)
                    d.postfix = LM.GUI.TextControl(40, "  ", self.UPDATE, LM.GUI.FIELD_TEXT)
                    l:AddChild(d.postfix, LM.GUI.ALIGN_LEFT)
                    d.fillcol = LM.GUI.ColorSwatch(true, 0)
                    l:AddChild(d.fillcol)
                    d.linecol = LM.GUI.ColorSwatch(true, 0)
                    l:AddChild(d.linecol)
                    d.linewid = LM.GUI.TextControl(40, "4", 0, LM.GUI.FIELD_UFLOAT)
                    l:AddChild(d.linewid, LM.GUI.ALIGN_LEFT)
                l:Pop()
                l:PushV()
                    l:AddChild(LM.GUI.StaticText(" - (Option) Add text before SMPTE text"), LM.GUI.ALIGN_LEFT)
                    l:AddChild(LM.GUI.StaticText(" - (Option) Add text after SMPTE text"), LM.GUI.ALIGN_LEFT)
                    l:AddChild(LM.GUI.StaticText(" - Set the Fill Colour or Disable it"), LM.GUI.ALIGN_LEFT)
                    l:AddChild(LM.GUI.StaticText(" - Set the Line Colour or Disable it"), LM.GUI.ALIGN_LEFT)
                    l:AddChild(LM.GUI.StaticText(" - Set the Line thickness"), LM.GUI.ALIGN_LEFT)
                l:Pop()

            l:Pop()
            l:AddChild(LM.GUI.Divider(false), LM.GUI.ALIGN_FILL)
            d.nameoverlay = LM.GUI.CheckBox("Overlay SMPTE text on Layer name")
            l:AddChild(d.nameoverlay, LM.GUI.ALIGN_LEFT)
            d.fontPreview = MOHO.FontPreview(64, 64)
            d.firstframe0 = LM.GUI.CheckBox("First frame is 000 (otherwise 001)")
            l:AddChild(d.firstframe0, LM.GUI.ALIGN_LEFT)
            l:AddChild(d.fontPreview, LM.GUI.ALIGN_FILL)
        l:Pop() --V
        l:AddPadding(16)
        d.fontList = LM.GUI.TextList(300, 64, self.UPDATE)
        l:AddChild(d.fontList, LM.GUI.ALIGN_FILL)
        moho:FillInFontList(d.fontList)
    l:Pop() --H

    return d
end

function SS_SMPTE_Dialog:UpdateWidgets()
    self.prefix:SetValue(SS_SMPTE.prefix)
    self.postfix:SetValue(SS_SMPTE.postfix)
    self.linewid:SetValue(SS_SMPTE.linewid)
    self.nameoverlay:SetValue(SS_SMPTE.nameoverlay)
    self.firstframe0:SetValue(SS_SMPTE.firstframe0)
    self.chkfillcol:SetValue(SS_SMPTE.chkfillcol)
    self.chklinecol:SetValue(SS_SMPTE.chklinecol)
    self.fillcol:SetValue(SS_SMPTE.fillcol)
    self.linecol:SetValue(SS_SMPTE.linecol)  
    if (not self.fontList:SetSelItem(SS_SMPTE.fontname)) then
      self.fontList:SetSelItem(0)
    end
    self:HandleMessage(self.UPDATE)
end

function SS_SMPTE_Dialog:OnValidate()
    local b = true
    if (not self:Validate(self.linewid, 0.25, 16)) then
        b = false
    end
    return b
end

function SS_SMPTE_Dialog:HandleMessage(what)
    if (what == self.UPDATE) then
        self.fontPreview:SetPreviewText(self.prefix:Value() .. "00:00:01:23" .. self.postfix:Value())
        self.fontPreview:SetFontName(self.fontList:SelItemLabel())
        self.fontPreview:Refresh()
    elseif (what == self.UPDATE_CHK) then
        self.fillcol:Enable(self.chkfillcol:Value())
        self.linecol:Enable(self.chklinecol:Value())
    end
end

function SS_SMPTE_Dialog:OnOK()
    SS_SMPTE.prefix = self.prefix:Value()
    SS_SMPTE.postfix = self.postfix:Value()
    SS_SMPTE.linewid = LM.Clamp(self.linewid:FloatValue(), 0.25, 256)
    SS_SMPTE.nameoverlay = self.nameoverlay:Value()
    SS_SMPTE.firstframe0 = self.firstframe0:Value()
    SS_SMPTE.chkfillcol = self.chkfillcol:Value()
    SS_SMPTE.chklinecol = self.chklinecol:Value()
    SS_SMPTE.fillcol = self.fillcol:Value()
    SS_SMPTE.linecol = self.linecol:Value()
    SS_SMPTE.fontname = self.fontList:SelItemLabel()
end


-- **************************************************
-- The guts of this script
-- **************************************************

function LayerScript(moho)
    local mohoName = moho.document:Name()
    local mohoNameUnique = mohoName .. "--" ..moho.document:LayerAbsoluteID(moho.layer)

    local gSet = false 
    local ssUpdated = false

    if (SS_SMPTE_n) then
        SS_SMPTE_n = SS_SMPTE_n + 1
    else
        SS_SMPTE_n = 1
    end
    local SS_SMPTE_i 
    SS_SMPTE_i = SS_SMPTE_n
    --local SS_SMPTE_ii = SS_SMPTE_n

    -- Only works with Vector layers
    if ((moho.layer:LayerType() ~= MOHO.LT_VECTOR)) then
         return false     
    end
    local vecLayer = moho:LayerAsVector(moho.layer)


    local ScriptInfo    
    if (moho.layer.ScriptData) then  --> AS11+
        ScriptInfo = moho.layer:ScriptData() 
    else
        if (moho.layer.Metadata) then --> AS9.5+~
            ScriptInfo = moho.layer:Metadata()
        else
            print("SS SMPTE ERROR: 'Cannot Get/Set ScriptInfo' - Your version of Moho/Anime may be incorrect")
            return
        end      
    end

    firstRun = ScriptInfo:GetBool("NewLayerScript")
    if ((firstRun == true) and (hasRun == false)) then
        ScriptInfo:Set("NewLayerScript", false)
        hasRun = true
        
        vecLayer:SetImmuneToCamera(true) 
        if (not SS_SMPTE.isDialogVisible) then
            SS_SMPTE.showDialog = true
        end
    end

    -- If there is any text in the Comment (@ frame zero) for this layer - them POP Up the dialog
    if (moho.layer.fTimelineMarkers:HasKey(SS_SMPTE.popFrame)) then
        SS_SMPTE.showDialog = true
        moho.layer.fTimelineMarkers:DeleteKey(SS_SMPTE.popFrame)
        moho:UpdateSelectedChannels()
    end    

    if (SS_SMPTE.showDialog and (not SS_SMPTE.isDialogVisible)) then
        if ((SS_SMPTE.isSet == nil) and ScriptInfo:HasKey("SS_SMPTE.isSet")) then
            SS_SMPTE.isSet = ScriptInfo:GetBool("SS_SMPTE.isSet")
            SS_SMPTE.prefix = ScriptInfo:GetString("SS_SMPTE.prefix")
            SS_SMPTE.postfix = ScriptInfo:GetString("SS_SMPTE.postfix")
            SS_SMPTE.linewid = ScriptInfo:GetFloat("SS_SMPTE.linewid")
            SS_SMPTE.nameoverlay = ScriptInfo:GetBool("SS_SMPTE.nameoverlay")
            SS_SMPTE.firstframe0 = ScriptInfo:GetBool("SS_SMPTE.firstframe0")
            SS_SMPTE.chkfillcol = ScriptInfo:GetBool("SS_SMPTE.chkfillcol")
            SS_SMPTE.chklinecol = ScriptInfo:GetBool("SS_SMPTE.chklinecol")
            SS_SMPTE.fontname = ScriptInfo:GetString("SS_SMPTE.fontname")
            SS_SMPTE.linecol = ScriptInfo:GetColor("SS_SMPTE.linecol")
            SS_SMPTE.fillcol = ScriptInfo:GetColor("SS_SMPTE.fillcol")
        end
        
        SS_SMPTE.isDialogVisible = true
        SS_SMPTE.showDialog = false
        local dlog = SS_SMPTE_Dialog:new(moho)
        SS_SMPTE.isDialogVisible = false                
        if (dlog:DoModal() == LM.GUI.MSG_OK) then
            ScriptInfo:Set("SS_SMPTE.isSet", true)
            ScriptInfo:Set("SS_SMPTE.prefix", SS_SMPTE.prefix)
            ScriptInfo:Set("SS_SMPTE.postfix", SS_SMPTE.postfix)
            ScriptInfo:Set("SS_SMPTE.linewid", SS_SMPTE.linewid)
            ScriptInfo:Set("SS_SMPTE.nameoverlay", SS_SMPTE.nameoverlay)
            ScriptInfo:Set("SS_SMPTE.firstframe0", SS_SMPTE.firstframe0)
            ScriptInfo:Set("SS_SMPTE.chkfillcol", SS_SMPTE.chkfillcol)
            ScriptInfo:Set("SS_SMPTE.chklinecol", SS_SMPTE.chklinecol)
            ScriptInfo:Set("SS_SMPTE.fontname", SS_SMPTE.fontname)
            ScriptInfo:Set("SS_SMPTE.linecol", SS_SMPTE.linecol)
            ScriptInfo:Set("SS_SMPTE.fillcol", SS_SMPTE.fillcol)
            didoSettings = true
            --moho:Mesh():Clear()
            MOHO.Redraw()
            --moho.document:Refresh() -- ??
        else
            -- Dialog was Cancelled
            if (firstRun) then  --< Only destroy if FirstRun (Setup)
                if (moho:Mesh()) then
                    moho:Mesh():Clear()
                end
                moho.layer:SetLayerScript("") -- ??? since the user cancelled  -- dont use script?? (what about other dialog - apply vs OK)
                return -- the user cannot really cancel at this point, since the script has no way to remove itself from a layer???
            end
        end
    end

    if (not SS_SMPTE.gFps) then
        SS_SMPTE.gFps = moho.document:Fps()    --< Frames Per Second
    end

    if (gSS_SMPTE.gFrm[mohoNameUnique] == nil) then
        gSS_SMPTE.gFrm[mohoNameUnique] = moho.frame
        gSet = true        
    end

    if (not SS_SMPTE.gFrm) then
        SS_SMPTE.gFrm = moho.frame    --< Current Frame
    end

    local iFrm = moho.frame
    local iFps = tonumber(moho.document:Fps())
    if (not iFps) then
        print("SS SMPTE Error: 'Invalid Frame Rate' - Please update the Project Settings..." )
        return
    end
    iFps = LM.Round((iFps *100)) / 100  -- 2 deci points

    -- Set number of digits for #Frames display
    if (((SS_SMPTE.iFps ~= iFps) or gSet) or (not SS_SMPTE.dFps)) then  --< If FPS has changed / unknown by script
        SS_SMPTE.dFps = #tostring(math.floor(iFps)) -- no. of digits (after remove decimals)
        SS_SMPTE.dFps = (((SS_SMPTE.dFps > 2) and SS_SMPTE.dFps) or 2) --< min. 2 digits
        SS_SMPTE.iFps = iFps
    end

    if ((((iFrm ~= gSS_SMPTE.gFrm[mohoNameUnique]) or gSet) and (iFrm ~= 0)) or didoSettings) then --> Frame has changed, so update display  
        didoSettings = false

        if ((SS_SMPTE.isSet == nil) and ScriptInfo:HasKey("SS_SMPTE.isSet")) then
            SS_SMPTE.isSet = ScriptInfo:GetBool("SS_SMPTE.isSet")
            SS_SMPTE.prefix = ScriptInfo:GetString("SS_SMPTE.prefix")
            SS_SMPTE.postfix = ScriptInfo:GetString("SS_SMPTE.postfix")
            SS_SMPTE.linewid = ScriptInfo:GetFloat("SS_SMPTE.linewid")
            SS_SMPTE.nameoverlay = ScriptInfo:GetBool("SS_SMPTE.nameoverlay")
            SS_SMPTE.firstframe0 = ScriptInfo:GetBool("SS_SMPTE.firstframe0")
            SS_SMPTE.chkfillcol = ScriptInfo:GetBool("SS_SMPTE.chkfillcol")
            SS_SMPTE.chklinecol = ScriptInfo:GetBool("SS_SMPTE.chklinecol")
            SS_SMPTE.fontname = ScriptInfo:GetString("SS_SMPTE.fontname")
            SS_SMPTE.linecol = ScriptInfo:GetColor("SS_SMPTE.linecol")
            SS_SMPTE.fillcol = ScriptInfo:GetColor("SS_SMPTE.fillcol")
        end

        if (SS_SMPTE.isSet) then
            --gSS_SMPTE.gFrm[mohoNameUnique .. "__SS_SMPTE_Refreshed"] = false
            local ffOffset = SS_SMPTE.firstframe0 and 1 or 0 --SS_SMPTE.firstframe0 == true and 1 or SS_SMPTE.firstframe0 == false and 0 -- SS_SMPTE.firstframe0 and 1 or 0
            local iFrm0 = math.max(0, iFrm - ffOffset)
            local iRatio = iFrm0 / iFps
            local iHrs = math.floor(iRatio / 60 / 60)
            local iMin = math.floor((iRatio / 60) % 60)
            local iSec = math.floor(iRatio % 60)
            local iFF  = math.floor(iFrm0 % iFps)
    		
    		-- Save existing selected layer(s)
    		local iSelectedCount = moho.document:CountSelectedLayers()
    		local selectedLayers = {}
    		for iSelected = 1, iSelectedCount do
    			selectedLayers[iSelected] = moho.document:GetSelectedLayer(iSelected -1)
    		end

            -- Select our display layer
    		moho:SetSelLayer(vecLayer)
    		local smpteText = string.format("%02d:%02d:%02d:%0".. SS_SMPTE.dFps .."d", iHrs, iMin, iSec, iFF)
    		
    		if (moho:Mesh()) then
    			moho:Mesh():Clear()
    		end
    		
    		local strFont = LM.String:new_local()
    		local strText = LM.String:new_local()
            local strBalloonStyle = LM.String:new_local()
    		local inText = MOHO.MohoGlobals.InsertText

            -- Do Prefixes (required for stabilisation / styling)
            strText:Set(SS_SMPTE.prefix .. smpteText .. SS_SMPTE.postfix)
            inText.Text = strText

            strFont:Set(SS_SMPTE.fontname) --< default "Consolas Regular"
    		inText.FontName = strFont

            inText.Fill = SS_SMPTE.chkfillcol
            inText.Stroke = SS_SMPTE.chklinecol
            inText.FillCol = SS_SMPTE.fillcol
            inText.LineCol = SS_SMPTE.linecol
            inText.Leading = 0
            inText.Kerning = 0
    		inText.TextSize = 100 -- ... You should set size / location / orientation using standard Layer properties (on frame 0)
    		inText.MakeLayer = true
            inText.Justification = 0 --> 0 == L, 1 == C, 2 == R (multiline text)

            strBalloonStyle:Set("")
            inText.BalloonStyle = strBalloonStyle
            inText.OneFill = true
    		
            docHeight = moho.document:Height()
            inText.LineWidth = SS_SMPTE.linewid/docHeight
            
    		moho:InsertText(inText, 0)

            if (SS_SMPTE.nameoverlay) then
                vecLayer:SetName("smpte: " .. smpteText)
            end

            vecLayer:ClearAnimation(false, 0, false)  --#SC If you need animation - put this layer into a Group Layer and animate that

            -- Reselect previous selected Layer(s)
    		moho:SetSelLayer(selectedLayers[1])
    		for iSelected = 2, iSelectedCount do
    			moho:SetSelLayer(selectedLayers[iSelected], true, true)
    		end

            ssUpdated = true
        end

        SS_SMPTE.gFps = iFps
        SS_SMPTE.gFrm = iFrm 
        gSS_SMPTE.gFrm[mohoNameUnique] = iFrm    

        if (ssUpdated == true) then
            moho.document:Refresh() --#SC ??Fixed Outline prob. ???
            ssUpdated = false
        end
    end
end